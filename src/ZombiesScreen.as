package
{

	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.*;

	public class ZombiesScreen extends MovieClip
	{
		var vars:Vars = new Vars();
		
		public function ZombiesScreen()
		{
			vars.setWhere("multiplayer");
			zomsvid.addEventListener(MouseEvent.CLICK, zombieVideo);
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
		private function zombieVideo(event:Event):void
		{
			var url:URLRequest = new URLRequest("http://www.youtube.com/watch?v=HljoF6fjp3k");
			navigateToURL(url);
		}
	}
}