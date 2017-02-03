﻿/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: DefaultScrollListItemRenderer.as</p>
 * <p>Version: 0.4</p>
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
package com.custardbelly.as3flobile.controls.list.renderer
{
	import com.custardbelly.as3flobile.controls.core.AS3FlobileComponent;
	import com.custardbelly.as3flobile.controls.label.Label;
	import com.custardbelly.as3flobile.enum.BasicStateEnum;
	import com.custardbelly.as3flobile.enum.OrientationEnum;
	import com.custardbelly.as3flobile.model.BoxPadding;
	import com.custardbelly.as3flobile.skin.ScrollListItemRendererSkin;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.TextFormat;
	
	/**
	 * DefaultScrollListItemRenderer is the default item renderer for a IScrollListContainer.
	 * The recognize object model for the data supplied to this class is {label:"your label"}. The label property of the object model is represented textually.
	 * @author toddanderson
	 */
	public class DefaultScrollListItemRenderer extends AS3FlobileComponent implements IScrollListItemRenderer
	{
		private static const STATE_UNLOCKED:uint = 0;
		private static const STATE_LOCKED:uint = 1;
		
		protected var _background:Shape;
		protected var _label:Label;
		
		protected var _isDirty:Boolean;
		protected var _currentState:uint = DefaultScrollListItemRenderer.STATE_UNLOCKED;
		protected var _useVariableWidth:Boolean;
		protected var _useVariableHeight:Boolean;
		protected var _orientation:int;
		
		protected var _labelField:String = "label";
		protected var _data:Object;
		protected var _selected:Boolean;
		
		
		/**
		 * Constructor.
		 */
		public function DefaultScrollListItemRenderer()
		{
			super();
		}
		
		/**
		 * @inherit
		 */
		override protected function initialize():void
		{
			super.initialize();
			
			this.cacheAsBitmap = true;
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
			_width = 100;
			_height = 48;
			
			updatePadding( 3, 3, 3, 3 );
			
			_orientation = OrientationEnum.VERTICAL;
			
			_skin = new ScrollListItemRendererSkin();
			_skin.target = this;
		}
		
		/**
		 * @inherit
		 */
		override protected function createChildren():void
		{
			_background = new Shape();
			addChild( _background );
			
			var myTextFormat:TextFormat = new TextFormat();
			myTextFormat.font = "COD Font"
			myTextFormat.size = 20;
			
			_label = new Label();
			_label.multiline = true;
			_label.autosize = true;
			addChild( _label );
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplay():void
		{
			_label.draw();
			super.updateDisplay();
		}
		
		/**
		 * @private
		 * 
		 * Validates a property and forwards along method invocation based on current state. 
		 * @param handler Function
		 * @param args ...
		 */
		protected function invalidateProperty( handler:Function, ...args ):void
		{
			var isUnlocked:Boolean = _currentState == DefaultScrollListItemRenderer.STATE_UNLOCKED;
			if( isUnlocked )
				invalidate.apply( this, [handler, args] );
			else
				_isDirty = true;
		}
		
		/**
		 * @private 
		 * 
		 * Validates the supplied data and updates the display.
		 */
		protected function invalidateData():void
		{
			// If no data and this was called in response to a property change, move on.
			if( _data == null ) return;
			
			_label.text = _data[_labelField];
			_label.draw();
			
			if( _useVariableHeight ) _height = _label.height + _padding.top + _padding.bottom;
			if( _useVariableWidth ) _width = _label.width + _padding.left + _padding.right;
			updateDisplay();
			_isDirty = false;
		}
		
		/**
		 * @inherit
		 */
		override protected function invalidateSize():void
		{
			_label.width = _width - ( _padding.left + _padding.right );
			super.invalidateSize();
		}
		
		/**
		 * @private
		 * 
		 * Validates the selection state.
		 */
		protected function invalidateSelected():void
		{
			_skinState = ( _selected ) ? BasicStateEnum.SELECTED : BasicStateEnum.NORMAL;
			invalidateSize();
		}
		
		/**
		 * @private 
		 * 
		 * Validates the orientation of this item renderer based on parening list layout.
		 */
		protected function invalidateOrientation():void
		{
			updateDisplay();
		}
		
		/**
		 * @private
		 * 
		 * Updates the current state.  
		 * @param oldState uint
		 * @param newState uint
		 */
		protected function handleStateChange( oldState:uint, newState:uint ):void
		{
			_currentState = newState;
			
			// If properties have changed, run an update.
			if( _currentState == DefaultScrollListItemRenderer.STATE_UNLOCKED && _isDirty )
				invalidateData();
		}
		
		/**
		 * @copy IScrollListItemRenderer#lock()
		 */
		public function lock():void
		{
			handleStateChange( _currentState, DefaultScrollListItemRenderer.STATE_LOCKED );
		}
		
		/**
		 * @copy IScrollListItemRenderer#unlock() 
		 * 
		 */
		public function unlock():void
		{
			handleStateChange( _currentState, DefaultScrollListItemRenderer.STATE_UNLOCKED );
		}
		
		/**
		 * @copy IScrollListItemRenderer#backgroundDisplay
		 */
		public function get backgroundDisplay():Graphics
		{
			return _background.graphics;
		}
		
		/**
		 * Returns the display related to textual content. 
		 * @return Label
		 */
		public function get labelDisplay():Label
		{
			return _label;
		}
		
		/**
		 * @copy IScrollListItemRenderer#selected
		 */
		public function get selected():Boolean
		{
			return _selected;
		}
		public function set selected( value:Boolean ):void
		{
			if( _selected == value ) return;
			
			_selected = value;
			invalidateProperty( invalidateSelected );
		}
		
		/**
		 * @copy IScrollListItemRenderer#useVariableHeight
		 */
		public function get useVariableHeight():Boolean
		{
			return _useVariableHeight;
		}
		public function set useVariableHeight( value:Boolean ):void
		{
			if( _useVariableHeight == value ) return;
			
			_useVariableHeight = value;
			invalidateProperty( invalidateData );
		}
		
		/**
		 * @copy IScrollListItemRenderer#useVariableWidth
		 */
		public function get useVariableWidth():Boolean
		{
			return _useVariableWidth;
		}
		public function set useVariableWidth( value:Boolean ):void
		{
			if( _useVariableWidth == value ) return;
			
			_useVariableWidth = value;
			invalidateProperty( invalidateData );
		}
		
		/**
		 * @copy IScrollListItemRenderer#orientation
		 */
		public function get orientation():int
		{
			return _orientation;
		}
		public function set orientation(value:int):void
		{
			if( _orientation == value ) return;
			
			_orientation = value;
			invalidateProperty( invalidateOrientation );
		}
		
		/**
		 * @copy IScrollListItemRenderer#labelField
		 */
		public function get labelField():String
		{
			return _labelField;
		}
		public function set labelField( value:String ):void
		{
			_labelField = value;
		}
		
		/**
		 * @copy IScrollListItemRenderer#data
		 */
		public function get data():Object
		{
			return _data;
		}
		public function set data( value:Object ):void
		{
			if( _data == value ) return;
			
			_data = value;	
			invalidateProperty( invalidateData );
		}

		/**
		 * @inherit
		 */
		override public function set padding( value:BoxPadding ):void
		{
			if( BoxPadding.equals( _padding, value ) ) return;
			
			_padding = value;
			invalidateProperty( invalidateData );
		}
	}
}