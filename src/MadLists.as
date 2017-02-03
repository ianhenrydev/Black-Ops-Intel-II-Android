package 
{
	import com.danielfreeman.madcomponents.*;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public class MadLists extends Sprite
	{
		public var list:UIList;
		public var itemInfo:ItemInfo;
		var myLoader:Loader = new Loader();

		public function MadLists(DATA:XML,screen:Sprite = null)
		{
			
			if (screen)
			{
				screen.addChild(this);
			}
			var LIST:XML = 
			<list autoLayout="true" colour="#c10000" background= "#CCCCFF,#9999CC,#AAAACC">
			<horizontal>
			<vertical gapV="0">
			<label id="name" alignH="fill"><font size="24" color="#FFFFFF"/></label>
			<imageLoader id="image" width="200"/>
			</vertical>
			<vertical gapV="0">
			<label id="name" alignH="fill"><font size="24" color="#FFFFFF"/></label>
			<label id="info" alignH="fill"><font size="22" color="#FFFFFF"/></label>
			</vertical>
			</horizontal>
			</list>;

			list = new UIList(this,LIST,new Attributes(0,180,640,780));
			list.addEventListener(UIList.CLICKED, listClicked);

			list.xmlData = DATA;
			
			itemInfo = new ItemInfo();
			itemInfo.x = 220;
			itemInfo.y = 0;
			addChild(itemInfo);
			itemInfo.titletext.text = "";
			itemInfo.infotext.text = "Select an item from the list to see more info.";
		}
		protected function listClicked(event:Event):void 
		{
			if (list.row.info.toString().search("http") != -1)
			{
				var url:URLRequest = new URLRequest(list.row.info.toString());
				navigateToURL(url);
			}
					
			trace(list.row.name);
			Vars.where = "item";
			removeChild(itemInfo);
			itemInfo = new ItemInfo();
			itemInfo.x = 220;
			itemInfo.y = 0;
			addChild(itemInfo);
			//itemInfo.closebutton.addEventListener(MouseEvent.CLICK, itemBackClicked);
			itemInfo.titletext.text = list.row.name;
			itemInfo.infotext.text = list.row.info;
			var image:String;
			if (list.row.info.toString().search("Type: Assault") != -1)
			image = "images/weapons/assault.jpg";
			if (list.row.info.toString().search("Type: SMG") != -1)
			image = "images/weapons/smg.jpg";
			if (list.row.info.toString().search("Type: Pistols") != -1)
			image = "images/weapons/pistol.jpg";
			if (list.row.info.toString().search("Type: LMG") != -1)
			image = "images/weapons/lmg.jpg";
			if (list.row.info.toString().search("Type: Shotguns") != -1)
			image = "images/weapons/shotgun.jpg";
			if (list.row.info.toString().search("Type: Snipers") != -1)
			image = "images/weapons/sniper.jpg";
			
			if (image != null)
			{
				var fileRequest:URLRequest = new URLRequest(image);
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady);
				myLoader.load(fileRequest);
			}
			
		}
		public function onLoaderReady(e:Event)
		{
			myLoader.width = 210;
			myLoader.height = 233;
			itemInfo.itemimage.addChild(myLoader);
		}
		private function itemBackClicked(e:MouseEvent):void
		{
			Vars.where = "item";
			removeChild(itemInfo);
		}
	}
}