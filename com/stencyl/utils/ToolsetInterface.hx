#if stencyltools
package com.stencyl.utils;

import haxe.io.Bytes;
import openfl.display.*;
import openfl.geom.*;
import openfl.errors.*;
import openfl.events.*;
import openfl.net.Socket;
import openfl.utils.ByteArray;

using StringTools;

typedef Listener = String->Void;

class ToolsetInterface
{
	public static var instance:ToolsetInterface;

	var socket:Socket;
	var response:String = "";

	public static var connected(default, null):Bool = false;
	public static var ready(default, null):Bool = false;

	public static var assetUpdatedListeners = new Map<String, Array<Listener>>();

	#if !(scriptable || cppia)
	var hscript:HscriptRunner;
	#end
	
	public static function resetStatics():Void
	{
		assetUpdatedListeners = new Map<String, Array<Listener>>();
	}

	public function new()
	{
		socket = new Socket();
		var host:String = Config.toolsetInterfaceHost;
		var port:Null<Int> = Config.toolsetInterfacePort;

		if(host == null)
			host = "localhost";
		if(port != -1)
		{
			trace("GCI attempting to connect to toolset @" + host + ":" + port);
			configureListeners();
			socket.connect(host, port);
		}
		else
		{
			ToolsetInterface.ready = true;
		}

		instance = this;
	}

	public static function cancelConnection():Void
	{
		trace("Couldn't establish gci connection.");
		instance.unconfigureListeners();
		ToolsetInterface.ready = true;
	}

	private function configureListeners():Void
	{
		socket.addEventListener(Event.CLOSE, closeHandler);
		socket.addEventListener(Event.CONNECT, connectHandler);
		socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
	}

	private function unconfigureListeners():Void
	{
		socket.removeEventListener(Event.CLOSE, closeHandler);
		socket.removeEventListener(Event.CONNECT, connectHandler);
		socket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		socket.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
	}

	@:access(openfl.net.Socket)
	public static function preloadedUpdate()
	{
		#if !flash
		instance.socket.this_onEnterFrame(new Event(Event.ENTER_FRAME));
		#end
	}

	private function closeHandler(event:Event):Void
	{
		trace("closeHandler: " + event);
	}

	private function connectHandler(event:Event):Void
	{
		trace("connectHandler: " + event);
		if(Config.buildConfig != null)
		{
			sendData
			(
				["Content-Type" => "Client-Registration", "Project-Name" => Config.projectName],
				haxe.Json.stringify(Config.buildConfig)
			);
		}
	}

	private function ioErrorHandler(event:IOErrorEvent):Void
	{
		trace("ioErrorHandler: " + event);
		if(!ToolsetInterface.ready)
			cancelConnection();
	}

	private function securityErrorHandler(event:SecurityErrorEvent):Void
	{
		trace("securityErrorHandler: " + event);
	}

	private var waiting:Bool = true;
	private var readingHeader:Bool;
	private var currentHeader:Map<String,String>;
	private var bytes:ByteArray;
	private var bytesExpected:UInt = 0;
	private static inline var INT_LENGTH = 4;

	private function socketDataHandler(event:ProgressEvent):Void
	{
		//trace("socketDataHandler: " + event);
		while(socket.bytesAvailable > 0)
		{
			//trace(socket.bytesAvailable + " bytes available on socket.");
			if(waiting)
			{
				//throw it away if it's just a ping with no data.
				bytesExpected = socket.readInt();
				if(bytesExpected == 0)
					continue;

				waiting = false;
				readingHeader = true;
				//trace("Header expects " + bytesExpected + " bytes.");
				//trace(socket.bytesAvailable + " bytes available.");
				bytes = new ByteArray(bytesExpected);
			}

			if(readingHeader)
			{
				if(bytes.position + socket.bytesAvailable >= bytesExpected)
				{
					socket.readBytes(bytes, bytes.position, bytesExpected - bytes.position);
					
					readingHeader = false;
					currentHeader = parseHeader(bytes);
					bytesExpected = Std.parseInt(currentHeader.get("Content-Length"));
					bytes = new ByteArray(bytesExpected);
					//trace("Content expects " + bytesExpected + " bytes.");
					//trace(socket.bytesAvailable + " bytes available.");
				}
				else
				{
					var newBytes = socket.bytesAvailable;
					socket.readBytes(bytes, bytes.position, newBytes);
					bytes.position += newBytes;
				}
			}
			if(!readingHeader)
			{
				if(bytes.position + socket.bytesAvailable >= bytesExpected)
				{
					if(bytesExpected - bytes.position > 0)
					{
						socket.readBytes(bytes, bytes.position, bytesExpected - bytes.position);
					}
					
					packetReady(currentHeader, bytes);
					bytesExpected = 0;
					currentHeader = null;
					bytes = null;
					waiting = true;
				}
				else
				{
					var newBytes = socket.bytesAvailable;
					socket.readBytes(bytes, bytes.position, newBytes);
					bytes.position += newBytes;
				}
			}
		}
	}

	private function parseHeader(bytes:ByteArray):Map<String,String>
	{
		var map = new Map<String,String>();

		bytes.position = 0;
		var headerString = bytes.readUTFBytes(bytes.length);
		for(line in headerString.split("\r\n"))
		{
			var i:Int = line.indexOf(":");
			map.set(line.substring(0, i), line.substring(i + 2));
		}

		return map;
	}

	private function packetReady(header:Map<String,String>, content:ByteArray)
	{
		content.position = 0;
		
		var contentType = header.get("Content-Type");
		switch(contentType)
		{
			case "Status":
				if(header.get("Status") == "Connected")
				{
					ToolsetInterface.connected = true;
					if(traceQueue != null)
					{
						for(msg in traceQueue)
						{
							gciTrace(msg.v, msg.pos);
						}
						traceQueue = null;
					}
					trace("GCI connected. Waiting for updated assets.");
				}
				if(header.get("Status") == "Assets Ready")
				{
					ToolsetInterface.ready = true;
				}

			case "Command":
				var action = header.get("Command-Action");

				if(action == "Reset")
				{
					Universal.reloadGame();
				}
				else if(action == "Load Scene")
				{
					var sceneID = Std.parseInt(header.get("Scene-ID"));

					if(ToolsetInterface.ready)
						Engine.engine.switchScene(sceneID);
					else
						Config.initSceneID = sceneID;
					
				}
				
			#if !(scriptable || cppia)
			case "Hscript":
				if(hscript == null) hscript = new HscriptRunner();
				
				var hsType = header.get("Hscript-Type");
				
				switch(hsType)
				{
					case "Resolve Types":
						var typesToRegister = content.readUTFBytes(content.length).split("\n");
						for(type in typesToRegister)
						{
							type = StringTools.trim(type);
							if(type == "") continue;
							
							var resolvedType = Type.resolveClass(type);
							if(resolvedType != null)
							{
								hscript.registerVar(type.split(".").pop(), resolvedType);
							}
							else
							{
								trace("Couldn't resolve class: " + type);
							}
						}
						
					case "Run Script":
						try
						{
							hscript.execute(content.readUTFBytes(content.length));
						}
						catch(ex:Dynamic)
						{
							trace(ex);
						}
				}
			#end

			case "Modified Asset":
				var assetID = header.get("Asset-ID");

				if(assetID == "config/game-config.json")
				{
					var receivedText = content.readUTFBytes(content.length);
					Config.loadFromString(receivedText, ToolsetInterface.ready);
				}
				else if(assetID.startsWith("assets/"))
				{
					Assets.updateAsset(assetID, header.get("Asset-Type"), content, function() {

						if(assetID.startsWith('assets/graphics/${Engine.IMG_BASE}'))
						{
							assetID = assetID.split("/")[3].split(".")[0];
							var parts = assetID.split("-");
							var resourceType = parts[0];
							var resourceID = Std.parseInt(parts[1]);
							var subID = -1;
							if(parts.length == 3)
								subID = Std.parseInt(parts[2]);

							var resource = Data.get().resources.get(resourceID);
							if(resource != null && resource.isAtlasActive())
							{
								resource.reloadGraphics(subID);
							}
						}

						if(assetID.startsWith('assets/data/scene-') && assetID.endsWith(".mbs"))
						{
							var sceneID = Std.parseInt(assetID.substring('assets/data/scene-'.length, assetID.length - ".mbs".length));

							if(Engine.engine.scene.ID == sceneID)
							{
								Engine.engine.switchScene(sceneID, null, null);
							}
						}

						if(assetUpdatedListeners.exists(assetID))
						{
							for(listener in assetUpdatedListeners.get(assetID))
							{
								listener(assetID);
							}
						}

					});
				}

			default:
		}
	}

	private static var traceQueue:Array<{v:Dynamic, pos:haxe.PosInfos}> = null;

	public static function gciTrace(v : Dynamic, ?pos : haxe.PosInfos)
	{
		if(ToolsetInterface.connected)
		{
			if(Std.is(v, BitmapData))
			{
				imageTrace((v : BitmapData), pos);
			}
			else if(Std.is(v, DisplayObject))
			{
				var dobj:DisplayObject = cast v;
				
				var mtx = dobj.transform.concatenatedMatrix;
				
				#if flash
				var bounds = dobj.transform.pixelBounds;
				#else
				var bounds = new Rectangle();
				@:privateAccess dobj.getBounds(null).__transform(bounds, mtx);
				#end
				
				mtx.translate(-bounds.x, -bounds.y);
				
				var img:BitmapData = new BitmapData(Std.int(bounds.width), Std.int(bounds.height));
				img.draw(dobj, mtx, null, null, null, Config.antialias);
				
				imageTrace(img, pos);
			}
			else
			{
				instance.sendData
				(
					["Content-Type" => "Log",
					"Class" => pos.className,
					"Method" => pos.methodName,
					"Line" => ""+pos.lineNumber],
					"" + v
				);
			}
		}
		else
		{
			if(traceQueue == null)
				traceQueue = [];
			traceQueue.push({v: v, pos: pos});
		}
	}
	
	public static function imageTrace(img : BitmapData, ?pos : haxe.PosInfos)
	{
		if(ToolsetInterface.connected)
		{
			instance.sendBinaryData
			(
				["Content-Type" => "ImageLog",
				"Class" => pos.className,
				"Method" => pos.methodName,
				"Line" => ""+pos.lineNumber],
				img.encode(img.rect, new PNGEncoderOptions())
			);
		}
	}

	public function sendData(header:Map<String,String>, data:String)
	{
		var dataBytes = haxe.io.Bytes.ofString(data == null ? "" : data);
		var headerBytes = generateHTTPHeader(header, dataBytes);
		var packet = createPacket(headerBytes, dataBytes);
		socket.writeBytes(packet, 0, packet.length);
		#if flash
		socket.flush();
		#end
	}
	
	public function sendBinaryData(header:Map<String,String>, dataBytes:Bytes)
	{
		var headerBytes = generateHTTPHeader(header, dataBytes);
		var packet = createPacket(headerBytes, dataBytes);
		socket.writeBytes(packet, 0, packet.length);
		#if flash
		socket.flush();
		#end
	}

	private function createPacket(header:ByteArray, data:ByteArray):ByteArray
	{
		var message:ByteArray = new ByteArray(INT_LENGTH + header.length + data.length);
		message.endian = openfl.utils.Endian.BIG_ENDIAN;
		message.writeInt(header.length);
		message.writeBytes(header, 0, header.length);
		message.writeBytes(data, 0, data.length);
		return message;
	}

	private function generateHTTPHeader(keyValues:Map<String,String>, data:ByteArray):ByteArray
	{
		var sb = new StringBuf();
		
		for(key in keyValues.keys())
		{
			sb.add(key);
			sb.add(": ");
			sb.add(keyValues.get(key));
			sb.add("\r\n");
		}
		sb.add("Content-Length: "); sb.add("" + data.length); sb.add("\r\n");
		sb.add("\r\n");
		
		return haxe.io.Bytes.ofString(sb.toString());
	}

	public static function addAssetUpdatedListener(assetID:String, listener:Listener):Void
	{
		if(!assetUpdatedListeners.exists(assetID))
			assetUpdatedListeners.set(assetID, new Array<Listener>());
		assetUpdatedListeners.get(assetID).push(listener);
	}

	public static function removeAssetUpdatedListener(assetID:String, listener:Listener):Void
	{
		if(!assetUpdatedListeners.exists(assetID))
			return;
		assetUpdatedListeners.get(assetID).remove(listener);
	}

	public static function clearAssetUpdatedListeners():Void
	{
		for(key in assetUpdatedListeners.keys())
			assetUpdatedListeners.remove(key);
	}
	
	private static var paused:Bool = false;
	public static var wasPaused = false;
	
	public static function pause():Void
	{
		paused = true;
		wasPaused = true;
		while(paused)
		{
			preloadedUpdate();
		}
	}
}
#end