package
{

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;

	public class CampaignScreen extends MovieClip
	{
		var vars:Vars = new Vars();

		public function CampaignScreen()
		{
			vars.setWhere("campaign");
			charactersbutton.addEventListener(MouseEvent.CLICK, charactersClick);
			missionsbutton.addEventListener(MouseEvent.CLICK, missionsClick);
			vehiclesbutton.addEventListener(MouseEvent.CLICK, vehiclesClick);
			videosbutton.addEventListener(MouseEvent.CLICK, videosClick);
			triviabutton.addEventListener(MouseEvent.CLICK, triviaClick);
		}
		function makeGrid(type:String)
		{
			var grid:GridViewScreen = new GridViewScreen();
			grid.makeGrid(type,"campaign");
			addChild(grid);
		}
		function charactersClick(e:MouseEvent)
		{
			makeGrid("characters");
			//explain.text = "Test";
		}
		function missionsClick(e:MouseEvent):void
		{
			makeGrid("missions");
		}
		function vehiclesClick(e:MouseEvent):void
		{
			makeGrid("vehicles");
		}
		function videosClick(e:MouseEvent):void
		{
			makeGrid("videos");
		}
		function triviaClick(e:MouseEvent):void
		{
			var url:URLRequest = new URLRequest("http://itunes.apple.com/us/app/inquizitive/id527398484?ls=1&mt=8");
			navigateToURL(url);
		}
		private function backClick(e:MouseEvent):void
		{
			while (numChildren > 0)
			{
				removeChildAt(0);
			}
			var splash:SplashScreen = new SplashScreen();
			addChild(splash);
		}
	}
}