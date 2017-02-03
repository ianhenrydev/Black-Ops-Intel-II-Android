/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ScrollListHorizontalLayout.as</p>
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
package com.custardbelly.as3flobile.controls.list.layout
{
	import com.custardbelly.as3flobile.controls.list.IScrollListContainer;
	import com.custardbelly.as3flobile.controls.list.IScrollListLayoutTarget;
	import com.custardbelly.as3flobile.controls.list.renderer.IScrollListItemRenderer;
	import com.custardbelly.as3flobile.enum.OrientationEnum;
	import com.custardbelly.as3flobile.model.BoxPadding;
	import com.custardbelly.as3flobile.util.DisplayPositionSearch;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ScrollListHorizontalLayout is an IScrollListHorizontalLayout implementation to layout children of a target IScrollListContainer along the x axis. 
	 * @author toddanderson
	 */
	public class ScrollListHorizontalLayout implements IScrollListHorizontalLayout
	{
		protected var _target:IScrollListContainer;
		protected var _contentWidth:Number;
		protected var _contentHeight:Number;
		
		protected var _itemWidth:Number;
		protected var _padding:BoxPadding;
		protected var _useVariableWidth:Boolean;
		
		protected var _indexPositionCache:Point;
		
		/**
		 * @private
		 * 
		 * Cache of width of each child display item on IScrollListContainer display list. 
		 */
		protected var _widthCache:Vector.<int>;
		/**
		 * @private
		 * 
		 * Reference to the largest width of a child display item on IScrollListContainer display list to determine positioning within a variable layout. 
		 */
		protected var _widestItemWidth:Number;
		
		/**
		 * Constructor.
		 */
		public function ScrollListHorizontalLayout()
		{
			_widthCache = new Vector.<int>();
			_padding = new BoxPadding();
			_indexPositionCache = new Point();
		}
		
		/**
		 * @private
		 *  
		 * Validates the box model padding between the list target edge and the renderers.
		 */
		protected function invalidatePadding():void
		{
			if( _target == null ) return;
			
			var renderers:Vector.<IScrollListItemRenderer> = _target.renderers;
			var rect:Rectangle = _target.scrollBounds;
			var i:int = 0;
			var length:int = renderers.length;
			var renderer:IScrollListItemRenderer;
			var xpos:Number = _padding.left;
			while( i < length )
			{
				renderer = renderers[i];
				renderer.lock();
				renderer.height = rect.height - _padding.top - _padding.bottom;
				renderer.unlock();
				
				( renderer as DisplayObject ).x = xpos;
				( renderer as DisplayObject ).y = 0;
				xpos += renderer.width + _target.seperatorLength;
				i++;
			}
			// Cache the widths.
			cacheWidths( _target.renderers );
			// Update the determined height of the content.
			_contentHeight = rect.height;
			( _target as IScrollListLayoutTarget ).commitContentChange();
		}
		
		/**
		 * @private
		 * 
		 * Delegate function to determine if an item resides above or below the position. 
		 * @param item DisplayObject
		 * @param position Number
		 * @return Boolean
		 * @see #DisplayPositionSearch
		 */
		protected function compareItemPosition( item:DisplayObject, position:Number ):Boolean
		{
			return (item.x < position) && (item.x + item.width < position);
		}
		
		/**
		 * @private
		 * 
		 * Delegate function to determine if an item lies within the position on the display. 
		 * @param item DisplayObject
		 * @param position Number
		 * @return Boolean
		 * @see #DisplayPositionSearch
		 */
		protected function isWithinRange( item:DisplayObject, position:Number ):Boolean
		{
			return (item.x <= position) && (item.x + item.width >= position);
		}
		
		/**
		 * @private
		 * 
		 * Caches the width of each IScrollListItemRenderer instance for speed of use in determining layout. 
		 * @param cells Vector.<IScrollListItemRenderer> The list to traverse and cache widths from.
		 */
		protected function cacheWidths( cells:Vector.<IScrollListItemRenderer> ):void
		{
			var i:int = cells.length;
			var w:Number;
			var seperator:int = _target.seperatorLength;
			_widthCache = new Vector.<int>( i );
			_contentWidth = 0;
			while( --i > -1 )
			{
				w = cells[i].width;
				_contentWidth += w;
				_widthCache[i] = w;
			}
			_contentWidth += ( ( _widthCache.length - 1 ) * seperator ) + ( _padding.left + _padding.right );
			// Hold reference to largest width to be used if using variable layout.
			_widestItemWidth = ( _widthCache.length > 0 ) ? _widthCache.sort( Array.NUMERIC )[_widthCache.length - 1] : 0;
		}
		
		/**
		 * @private 
		 * 
		 * Empties cache of widths for IScrollListItemRenderer instances.
		 */
		protected function emptyWidthCache():void
		{
			while( _widthCache.length > 0 )
				_widthCache.shift();
		}
		
		/**
		 * @copy IScrollListLayout#updateDisplay()
		 */
		public function updateDisplay():void
		{
			var renderers:Vector.<IScrollListItemRenderer> = _target.renderers;
			var rect:Rectangle = _target.scrollBounds;
			var data:Array = _target.dataProvider;
			var i:int = 0;
			var length:int = renderers.length;
			var renderer:IScrollListItemRenderer;
			var xpos:Number = 0;
			while( i < length )
			{
				renderer = renderers[i];
				renderer.lock();
				renderer.orientation = OrientationEnum.HORIZONTAL;
				renderer.useVariableHeight = false;
				renderer.useVariableWidth = _useVariableWidth;
				if( !isNaN( _itemWidth ) ) renderer.width = _itemWidth;
				renderer.height = rect.height;
				renderer.data = data[i];
				renderer.unlock();
				( renderer as DisplayObject ).x = xpos;
				( renderer as DisplayObject ).y = 0;
				( _target as IScrollListLayoutTarget ).addRendererToDisplay( renderer );
				xpos += renderer.width + _target.seperatorLength;
				i++;
			}
			// Cache the widths.
			cacheWidths( _target.renderers );
			// Update the determined height of the content.
			_contentHeight = rect.height;
			( _target as IScrollListLayoutTarget ).commitContentChange();
		}
		
		/**
		 * @copy IScrollListLayout#updateScrollPosition()
		 */
		public function updateScrollPosition():void
		{
			/*
			// 	[NOTE] 
			//	This has been deprecated to save rendering time.
			//	Previous implementation ensured only needed list items were on the display list.
			//	Unfortunately this was too expensive during runtime and affacted the rendering position of list items.
			//	Left in or histories sake, if we circle around and want to implement on-demand item rendering.
			//	[/NOTE]
			
			var currentScrollPosition:Number = _target.scrollPosition.x;
			var position:Number = ( currentScrollPosition > 0.0 ) ? currentScrollPosition : -currentScrollPosition;
			
			var cells:Vector.<IScrollListItemRenderer> = _target.renderers;
			var cellAmount:int = cells.length;
			var rect:Rectangle = _target.scrollBounds;
			var scrollAreaWidth:Number = rect.width - rect.x;
			var cellWidth:Number = _itemWidth + _target.seperatorLength;
			var startIndex:int;
			var endIndex:int;
			
			// If using variable height, determine visible content using the DisplayPositionSearch algorithm.
			if( _useVariableWidth )
			{
				startIndex = DisplayPositionSearch.findCellIndexInPosition( cells, position, compareItemPosition, isWithinRange );
				endIndex = DisplayPositionSearch.findCellIndexInPosition( cells, position + scrollAreaWidth + _widestItemWidth, compareItemPosition, isWithinRange );	
				endIndex = ( endIndex == -1 && startIndex > -1 ) ? cellAmount : endIndex;
			}
			// Else determine visible content faster based on index values.
			else
			{
				var length:Number = ( scrollAreaWidth / cellWidth );
				startIndex = int( position / cellWidth );
				length = ( length % 1 ) ? int(length) + 1 : length;
				endIndex = startIndex + int(length) + 1;
			}
			
			// Use the start and end index to find visible content.
			var index:int = cellAmount;
			var cell:IScrollListItemRenderer;
			var listProvider:Array = _target.dataProvider;
			while( --index > -1 )
			{
				cell = cells[index];
				if( index >= startIndex && index < endIndex )
				{
					IScrollListItemRenderer(cell).data = listProvider[index];
					( _target as IScrollListLayoutTarget ).addRendererToDisplay( cell );
				}
				else
				{
					( _target as IScrollListLayoutTarget ).removeRendererFromDisplay( cell );
				}
			}
			*/
		}
		
		/**
		 * @copy IScrollListLayout#getPositionFromIndex()
		 */
		public function getPositionFromIndex( index:uint ):Point
		{
			var cells:Vector.<IScrollListItemRenderer> = _target.renderers;
			// Update cache position based on index.
			if( index > cells.length - 1 )
			{
				_indexPositionCache.x = 0;
			}
			else
			{
				_indexPositionCache.x = -( ( cells[index] as DisplayObject ).x - _padding.left );
			}
			_indexPositionCache.y = 0;
			return _indexPositionCache;
		}
		
		/**
		 * @copy IScrollListLayout#getChildIndexAtPosition()
		 */
		public function getChildIndexAtPosition( xposition:Number, yposition:Number ):int
		{
			var cells:Vector.<IScrollListItemRenderer> = _target.renderers;
			var index:int = DisplayPositionSearch.findCellIndexInPosition( cells, xposition, compareItemPosition, isWithinRange );
			return index;
		}
		
		/**
		 * @copy IScrollListLayout#getContentWidth()
		 */
		public function getContentWidth():Number
		{
			return _contentWidth;
		}
		/**
		 * @copy IScrollListLayout#getContentHeight()
		 */
		public function getContentHeight():Number
		{
			return _contentHeight;
		}
		
		/**
		 * @copy IScrollListLayout#dispose()
		 */
		public function dispose():void
		{
			emptyWidthCache();
			_target = null;
		}
		
		/**
		 * @copy IScrollListLayout#target
		 */
		public function get target():IScrollListContainer
		{
			return _target;
		}
		public function set target(value:IScrollListContainer):void
		{
			_target = value;
		}
		
		/**
		 * @copy IScrollListLayout#padding 
		 */
		public function get padding():BoxPadding
		{
			return _padding;
		}
		public function set padding( value:BoxPadding ):void
		{
			if( _padding == value ) return;
			
			_padding = value;
			invalidatePadding();
		}
		
		/**
		 * @copy IScrollListHorizontalLayout#itemWidth
		 */
		public function get itemWidth():Number
		{
			return _itemWidth;
		}
		public function set itemWidth( value:Number ):void
		{
			if( _itemWidth == value ) return;
			
			_itemWidth = value;
			if( _target != null ) updateDisplay();
		}
		
		/**
		 * @copy IScrollListHorizontalLayout#useVariableWidth
		 */
		public function get useVariableWidth():Boolean
		{
			return _useVariableWidth;
		}
		public function set useVariableWidth( value:Boolean ):void
		{
			if( _useVariableWidth == value ) return;
			
			_useVariableWidth = value;
			if( _target != null ) 
			{
				updateDisplay();
				updateScrollPosition();
			}
		}
	}
}