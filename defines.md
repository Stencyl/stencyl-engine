# Haxedefs used by Stencyl

## Targets

Haxedefs that are conditionally enabled depending on the target platform.

### flash

### html5

### android

### ios

### mobile

Enabled for both android and ios

### desktop

Enabled for windows, mac, and linux

### sys

Enabled for all platforms that have access to the sys api. All desktop and mobile platforms.

### cpp

Enabled for all platforms that use hxcpp. All desktop and mobile platforms.

### scriptable

Enabled for cppia, but only during host compilation. Use `!(scriptable || cppia)` to avoid cppia altogether.

### cppia

Enabled for cppia, but only during game compilation. Use `!(scriptable || cppia)` to avoid cppia altogether.

## Features

Haxedefs that are conditionally enabled depending on optional features we want to use.

### stencyltools

The Stencyl toolset <-> engine connection using sockets. This enables many features,
such as:

- Live reloading of configuration, assets, and code
- Pausing of game execution and running Haxe code snippets
- Running one-off commands like resetting the game and loading specific scenes
- A richer logging backend that can log arbitrary data, such as images, in addition to text

The provided communication channel is also available for use by extensions to provide more
features.

### use_actor_tilemap

Uses a Tilemap to render Actors instead of individual DisplayObjects.

### use_tilemap

Uses a Tilemap for rendering where appropriate, such as tile layers and bitmap fonts,
on platforms where Tilemap is backed by the GPU (all but Flash).

### live_code_reload

Enables reloading of function bodies using the "Callable" class.

## Modes

Haxedefs that are enabled depending on the testing mode of the game.

### debug

Enabled if the game is running in debug mode. For Flash and HTML5, the game is always in debug mode,
but for mobile and desktop platforms, debug mode is an explicitly chosen game mode.

### testing

Enabled if the game is being tested (i.e. the game was built by means other than the "publish" menu).

## Integration

Haxedefs that are enabled depending on included third-party libs.

### actuate

We preserve timing compatibility with actuate for anybody who chooses to use it.

### hxtelemetry

## Misc

### canvas && !dom

### lime_opengl || lime_opengles || lime_webgl

A catch-all for any platform that includes OpenGL support.

### lime_vorbis

Platforms that includes OGG Vorbis support.