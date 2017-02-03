/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CheckBoxToggleSkin.as</p>
 * <p>Version: 0.3</p>
 *
 * <p>Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:</p>
 *
 * <p>The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.</p>
 *
 * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.</p>
 *
 * <p>Licensed under The MIT License</p>
 * <p>Redistributions of files must retain the above copyright notice.</p>
 */
package com.custardbelly.as3flobile.skin
{
	import com.custardbelly.as3flobile.controls.button.ToggleButton;
	import com.custardbelly.as3flobile.enum.BasicStateEnum;
	
	import flash.display.Graphics;

	/**
	 * CheckBoxToggleSkin is a skin class for the toggle display in a CheckBox control. 
	 * @author toddanderson
	 */
	public class CheckBoxToggleSkin extends ToggleButtonSkin
	{
		/**
		 * Constructor.
		 */
		public function CheckBoxToggleSkin() { super(); }
		
		/**
		 * @inherit
		 */
		override protected function clearDisplay():void
		{
			super.clearDisplay();
			var target:ToggleButton = ( _target as ToggleButton );
			var background:Graphics = target.backgroundDisplay;
			background.clear();
		}
		
		/**
		 * @inherit
		 */
		override protected function updateBackground( display:Graphics, width:int, height:int ):void
		{
			if( display == null ) return;
			
			super.updateBackground( display, width, height );
			
			if( _target.skinState == BasicStateEnum.SELECTED )
			{	
				var position:Number = height * 0.25;
				display.lineStyle( 4, 0xFF7F00 );
				display.moveTo( position, position );
				display.lineTo( width * 0.5, height - position );
				display.lineTo( width + position, -position );
			}
		}
	}
}