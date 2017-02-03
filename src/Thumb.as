package
{
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ImageCell;
	import fl.controls.TileList;
	import flash.text.*;

	public class Thumb extends ImageCell implements ICellRenderer
	{
		private var desc:TextField;
		private var textStyle:TextFormat;

		public function Thumb()
		{
			super();
			loader.scaleContent = true;
			useHandCursor = true;



			// Create and format desc
			desc = new TextField();
			desc.autoSize = TextFieldAutoSize.LEFT;
			desc.x = 0;
			desc.width = 110;
			desc.height = 400;
			desc.y = 0;
			desc.multiline = true;
			desc.wordWrap = true;
			addChild(desc);
			textStyle = new TextFormat();
			textStyle.font = "Calibri";
			textStyle.size = 45;
		}
	}
}