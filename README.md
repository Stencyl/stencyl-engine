Stencyl
==============

http://www.stencyl.com

Create Flash, iOS, Android, desktop and HTML5 games with no code with Stencyl. This is the source to Stencyl's Haxe-based engine.


Requirements
==============

* Haxe 2.10 (http://www.haxe.org)
* Stencyl 3.0 (http://www.stencyl.com)


Installing
==============

1) Check the code out anywhere you'd like.

2) Edit build-stencyl and provide the path to your Stencyl 3.0 install.

```
STENCYL_PATH=/path/to/stencyl/
```

That's it. Any time you modify the engine, run build-stencyl and then run a game from Stencyl. You 
don't even have to restart Stencyl to see your changes reflected.

```
./build.sh
```

Stencyl's engine is written in Haxe (http://www.haxe.org), a language similar to ActionScript 3. 
You can edit Haxe directly from any text editor, or you can use something more complete such as FlashDevelop, 
Sublime Text, MonoDevelop or Eclipse.



Developing Standalone
==============

For those seeking a quicker workflow, the engine can be run standalone, outside of Stencyl.

To do this, run any of the following commands from within the checked out directory to test the engine standalone.

```
haxelib run nme test TestProject.nmml flash -debug
haxelib run nme test TestProject.nmml ios -simulator
haxelib run nme test TestProject.nmml ios
haxelib run nme test TestProject.nmml android
haxelib run nme test TestProject.nmml windows
haxelib run nme test TestProject.nmml mac
```

To edit the data for the standalone game, peek inside of Assets (contains the resource definitions, graphics, sounds) and inside of Scripts.


Debugging
==============

If you're running the engine standalone, viewing the engine's logs involves external apps.

* For Flash, use Vizzy.
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
