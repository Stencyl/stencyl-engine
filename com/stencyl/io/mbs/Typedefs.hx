package com.stencyl.io.mbs;

import mbs.core.MbsTypedefSet;

class Typedefs extends MbsTypedefSet
{
	public static var instance = new Typedefs();
	
	override public function addTypes():Void
	{
		com.stencyl.io.mbs.MbsResource.initializeType();
		types.push(com.stencyl.io.mbs.MbsResource.MBS_RESOURCE);
		com.stencyl.io.mbs.MbsBackground.initializeType();
		types.push(com.stencyl.io.mbs.MbsBackground.MBS_BACKGROUND);
		com.stencyl.io.mbs.MbsCustomBlock.initializeType();
		types.push(com.stencyl.io.mbs.MbsCustomBlock.MBS_CUSTOM_BLOCK);
		com.stencyl.io.mbs.MbsBlank.initializeType();
		types.push(com.stencyl.io.mbs.MbsBlank.MBS_BLANK);
		com.stencyl.io.mbs.MbsFont.initializeType();
		types.push(com.stencyl.io.mbs.MbsFont.MBS_FONT);
		com.stencyl.io.mbs.MbsMusic.initializeType();
		types.push(com.stencyl.io.mbs.MbsMusic.MBS_MUSIC);
		com.stencyl.io.mbs.actortype.MbsActorType.initializeType();
		types.push(com.stencyl.io.mbs.actortype.MbsActorType.MBS_ACTOR_TYPE);
		com.stencyl.io.mbs.actortype.MbsSprite.initializeType();
		types.push(com.stencyl.io.mbs.actortype.MbsSprite.MBS_SPRITE);
		com.stencyl.io.mbs.actortype.MbsAnimation.initializeType();
		types.push(com.stencyl.io.mbs.actortype.MbsAnimation.MBS_ANIMATION);
		com.stencyl.io.mbs.actortype.MbsAnimShape.initializeType();
		types.push(com.stencyl.io.mbs.actortype.MbsAnimShape.MBS_ANIM_SHAPE);
		com.stencyl.io.mbs.scene.MbsTileset.initializeType();
		types.push(com.stencyl.io.mbs.scene.MbsTileset.MBS_TILESET);
		com.stencyl.io.mbs.scene.MbsTile.initializeType();
		types.push(com.stencyl.io.mbs.scene.MbsTile.MBS_TILE);
		com.stencyl.io.mbs.scene.MbsScene.initializeType();
		types.push(com.stencyl.io.mbs.scene.MbsScene.MBS_SCENE);
		com.stencyl.io.mbs.scene.MbsActorInstance.initializeType();
		types.push(com.stencyl.io.mbs.scene.MbsActorInstance.MBS_ACTOR_INSTANCE);
		com.stencyl.io.mbs.scene.layers.MbsColorBackground.initializeType();
		types.push(com.stencyl.io.mbs.scene.layers.MbsColorBackground.MBS_COLOR_BACKGROUND);
		com.stencyl.io.mbs.scene.layers.MbsGradientBackground.initializeType();
		types.push(com.stencyl.io.mbs.scene.layers.MbsGradientBackground.MBS_GRADIENT_BACKGROUND);
		com.stencyl.io.mbs.scene.layers.MbsLayer.initializeType();
		types.push(com.stencyl.io.mbs.scene.layers.MbsLayer.MBS_LAYER);
		com.stencyl.io.mbs.scene.layers.MbsInteractiveLayer.initializeType();
		types.push(com.stencyl.io.mbs.scene.layers.MbsInteractiveLayer.MBS_INTERACTIVE_LAYER);
		com.stencyl.io.mbs.scene.layers.MbsImageBackground.initializeType();
		types.push(com.stencyl.io.mbs.scene.layers.MbsImageBackground.MBS_IMAGE_BACKGROUND);
		com.stencyl.io.mbs.scene.physics.MbsJoint.initializeType();
		types.push(com.stencyl.io.mbs.scene.physics.MbsJoint.MBS_JOINT);
		com.stencyl.io.mbs.scene.physics.MbsStickJoint.initializeType();
		types.push(com.stencyl.io.mbs.scene.physics.MbsStickJoint.MBS_STICK_JOINT);
		com.stencyl.io.mbs.scene.physics.MbsHingeJoint.initializeType();
		types.push(com.stencyl.io.mbs.scene.physics.MbsHingeJoint.MBS_HINGE_JOINT);
		com.stencyl.io.mbs.scene.physics.MbsSlidingJoint.initializeType();
		types.push(com.stencyl.io.mbs.scene.physics.MbsSlidingJoint.MBS_SLIDING_JOINT);
		com.stencyl.io.mbs.scene.physics.MbsRegion.initializeType();
		types.push(com.stencyl.io.mbs.scene.physics.MbsRegion.MBS_REGION);
		com.stencyl.io.mbs.scene.physics.MbsTerrainRegion.initializeType();
		types.push(com.stencyl.io.mbs.scene.physics.MbsTerrainRegion.MBS_TERRAIN_REGION);
		com.stencyl.io.mbs.shape.MbsPoint.initializeType();
		types.push(com.stencyl.io.mbs.shape.MbsPoint.MBS_POINT);
		com.stencyl.io.mbs.shape.MbsShape.initializeType();
		types.push(com.stencyl.io.mbs.shape.MbsShape.MBS_SHAPE);
		com.stencyl.io.mbs.shape.MbsCircle.initializeType();
		types.push(com.stencyl.io.mbs.shape.MbsCircle.MBS_CIRCLE);
		com.stencyl.io.mbs.shape.MbsPolygon.initializeType();
		types.push(com.stencyl.io.mbs.shape.MbsPolygon.MBS_POLYGON);
		com.stencyl.io.mbs.shape.MbsPolyRegion.initializeType();
		types.push(com.stencyl.io.mbs.shape.MbsPolyRegion.MBS_POLY_REGION);
		com.stencyl.io.mbs.shape.MbsWireframe.initializeType();
		types.push(com.stencyl.io.mbs.shape.MbsWireframe.MBS_WIREFRAME);
		com.stencyl.io.mbs.snippet.MbsSnippetDef.initializeType();
		types.push(com.stencyl.io.mbs.snippet.MbsSnippetDef.MBS_SNIPPET_DEF);
		com.stencyl.io.mbs.snippet.MbsAttributeDef.initializeType();
		types.push(com.stencyl.io.mbs.snippet.MbsAttributeDef.MBS_ATTRIBUTE_DEF);
		com.stencyl.io.mbs.snippet.MbsBlock.initializeType();
		types.push(com.stencyl.io.mbs.snippet.MbsBlock.MBS_BLOCK);
		com.stencyl.io.mbs.snippet.MbsEvent.initializeType();
		types.push(com.stencyl.io.mbs.snippet.MbsEvent.MBS_EVENT);
		com.stencyl.io.mbs.snippet.MbsSnippet.initializeType();
		types.push(com.stencyl.io.mbs.snippet.MbsSnippet.MBS_SNIPPET);
		com.stencyl.io.mbs.snippet.MbsAttribute.initializeType();
		types.push(com.stencyl.io.mbs.snippet.MbsAttribute.MBS_ATTRIBUTE);
		com.stencyl.io.mbs.snippet.MbsMapElement.initializeType();
		types.push(com.stencyl.io.mbs.snippet.MbsMapElement.MBS_MAP_ELEMENT);
		
	}
}
