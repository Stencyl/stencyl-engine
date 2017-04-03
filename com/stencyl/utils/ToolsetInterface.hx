package com.stencyl.utils;

import openfl.errors.*;
import openfl.events.*;
import openfl.net.Socket;
import openfl.utils.ByteArray;

class ToolsetInterface
{
	var socket:Socket;
	var response:String = "";

	public function new()
	{
		socket = new Socket();
		var host:String = Config.toolsetInterfaceHost;
		var port:Null<Int> = Config.toolsetInterfacePort;

		if(host == null)
			host = "localhost";
		if(port == null)
			port = 80;

		configureListeners();
		socket.connect(host, port);
	}

	private function configureListeners():Void
	{
		socket.addEventListener(Event.CLOSE, closeHandler);
		socket.addEventListener(Event.CONNECT, connectHandler);
		socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
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
					socket.readBytes(bytes, bytes.position, bytesExpected - bytes.position);
					
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
			case "Command":
				var action = header.get("Command-Action");

				if(action == "Reset")
				{
					ApplicationMain.reloadGame();
				}

			case "Modified Asset":
				var assetID = header.get("Asset-ID");

				if(assetID == "config/game-config.json")
				{
					var receivedText = content.readUTFBytes(content.length);
					Config.loadFromString(receivedText);
				}

			default:
		}
	}
}