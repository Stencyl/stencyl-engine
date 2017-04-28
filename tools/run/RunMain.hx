import haxe.Serializer;
import haxe.Unserializer;
import haxe.io.Path;
import lime.project.*;
import lime.tools.helpers.*;
import sys.io.File;
import sys.FileSystem;

using StringTools;

class RunMain
{
	public static function main()
	{
		var args = Sys.args();
		var runFromHaxelib = false;
		
		if (args.length > 0)
		{
			var lastArg = "";
			
			for (i in 0...args.length)
			{
				lastArg = args.pop();
				if (lastArg.length > 0) break;
			}
			
			lastArg = new Path(lastArg).toString();
			
			if ((lastArg.endsWith("/") && lastArg != "/") || lastArg.endsWith("\\") && !lastArg.endsWith(":\\"))
			{
				lastArg = lastArg.substr(0, lastArg.length - 1);
			}
			
			if (FileSystem.exists(lastArg) && FileSystem.isDirectory(lastArg))
			{
				Sys.setCwd(lastArg);
				runFromHaxelib = true;
			}
			else
			{
				args.push(lastArg);
			}
		}

		if(args.length >= 3 && args[0] == "process")
		{
			//process inputFile outputFile (-verbose) (--targetDirectory=/path/to/gamegen/)
			var inputFile = args[1];
			var outputFile = args[2];
			var verbose = args.indexOf("-verbose") != -1;
			var targetDirectory = "";
			for(s in args)
			{
				if(s.startsWith("--targetDirectory"))
				{
					targetDirectory = s.substr(s.indexOf("=") + 1);
					break;
				}
			}
			
			var project:HXProject = Unserializer.run(File.getContent(inputFile));

			var manifest, asset;

			for (library in project.libraries)
			{
				if (library.type == "stencyl-assets")
				{
					var manifest = AssetHelper.createManifest(project, library.name);
					
					for(assetData in manifest.assets)
					{
						assetData.preload = true;
					}
					library.preload = true;
					
					asset = new Asset ("", "manifest/" + library.name + ".json", AssetType.MANIFEST);
					asset.library = library.name;
					asset.data = manifest.serialize ();
					if (manifest.assets.length == 0) asset.embed = true;
					project.assets.push (asset);
				}
			}

			File.saveContent(outputFile, Serializer.run(project));
		}
	}
}