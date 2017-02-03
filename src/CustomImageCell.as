package
{
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ImageCell;
	import fl.controls.TileList;
	import fl.data.DataProvider;
	import fl.managers.StyleManager;
	import flash.events.EventDispatcher;
	import flash.text.*;
	import flash.events.*;
	import fl.containers.UILoader;
	import fl.controls.Button;
	import flash.display.Bitmap;
	
	public class CustomImageCell extends ImageCell implements ICellRenderer
	{  
		private var title	:	TextField;
		private var tf		: 	TextFormat;
		
    	public function CustomImageCell() 
		{
			super();
			
			// set skins
			
			
			// turn off text overlay
			setStyle("textOverlayAlpha", 0);
			
			title = new TextField ();
			
			title.autoSize = TextFieldAutoSize.LEFT;
			//title.defaultTextFormat = styles.Arial_11_white;
			title.antiAliasType = AntiAliasType.ADVANCED;
			title.embedFonts = StyleManager.getStyle("embedFonts");
			title.x = 5;
			title.width = 320;
			title.multiline = true;
			title.wordWrap = true;
			title.selectable = false;
			addChild(title);
			
			tf = new TextFormat();
			tf.font = "BankGothic Md BT";
			tf.color = 0xFFFFFF;
			tf.size = 30;
			
			//loader.scaleContent = false;
		
			useHandCursor = true;
    	}
	
		override protected function drawLayout():void
		{
			//var imagePadding:Number = getStyleValue("imagePadding") as Number;
			//loader.move(11, 5);
			
			var w:Number = 320;
			var h:Number = 200;
			if (loader.width != w && loader.height != h)
			{
				loader.setSize(w,h);
			}
			loader.drawNow(); // Force validation!

			title.text = data.label;
			title.setTextFormat(tf);
			
			background.width = width;
			background.height = height;
			textField.visible = false;
		}
	}
}