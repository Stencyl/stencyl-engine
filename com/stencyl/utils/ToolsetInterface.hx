#if (stencyltools)
package com.stencyl.utils;

import openfl.errors.*;
import openfl.events.*;
import openfl.net.Socket;
import openfl.utils.ByteArray;

using StringTools;

typedef Listener = String->Void;

class ToolsetInterface
{
	static var instance:ToolsetInterface;

	var socket:Socket;
	var response:String = "";

	public static var connected(default, null):Bool = false;
	public static var ready(default, null):Bool = false;

	public static var assetUpdatedListeners = new Map<String, Array<Listener>>();

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
		#if(!flash)
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
			socket.writeUTFBytes("Client-Registration: \r\n\r\n" + haxe.Json.stringify(Config.buildConfig));
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
	private static final INT_LENGTH = 4;

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
					socket.readBytes(bytes, bytes.position, socket.bytesAvailable);
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
					socket.readBytes(bytes, bytes.position, socket.bytesAvailable);
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
							if(parts.length == 2)
								subID = Std.parseInt(parts[2]);

							var resource = Data.get().resources.get(resourceID);
							if(resource != null && resource.isAtlasActive())
							{
								resource.reloadGraphics(subID);
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
			instance.sendData
			(
				["Content-Type" => "Log",
				"Class" => pos.className,
				"Method" => pos.methodName,
				"Line" => ""+pos.lineNumber,
				"Message" => v],
				null
			);
		}
		else
		{
			if(traceQueue == null)
				traceQueue = [];
			traceQueue.push({v: v, pos: pos});
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

	private function createPacket(header:ByteArray, data:ByteArray):ByteArray
	{
		var message:ByteArray = new ByteArray(header.length + data.length);
		message.endian = openfl.utils.Endian.BIG_ENDIAN;
		message.writeBytes(header, 0, header.length);
		message.writeBytes(data, 0, data.length);
		return message;
	}

	private function generateHTTPHeader(keyValues:Map<String,String>, data:ByteArray):ByteArray
	{
		var sb = new StringBuf();
		//not really http, but tells the toolset to process it as such
		sb.add("GET/HTTP\r\n");

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
}
#end