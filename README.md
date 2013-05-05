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

That's it. Any time you modify the engine, run build-stencyl and then run a game from Stencyl.

```
./build.sh
```


Developing alongside Stencyl
==============

Stencyl's engine is written in Haxe (http://www.haxe.org), a language similar to ActionScript 3. 
You can edit Haxe directly from any text editor, or you can use something more complete such as FlashDevelop, 
Sublime Text, MonoDevelop or Eclipse.

Developing is as simple as editing the source, running the build-stencyl script and running any game from Stencyl. You 
don't even have to restart Stencyl to see your changes reflected.


Developing Standalone
==============

More serious developers may want to run the engine outside of Stencyl for a quicker workflow.

See this Wiki page. (TODO)


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
