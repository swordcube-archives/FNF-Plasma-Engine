package funkin.gameplay;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import modding.HScript;
import modding.LuaScript;
import modding.Script;
import scenes.PlayState;

class StageGroup extends FlxGroup {
    public var curStage:String = "";
    public var layeredSprites:Array<FlxGroup> = [
        new FlxGroup(), // dad layer
        new FlxGroup(), // gf layer
        new FlxGroup(), // front layer
    ];

    public var dadPosition:FlxPoint = new FlxPoint(100, 100);
	public var gfPosition:FlxPoint = new FlxPoint(400, 130);
	public var bfPosition:FlxPoint = new FlxPoint(770, 100);

    public var script:Script;

    public function load(stage:String) {
        curStage = stage;
        
        // Remove old stage
        for(i in members) {
            members.remove(i);
            i.destroy();
        }
        clear();
        for(group in layeredSprites) {
            for(i in group.members) {
                group.members.remove(i);
                i.destroy();
            }
            group.clear();
        }

        // Loading the new stage
        if(script != null) {
            PlayState.current.scripts.removeScript(script);
            script.destroy();
        };

        script = Script.createScript('stages/$stage');
        script.set("curStage", curStage);
        switch(script.type) {
            case "hscript":
                var script:HScript = cast this.script;
                script.setScriptObject(PlayState.current);
                script.set("stage", this);
                script.set("add", function(obj:FlxBasic, layer:Int = 0) {
                    switch(layer) {
                        case 1: layeredSprites[0].add(obj); // dad layer
                        case 2: layeredSprites[1].add(obj); // gf layer
                        case 3: layeredSprites[2].add(obj); // front layer
                        default: this.add(obj);             // bg layer
                    }
                });
                script.set("remove", function(obj:FlxBasic) {
                    for(i in members) {
                        if(i == obj) {
                            members.remove(i);
                            i.destroy();
                        }
                    }
                    for(group in layeredSprites) {
                        for(i in group.members) {
                            if(i == obj) {
                                group.members.remove(i);
                                i.destroy();
                            }
                        }
                    }
                });
            #if LUA_ALLOWED
            // lua??? grr >:((
            case "lua":
                var script:LuaScript = cast this.script;
                script.setFunction("setDefaultCamZoom", function(value:Float) {
                    PlayState.current.defaultCamZoom = value;
                });
                script.setFunction("getProperty", function(object:String, variable:String) {
                    var result:Dynamic = null;
                    var split:Array<String> = variable.split('.');
                    if(split.length > 1)
                        result = LuaScript.getVarInArray(LuaScript.getPropertyLoopThingWhatever(split), split[split.length-1]);
                    else
                        result = LuaScript.getVarInArray(this, variable);
        
                    if(result == null) llua.Lua.pushnil(script.lua);
                    return result;
                });
                script.setFunction("setProperty", function(variable:String, value:Dynamic) {
                    var split:Array<String> = variable.split('.');
                    if(split.length > 1) {
                        LuaScript.setVarInArray(LuaScript.getPropertyLoopThingWhatever(split), split[split.length-1], value);
                        return true;
                    }
                    LuaScript.setVarInArray(this, variable, value);
                    return true;
                });
                script.setFunction("addSprite", function(objName:String, layer:Int = 0) {
                    var obj = LuaScript.getLuaObject(objName);
                    switch(layer) {
                        case 1: layeredSprites[0].add(obj); // dad layer
                        case 2: layeredSprites[1].add(obj); // gf layer
                        case 3: layeredSprites[2].add(obj); // front layer
                        default: this.add(obj);             // bg layer
                    }
                });
                script.setFunction("removeSprite", function(objName:String) {
                    var obj = LuaScript.getLuaObject(objName); 
                    for(i in members) {
                        if(i == obj) {
                            members.remove(i);
                            i.destroy();
                        }
                    }
                    for(group in layeredSprites) {
                        for(i in group.members) {
                            if(i == obj) {
                                group.members.remove(i);
                                i.destroy();
                            }
                        }
                    }
                });
                script.setFunction("setSpriteBlendMode", function(name:String, blend:String) {
                    var obj:Dynamic = LuaScript.getLuaObject(name); 
                    for(i in members) {
                        if(i == obj) {
                            obj.blend = LuaScript.blendModeFromString(blend);
                        }
                    }
                    for(group in layeredSprites) {
                        for(i in group.members) {
                            if(i == obj) {
                                obj.blend = LuaScript.blendModeFromString(blend);
                            }
                        }
                    }
				});
            #end
        }
        script.start();
        PlayState.current.scripts.addScript(script);
        
        return this;
    }
}