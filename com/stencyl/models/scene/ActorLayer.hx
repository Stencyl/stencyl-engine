package com.stencyl.models.scene;

#if (use_actor_tilemap)
typedef ActorLayer = openfl.display.Tilemap;
#else
typedef ActorLayer = openfl.display.Sprite;
#end