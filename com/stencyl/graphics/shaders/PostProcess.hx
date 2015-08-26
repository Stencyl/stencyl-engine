package com.stencyl.graphics.shaders;

import flash.geom.Rectangle;
import com.stencyl.Engine;
import motion.Actuate;

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

	public function new(shader:String, literalText:Bool = false)
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

import openfl.Assets;
import openfl.gl.*;
import openfl.utils.Float32Array;
import openfl.display.OpenGLView;

typedef Uniform = {
	#if js
	var id:lime.graphics.opengl.GLUniformLocation;
	#else
	var id:Int;
	#end
	var value:Float;
};

/**
 * Fullscreen post processing class
 * Uses glsl shaders to produce post processing effects
 */
class PostProcess extends OpenGLView
{

	/**
	 * Create a new PostProcess object
	 * @param fragmentShader  A glsl file in your assets path
	 */
	public function new(fragmentShader:String, literalText:Bool = false)
	{
		super();
		#if !openfl_legacy
		render = _render;
		#end

		uniforms = new Map<String, Uniform>();

#if ios
		defaultFramebuffer = new GLFramebuffer(GL.version, 1); // faked framebuffer
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
		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(cast vertices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);

		if(literalText)
		{
			shader = new Shader([
				{ src: vertexShader, fragment: false },
				{ src: fragmentShader, fragment: true }
			]);
		}

		else
		{
			if(fragmentShader.length > 6 && fragmentShader.substr(-6) == ".glslx")
			{
				var shaderXml:haxe.xml.Fast = new haxe.xml.Fast(Xml.parse(Assets.getText(fragmentShader)).firstElement());
				var vertexData:String = (shaderXml.hasNode.vertex) ? shaderXml.node.vertex.innerData : vertexShader;
				var fragmentData:String = shaderXml.node.fragment.innerData;

				shader = new Shader([
					{ src: vertexData, fragment: false },
					{ src: fragmentData, fragment: true }
				]);
			}
			else
			{
				shader = new Shader([
					{ src: vertexShader, fragment: false },
					{ src: Assets.getText(fragmentShader), fragment: true }
				]);
			}
		}
		
		// default shader variables
		imageUniform = shader.uniform("uImage0");
		timeUniform = shader.uniform("uTime");
		resolutionUniform = shader.uniform("uResolution");
		resolutionUsUniform = shader.uniform("uResolutionUs");

		vertexSlot = shader.attribute("aVertex");
		texCoordSlot = shader.attribute("aTexCoord");
	}

	/**
	 * Set a uniform value in the shader
	 * @param uniform  The uniform name within the shader source
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
			#if js
			var id:lime.graphics.opengl.GLUniformLocation = shader.uniform(uniform);
			uniforms.set(uniform, {id: id, value: value});
			#else
			var id:Int = shader.uniform(uniform);
			if (id != -1) uniforms.set(uniform, {id: id, value: value});
			#end
		}
	}
	
	/**
	 * Gets a uniform value in the shader
	 * @param uniform  The uniform name within the shader source
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

		#if(desktop)
		if(Engine.engine.isInFullScreen())
		{
			createTexture(Std.int(openfl.system.Capabilities.screenResolutionX), Std.int(openfl.system.Capabilities.screenResolutionY));
			createRenderbuffer(Std.int(openfl.system.Capabilities.screenResolutionX), Std.int(openfl.system.Capabilities.screenResolutionY));
		}
		
		else
		{
			createTexture(Std.int(scripts.MyAssets.stageWidth * scripts.MyAssets.gameScale), Std.int(scripts.MyAssets.stageHeight * scripts.MyAssets.gameScale));
			createRenderbuffer(Std.int(scripts.MyAssets.stageWidth * scripts.MyAssets.gameScale), Std.int(scripts.MyAssets.stageHeight * scripts.MyAssets.gameScale));
		}
		#else
		createTexture(Std.int(openfl.system.Capabilities.screenResolutionX), Std.int(openfl.system.Capabilities.screenResolutionY));
		createRenderbuffer(Std.int(openfl.system.Capabilities.screenResolutionX), Std.int(openfl.system.Capabilities.screenResolutionY));
		#end

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
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB,  width, height,  0,  GL.RGB, GL.UNSIGNED_BYTE, null);

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
		GL.viewport(0, 0, Std.int(openfl.Lib.current.stage.stageWidth), Std.int(openfl.Lib.current.stage.stageHeight));
		GL.clear(GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
	}

	/**
	 * Renders to a framebuffer or the screen every frame
	 */
	#if openfl_legacy
	override public function render(rect:Rectangle)
	#else
	public function _render(rect:Rectangle)
	#end
	{
		time += Engine.elapsedTime * timeScale;
		GL.bindFramebuffer(GL.FRAMEBUFFER, renderTo);
		
		//Makes it work on full screen.
		#if(desktop)
		if(Engine.engine.isInFullScreen())
		{
			GL.viewport(0, 0, Std.int(openfl.system.Capabilities.screenResolutionX), Std.int(openfl.system.Capabilities.screenResolutionY));
		}
		
		else
		{
			GL.viewport(0, 0, Std.int(scripts.MyAssets.stageWidth * scripts.MyAssets.gameScale), Std.int(scripts.MyAssets.stageHeight * scripts.MyAssets.gameScale));
		}
		#else
		GL.viewport(0, 0, Std.int(openfl.system.Capabilities.screenResolutionX), Std.int(openfl.system.Capabilities.screenResolutionY));
		#end


		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

		shader.bind();

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
		GL.uniform2f(resolutionUsUniform, Std.int(openfl.Lib.current.stage.stageWidth / scripts.MyAssets.gameScale), Std.int(openfl.Lib.current.stage.stageHeight / scripts.MyAssets.gameScale));

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

		// check gl error
		if (GL.getError() == GL.INVALID_FRAMEBUFFER_OPERATION)
		{
			trace("INVALID_FRAMEBUFFER_OPERATION!!");
		}
	}

	private var framebuffer:GLFramebuffer;
	private var renderbuffer:GLRenderbuffer;
	private var texture:GLTexture;

	private var shader:Shader;
	private var buffer:GLBuffer;
	public var renderTo:GLFramebuffer;
	private var defaultFramebuffer:GLFramebuffer = null;

	/* @private Time accumulator passed to the shader */
	private var time:Float = 0;
	public var timeScale:Float = 1;

	private var vertexSlot:Int;
	private var texCoordSlot:Int;
	#if js
	private var imageUniform:lime.graphics.opengl.GLUniformLocation;
	private var resolutionUniform:lime.graphics.opengl.GLUniformLocation;
	private var resolutionUsUniform:lime.graphics.opengl.GLUniformLocation;
	private var timeUniform:lime.graphics.opengl.GLUniformLocation;
	#else
	private var imageUniform:Int;
	private var resolutionUniform:Int;
	private var resolutionUsUniform:Int;
	private var timeUniform:Int;
	#end
	private var uniforms:Map<String, Uniform>;

	/* @private Simple full screen vertex shader */
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
