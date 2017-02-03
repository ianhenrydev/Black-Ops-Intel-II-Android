package
{

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.Capabilities;

	public class MultiplayerScreen extends MovieClip
	{
		var vars:Vars = new Vars();
		
		public function MultiplayerScreen()
		{
			vars.setWhere("multiplayer");
			weaponsbutton.addEventListener(MouseEvent.CLICK, weaponsClick);
			mapsbutton.addEventListener(MouseEvent.CLICK, mapsClick);
			perksbutton.addEventListener(MouseEvent.CLICK, perksClick);
			killstreakbutton.addEventListener(MouseEvent.CLICK, killstreakClick);
			gadgetsbutton.addEventListener(MouseEvent.CLICK, gadgetsClick);
			custombutton.addEventListener(MouseEvent.CLICK, customClick);
		}
		function makeGrid(type:String)
		{
			var grid:GridViewScreen = new GridViewScreen();
			grid.makeGrid(type,"multiplayer");
			addChild(grid);
		}
		function weaponsClick(e:MouseEvent)
		{
			makeGrid("weapons");
		}
		function mapsClick(e:MouseEvent):void
		{
			makeGrid("maps");
		}
		function perksClick(e:MouseEvent):void
		{
			makeGrid("perks");
		}
		function videosClick(e:MouseEvent):void
		{
			makeGrid("videos");
		}
		function killstreakClick(e:MouseEvent):void
		{
			makeGrid("scorestreaks");
		}
		function gadgetsClick(e:MouseEvent):void
		{
			makeGrid("gadgets");
		}
		function customClick(e:MouseEvent):void
		{
			makeGrid("attachments");
		}
		function triviaClick(e:MouseEvent):void
		{
			var url:URLRequest = new URLRequest("http://itunes.apple.com/us/app/inquizitive/id527398484?ls=1&mt=8");
			navigateToURL(url);
		}
		function backClick(e:MouseEvent):void
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