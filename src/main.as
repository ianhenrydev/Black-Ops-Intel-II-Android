package
{

	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import flash.utils.setTimeout;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.net.SharedObject;
	import flash.media.StageWebView;
	import flash.net.URLRequest;
	import flash.events.LocationChangeEvent;
	import flash.net.navigateToURL;
	import flash.geom.Rectangle;
	import flash.display.StageAlign;


	public class main extends MovieClip
	{
		//[Embed(source="C:\Windows\Fonts\bankgthd.ttf", fontFamily="cod")]
		private var htmladURL:String;
		private var webView:StageWebView;
		public var na:NativeApplication;
		private var admobId:String = 'a1500771e53e97b';
		var userInfo:SharedObject = SharedObject.getLocal("userInfo");
		var cl:ChangeLog;
		var tv:TabView;

		public function main()
		{
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			LoadAds();

			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			var splash:SplashScreen = new SplashScreen();

			addChild(splash);
			tv = new TabView();
			addChild(tv);
			tv.gotoAndStop(4);
			tv.y = 860;
			tv.campaign.addEventListener(MouseEvent.CLICK, tvCampaignClick);
			tv.zombies.addEventListener(MouseEvent.CLICK, tvZombiesClick);
			tv.multiplayer.addEventListener(MouseEvent.CLICK, tvMultiplayerClick);
			tv.about.addEventListener(MouseEvent.CLICK, tvAboutClick);

			if (userInfo.data.databaseVersion == null)
			{
				
				userInfo.data.databaseVersion = "1";
			}
			if (userInfo.data.version == null)
			{
				/*cl = new ChangeLog();
				addChild(cl);
				userInfo.data.version = "1.3";
				cl.backbutton.addEventListener(MouseEvent.CLICK, clBackClick);*/
			}
		}
		private function tvCampaignClick(event:MouseEvent):void
		{
			tv.gotoAndStop(1);
			var c:CampaignScreen = new CampaignScreen();
			addChild(c);
		}
		private function tvZombiesClick(event:MouseEvent):void
		{
			tv.gotoAndStop(2);
			var z:ZombiesScreen = new ZombiesScreen();
			addChild(z);
		}
		private function tvMultiplayerClick(event:MouseEvent):void
		{
			tv.gotoAndStop(3);
			var m:MultiplayerScreen = new MultiplayerScreen();
			addChild(m);
		}
		private function tvAboutClick(event:MouseEvent):void
		{
			tv.gotoAndStop(4);
			var s:SplashScreen = new SplashScreen();
			addChild(s);
		}
		private function clBackClick(event:Event):void
		{
			removeChild(cl);
		}
		private function yesClick(event:Event):void
		{
			var url:URLRequest = new URLRequest("http://www.youtube.com/watch?v=l-l81SZoeHU");
			navigateToURL(url);
			removeChild(cl);
		}
		private function noClick(event:Event):void
		{
			removeChild(cl);
		}
		//Leadbolt
		public function LoadAds()
		{
			trace("Start leadbolt ads");
			htmladURL = "http://idealistictechnologies.com/blackops2/ios.html";
			//htmladURL = "http://idealistictechnologies.com/blackops2/android.html";
			webView = new StageWebView();
			webView.stage = this.stage;
			webView.viewPort = new Rectangle(0,0,640,100);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, loadAds);
			webView.loadURL(htmladURL);
		}

		function loadAds(e:LocationChangeEvent):void
		{
			if (e.location != htmladURL)
			{
				e.preventDefault();
				webView.historyBack();
				var url:URLRequest = new URLRequest(e.location);
				navigateToURL(url);
			}
		}
		function onKey(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.BACK)
			{
				e.preventDefault();

				/*switch (Vars.where)
				{
					case "splash" :
						NativeApplication.nativeApplication.exit();
						break;
					case "campaign" :
						{
							while (numChildren > 0)
							{
								removeChildAt(0);
							}
							var splash:SplashScreen = new SplashScreen();
							addChild(splash);
							break;




						};
					case "multiplayer" :
						{
							while (numChildren > 0)
							{
								removeChildAt(0);
							}
							var splash2:SplashScreen = new SplashScreen();
							addChild(splash2);
							break;







						};
					case "zombies" :
						{
							while (numChildren > 0)
							{
								removeChildAt(0);
							}
							var splash3:SplashScreen = new SplashScreen();
							addChild(splash3);
							break;






						};
					case "aboutus" :
						{
							while (numChildren > 0)
							{
								removeChildAt(0);
							}
							var splash4:SplashScreen = new SplashScreen();
							addChild(splash4);
							break;




						};
					case "campaigngrid" :
						{
							while (numChildren > 0)
							{
								removeChildAt(0);
							}
							var camp:CampaignScreen = new CampaignScreen();
							addChild(camp);
							break;




						};
					case "multiplayergrid" :
						{
							while (numChildren > 0)
							{
								removeChildAt(0);
							}
							var multi:MultiplayerScreen = new MultiplayerScreen();
							addChild(multi);
							break;




					}
				}*/
			}
		}
	}
};