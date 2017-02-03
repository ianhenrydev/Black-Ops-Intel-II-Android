package
{

	import flash.display.MovieClip;
	import fl.controls.TileList;
	import fl.controls.ScrollBarDirection;
	import flash.events.MouseEvent;
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.data.SQLResult;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.events.TransformGestureEvent;
	import flash.net.FileFilter;
	import flash.ui.MultitouchInputMode;
	import flash.ui.Multitouch;
	import flash.display.Bitmap;
	import flash.events.*;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.net.SharedObject;


	public class GridViewScreen extends MovieClip
	{
		var conn:SQLConnection = new SQLConnection();
		var selectStmt:SQLStatement = new SQLStatement();
		var selectItemStmt:SQLStatement = new SQLStatement();
		var itemInfo:ItemInfo;
		var section:String;
		var selectedItem:String;
		var filename:String;
		var myLoader:Loader = new Loader();
		var split:String;
		var vars:Vars = new Vars();
		var userInfo:SharedObject = SharedObject.getLocal("userInfo");
		var currentItem:String;
		var ml:MadLists;
		public var bs:BlackScreen;

		public function GridViewScreen()
		{

		}
		public function removeItemInfo()
		{
			removeChild(itemInfo);
		}
		public function makeGrid(sect:String,spl:String)
		{
			vars.setWhere(spl+"grid");
			section = sect;
			//titletext.text = sect;
			split = spl;
			openDatabase();
			
		}
		private function openDatabase()
		{
			conn.addEventListener(SQLEvent.OPEN, openHandler);
			conn.addEventListener(SQLErrorEvent.ERROR, sqlError);
			trace(userInfo.data.databaseVersion+".db");
			var dbFile:File;
			if (userInfo.data.databaseVersion == "1")
			dbFile = File.applicationDirectory.resolvePath("v"+userInfo.data.databaseVersion+".db");
			else
			dbFile = File.applicationStorageDirectory.resolvePath("v"+userInfo.data.databaseVersion+".db");
			trace(dbFile.nativePath);
			conn.openAsync(dbFile);
		}
		function openHandler(event:SQLEvent):void
		{
			trace("db opened");
			if (section == "weapons" || section == "perks" || section == "gadgets")
			selectFromDatabase("SELECT * FROM "+section+" ORDER BY type ASC,level ASC");
			if (section == "scorestreaks")
			selectFromDatabase("SELECT * FROM "+section+" ORDER BY points ASC");
			if (section == "maps" || section == "characters" || section == "vehicles" || section == "missions" || section == "attachments" || section == "videos")
			selectFromDatabase("SELECT * FROM "+section+" ORDER BY name");
		}
		private function selectFromDatabase(sql:String)
		{
			selectStmt.sqlConnection = conn;
			selectStmt.text = sql;
			selectStmt.addEventListener(SQLEvent.RESULT, gridHandler);
			selectStmt.addEventListener(SQLErrorEvent.ERROR, sqlError);
			selectStmt.execute();
		}
		function gridHandler(event:SQLEvent):void
		{
			var listdata:String = "<data>";
			
			var result:SQLResult = selectStmt.getResult();

			var numResults:int = result.data.length;
			for (var i:int = 0; i < numResults; i++)
			{
				var row:Object = result.data[i];
				
				var n:String;
				if (section == "weapons" || section == "perks" || section == "gadgets")
				n = "Type: "+row.type+"\nLevel: "+row.level+"\n"+row.info;
				if (section == "scorestreaks")
				n = "Points: "+row.points+"\nLevel: "+row.level+"\n"+row.info;
				if (section == "videos")
				n = row.link;
				if (section == "maps" || section == "characters" || section == "vehicles" || section == "missions" || section == "attachments")
				n = row.info;
				
				var info:String = n.toString().split("'").join("`");
				
				
				listdata += "<item name = '"+row.name+"' info ='"+info+"' image = 'images/"+section+"/"+row.image+"'/>";
			}
			listdata += "</data>";
			//listdata = listdata.replace(/(['\\])/g, "\\$1");
			trace(listdata);
			selectStmt = null;
			var xml:XML = new XML(listdata);
			bs = new BlackScreen();
			addChild(bs);
			ml = new MadLists(new XML(listdata),this);
			ml.y = 200;
			addChild(ml);
			var nb:NavBar = new NavBar();
			nb.y = 100;
			addChild(nb);
			nb.backbutton.addEventListener(MouseEvent.CLICK, backClick);
			
		}
		function strReplace(str:String, search:String, replace:String):String 
		{
			return str.split(search).join(replace);
		}
		/*private function handlelistItemSelected(e:ListItemEvent):void
		{
			if (e.renderer.data.toString().toLowerCase().indexOf("category") > -1 || e.renderer.data.toString().toLowerCase().indexOf("tier") > -1)
			trace("category");
			else
			{
				Vars.where = "item";
				itemInfo = new ItemInfo();
				addChild(itemInfo);
				itemInfo.navbar.backbutton.addEventListener(MouseEvent.CLICK, itemBackClicked);
				itemInfo.titletext.text = e.renderer.data.toString();
				selectItemFromDatabase("SELECT * FROM "+section+" WHERE name='"+e.renderer.data.toString()+"'");
			}
		}*/
		private function tileListClicked(e:MouseEvent):void
		{
			if (section == "videos")
			{
				selectItemFromDatabase("SELECT * FROM "+section+" WHERE name='"+e.target.label.toString()+"'");
			}
			else
			{
				if (e.target.label == null)
				{

				}
				else
				{
					Vars.where = "item";
					itemInfo = new ItemInfo();
					addChild(itemInfo);
					itemInfo.backbutton.addEventListener(MouseEvent.CLICK, itemBackClicked);
					itemInfo.titletext.text = e.target.label.toString();
					selectItemFromDatabase("SELECT * FROM "+section+" WHERE name='"+e.target.label.toString()+"'");
				}
			}
		}
		private function swipehandler(evt:TransformGestureEvent):void
		{
			if (evt.offsetY == 1)
			{
				trace("up");
			}
			if (evt.offsetY == -1)
			{
				trace("down");
			}
		}
		private function selectItemFromDatabase(sql:String)
		{
			selectItemStmt.sqlConnection = conn;
			selectItemStmt.text = sql;
			selectItemStmt.addEventListener(SQLEvent.RESULT, itemHandler);
			selectItemStmt.addEventListener(SQLErrorEvent.ERROR, sqlError);
			selectItemStmt.execute();
		}
		function itemHandler(event:SQLEvent):void
		{
			
			var result:SQLResult = selectItemStmt.getResult();
			var numResults:int = result.data.length;
			for (var i:int = 0; i < numResults; i++)
			{
				var row:Object = result.data[i];
				if (section == "videos")
				{
					var url:URLRequest = new URLRequest(row.link);
					navigateToURL(url);
				}
				else
				{
					if (row.image == null)
					{
						var fileRequest1:URLRequest = new URLRequest("images/unknown.jpg");
						myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady);
						myLoader.load(fileRequest1);
					}
					else
					{
						if (row.version > 1)
						{
							var file:File = File.applicationStorageDirectory.resolvePath(row.image);
							var fileRequest3:URLRequest = new URLRequest(file.nativePath);
							myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady);
							myLoader.load(fileRequest3);
						}
						else
						{
							var fileRequest:URLRequest = new URLRequest("images/"+section+"/"+row.image);
							myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady);
							myLoader.load(fileRequest);
						}
					}
					if (row.info == null)
					{
						trace("no info");
					}
					else
					{
						itemInfo.infotext.text = row.info;
					}
				}
			}

		}
		public function onLoaderReady(e:Event)
		{
			myLoader.width = 160;
			myLoader.height = 100;
			itemInfo.itemimage.addChild(myLoader);
		}

		private function backClick(e:MouseEvent):void
		{
			removeChild(ml);
			removeChild(bs);
			if (split == "multiplayer")
			{
			var multi:MultiplayerScreen = new MultiplayerScreen();
			addChild(multi);
			}
			else if (split == "campaign")
			{
				var camp:CampaignScreen = new CampaignScreen();
				addChild(camp);
			}
		}
		private function itemBackClicked(e:MouseEvent):void
		{
			Vars.where = "item";
			removeChild(itemInfo);
		}

		function sqlError(event:SQLErrorEvent):void
		{
			trace("Error message:", event.error.message);
			trace("Details:", event.error.details);
		}
	}

}