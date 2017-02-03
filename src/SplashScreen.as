package
{

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.Stage;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.net.*;
	import fl.controls.ProgressBarDirection;
	import fl.controls.ProgressBarMode;
	import flash.utils.ByteArray;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	import flash.system.Capabilities;

	public class SplashScreen extends MovieClip
	{
		var vars:Vars = new Vars();
		var userInfo:SharedObject = SharedObject.getLocal("userInfo");
		var db:DatabaseUpdate;
		var newdb:Number;
		var olddb:Number;
		var updatedb:Number;
		var urlStream:URLStream;
		var zip:FZip;
		var aboutus:AboutUs;

		public function SplashScreen()
		{
			
			vars.setWhere("splash");

			
			checkDB();
			devMessage();
			facebookbutton.addEventListener(MouseEvent.CLICK, aboutFacebookClick);
			
			ratebutton.addEventListener(MouseEvent.CLICK, rateClick);
		}
		private function rateClick(event:Event):void
		{
			//var url:URLRequest = new URLRequest("https://play.google.com/store/apps/details?id=air.com.idealistictechnologies.blackopsinfo2");
			var url:URLRequest = new URLRequest("http://itunes.apple.com/us/app/black-ops-2-info/id553216980?ls=1&mt=8");
			navigateToURL(url);
		}
		private function aboutFacebookClick(event:Event):void
		{
			var url:URLRequest = new URLRequest("http://www.facebook.com/IdealisticTechnologiesInc");
			navigateToURL(url);
		}
		private function aboutYoutubeClick(event:Event):void
		{
			var url:URLRequest = new URLRequest("http://www.youtube.com/user/IdealisticTech");
			navigateToURL(url);
		}
		private function aboutEmailClick(event:Event):void
		{
			var url:URLRequest = new URLRequest("mailto:support@idealistictechnologies.com");
			navigateToURL(url);
		}
		private function aboutBackClick(event:Event):void
		{
			vars.setWhere("splash");
			removeChild(aboutus);
		}
		private function preorderClick(event:Event):void
		{
			var url:URLRequest = new URLRequest("http://www.amazon.com/gp/product/B007XVTR3K/ref=as_li_qf_sp_asin_il?ie=UTF8&camp=1789&creative=9325&creativeASIN=B007XVTR3K&linkCode=as2&tag=powerchcom-20");
			navigateToURL(url);
		}
		public function devMessage()
		{
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest("http://idealistictechnologies.com/blackops2/getDevMessage.php");
			loader.addEventListener(Event.COMPLETE, messageHandler);
			try
			{
				loader.load(request);
			}
			catch (error:Error)
			{
				dev_txt.text = "Error loading message from the developers.";
			}
		}
		private function messageHandler(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			dev_txt.text = String(loader.data);
			trace(loader.data);
			
		}
		public function checkDB()
		{
			
			databasetext.text = "Checking for Database updates...";
			loadinggear.visible = true;
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest("http://idealistictechnologies.com/blackops2/getDatabaseVersion.php");
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			try
			{
				loader.load(request);
			}
			catch (error:Error)
			{
				redx.visble = true;
				loadinggear.visible = false;
				databasetext.text = "Error checking for updates";
			}
		}
		private function completeHandler(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			newdb = loader.data;
			olddb = Number(userInfo.data.databaseVersion);
			trace(olddb);
			if (userInfo.data.databaseVersion == loader.data)
			{
				loadinggear.visible = false;
				checkmark.visible = true;
				databasetext.text = "Database up to date\nv"+newdb;
			}
			else
			{
				updatedb = olddb + 1;
				loadinggear.visible = false;
				databasetext.text = "Database out of date. Tap to update to v"+updatedb;
				downloadarrow.visible = true;
				downloadarrow.addEventListener(MouseEvent.CLICK, updateClick);
				databasetext.addEventListener(MouseEvent.CLICK, updateClick);
			}
		}
		function updateClick(e:MouseEvent):void
		{
			downloadarrow.visible = false;
			progressbar.visible = true;
			progressbar.direction = ProgressBarDirection.RIGHT;
			progressbar.mode = ProgressBarMode.MANUAL;
			progressbar.setProgress(0, 100);
			databasetext.text = "Downloading Update";
			
			zip = new FZip();
			zip.addEventListener(Event.COMPLETE, onComplete);
			zip.load(new URLRequest("http://idealistictechnologies.com/blackops2/databases/v" + updatedb + ".zip"));
		}
		private function onComplete(evt:Event):void 
		{
			databasetext.text = "Unpacking Images";
			progressbar.setProgress(0, zip.getFileCount());
			var numFiles = zip.getFileCount();
			var i:Number = 0;
			trace(numFiles);
			while (i < numFiles)
			{
				var zipFile:FZipFile = zip.getFileAt(i);
				var file:File;
				file = File.applicationStorageDirectory.resolvePath(zipFile.filename);
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeBytes(zipFile.content, 0, zipFile.content.length);
				fileStream.close();
				i++;
				progressbar.value == i;
			}
			downloadarrow.removeEventListener(MouseEvent.CLICK, updateClick);
			databasetext.removeEventListener(MouseEvent.CLICK, updateClick);
			checkmark.visible = true;
			progressbar.visible = false;
			databasetext.text = "Update complete\nv"+updatedb;
			userInfo.data.databaseVersion = updatedb;
		}
		private function downloadIoErrorHandler(event:IOErrorEvent):void
		{
			trace(event.toString());
		}
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			redx.visible = true;
			loadinggear.visible = false;
			databasetext.text = "Error checking for updates";
		}
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			redx.visible = true;
			loadinggear.visible = false;
			databasetext.text = "Error checking for updates";
		}
		function campaignClick(e:MouseEvent):void
		{
			var camp:CampaignScreen = new CampaignScreen();
			addChild(camp);
		}
		function multiplayerClick(e:MouseEvent):void
		{
			var multi:MultiplayerScreen = new MultiplayerScreen();
			addChild(multi);
		}
		function zombiesClick(e:MouseEvent):void
		{
			var zombs:ZombiesScreen = new ZombiesScreen();
			addChild(zombs);
		}
		function countDays( startDate:Date, endDate:Date ):int
		{
			var oneDay:int = 24 * 60 * 60 * 1000;// hours*minutes*seconds*milliseconds 
			var diffDays:int = Math.round(Math.abs((startDate.getTime() - endDate.getTime())/(oneDay)));
			return diffDays;
		}
	}
}