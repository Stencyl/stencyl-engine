package com.stencyl.graphics.shaders;

#if html5
import js.html.CanvasElement;
import js.Browser;
#end

import flash.geom.Rectangle;
import com.stencyl.Config;
import com.stencyl.Engine;
import com.stencyl.utils.motion.*;
import com.stencyl.utils.Assets;

import com.stencyl.graphics.shaders.Shader in FullScreenShader;

#if flash

/**
 * Flash doesn't support post processing
 * This is an empty class to prevent compilation errors
 */
class PostProcess
{
	public var timeScale:Float = 1;
	public var parent:Dynamic;
	public var to:Dynamic;
	public static var isSupported (get, never):Bool;

	public function new(shader:BasicShader, fullScreenShader:String, literalText:Bool = false)
	{
		#if debug trace("Post processing not supported on Flash"); #end
	}
	public function enable(?to:PostProcess) { }
	public function capture() { }
	public function rebuild() { }
	public function setUniform(variable:String, value:Float) { }
	public function getUniform(variable:String):Float { return -1; }
	public function tweenUniform(name:String, targetValue:Float, duration:Float = 1, easing:Dynamic = null) { }
	
	@:noCompletion private static function get_isSupported ():Bool
	{
		return false;
	}
}

#else

import lime.graphics.opengl.*;
import lime.graphics.WebGLRenderContext;
import lime.utils.Float32Array;
import openfl._internal.Lib;
import openfl.display.DisplayObject;
import openfl.display.OpenGLRenderer;
import openfl.display3D.textures.RectangleTexture;
import openfl.geom.Rectangle;

#if (haxe_ver >= 4)
import haxe.xml.Access;
#else
import haxe.xml.Fast in Access;
#end

typedef Uniform = {
	var id:GLUniformLocation;
	var value:Dynamic;
};

@:access(lime.graphics.opengl.gl)

/**
 * Fullscreen post processing class
 * Uses glsl fullScreenShaders to produce post processing effects
 */
class PostProcess extends DisplayObject
{
	static var UNIFORM_NOT_FOUND(default, never) = #if html5 null #else -1 #end;
	public static inline var CONTEXT_LOST = "glcontextlost";
	public static inline var CONTEXT_RESTORED = "glcontextrestored";
	
	public static var isSupported (get, never):Bool;
	
	@:noCompletion private var __added:Bool;
	@:noCompletion private var __initialized:Bool;
	@:noCompletion private var gl:WebGLRenderContext;
	
	/**
	 * Create a new PostProcess object
	 * @param fragmentShader  A glsl file in your assets path
	 */
	public function new(shader:BasicShader, fragmentShader:String, literalText:Bool = false)
	{
		super();
		
		basicShader = shader;
		
		@:privateAccess var renderer:OpenGLRenderer = cast Engine.stage.__renderer;
		gl = renderer.gl;
		
		uniforms = new Map<String, Uniform>();
		changedUniforms = [];
		uniformTweens = new Map<String, TweenFloat>();

		// create and the texture
		rebuild();

#if !ios
		var status = gl.checkFramebufferStatus(GL.FRAMEBUFFER);
		switch (status)
		{
			case GL.FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
				trace("FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
			case GL.FRAMEBUFFER_UNSUPPORTED:
				trace("GL_FRAMEBUFFER_UNSUPPORTED");
			case GL.FRAMEBUFFER_COMPLETE:
			default:
				trace("Check frame buffer: " + status);
		}
#end

		buffer = gl.createBuffer();
		gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
		var data = new Float32Array(vertices);
		gl.bufferData(GL.ARRAY_BUFFER, data, GL.STATIC_DRAW);
		gl.bindBuffer(GL.ARRAY_BUFFER, null);

		if(literalText)
		{
			fullScreenShader = new FullScreenShader([
				{ src: vertexShader, fragment: false },
				{ src: fragmentShader, fragment: true }
			]);
		}

		else
		{
			if(fragmentShader.length > 6 && fragmentShader.substr(-6) == ".glslx")
			{
				var fullScreenShaderXml:Access = new Access(Xml.parse(Assets.getText(fragmentShader)).firstElement());
				var vertexData:String = (fullScreenShaderXml.hasNode.vertex) ? fullScreenShaderXml.node.vertex.innerData : vertexShader;
				var fragmentData:String = fullScreenShaderXml.node.fragment.innerData;

				fullScreenShader = new FullScreenShader([
					{ src: vertexData, fragment: false },
					{ src: fragmentData, fragment: true }
				]);
			}
			else
			{
				fullScreenShader = new FullScreenShader([
					{ src: vertexShader, fragment: false },
					{ src: Assets.getText(fragmentShader), fragment: true }
				]);
			}
		}
		
		// default fullScreenShader variables
		imageUniform = fullScreenShader.uniform("uImage0");
		timeUniform = fullScreenShader.uniform("uTime");
		resolutionUniform = fullScreenShader.uniform("uResolution");
		resolutionUsUniform = fullScreenShader.uniform("uResolutionUs");
		
		vertexSlot = fullScreenShader.attribute("aVertex");
		texCoordSlot = fullScreenShader.attribute("aTexCoord");
	}
	
	@:noCompletion private static function get_isSupported ():Bool
	{
		#if html5
		
		#if (canvas && !dom)
		return false;
		#else
		
		if (untyped (!window.WebGLRenderingContext)) {
			
			return false;
			
		}
		
		if (GL.context != null) {
			
			return true;
			
		} else {
			
			var canvas:CanvasElement = cast Browser.document.createElement ("canvas");
			var context = cast canvas.getContext ("webgl");
			
			if (context == null) {
				
				context = cast canvas.getContext ("experimental-webgl");
				
			}
			
			return (context != null);
			
		}
		#end
		
		#else
		
		return true;
		
		#end
		
	}
	
	@:noCompletion private override function __enterFrame (deltaTime:Int):Void
	{
		__setRenderDirty ();
	}
	
	@:access(openfl.display.DisplayObjectRenderer)
	@:access(openfl.display3D.Context3D)
	@:access(openfl._internal.renderer.context3D.Context3DState)
	@:noCompletion private override function __renderGL (renderer:OpenGLRenderer):Void
	{
		if (stage != null && __renderable)
		{
			var stage = Engine.stage;
			var context3D = stage.context3D;
			
			//renderer.setShader (null);
			renderer.__setBlendMode (null);
			
			if(basicShader.multipassTarget == null)
				context3D.setRenderToBackBuffer();
			else
				context3D.setRenderToTexture(basicShader.multipassTarget.model.texture);
			context3D.clear();
			
			time += Engine.elapsedTime * timeScale;
			
			fullScreenShader.bind();

			gl.enableVertexAttribArray(vertexSlot);
			gl.enableVertexAttribArray(texCoordSlot);

			gl.activeTexture(GL.TEXTURE0);
			@:privateAccess gl.bindTexture(GL.TEXTURE_2D, texture.__getTexture());
			if(stage.window.context.type == OPENGL)
				gl.enable(GL.TEXTURE_2D);

			gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
			gl.vertexAttribPointer(vertexSlot, 2, GL.FLOAT, false, 16, 0);
			gl.vertexAttribPointer(texCoordSlot, 2, GL.FLOAT, false, 16, 8);

			gl.uniform1i(imageUniform, 0);
			gl.uniform1f(timeUniform, time);
			gl.uniform2f(resolutionUniform, Std.int(stage.stageWidth), Std.int(stage.stageHeight));
			gl.uniform2f(resolutionUsUniform, Std.int(stage.stageWidth / (Engine.SCALE * Engine.screenScaleX)), Std.int(stage.stageHeight / (Engine.SCALE * Engine.screenScaleY)));

			var i = changedUniforms.length;
			while(i-- > 0)
			{
				var u = changedUniforms.pop();
				if (Std.is(u.value, Array))
				{
					if (u.value.length == 0)
					{
						continue;
					}
					#if (html5)
					gl.uniform1fv(u.id, new Float32Array(null, u.value));
					#else
					gl.uniform1fv(u.id, new Float32Array(null, null, u.value));
					#end
				}
				else
				{
					gl.uniform1f(u.id, u.value);
				}
			}
			
			gl.drawArrays(GL.TRIANGLES, 0, 6);

			gl.bindBuffer(GL.ARRAY_BUFFER, null);
			if (stage.window.context.type == OPENGL)
				gl.disable(GL.TEXTURE_2D);
			gl.bindTexture(GL.TEXTURE_2D, null);

			gl.disableVertexAttribArray(vertexSlot);
			gl.disableVertexAttribArray(texCoordSlot);

			//keep OpenFL's cache valid, restore needed state
			
			context3D.__contextState.program = null;
			context3D.__flushGLProgram();
			
			context3D.__contextState.__currentGLElementArrayBuffer = null;
			
			//currently unimplemented in openfl
			//context3D.__contextState.__currentGLTexture2D = null;
		}
	}
	
	@:noCompletion private override function __renderGLMask (renderer:OpenGLRenderer):Void
	{
	}

	/**
	 * Set a uniform value in the fullScreenShader
	 * @param uniform  The uniform name within the fullScreenShader source
	 * @param value    Value to set the uniform to
	 */
	public function setUniform(uniform:String, value:Dynamic):Void
	{
		if (uniforms.exists(uniform))
		{
			var uniform = uniforms.get(uniform);
			uniform.value = value;
			changedUniforms.push(uniform);
		}
		else
		{
			var id:GLUniformLocation = fullScreenShader.uniform(uniform);
			if(id != UNIFORM_NOT_FOUND)
			{
				var newUniform = {id: id, value: value};
				uniforms.set(uniform, newUniform);
				changedUniforms.push(newUniform);
			}
		}
	}
	
	/**
	 * Gets a uniform value in the fullScreenShader
	 * @param uniform  The uniform name within the fullScreenShader source
	 */
	public function getUniform(uniform:String):Float
	{
		if (uniforms.exists(uniform))
		{
			var uniform = uniforms.get(uniform);
			return uniform.value;
		}
		
		return -1;
	}
	
	public function tweenUniform(name:String, targetValue:Float, duration:Float = 1, easing:EasingFunction = null)
	{
		if(uniforms.exists(name))
		{
			var uniform = uniforms.get(name);
			var uniformTween = uniformTweens.get(name);
			if(uniformTween == null)
			{
				uniformTween = new TweenFloat();
				uniformTween.doOnUpdate(function() {
					uniform.value = uniformTween.value;
					changedUniforms.push(uniform);
				});
				uniformTweens.set(name, uniformTween);
			}
			uniformTween.tween(uniform.value, targetValue, easing, Std.int(duration*1000));
		}
	}

	/**
	 * Rebuilds the texture to match screen dimensions
	 */
	public function rebuild()
	{
		if (texture != null) texture.dispose();
		
		createTexture(Std.int(Universal.windowWidth), Std.int(Universal.windowHeight));
	}

	/* @private creates a texture */
	@:access(openfl.display3D.textures.RectangleTexture)
	@:access(openfl.display3D.Context3D)
	private inline function createTexture(width:Int, height:Int)
	{
		texture = com.stencyl.Engine.stage.context3D.createRectangleTexture(width, height, BGRA, true);
		//texture.uploadFromTypedArray(null);
		
		texture.__context.__bindGLTexture2D (texture.__textureID);
		texture.__setSamplerState(new openfl._internal.renderer.SamplerState());
		gl.texImage2D (texture.__textureTarget, 0, texture.__internalFormat, texture.__width, texture.__height, 0, gl.RGB, gl.UNSIGNED_BYTE, null);
		texture.__context.__bindGLTexture2D (null);
	}

	/**
	 * Capture what is subsequently rendered to the screen in a texture
	 */
	public function capture()
	{
		com.stencyl.Engine.stage.context3D.setRenderToTexture(texture);
		@:privateAccess var framebuffer = texture.__getGLFramebuffer(false, 0, 0);
		gl.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		gl.clear(GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
	}
	
	private var texture:RectangleTexture;

	private var fullScreenShader:Shader;
	private var buffer:GLBuffer;
	
	public var basicShader:BasicShader;
	
	/* @private Time accumulator passed to the fullScreenShader */
	private var time:Float = 0;
	public var timeScale:Float = 1;

	private var vertexSlot:Int;
	private var texCoordSlot:Int;
	private var imageUniform:GLUniformLocation;
	private var resolutionUniform:GLUniformLocation;
	private var resolutionUsUniform:GLUniformLocation;
	private var timeUniform:GLUniformLocation;
	private var uniforms:Map<String, Uniform>;
	private var changedUniforms:Array<Uniform>;
	private var uniformTweens:Map<String, TweenFloat>;

	/* @private Simple full screen vertex fullScreenShader */
	private static inline var vertexShader:String = "
#ifdef GL_ES
	precision mediump float;
#endif

attribute vec4 aVertex;

attribute vec2 aTexCoord;
varying vec2 vTexCoord;

void main() {
	vTexCoord = aTexCoord;
	gl_Position = vec4(aVertex.x, aVertex.y, 0.0, 1.0);
}";

	private static var vertices(get, never):Array<Float>;
	private static inline function get_vertices():Array<Float>
	{
		return [
			-1.0, -1.0, 0, 0,
			 1.0, -1.0, 1, 0,
			-1.0,  1.0, 0, 1,
			 1.0, -1.0, 1, 0,
			 1.0,  1.0, 1, 1,
			-1.0,  1.0, 0, 1
		];
	}

}

#end
