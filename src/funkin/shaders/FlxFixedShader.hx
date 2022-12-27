package funkin.shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display3D.Program3D;

using StringTools;

@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.Program3D)
@:access(openfl.display.ShaderInput)
@:access(openfl.display.ShaderParameter)

// This class was made by YoshiCrafter29
//
// this class only still exists because of ColorShader and OutlineShader, if those didn't exist
// this class wouldn't exist either

class FlxFixedShader extends FlxShader {
    public var custom:Bool = false;
    public override function new() {
        super();
    }
    @:noCompletion private override function __initGL():Void
    {
        if (__glSourceDirty || __paramBool == null)
        {
            __glSourceDirty = false;
            program = null;

            __inputBitmapData = new Array();
            __paramBool = new Array();
            __paramFloat = new Array();
            __paramInt = new Array();

            __processGLData(glVertexSource, "attribute");
            __processGLData(glVertexSource, "uniform");
            __processGLData(glFragmentSource, "uniform");
        }

        if (__context != null && program == null)
        {
            var prefix = "#version 120\n";

            var gl = __context.gl;

			prefix += "#ifdef GL_ES
				"
				+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH
				precision highp float;
				#else
				precision mediump float;
				#endif" : "precision lowp float;")
				+ "
				#endif
				";

			var vertex = prefix + glVertexSource;
			var fragment = prefix + glFragmentSource;

			var id = vertex + fragment;

			if (__context.__programs.exists(id))
			{
				program = __context.__programs.get(id);
			}
			else
			{
				program = __context.createProgram(GLSL);

				// TODO
				// program.uploadSources (vertex, fragment);
				program.__glProgram = __createGLProgram(vertex, fragment);

				__context.__programs.set(id, program);
			}

			if (program != null)
			{
				glProgram = program.__glProgram;

				var _tempShit:Array<Array<Dynamic>> = [__inputBitmapData, __paramBool, __paramFloat, __paramInt];

				for (_shit in _tempShit)
				{
					for (shit in _shit) {
						if (shit.__isUniform)
						{
							shit.index = gl.getUniformLocation(glProgram, shit.name);
						}
						else
						{
							shit.index = gl.getAttribLocation(glProgram, shit.name);
						}
					}
				}
			}
        }
    }
}