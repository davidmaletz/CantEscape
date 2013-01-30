package  {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	/**
	 * ...
	 * @author David Maletz
	 */
	public class Preloader extends MovieClip {
		[Embed(source = "../lib/GypsyCurse.ttf",fontName = "Gypsy Curse",mimeType = "application/x-font",
		fontWeight="normal",fontStyle="normal", unicodeRange="U+0027,U+0041-U+005a",advancedAntiAliasing="true",embedAsCFF="false")] 
		public static var Gypsy_Curse:Class; private var loading:TextField;
		[Embed(source = "../lib/fancyfishgames.swf")] private static var fancyfish:Class;
		public function Preloader() {
			var s:Sprite = new Sprite(); s.graphics.beginFill(0); s.graphics.drawRect(0,0,5000,5000); s.graphics.endFill();
			var t:TextField = new TextField(); t.embedFonts = true; var tf:TextFormat = new TextFormat("Gypsy Curse",80,0xffffff);
			tf.align = TextFormatAlign.CENTER; t.defaultTextFormat = tf; t.text = "I CAN'T ESCAPE"; t.width = stage.stageWidth;
			t.height = stage.stageHeight; t.mouseEnabled = false; t.y = 80; s.addChild(t); t = new TextField(); tf = new TextFormat(null, 16, 0xffffff);
			tf.align = TextFormatAlign.CENTER; t.defaultTextFormat = tf; t.text = "David Maletz * Chase Bethea * Josh Goskey * Natalie Maletz";
			t.width = stage.stageWidth; t.height = stage.stageHeight; t.mouseEnabled = false; t.y = 190; s.addChild(t); t = new TextField(); tf = new TextFormat(null, 24, 0xffffff);
			tf.align = TextFormatAlign.CENTER; t.defaultTextFormat = tf; t.text = "Loading: 0%";
			t.width = stage.stageWidth; t.height = stage.stageHeight; t.mouseEnabled = false; t.y = 260; s.addChild(t); loading = t; addChild(s);
			addChild(createLogo(stage));
			if(stage.hasOwnProperty("stage3Ds")){
				addEventListener(Event.ENTER_FRAME, enter_frame); loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			} else {
				t.text = "Error: Requires Flash Player 11 or above.";
			}
		}
		private function progress(e:ProgressEvent):void {loading.text = "Loading: "+int(e.bytesLoaded*100/e.bytesTotal)+"%";}
		private function enter_frame(e:Event):void {
			if(currentFrame == totalFrames){
				removeEventListener(Event.ENTER_FRAME, enter_frame); loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress); stop();
				var main:Class = getDefinitionByName("Main") as Class; stage.addChild(new main() as Sprite); parent.removeChild(this);
			}
		}
		private static function ff_click(e:MouseEvent):void {navigateToURL(new URLRequest("http://www.fancyfishgames.com/"), "_blank");}
		public static function createLogo(stage:Stage):MovieClip {
			var ff:MovieClip = new fancyfish() as MovieClip; ff.x = (stage.stageWidth-ff.width)*0.5; ff.y = stage.stageHeight-ff.height-20;
			ff.buttonMode = true; ff.useHandCursor = true; ff.addEventListener(MouseEvent.CLICK, ff_click); return ff;
		}
	}

}