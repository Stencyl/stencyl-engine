package com.stencyl.graphics.shaders;

import flash.geom.Rectangle;
import com.stencyl.Config;
import com.stencyl.Engine;
import com.stencyl.utils.Assets;
import motion.Actuate;

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

	public function new(fullScreenShader:String, literalText:Bool = false)
	{
		#if debug trace("Post processing not supported on Flash"); #end
	}
	public function enable(?to:PostProcess) { }
	public function capture() { }
	public function rebuild() { }
	public function setUniform(variable:String, value:Float) { }
	public function getUniform(variable:String):Float { return -1; }
	public function tweenUniform(name:String, targetValue:Float, duration:Float = 1, easing:Dynamic = null) { }
}

#else

import lime.graphics.opengl.*;
import lime.utils.Float32Array;
import openfl.display.OpenGLView;

typedef Uniform = {
	var id:GLUniformLocation;
	var value:Float;
};

/**
 * Fullscreen post processing class
 * Uses glsl fullScreenShaders to produce post processing effects
 */
class PostProcess extends OpenGLView
{
	static var UNIFORM_NOT_FOUND(default, never) = #if js null #else -1 #end;

	/**
	 * Create a new PostProcess object
	 * @param fragmentShader  A glsl file in your assets path
	 */
	public function new(fragmentShader:String, literalText:Bool = false)
	{
		super();
		render = _render;

		uniforms = new Map<String, Uniform>();

#if ios
		defaultFramebuffer = 1; // faked framebuffer
#end

		// create and bind the framebuffer
		framebuffer = GL.createFramebuffer();
		rebuild();

#if !ios
		var status = GL.checkFramebufferStatus(GL.FRAMEBUFFER);
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

		buffer = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		var data = new Float32Array(vertices);
		GL.bufferData(GL.ARRAY_BUFFER, data.byteLength, data, GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);

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
				var fullScreenShaderXml:haxe.xml.Fast = new haxe.xml.Fast(Xml.parse(Assets.getText(fragmentShader)).firstElement());
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

	/**
	 * Set a uniform value in the fullScreenShader
	 * @param uniform  The uniform name within the fullScreenShader source
	 * @param value    Value to set the uniform to
	 */
	public function setUniform(uniform:String, value:Float):Void
	{
		if (uniforms.exists(uniform))
		{
			var uniform = uniforms.get(uniform);
			uniform.value = value;
		}
		else
		{
			var id:GLUniformLocation = fullScreenShader.uniform(uniform);
			if(id != UNIFORM_NOT_FOUND)
			{
				uniforms.set(uniform, {id: id, value: value});
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
	
	public function tweenUniform(name:String, targetValue:Float, duration:Float = 1, easing:Dynamic = null)
	{
		if(uniforms.exists(name))
		{
			var uniform = uniforms.get(name);
			Actuate.tween(uniform, duration, {value:targetValue}).ease(easing);
		}
	}

	/**
	 * Allows multi pass rendering by passing the framebuffer to another post processing class
	 * Renders to a PostProcess framebuffer instead of the screen, if set
	 * Set to null to render to the screen
	 */
	public var to(never, set):PostProcess;
	private function set_to(value:PostProcess):PostProcess
	{
		renderTo = (value == null ? defaultFramebuffer : value.framebuffer);
		return value;
	}

	/**
	 * Enables the PostProcess object for rendering
	 * @param to  (Optional) Render to PostProcess framebuffer instead of screen
	 */
	public function enable(?to:PostProcess):Void
	{
		var index = Engine.engine.root.numChildren;

		if (index < 0) index = 0;
		Engine.engine.root.addChildAt(this, index);

		this.to = to;
	}

	/**
	 * Rebuilds the renderbuffer to match screen dimensions
	 */
	public function rebuild()
	{
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);

		if (texture != null) GL.deleteTexture(texture);
		if (renderbuffer != null) GL.deleteRenderbuffer(renderbuffer);

		createTexture(Std.int(Universal.windowWidth), Std.int(Universal.windowHeight));
		createRenderbuffer(Std.int(Universal.windowWidth), Std.int(Universal.windowHeight));
		
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
	}

	/* @private creates a renderbuffer object */
	private inline function createRenderbuffer(width:Int, height:Int)
	{
		// Bind the renderbuffer and create a depth buffer
		renderbuffer = GL.createRenderbuffer();
		GL.bindRenderbuffer(GL.RENDERBUFFER, renderbuffer);
		GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height);

		// Specify renderbuffer as depth attachement
		GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, renderbuffer);
	}

	/* @private creates a texture */
	private inline function createTexture(width:Int, height:Int)
	{
		texture = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, texture);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB,  width, height,  0,  GL.RGB, GL.UNSIGNED_BYTE, 0);

		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER , GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

		// specify texture as color attachment
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
	}

	/**
	 * Capture what is subsequently rendered to this framebuffer
	 */
	public function capture()
	{
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		
		//These seem to have no effect.
		GL.viewport(0, 0, Std.int(Universal.windowWidth), Std.int(Universal.windowHeight));
		GL.clear(GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
	}

	/**
	 * Renders to a framebuffer or the screen every frame
	 */
	public function _render(rect:Rectangle)
	{
		time += Engine.elapsedTime * timeScale;
		GL.bindFramebuffer(GL.FRAMEBUFFER, renderTo);

		GL.viewport(0, 0, Std.int(Universal.windowWidth), Std.int(Universal.windowHeight));

		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

		fullScreenShader.bind();

		GL.enableVertexAttribArray(vertexSlot);
		GL.enableVertexAttribArray(texCoordSlot);

		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, texture);
		GL.enable(GL.TEXTURE_2D);

		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		GL.vertexAttribPointer(vertexSlot, 2, GL.FLOAT, false, 16, 0);
		GL.vertexAttribPointer(texCoordSlot, 2, GL.FLOAT, false, 16, 8);

		GL.uniform1i(imageUniform, 0);
		GL.uniform1f(timeUniform, time);
		GL.uniform2f(resolutionUniform, Std.int(openfl.Lib.current.stage.stageWidth), Std.int(openfl.Lib.current.stage.stageHeight));
		GL.uniform2f(resolutionUsUniform, Std.int(openfl.Lib.current.stage.stageWidth / (Engine.SCALE * Engine.screenScaleX)), Std.int(openfl.Lib.current.stage.stageHeight / (Engine.SCALE * Engine.screenScaleY)));

		//for (u in uniforms) GL.uniform1f(u.id, u.value);
		var it = uniforms.iterator();
		var u = it.next();
		while (u != null)
		{
			GL.uniform1f(u.id, u.value);
			u = it.next();
		}

		GL.drawArrays(GL.TRIANGLES, 0, 6);

		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		GL.disable(GL.TEXTURE_2D);
		GL.bindTexture(GL.TEXTURE_2D, null);

		GL.disableVertexAttribArray(vertexSlot);
		GL.disableVertexAttribArray(texCoordSlot);

		GL.useProgram(null);
	}

	private var framebuffer:GLFramebuffer;
	private var renderbuffer:GLRenderbuffer;
	private var texture:GLTexture;

	private var fullScreenShader:Shader;
	private var buffer:GLBuffer;
	public var renderTo:GLFramebuffer;
	private var defaultFramebuffer:GLFramebuffer = null;

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
