/*
    Stencyl exclusively uses the Haxe programming language. 
    Haxe is similar to ActionScript and JavaScript.
    
    Want to use native code or make something reusable? Use the Extensions Framework instead.
    https://www.stencyl.com/help/view/engine-extensions/
    
    Learn more about Haxe and our APIs
    https://www.stencyl.com/help/view/haxe/
*/

package scripts;


//==========================================================
// Imports
//==========================================================

import com.stencyl.graphics.G;

import com.stencyl.behavior.Script;
import com.stencyl.behavior.Script.*;
import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.SceneScript;
import com.stencyl.behavior.TimedTask;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;
import com.stencyl.models.actor.Animation;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.Group;
import com.stencyl.models.Scene;
import com.stencyl.models.Sound;
import com.stencyl.models.Region;
import com.stencyl.models.Font;

import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.utils.motion.*;
import com.stencyl.utils.Utils;

import nme.ui.Mouse;
import nme.display.Graphics;


class [CLASSNAME] extends SceneScript
{
	//Expose your attributes like this:
	//@:attribute("id='1' name='Display Name' desc='An Attribute'")
	//public var attributeName:String;
	
	//Need further help? See: https://www.stencyl.com/help/view/code-mode/
	
	override public function init()
	{
	}
	
	public inline function update(elapsedTime:Float)
	{
	}
	
	public inline function draw(g:G)
	{
	}
	
	
	//==========================================================
	// Don't edit below unless you know what you're doing
	//==========================================================
	
	public function new(dummy:Int, dummy2:Engine)
	{
		super();	
		
		addWhenUpdatedListener(null, onUpdate);
		addWhenDrawingListener(null, onDraw);
	}
	
	public function onUpdate(elapsedTime:Float, list:Array<Dynamic>)
	{
		if(wrapper.enabled)
		{
			update(elapsedTime);
		}
	}
	
	public function onDraw(g:G, x:Float, y:Float, list:Array<Dynamic>)
	{
		if(wrapper.enabled)
		{
			draw(g);
		}
	}
}