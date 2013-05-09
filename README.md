Stencyl
==============

http://www.stencyl.com

Create Flash, iOS, Android, desktop and HTML5 games with no code with Stencyl. 
This is the source to Stencyl's Haxe-based game engine. 

At the moment, this source is only useful to those who can use Stencyl 3.0. It's not of much relevance to the public
until 3.0 goes into public beta this summer.


Requirements
==============

* [Haxe 2.10](http://www.haxe.org)
* [Stencyl 3.0](http://www.stencyl.com)

Stencyl's engine is written in [Haxe](http://www.haxe.org), a language similar to ActionScript 3. 
You can edit Haxe directly from any text editor, or you can use something more complete such as FlashDevelop, 
Sublime Text, MonoDevelop or Eclipse.


Installing
==============

1) Check the code out anywhere you'd like.

2) If on Mac/Linux, chmod build-stencyl to 777.

```
chmod 777 build-stencyl
```


Developing alongside Stencyl
==============

To "build" the code, run build-stencyl, passing in the full (absolute) path to your Stencyl install as its argument. 
For example:

```
./build-stencyl /Users/jon/stencyl/
```

That's it. Any time you modify the engine, run build-stencyl and then run a game from Stencyl. You 
don't have to restart Stencyl each time you build the engine.


Developing Standalone
==============

For those who desire a more traditional workflow, the engine can be run standalone, outside of Stencyl.

To do this, run any of the following commands from within the checked out directory to run the engine by 
itself using a minimal test project. You do not need to run the build-stencyl script unless you wish to
run a game within Stencyl.

```
haxelib run nme test TestProject.nmml flash -debug
haxelib run nme test TestProject.nmml ios -simulator
haxelib run nme test TestProject.nmml ios
haxelib run nme test TestProject.nmml android
haxelib run nme test TestProject.nmml windows
haxelib run nme test TestProject.nmml mac
haxelib run nme test TestProject.nmml html5
```

To edit the data for the standalone test game, peek inside of Assets (contains the resource definitions, graphics, sounds) 
inside of Scripts.


Extensions
==============

Extensions expose native mobile functionality to the Stencyl engine. [Read this page for details.](https://github.com/Stencyl/stencyl-engine/wiki/Extensions)


Debugging
==============

If you're running the engine standalone, viewing the engine's logs involves external apps.

* For Flash, use [Vizzy](https://code.google.com/p/flash-tracer)
* For Windows, use XXXX?
* For Mac, use OS X's Console app.
* For iOS, use OS X's Console app. Also peek at the contents of ios-log.text.
* For Android, use DDMS.
* For HTML5, use your web browser's built in tools.



Code Structure
==============

[Read this Wiki page](https://github.com/Stencyl/stencyl-engine/wiki/Code-Structure)


Contributing
==============

* [Making Contributions](https://github.com/Stencyl/stencyl-engine/wiki/Making-Contributions)
* [What areas need the most help?](https://github.com/Stencyl/stencyl-engine/wiki/Areas-that-need-help)


Credits
==============

Stencyl's game engine is proudly built on top of [NME](http://www.nme.io) and [Haxe](http://www.haxe.org). 
We're a proud sponsor of the [Haxe Foundation](http://www.haxe-foundation.org).


Contributors
==============

This is where we'll list out all our open source contributors.


MIT License
==============

```
Copyright (c) 2013 Stencyl, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
