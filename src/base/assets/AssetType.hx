package base.assets;

@:enum abstract AssetType(String) from String to String {
    var IMAGE = "IMAGE";
    var SPARROW = "SPARROW";
    var PACKER = "PACKER";
    var SOUND = "SOUND";
    var TEXT = "TEXT";
}