Stencyl
==============

http://www.stencyl.com

Create Flash, iOS, Android, desktop and HTML5 games with no code with Stencyl. This is the source to Stencyl's Haxe-based engine.


Requirements
==============

* Haxe 2.10 (http://www.haxe.org)
* Stencyl 3.0 (http://www.stencyl.com)

Stencyl's engine is written in Haxe (http://www.haxe.org), a language similar to ActionScript 3. 
You can edit Haxe directly from any text editor, or you can use something more complete such as FlashDevelop, 
Sublime Text, MonoDevelop or Eclipse.


Installing
==============

No installation is required. Just check the code out anywhere you'd like.


Developing alongside Stencyl
==============

To "build" the code, run build-stencyl, passing in the full path to your Stencyl install as its argument. For example:

```
./build-stencyl /Users/jon/stencyl/
```

That's it. Any time you modify the engine, run build-stencyl and then run a game from Stencyl. You 
don't have to restart Stencyl.

All build-stencyl does is copy your checked out code to your Stencyl install. No compiling happens, 
so you won't know if something went wrong until you run your game. For that reason, we recommend developing
any larger changes standalone.


Developing Standalone
==============

For those who desire a more traditional workflow, the engine can be run standalone, outside of Stencyl.

To do this, run any of the following commands from within the checked out directory to run the engine by itself using a minimal test project. You do not need to run the build-stencyl script.

```
haxelib run nme test TestProject.nmml flash -debug
haxelib run nme test TestProject.nmml ios -simulator
haxelib run nme test TestProject.nmml ios
haxelib run nme test TestProject.nmml android
haxelib run nme test TestProject.nmml windows
haxelib run nme test TestProject.nmml mac
haxelib run nme test TestProject.nmml html5
```

To edit the data for the standalone game, peek inside of Assets (contains the resource definitions, graphics, sounds) and inside of Scripts.


Debugging
==============

If you're running the engine standalone, viewing the engine's logs involves external apps.

* For Flash, use Vizzy (https://code.google.com/p/flash-tracer)
* For Windows, use XXXX?
* For Mac, use OS X's Console app.
* For iOS, use OS X's Console app. Also peek at the contents of ios-log.text.
* For Android, use DDMS.
* For HTML5, use your web browser's built in tools.


Code Structure
==============

See this Wiki page. (TODO)


Contributing
==============

All contributions are made in the form of pull requests. An ideal, model pull request can be found here (TODO).

View this page for details on what areas of Stencyl need the most help. (TODO)


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
