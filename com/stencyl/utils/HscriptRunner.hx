package com.stencyl.utils;

#if (stencyltools && !(scriptable || cppia))

import com.stencyl.behavior.Script;

import hscript.*;

class HscriptRunner
{
	var parser:Parser;
	var interp:Interp;
	
	public function new()
	{
		parser = new Parser();
		interp = new Interp();
		
		interp.variables.set("trace", Reflect.makeVarArgs(function(el) {
			var inf = interp.posInfos();
			inf.className = "Script";
			inf.methodName = "run";
			var v = el.shift();
			if( el.length > 0 ) inf.customParams = el;
			haxe.Log.trace(v, inf);
		}));
		parser.allowTypes = true;
	}
	
	public function registerVar(name:String, obj:Dynamic):Void
	{
		interp.variables.set(name, obj);
	}
	
	public function execute(script:String)
	{
		var program = parser.parseString(script);
		interp.execute(program);
	}
	
	//XXX: Naive list of known types that should work in most cases
	public static function loadDefaults(interp:Interp)
	{
		for(type in [
			"com.stencyl.graphics.G",
			"com.stencyl.graphics.BitmapWrapper",
			"com.stencyl.behavior.Script",
			"com.stencyl.behavior.ActorScript",
			"com.stencyl.behavior.SceneScript",
			"com.stencyl.behavior.TimedTask",
			"com.stencyl.models.Actor",
			"com.stencyl.models.GameModel",
			"com.stencyl.models.actor.Animation",
			"com.stencyl.models.actor.ActorType",
			"com.stencyl.models.actor.Collision",
			"com.stencyl.models.actor.Group",
			"com.stencyl.models.Scene",
			"com.stencyl.models.Sound",
			"com.stencyl.models.Region",
			"com.stencyl.models.Font",
			"com.stencyl.models.Joystick",
			"com.stencyl.Engine",
			"com.stencyl.Input",
			"com.stencyl.Key",
			"com.stencyl.utils.Utils",
			"openfl.ui.Mouse",
			"openfl.display.Graphics",
			"openfl.display.BlendMode",
			"openfl.display.BitmapData",
			"openfl.display.Bitmap",
			"openfl.events.Event",
			"openfl.events.KeyboardEvent",
			"openfl.events.TouchEvent",
			"openfl.net.URLLoader",
			"box2D.common.math.B2Vec2",
			"box2D.dynamics.B2Body",
			"box2D.dynamics.B2Fixture",
			"box2D.dynamics.joints.B2Joint",
			"motion.Actuate",
			"motion.easing.Back",
			"motion.easing.Cubic",
			"motion.easing.Elastic",
			"motion.easing.Expo",
			"motion.easing.Linear",
			"motion.easing.Quad",
			"motion.easing.Quart",
			"motion.easing.Quint",
			"motion.easing.Sine",
			"com.stencyl.graphics.shaders.BasicShader",
			"com.stencyl.graphics.shaders.GrayscaleShader",
			"com.stencyl.graphics.shaders.SepiaShader",
			"com.stencyl.graphics.shaders.InvertShader",
			"com.stencyl.graphics.shaders.GrainShader",
			"com.stencyl.graphics.shaders.ExternalShader",
			"com.stencyl.graphics.shaders.InlineShader",
			"com.stencyl.graphics.shaders.BlurShader",
			"com.stencyl.graphics.shaders.SharpenShader",
			"com.stencyl.graphics.shaders.ScanlineShader",
			"com.stencyl.graphics.shaders.CSBShader",
			"com.stencyl.graphics.shaders.HueShader",
			"com.stencyl.graphics.shaders.TintShader",
			"com.stencyl.graphics.shaders.BloomShader"
		])
		{
			var resolvedType = Type.resolveClass(type);
			if(resolvedType != null)
			{
				interp.variables.set(type.split(".").pop(), resolvedType);
			}
		}
		
		interp.variables.set("sameAs", sameAs);
		interp.variables.set("sameAsAny", sameAsAny);
		interp.variables.set("asBoolean", asBoolean);
		interp.variables.set("strCompare", strCompare);
		interp.variables.set("strCompareBefore", strCompareBefore);
		interp.variables.set("strCompareAfter", strCompareAfter);
		interp.variables.set("asNumber", asNumber);
		interp.variables.set("hasValue", hasValue);
		
		interp.variables.set("resetStatics", Script.resetStatics);
		interp.variables.set("isPrimitive", Script.isPrimitive);
		interp.variables.set("getDefaultValue", Script.getDefaultValue);
		interp.variables.set("getGroupByName", Script.getGroupByName);
		interp.variables.set("getLastCreatedRegion", Script.getLastCreatedRegion);
		interp.variables.set("getAllRegions", Script.getAllRegions);
		interp.variables.set("getRegion", Script.getRegion);
		interp.variables.set("removeRegion", Script.removeRegion);
		interp.variables.set("createBoxRegion", Script.createBoxRegion);
		interp.variables.set("createCircularRegion", Script.createCircularRegion);
		interp.variables.set("isInRegion", Script.isInRegion);
		interp.variables.set("getActorsInRegion", Script.getActorsInRegion);
		interp.variables.set("sceneHasBehavior", Script.sceneHasBehavior);
		interp.variables.set("enableBehaviorForScene", Script.enableBehaviorForScene);
		interp.variables.set("disableBehaviorForScene", Script.disableBehaviorForScene);
		interp.variables.set("isBehaviorEnabledForScene", Script.isBehaviorEnabledForScene);
		interp.variables.set("getValueForScene", Script.getValueForScene);
		interp.variables.set("setValueForScene", Script.setValueForScene);
		interp.variables.set("shoutToScene", Script.shoutToScene);
		interp.variables.set("sayToScene", Script.sayToScene);
		interp.variables.set("setGameAttribute", Script.setGameAttribute);
		interp.variables.set("getGameAttribute", Script.getGameAttribute);
		interp.variables.set("runLater", Script.runLater);
		interp.variables.set("runPeriodically", Script.runPeriodically);
		interp.variables.set("getStepSize", Script.getStepSize);
		interp.variables.set("getScene", Script.getScene);
		interp.variables.set("getCurrentScene", Script.getCurrentScene);
		interp.variables.set("getIDForScene", Script.getIDForScene);
		interp.variables.set("getCurrentSceneName", Script.getCurrentSceneName);
		interp.variables.set("getSceneWidth", Script.getSceneWidth);
		interp.variables.set("getSceneHeight", Script.getSceneHeight);
		interp.variables.set("getTileWidth", Script.getTileWidth);
		interp.variables.set("getTileHeight", Script.getTileHeight);
		interp.variables.set("reloadCurrentScene", Script.reloadCurrentScene);
		interp.variables.set("switchScene", Script.switchScene);
		interp.variables.set("createPixelizeOut", Script.createPixelizeOut);
		interp.variables.set("createPixelizeIn", Script.createPixelizeIn);
		interp.variables.set("createBubblesOut", Script.createBubblesOut);
		interp.variables.set("createBubblesIn", Script.createBubblesIn);
		interp.variables.set("createBlindsOut", Script.createBlindsOut);
		interp.variables.set("createBlindsIn", Script.createBlindsIn);
		interp.variables.set("createRectangleOut", Script.createRectangleOut);
		interp.variables.set("createRectangleIn", Script.createRectangleIn);
		interp.variables.set("createSlideTransition", Script.createSlideTransition);
		interp.variables.set("createSlideUpTransition", Script.createSlideUpTransition);
		interp.variables.set("createSlideDownTransition", Script.createSlideDownTransition);
		interp.variables.set("createSlideLeftTransition", Script.createSlideLeftTransition);
		interp.variables.set("createSlideRightTransition", Script.createSlideRightTransition);
		interp.variables.set("createCrossfadeTransition", Script.createCrossfadeTransition);
		interp.variables.set("createFadeOut", Script.createFadeOut);
		interp.variables.set("createFadeIn", Script.createFadeIn);
		interp.variables.set("createCircleOut", Script.createCircleOut);
		interp.variables.set("createCircleIn", Script.createCircleIn);
		interp.variables.set("setBlendModeForLayer", Script.setBlendModeForLayer);
		interp.variables.set("showTileLayer", Script.showTileLayer);
		interp.variables.set("hideTileLayer", Script.hideTileLayer);
		interp.variables.set("fadeTileLayerTo", Script.fadeTileLayerTo);
		interp.variables.set("getTileLayerOpacity", Script.getTileLayerOpacity);
		interp.variables.set("setDrawingLayer", Script.setDrawingLayer);
		interp.variables.set("setDrawingLayerToActorLayer", Script.setDrawingLayerToActorLayer);
		interp.variables.set("setDrawingLayerToSceneLayer", Script.setDrawingLayerToSceneLayer);
		interp.variables.set("getScreenX", Script.getScreenX);
		interp.variables.set("getScreenY", Script.getScreenY);
		interp.variables.set("getScreenXCenter", Script.getScreenXCenter);
		interp.variables.set("getScreenYCenter", Script.getScreenYCenter);
		interp.variables.set("getCamera", Script.getCamera);
		interp.variables.set("isCtrlDown", Script.isCtrlDown);
		interp.variables.set("isShiftDown", Script.isShiftDown);
		interp.variables.set("simulateKeyPress", Script.simulateKeyPress);
		interp.variables.set("simulateKeyRelease", Script.simulateKeyRelease);
		interp.variables.set("isKeyDown", Script.isKeyDown);
		interp.variables.set("isKeyPressed", Script.isKeyPressed);
		interp.variables.set("isKeyReleased", Script.isKeyReleased);
		interp.variables.set("isMouseDown", Script.isMouseDown);
		interp.variables.set("isMousePressed", Script.isMousePressed);
		interp.variables.set("isMouseReleased", Script.isMouseReleased);
		interp.variables.set("getMouseX", Script.getMouseX);
		interp.variables.set("getMouseY", Script.getMouseY);
		interp.variables.set("getMouseWorldX", Script.getMouseWorldX);
		interp.variables.set("getMouseWorldY", Script.getMouseWorldY);
		interp.variables.set("getMousePressedX", Script.getMousePressedX);
		interp.variables.set("getMousePressedY", Script.getMousePressedY);
		interp.variables.set("getMouseReleasedX", Script.getMouseReleasedX);
		interp.variables.set("getMouseReleasedY", Script.getMouseReleasedY);
		interp.variables.set("showCursor", Script.showCursor);
		interp.variables.set("hideCursor", Script.hideCursor);
		interp.variables.set("charFromCharCode", Script.charFromCharCode);
		interp.variables.set("getLastCreatedActor", Script.getLastCreatedActor);
		interp.variables.set("createActor", Script.createActor);
		interp.variables.set("createRecycledActor", Script.createRecycledActor);
		interp.variables.set("createRecycledActorOnLayer", Script.createRecycledActorOnLayer);
		interp.variables.set("recycleActor", Script.recycleActor);
		interp.variables.set("createActorInNextScene", Script.createActorInNextScene);
		interp.variables.set("getActorTypeByName", Script.getActorTypeByName);
		interp.variables.set("getActorType", Script.getActorType);
		interp.variables.set("getAllActorTypes", Script.getAllActorTypes);
		interp.variables.set("getActorsOfType", Script.getActorsOfType);
		interp.variables.set("getActor", Script.getActor);
		interp.variables.set("getActorGroup", Script.getActorGroup);
		interp.variables.set("setGravity", Script.setGravity);
		interp.variables.set("getGravity", Script.getGravity);
		interp.variables.set("enableContinuousCollisions", Script.enableContinuousCollisions);
		interp.variables.set("toPhysicalUnits", Script.toPhysicalUnits);
		interp.variables.set("toPixelUnits", Script.toPixelUnits);
		interp.variables.set("makeActorNotPassThroughTerrain", Script.makeActorNotPassThroughTerrain);
		interp.variables.set("makeActorPassThroughTerrain", Script.makeActorPassThroughTerrain);
		interp.variables.set("mute", Script.mute);
		interp.variables.set("unmute", Script.unmute);
		interp.variables.set("getSound", Script.getSound);
		interp.variables.set("getSoundByName", Script.getSoundByName);
		interp.variables.set("playSound", Script.playSound);
		interp.variables.set("loopSound", Script.loopSound);
		interp.variables.set("playSoundOnChannel", Script.playSoundOnChannel);
		interp.variables.set("loopSoundOnChannel", Script.loopSoundOnChannel);
		interp.variables.set("stopSoundOnChannel", Script.stopSoundOnChannel);
		interp.variables.set("pauseSoundOnChannel", Script.pauseSoundOnChannel);
		interp.variables.set("resumeSoundOnChannel", Script.resumeSoundOnChannel);
		interp.variables.set("setVolumeForChannel", Script.setVolumeForChannel);
		interp.variables.set("stopAllSounds", Script.stopAllSounds);
		interp.variables.set("setVolumeForAllSounds", Script.setVolumeForAllSounds);
		interp.variables.set("fadeInSoundOnChannel", Script.fadeInSoundOnChannel);
		interp.variables.set("fadeOutSoundOnChannel", Script.fadeOutSoundOnChannel);
		interp.variables.set("fadeSoundOnChannel", Script.fadeSoundOnChannel);
		interp.variables.set("fadeInForAllSounds", Script.fadeInForAllSounds);
		interp.variables.set("fadeOutForAllSounds", Script.fadeOutForAllSounds);
		interp.variables.set("fadeForAllSounds", Script.fadeForAllSounds);
		interp.variables.set("getPositionForChannel", Script.getPositionForChannel);
		interp.variables.set("getSoundLengthForChannel", Script.getSoundLengthForChannel);
		interp.variables.set("getSoundLength", Script.getSoundLength);
		interp.variables.set("setColorBackground", Script.setColorBackground);
		interp.variables.set("setScrollSpeedForBackground", Script.setScrollSpeedForBackground);
		interp.variables.set("setScrollFactorForLayer", Script.setScrollFactorForLayer);
		interp.variables.set("changeBackground", Script.changeBackground);
		interp.variables.set("changeBackgroundImage", Script.changeBackgroundImage);
		interp.variables.set("addBackground", Script.addBackground);
		interp.variables.set("addBackgroundFromImage", Script.addBackgroundFromImage);
		interp.variables.set("removeBackground", Script.removeBackground);
		interp.variables.set("captureScreenshot", Script.captureScreenshot);
		interp.variables.set("getImageForActor", Script.getImageForActor);
		interp.variables.set("getExternalImage", Script.getExternalImage);
		interp.variables.set("loadImageFromURL", Script.loadImageFromURL);
		interp.variables.set("getSubImage", Script.getSubImage);
		interp.variables.set("setOrderForImage", Script.setOrderForImage);
		interp.variables.set("getOrderForImage", Script.getOrderForImage);
		interp.variables.set("bringImageBack", Script.bringImageBack);
		interp.variables.set("bringImageForward", Script.bringImageForward);
		interp.variables.set("bringImageToBack", Script.bringImageToBack);
		interp.variables.set("bringImagetoFront", Script.bringImagetoFront);
		interp.variables.set("attachImageToActor", Script.attachImageToActor);
		interp.variables.set("attachImageToHUD", Script.attachImageToHUD);
		interp.variables.set("attachImageToLayer", Script.attachImageToLayer);
		interp.variables.set("removeImage", Script.removeImage);
		interp.variables.set("resizeImage", Script.resizeImage);
		interp.variables.set("drawImageOnImage", Script.drawImageOnImage);
		interp.variables.set("drawTextOnImage", Script.drawTextOnImage);
		interp.variables.set("clearImagePartially", Script.clearImagePartially);
		interp.variables.set("clearImage", Script.clearImage);
		interp.variables.set("clearImageUsingMask", Script.clearImageUsingMask);
		interp.variables.set("retainImageUsingMask", Script.retainImageUsingMask);
		interp.variables.set("fillImage", Script.fillImage);
		interp.variables.set("filterImage", Script.filterImage);
		interp.variables.set("imageSetPixel", Script.imageSetPixel);
		interp.variables.set("imageGetPixel", Script.imageGetPixel);
		interp.variables.set("imageSwapColor", Script.imageSwapColor);
		interp.variables.set("flipImageHorizontal", Script.flipImageHorizontal);
		interp.variables.set("flipImageVertical", Script.flipImageVertical);
		interp.variables.set("setXForImage", Script.setXForImage);
		interp.variables.set("setYForImage", Script.setYForImage);
		interp.variables.set("fadeImageTo", Script.fadeImageTo);
		interp.variables.set("setOriginForImage", Script.setOriginForImage);
		interp.variables.set("growImageTo", Script.growImageTo);
		interp.variables.set("spinImageTo", Script.spinImageTo);
		interp.variables.set("moveImageTo", Script.moveImageTo);
		interp.variables.set("spinImageBy", Script.spinImageBy);
		interp.variables.set("moveImageBy", Script.moveImageBy);
		interp.variables.set("setFilterForImage", Script.setFilterForImage);
		interp.variables.set("clearFiltersForImage", Script.clearFiltersForImage);
		interp.variables.set("imageToText", Script.imageToText);
		interp.variables.set("imageFromText", Script.imageFromText);
		interp.variables.set("startShakingScreen", Script.startShakingScreen);
		interp.variables.set("stopShakingScreen", Script.stopShakingScreen);
		interp.variables.set("getTopLayer", Script.getTopLayer);
		interp.variables.set("getBottomLayer", Script.getBottomLayer);
		interp.variables.set("getMiddleLayer", Script.getMiddleLayer);
		interp.variables.set("getTileLayerAt", Script.getTileLayerAt);
		interp.variables.set("getTilesetIDByName", Script.getTilesetIDByName);
		interp.variables.set("setTileAt", Script.setTileAt);
		interp.variables.set("tileExistsAt", Script.tileExistsAt);
		interp.variables.set("tileCollisionAt", Script.tileCollisionAt);
		interp.variables.set("getTilePosition", Script.getTilePosition);
		interp.variables.set("getTileIDAt", Script.getTileIDAt);
		interp.variables.set("getTileColIDAt", Script.getTileColIDAt);
		interp.variables.set("getTileDataAt", Script.getTileDataAt);
		interp.variables.set("getTilesetIDAt", Script.getTilesetIDAt);
		interp.variables.set("getTileAt", Script.getTileAt);
		interp.variables.set("removeTileAt", Script.removeTileAt);
		interp.variables.set("getTileForCollision", Script.getTileForCollision);
		interp.variables.set("getTileDataForCollision", Script.getTileDataForCollision);
		interp.variables.set("getFont", Script.getFont);
		interp.variables.set("pause", Script.pause);
		interp.variables.set("unpause", Script.unpause);
		interp.variables.set("toggleFullScreen", Script.toggleFullScreen);
		interp.variables.set("pauseAll", Script.pauseAll);
		interp.variables.set("unpauseAll", Script.unpauseAll);
		interp.variables.set("getScreenWidth", Script.getScreenWidth);
		interp.variables.set("getScreenHeight", Script.getScreenHeight);
		interp.variables.set("getStageWidth", Script.getStageWidth);
		interp.variables.set("getStageHeight", Script.getStageHeight);
		interp.variables.set("setOffscreenTolerance", Script.setOffscreenTolerance);
		interp.variables.set("isTransitioning", Script.isTransitioning);
		interp.variables.set("setTimeScale", Script.setTimeScale);
		interp.variables.set("randomFloat", Script.randomFloat);
		interp.variables.set("randomFloatBetween", Script.randomFloatBetween);
		interp.variables.set("randomInt", Script.randomInt);
		interp.variables.set("abortTween", Script.abortTween);
		interp.variables.set("saveGame", Script.saveGame);
		interp.variables.set("loadGame", Script.loadGame);
		interp.variables.set("saveData", Script.saveData);
		interp.variables.set("loadData", Script.loadData);
		interp.variables.set("checkData", Script.checkData);
		interp.variables.set("openURLInBrowser", Script.openURLInBrowser);
		interp.variables.set("visitURL", Script.visitURL);
		interp.variables.set("postToURL", Script.postToURL);
		interp.variables.set("convertToPseudoUnicode", Script.convertToPseudoUnicode);
		interp.variables.set("simpleTweet", Script.simpleTweet);
		interp.variables.set("newgroundsShowAd", Script.newgroundsShowAd);
		interp.variables.set("newgroundsSetMedalPosition", Script.newgroundsSetMedalPosition);
		interp.variables.set("newgroundsUnlockMedal", Script.newgroundsUnlockMedal);
		interp.variables.set("newgroundsSubmitScore", Script.newgroundsSubmitScore);
		interp.variables.set("newgroundsShowScore", Script.newgroundsShowScore);
		interp.variables.set("kongregateInitAPI", Script.kongregateInitAPI);
		interp.variables.set("kongregateSubmitStat", Script.kongregateSubmitStat);
		interp.variables.set("kongregateIsGuest", Script.kongregateIsGuest);
		interp.variables.set("kongregateGetUsername", Script.kongregateGetUsername);
		interp.variables.set("kongregateGetUserID", Script.kongregateGetUserID);
		interp.variables.set("loadAtlas", Script.loadAtlas);
		interp.variables.set("unloadAtlas", Script.unloadAtlas);
		interp.variables.set("atlasIsLoaded", Script.atlasIsLoaded);
		interp.variables.set("initGooglePlayGames", Script.initGooglePlayGames);
		interp.variables.set("stopGooglePlayGames", Script.stopGooglePlayGames);
		interp.variables.set("getGPGConnectionInfo", Script.getGPGConnectionInfo);
		interp.variables.set("showGPGAchievements", Script.showGPGAchievements);
		interp.variables.set("showGPGLeaderboards", Script.showGPGLeaderboards);
		interp.variables.set("showGPGLeaderboard", Script.showGPGLeaderboard);
		interp.variables.set("showGPGQuests", Script.showGPGQuests);
		interp.variables.set("unlockGPGAchievement", Script.unlockGPGAchievement);
		interp.variables.set("incrementGPGAchievement", Script.incrementGPGAchievement);
		interp.variables.set("submitGPGScore", Script.submitGPGScore);
		interp.variables.set("updateGPGEvent", Script.updateGPGEvent);
		interp.variables.set("getCompletedGPGQuests", Script.getCompletedGPGQuests);
		interp.variables.set("gameCenterInitialize", Script.gameCenterInitialize);
		interp.variables.set("gameCenterIsAuthenticated", Script.gameCenterIsAuthenticated);
		interp.variables.set("gameCenterGetPlayerName", Script.gameCenterGetPlayerName);
		interp.variables.set("gameCenterGetPlayerID", Script.gameCenterGetPlayerID);
		interp.variables.set("gameCenterShowLeaderboard", Script.gameCenterShowLeaderboard);
		interp.variables.set("gameCenterShowAchievements", Script.gameCenterShowAchievements);
		interp.variables.set("gameCenterSubmitScore", Script.gameCenterSubmitScore);
		interp.variables.set("gameCenterSubmitAchievement", Script.gameCenterSubmitAchievement);
		interp.variables.set("gameCenterResetAchievements", Script.gameCenterResetAchievements);
		interp.variables.set("gameCenterShowBanner", Script.gameCenterShowBanner);
		interp.variables.set("purchasesAreInitialized", Script.purchasesAreInitialized);
		interp.variables.set("purchasesRestore", Script.purchasesRestore);
		interp.variables.set("purchasesBuy", Script.purchasesBuy);
		interp.variables.set("purchasesHasBought", Script.purchasesHasBought);
		interp.variables.set("purchasesGetTitle", Script.purchasesGetTitle);
		interp.variables.set("purchasesGetDescription", Script.purchasesGetDescription);
		interp.variables.set("purchasesGetPrice", Script.purchasesGetPrice);
		interp.variables.set("purchasesRequestProductInfo", Script.purchasesRequestProductInfo);
		interp.variables.set("purchasesUse", Script.purchasesUse);
		interp.variables.set("purchasesGoogleConsume", Script.purchasesGoogleConsume);
		interp.variables.set("purchasesGetQuantity", Script.purchasesGetQuantity);
		interp.variables.set("showAlert", Script.showAlert);
		interp.variables.set("vibrate", Script.vibrate);
		interp.variables.set("showKeyboard", Script.showKeyboard);
		interp.variables.set("hideKeyboard", Script.hideKeyboard);
		interp.variables.set("setKeyboardText", Script.setKeyboardText);
		interp.variables.set("setIconBadgeNumber", Script.setIconBadgeNumber);
		interp.variables.set("enableDebugDrawing", Script.enableDebugDrawing);
		interp.variables.set("disableDebugDrawing", Script.disableDebugDrawing);
		interp.variables.set("gameURL", Script.gameURL);
		interp.variables.set("exitGame", Script.exitGame);
		interp.variables.set("createGrayscaleFilter", Script.createGrayscaleFilter);
		interp.variables.set("createSepiaFilter", Script.createSepiaFilter);
		interp.variables.set("createNegativeFilter", Script.createNegativeFilter);
		interp.variables.set("createTintFilter", Script.createTintFilter);
		interp.variables.set("createHueFilter", Script.createHueFilter);
		interp.variables.set("createSaturationFilter", Script.createSaturationFilter);
		interp.variables.set("createBrightnessFilter", Script.createBrightnessFilter);
	}
	
	//inline Script.hx functions copied here to be un-inlined for hscript access.
	
	public static function sameAs(o:Dynamic, o2:Dynamic):Bool
	{
		return o == o2;
	}
	
	public static function sameAsAny(o:Dynamic, one:Dynamic, two:Dynamic):Bool
	{
		return (o == one) || (o == two);
	}
	
	public static function asBoolean(o:Dynamic):Bool
	{
		if (o == true)
		{
			return true;
		}
		else if (o == "true")
		{
			return true;
		}
		else
		{
			return false;
		}
		//return (o == true || o == "true"); // This stopped working in 3.5: http://community.stencyl.com/index.php?issue=845.0
	}
	
	public static function strCompare(one:String, two:String, whichWay:Int):Bool
	{
		if(whichWay < 0)
		{
			return strCompareBefore(one, two);
		}
		
		else
		{
			return strCompareAfter(one, two);
		}
	}
	
	public static function strCompareBefore(a:String, b:String):Bool
	{
		return(a < b);
	} 
	
	public static function strCompareAfter(a:String, b:String):Bool
	{
		return(a > b);
	} 
	
	public static function asNumber(o:Dynamic):Float
	{
		if(o == null)
		{
			return 0;
		}

		else if(Std.is(o, Float))
		{
			return cast(o, Float);
		}
		
		else if(Std.is(o, Int))
		{
			return cast(o, Int);
		}
		
		else if(Std.is(o, Bool))
		{
			return cast(o, Bool) ? 1 : 0;
		}
		
		else if(Std.is(o, String))
		{
			return Std.parseFloat(o);
		}
		
		else
		{
			return Std.parseFloat(Std.string(o));
		}
	}
	
	public static function hasValue(o:Dynamic):Bool
	{
		if(Script.isPrimitive(o))
		{
			return true;
		}
		
		else if(Std.is(o, String))
		{
			return cast(o, String) != "";
		}
		
		else
		{
			return o != null;
		}
	}
}

#end