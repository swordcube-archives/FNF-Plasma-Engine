package systems;

import substates.ModSelectionMenu.PackJSON;
import flixel.addons.ui.StrNameLabel;
import haxe.Exception;
import haxe.Json;
import haxe.crypto.Crc32;
import haxe.zip.Writer;
import haxe.zip.Tools;
import haxe.zip.Entry;
import haxe.zip.Uncompress;
import haxe.zip.Reader;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;

using StringTools;

// HOW TO USE THIS SHIT:
//
// -- making the zip --
// sys.thread.Thread.create(function() {
//     var e = ZipUtils.createZipFile("test.plasmod");
//     ZipUtils.writeFolderToZip(e, '${AssetPaths.cwd}assets/funkin', "testing is cool/");
//     e.flush();
//     e.close();
// }
//
// -- extracting the zip --
// Application.current.window.onDropFile.add(function(file) {
//     if(file.endsWith(".plasmod")) {
//         var outputPath:String = '${AssetPaths.cwd}assets';

//         sys.thread.Thread.create(function() {
//             ZipUtils.uncompressZip(ZipUtils.openZip(file), outputPath);
//         });
//     }
// });

typedef ZipMod = {
    var name:String;
    var config:PackJSON;
    var icon:BitmapData;
};

class ZipUtils {
    public static var bannedNames:Array<String> = [".git", ".gitignore", ".github", ".vscode", ".gitattributes"];

	/**
	 * [Description] Uncompresses `zip` into the `destFolder` folder
	 * @param zip 
	 * @param destFolder 
	 */
	public static function uncompressZip(zip:Reader, destFolder:String, ?prefix:String) {
		// we never know
		FileSystem.createDirectory(destFolder);

        var fields = zip.read();

        try {
            if (prefix != null) {
                var f = fields;
                fields = new List<Entry>();
                for(field in f) {
                    if (field.fileName.startsWith(prefix)) {
                        fields.push(field);
                    }
                }
            }

            for(k=>field in fields) {
                var isFolder = field.fileName.endsWith("/") && field.fileSize == 0;
                if (isFolder) {
                    FileSystem.createDirectory('${destFolder}/${field.fileName}');
                } else {
                    var split = [for(e in field.fileName.split("/")) e.trim()];
                    split.pop();
                    FileSystem.createDirectory('${destFolder}/${split.join("/")}');
                    
                    var data = unzip(field);
                    File.saveBytes('${destFolder}/${field.fileName}', data);
                }
            }
        } catch(e) {
            trace(e);
        }
	}

    /**
     * [Description] Returns a `zip.Reader` instance from path.
     * @param zipPath 
     * @return Reader
     */
    public static function openZip(zipPath:String):Reader {
        return new ZipReader(File.read(zipPath));
    }

    /**
     * [Description] Gets all mods from zip file
     * (Also works for .plasmod files because they're literally just zip files but with a different file extension)
     * @param zip Zip file
     * @return Array<ZipMod>
     */
    public static function getModsFromZip(zip:Reader):Array<ZipMod> {
        var mods:Array<ZipMod> = [];

        var fields = zip.read();
        var n = "";
        for(f in fields) {
            var splitName = [for(e in f.fileName.split("/")) if ((n = e.trim()) != "") n];
            if (splitName.length == 2 && splitName[1].toLowerCase() == "pack.json" && f.fileSize > 0) {
                // config.json detected
                var mod:ZipMod = {
                    name: splitName[0],
                    config: null,
                    icon: null
                };
                var configData = unzip(f);
                var configJson = configData.getString(0, configData.length).trim();
                try {
                    mod.config = Json.parse(configJson);
                } catch(e) {
                    trace('Couldn\'t parse JSON at ${f.fileName}.');
                    trace(e.details());
                    continue;
                }
                var iconField:Entry = null;
                for(e in fields) {
                    if (e.fileName.toLowerCase() == '${splitName[0].toLowerCase()}/pack.png') {
                        iconField = e;
                        break;
                    }
                }

                if (iconField != null)
                    mod.icon = BitmapData.fromBytes(unzip(iconField));
                
                mods.push(mod);
            }
        }

        return mods;
    }

    /**
     * [Description] Copy of haxe's Zip unzip function cause lime replaced it.
     * @param f Zip entry
     */
    public static function unzip(f:Entry) {
		if (!f.compressed)
			return f.data;
		var c = new haxe.zip.Uncompress(-15);
		var s = haxe.io.Bytes.alloc(f.fileSize);
		var r = c.execute(f.data, 0, s, 0);
		c.close();
		if (!r.done || r.read != f.data.length || r.write != f.fileSize)
			throw "Invalid compressed data for " + f.fileName;
		f.compressed = false;
		f.dataSize = f.fileSize;
		f.data = s;
		return f.data;
	}

    /**
     * [Description] Creates a ZIP file at the specified location and returns the Writer.
     * @param path 
     * @return Writer
     */
    public static function createZipFile(path:String):ZipWriter {
        var output = File.write(path);
        return new ZipWriter(output);
    }

    /**
        [Description] Writes the entirety of a folder to a zip file.
        @param zip ZIP file to write to
        @param path Folder path
        @param prefix (Additional) allows you to set a prefix in the zip itself.
    **/
    public static function writeFolderToZip(zip:ZipWriter, path:String, ?prefix:String) {
        if (prefix == null) prefix = "";

        try {
            var curPath:Array<String> = ['$path'];
            var destPath:Array<String> = [];
            if (prefix != null) {
                prefix = prefix.replace("\\", "/");
                while(prefix.charAt(0) == "/") prefix = prefix.substr(1);
                while(prefix.charAt(prefix.length-1) == "/") prefix = prefix.substr(0, prefix.length-1);
                destPath.push(prefix);
            }
    
            var files:Array<StrNameLabel> = [];
    
            var doFolder:Void->Void = null;
            (doFolder = function() {
                var path = curPath.join("/");
                var zipPath = destPath.join("/");
                for(e in FileSystem.readDirectory(path)) {
                    if (bannedNames.contains(e.toLowerCase())) continue;
                    if (FileSystem.isDirectory('$path/$e')) {
                        // is directory, so loop into that function again
                        for(p in [curPath, destPath]) p.push(e);
                        doFolder();
                        for(p in [curPath, destPath]) p.pop();
                    } else {
                        // is file, put it in the list
                        files.push(new StrNameLabel('$path/$e', '$zipPath/$e'));
                    }
                }
            })();
    
            for(k=>file in files) {
                var fileContent = File.getBytes(file.name);
                var fileInfo = FileSystem.stat(file.name);
                var entry:Entry = {
                    fileName: file.label,
                    fileSize: fileInfo.size,
                    fileTime: Date.now(),
                    dataSize: 0,
                    data: fileContent,
                    crc32: Crc32.make(fileContent),
                    compressed: false
                };
                Tools.compress(entry, 1);
                zip.writeFile(entry);
            }
            zip.writeCDR();
        } catch(e) {
            trace(e);
        }
    }

    public static function writeFolderToZipAsync(zip:ZipWriter, path:String, ?prefix:String) {
        Thread.create(function() {
            writeFolderToZip(zip, path, prefix);
        });
    }

    /**
     * [Description] Converts an `Array<Entry>` to a `List<Entry>`.
     * @param array 
     * @return List<Entry>
     */
    public static function arrayToList(array:Array<Entry>):List<Entry> {
        var list = new List<Entry>();
        for(e in array) list.push(e);
        return list;
    }
}

class ZipReader extends Reader {
    public var files:List<Entry>;

    public override function read() {
        if (files != null) return files;
        try {
            var files = super.read();
            return this.files = files;
        } catch(e) {
        }
        return new List<Entry>();
    }
}

class ZipWriter extends Writer {
    public function flush() {
        o.flush();
    }

    public function writeFile(entry:Entry) {
        writeEntryHeader(entry);
        o.writeFullBytes(entry.data, 0, entry.data.length);
    }

    public function close() {
        o.close();
    }
}