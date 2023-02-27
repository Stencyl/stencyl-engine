package com.stencyl;

import com.stencyl.models.GameModel;
import com.stencyl.models.Scene;

class Extension
{	
	/**
	 * Extensions are constructed before the preloader is shown and assets are loaded.
	 */
	public function new()
	{
	}
	
	/**
	 * Called when the game is started, before the first scene is loaded.
	 */
	public function initialize()
	{
	
	}

	/**
	 * Called when a new scene is being loaded.
	 * This is an ideal place to prepare event
	 * queues for use.
	 */
	public function loadScene(scene:Scene)
	{
	
	}
	
	/**
	 * Called when a scene is being left.
	 * Dispose of scene-specific data.
	 */
	public function cleanupScene()
	{
	
	}
	
	/**
	 * Called before the whenUpdated event is dispatched.
	 */
	public function preSceneUpdate()
	{
		
	}
	
	/**
	 * Called when a game is being reloaded.
	 * Reset static variables to their initial state if needed.
	 */
	public function reloadGame()
	{
	
	}
}