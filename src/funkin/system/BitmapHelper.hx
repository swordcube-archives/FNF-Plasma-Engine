package funkin.system;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Shape;

class BitmapHelper {
    public static function newRoundRect(width,height,elwidth,elheight,color) {
        var bm:BitmapData = new BitmapData(width, height, true, 0x00000000);
        var hs:Shape = new Shape();
        var g:Graphics = hs.graphics;
        g.lineStyle(0, 0, 0);
        g.beginFill(color, ((color >> 24) & 0xff) / 255);
        g.drawRoundRect(0,0,width,height,elwidth,elheight);
        g.endFill();
        bm.draw(hs);
        return bm;
    }
    public static function newOutlinedRect(width,height,color,outlinethickness, outlinecolor) {
        var bm:BitmapData = new BitmapData(width, height, true, 0x00000000);
        var hs:Shape = new Shape();
        var g:Graphics = hs.graphics;
        g.lineStyle(outlinethickness, outlinecolor, ((outlinecolor >> 24) & 0xff) / 255);
        g.beginFill(color, ((color >> 24) & 0xff) / 255);
        g.drawRect(0,0,width,height);
        g.endFill();
        bm.draw(hs);
        return bm;
    }
    public static function newOutlinedCircle(radius,color,outlinethickness, outlinecolor) {
        var bm:BitmapData = new BitmapData(radius*2+outlinethickness, radius*2+outlinethickness, true, 0x00000000);
        var hs:Shape = new Shape();
        var g:Graphics = hs.graphics;
        g.lineStyle(outlinethickness, outlinecolor, ((outlinecolor >> 24) & 0xff) / 255);
        g.beginFill(color, ((color >> 24) & 0xff) / 255);
        g.drawCircle(radius+outlinethickness/2,radius+outlinethickness/2,radius);
        g.endFill();
        bm.draw(hs);
        return bm;
    }
}