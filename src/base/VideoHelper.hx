package base;

/**
 * A class for doing video playback easily.
 */
class VideoHelper {
    /**
     * Plays the video located at `path`. Executes the function that `finishCallback()` is set to afterwards.
     * Returns a VideoHandler instance.
     * @param path The path to the video. (You must specify file extension manually!)
     * @param finishCallback The function that executes after the video finishes.
     * @return VideoHandler
     */
    public static function playVideo(path:String, finishCallback:Void->Void) {
        #if VIDEOS_ALLOWED
        var video:VideoHandler = new VideoHandler();
        video.finishCallback = finishCallback;
        video.playVideo(path);
        return video;
        #else
        finishCallback();
        return Console.error('Failed to play video: $path - Videos aren\'t supported on this platform!');
        #end
    }

    /**
     * Plays the video located at `path`. Executes the function that `finishCallback()` is set to afterwards.
     * Returns a `VideoSprite` (extends `FlxSprite`) that plays the video.
     * @param path The path to the video. (You must specify file extension manually!)
     * @param finishCallback The function that executes after the video finishes.
     * @return VideoSprite
     */
     public static function playVideoSprite(path:String, finishCallback:Void->Void) {
        #if VIDEOS_ALLOWED
        var video:VideoSprite = new VideoSprite();
        video.finishCallback = finishCallback;
        video.playVideo(path);
        return video;
        #else
        finishCallback();
        return Console.error('Failed to play video: $path - Videos aren\'t supported on this platform!');
        #end
    }
}