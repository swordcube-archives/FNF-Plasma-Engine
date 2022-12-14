package funkin.system;

import haxe.xml.Access;
import funkin.states.menus.StoryMenuState.StoryWeek;

class WeekUtil {
    public static function getWeekList() {
		var returnList:Array<StoryWeek> = [];
		while(true) {
			// Load the intial XML Data.
			var xml:Xml = Xml.parse(Assets.load(TEXT, Paths.xml('data/storyWeeks'))).firstElement();
			if(xml == null) {
				Console.error('Occured while trying to load story mode weeks. | Either the XML doesn\'t exist or the "weeks" node is missing!');
				break;
			}

			var data:Access = new Access(xml);
			for(week in data.nodes.week) {
				var weekData:StoryWeek = {
                    name: week.att.name,
					texture: week.att.texture,
					title: week.att.title,
					songs: [],
					difficulties: CoolUtil.trimArray(week.att.difficulties.split(",")),
					characters: CoolUtil.trimArray(week.att.chars.split(","))
				};
				for(song in week.nodes.song) {
					weekData.songs.push({
						name: song.att.name,
						chartType: song.att.chartType
					});
				}
				returnList.push(weekData);
			}

			break;
		}
		if(returnList.length < 1) returnList = [
			{
                name: "tutorial",
				texture: "tutorial",
				title: "ERROR LOADING WEEKS",
				songs: [
					{
						name: "tutorial",
						chartType: VANILLA
					}
				],
				difficulties: ["easy", "normal", "hard"],
				characters: ["", "bf", ""]
			}
		];

		return returnList;
	}

	public static function getWeekListMap():Map<String, StoryWeek> {
		var returnList:Map<String, StoryWeek> = [];
		while(true) {
			// Load the intial XML Data.
			var xml:Xml = Xml.parse(Assets.load(TEXT, Paths.xml('data/storyWeeks'))).firstElement();
			if(xml == null) {
				Console.error('Occured while trying to load story mode weeks. | Either the XML doesn\'t exist or the "weeks" node is missing!');
				break;
			}

			var data:Access = new Access(xml);
			for(week in data.nodes.week) {
				var weekData:StoryWeek = {
                    name: week.att.name,
					texture: week.att.texture,
					title: week.att.title,
					songs: [],
					difficulties: CoolUtil.trimArray(week.att.difficulties.split(",")),
					characters: CoolUtil.trimArray(week.att.chars.split(","))
				};
				for(song in week.nodes.song) {
					weekData.songs.push({
						name: song.att.name,
						chartType: song.att.chartType
					});
				}
				returnList[week.att.texture] = weekData;
			}

			break;
		}
		if(Lambda.count(returnList) < 1) returnList = [
			"tutorial" => {
                name: "tutorial",
				texture: "tutorial",
				title: "ERROR LOADING WEEKS",
				songs: [
					{
						name: "tutorial",
						chartType: VANILLA
					}
				],
				difficulties: ["easy", "normal", "hard"],
				characters: ["", "bf", ""]
			}
		];

		return returnList;
	}
}