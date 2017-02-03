/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: TextArea.as</p>
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
package com.custardbelly.as3flobile.controls.text
{
	import com.custardbelly.as3flobile.controls.core.AS3FlobileComponent;
	import com.custardbelly.as3flobile.controls.viewport.IScrollViewport;
	import com.custardbelly.as3flobile.controls.viewport.ScrollViewport;
	import com.custardbelly.as3flobile.controls.viewport.context.IScrollViewportContext;
	import com.custardbelly.as3flobile.model.BoxPadding;
	import com.custardbelly.as3flobile.skin.TextAreaSkin;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	import org.osflash.signals.Signal;
	
	/**
	 * TextArea is a scrollable area of static textual content. 
	 * @author toddanderson
	 */
	public class TextArea extends AS3FlobileComponent
	{
		protected var _background:Shape;
		protected var _viewport:IScrollViewport;
		
		protected var _block:TextBlock;
		protected var _lineHolder:TextAreaLineHolder;
		protected var _numLines:int;
		protected var _linePositions:Vector.<int>;
		
		protected var _text:String;
		protected var _format:ElementFormat;
		protected var _scrollPosition:Point;
		protected var _maximumScrollPosition:int;
		
		protected var _scrollContext:IScrollViewportContext;
		
		protected var _textChange:Signal;
		protected var _scrollChange:Signal;
		
		/**
		 * Constructor.
		 */
		public function TextArea() 
		{
			super();
		}
		
		/**
		 * @inherit
		 */
		override protected function initialize():void
		{	
			super.initialize();
			
			_width = 100;
			_height = 100;
			
			_format = new ElementFormat( new FontDescription("DroidSans") );
			_format.fontSize = 14;
			
			_block = new TextBlock();
			
			_linePositions = new Vector.<int>(1);
			
			updatePadding( 5, 5, 5, 5 );
			
			_skin = new TextAreaSkin();
			_skin.target = this;
			
			_textChange = new Signal( String );
			_scrollChange = new Signal( Point );
		}
		
		/**
		 * @inherit
		 */
		override protected function createChildren():void
		{
			_background = new Shape();
			addChild( _background );
			
			_lineHolder = new TextAreaLineHolder();
			_lineHolder.mouseChildren = false;
			_lineHolder.cacheAsBitmap = true;
			
			var horizPadding:int = ( _padding.left + _padding.right );
			var vertPadding:int = ( _padding.top + _padding.bottom );
			_viewport = new ScrollViewport();
			_viewport.scrollStart.add( scrollViewScrollChange );
			_viewport.scrollChange.add( scrollViewScrollChange );
			_viewport.scrollEnd.add( scrollViewScrollChange );
			_viewport.width = _width - horizPadding;
			_viewport.height = _height - vertPadding;
			_viewport.x = _padding.left;
			_viewport.y = _padding.top;
			_viewport.content = _lineHolder;
			addChild( _viewport as DisplayObject );
		}
		
		/**
		 * @private 
		 * 
		 * Validates the textual content and its formatting.
		 */
		protected function invalidateTextDisplay():void
		{
			_lineHolder.clear();
			if( _block.firstLine ) _block.releaseLines( _block.firstLine, _block.lastLine );
			
			var horizPadding:int = ( _padding.left + _padding.right );
			// Use TextBlock factory to create TextLines and add to the display.
			_block.content = new TextElement( _text, _format );
			_numLines = 0;
			var line:TextLine = _block.createTextLine( null, _width - horizPadding );
			var ypos:int = _padding.top;
			while( line )
			{
				ypos += line.height;
				line.y = ypos;
				
				_lineHolder.addChild( line );
				_linePositions[_numLines] = ypos;
				
				ypos += ( line.ascent - line.descent );
				
				_numLines++;
				// Get next line from factory.
				line = _block.createTextLine( line, _width - horizPadding );
			}
			
			// Update dimensions and viewport.
			_lineHolder.width = _width - horizPadding;
			_lineHolder.height = ypos;
			_viewport.refresh();
			
			// Update maximum scroll position.
			_maximumScrollPosition = ( _lineHolder.height < _height ) ? 0 : _lineHolder.height - _height;
		}
		
		/**
		 * @private 
		 * 
		 * Validate the scrollable area of the content.
		 */
		override protected function invalidateSize():void
		{
			super.invalidateSize();
			
			var horizPadding:int = ( _padding.left + _padding.right );
			var vertPadding:int = ( _padding.top + _padding.bottom );
			_viewport.width = _width - horizPadding;
			_viewport.height = _height - vertPadding;
			_viewport.x = _padding.left;
			_viewport.y = _padding.top;
			invalidateTextDisplay();
		}
		
		/**
		 * @private 
		 * 
		 * Validates the scroll position within the viewport set by the user directly.
		 */
		protected function invalidateScrollPosition():void
		{
			if( _viewport.context )
				_viewport.context.position = _scrollPosition;
		}
		
		/**
		 * @private
		 * 
		 * Validates the IScrollViewportContext implementation applied to this instance.
		 */
		protected function invalidateScrollContext():void
		{
			// If we have a viewport set, apply the new context.
			if( _viewport != null )
			{
				_viewport.context = _scrollContext;
			}
		}
		
		/**
		 * @private
		 * 
		 * Signal handler for change in scroll position from viewport. 
		 * @param position Point
		 */
		protected function scrollViewScrollChange( position:Point ):void
		{
			_scrollPosition = position;
			_scrollChange.dispatch( position );
		}
		
		/**
		 * @inherit
		 */
		override public function dispose():void
		{
			super.dispose();
			
			_linePositions = null;
			
			_viewport.dispose();
			_viewport = null;
			
			_lineHolder.clear();
			_lineHolder = null;
				
			_format = null;
			_block.releaseLines( _block.firstLine, _block.lastLine );
			_block = null;
			
			_textChange.removeAll();
			_textChange = null;
			
			_scrollChange.removeAll();
			_scrollChange = null;
		}
		
		/**
		 * Positions the content at the top of the line specified at the index within the content. 
		 * @param index int
		 */
		public function scrollToLine( index:int ):void
		{
			if( index > _linePositions.length - 1 ) index = 0;
			
			// Limit position.
			var ypos:int = -_linePositions[index];
			ypos = ( ypos < _maximumScrollPosition ) ? _maximumScrollPosition : ypos;
			// Update scroll position.
			if( _scrollPosition )
			{
				_scrollPosition.y = ypos	
			} 
			else
			{
				_scrollPosition = new Point( 0, ypos );	
			}
			// Invoke invalidation.
			invalidateScrollPosition();
		}		
		
		/**
		 * Returns the number of lines created from the textual content. 
		 * @return int
		 */
		public function get numLines():int
		{
			return _numLines;
		}
		
		/**
		 * Returns signal reference for change in scroll. 
		 * @return Signal Signal( Point )
		 */
		public function get scrollChange():Signal
		{
			return _scrollChange;
		}
		/**
		 * Returns signal reference for change in textual content. 
		 * @return Signal Signal( String )
		 */
		public function get textChange():Signal
		{
			return _textChange;
		}
		
		/**
		 * Accessor for the background display for a ISkin instance targeting this control. 
		 * @return Shape
		 */
		public function get backgroundDisplay():Shape
		{
			return _background;
		}
		
		/**
		 * @inherit
		 */
		override public function set padding( value:BoxPadding ):void
		{
			if( BoxPadding.equals( _padding, value ) ) return;
			
			_padding = value;
			invalidate( invalidateTextDisplay );
			invalidate( invalidateSize );
		}
		
		/**
		 * Accessor/Modifier for the textual content to display. 
		 * @return String
		 */
		public function get text():String
		{
			return _text;
		}
		public function set text( value:String ):void
		{
			if( _text == value ) return;
			
			_text = value;
			invalidate( invalidateTextDisplay );
			_textChange.dispatch( _text );
		}
		
		/**
		 * Accessor/Modifier for the element formatting of the textual content. 
		 * @return ElementFormat
		 */
		public function get format():ElementFormat
		{
			return _format;
		}
		public function set format(value:ElementFormat):void
		{
			if( _format == value ) return;
			
			_format = value;
			invalidate( invalidateTextDisplay );
		}
		
		/**
		 * Accessor/Modifier for the coordinate position of the content within the viewport based on its top/left position. 
		 * @return Point
		 */
		public function get scrollPosition():Point
		{
			return _scrollPosition;
		}
		public function set scrollPosition( value:Point ):void
		{
			if( _scrollPosition == value ) return;
			
			_scrollPosition = value;
			invalidate( invalidateScrollPosition );
		}
		
		/**
		 * Accessor/Modifier for the viewport context that manages user gestures and animation of display. 
		 * @return IScrollViewportContext
		 */
		public function get scrollContext():IScrollViewportContext
		{
			return _scrollContext;
		}
		public function set scrollContext( value:IScrollViewportContext ):void
		{
			if( _scrollContext == value ) return;
			
			_scrollContext = value;
			invalidate( invalidateScrollContext );
		}

		/**
		 * Accessor/Modifier for the width of this display. 
		 * @return Number
		 */
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if( _width == value ) return;
			
			_viewport.width = value;
			super.width = value;
		}

		/**
		 * Accessor/Modifier for the height of this display. 
		 * @return Number
		 */
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if( _height == value ) return;
			
			_viewport.height = value;
			super.height = value;
		}
	}
}

import flash.display.Shape;
import flash.display.Sprite;
/**
 * @private
 * 
 * TextAreaLineHolder is an extension of Sprite that holds dimension values representing width and height. This is so not to scale the Sprite,
 * and is used as the basis for scrolling in the viewport based on content dimensions. 
 * @author toddanderson
 */
class TextAreaLineHolder extends Sprite
{
	protected var _background:Shape;
	protected var _width:int = 0;
	protected var _height:int = 0;
	
	/**
	 * Constructor.
	 */
	public function TextAreaLineHolder() 
	{
		_background = new Shape();
		addChild( _background );
	}

	/**
	 * @private 
	 * 
	 * Validates the size.
	 */
	protected function invalidateSize():void
	{
		// Redraw false background.
		_background.graphics.clear();
		_background.graphics.beginFill( 0, 0 );
		_background.graphics.drawRect( 0, 0, _width, _height );
		_background.graphics.endFill();
	}
	
	/**
	 * Clears the textual content of the display.
	 */
	public function clear():void
	{
		var i:int = numChildren;
		while( --i > 0 )
		{
			removeChildAt( i );
		}
	}
	
	/**
	 * Accessor/Modifier for the preferred width of the display. 
	 * @return Number
	 */
	override public function get width():Number
	{
		return _width;
	}
	override public function set width( value:Number ):void
	{
		if( _width == value ) return;
		
		_width = value;
		invalidateSize();
	}
	
	/**
	 * Accessor/Modifier for the preferred height of the display. 
	 * @return Number
	 */
	override public function get height():Number
	{
		return _height;
	}
	override public function set height( value:Number ):void
	{
		if( _height == value ) return;
		
		_height = value;
		invalidateSize();
	}
}