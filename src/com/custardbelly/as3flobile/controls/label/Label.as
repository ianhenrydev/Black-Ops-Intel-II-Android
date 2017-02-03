﻿/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: Label.as</p>
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
package com.custardbelly.as3flobile.controls.label
{
	import com.custardbelly.as3flobile.controls.core.AS3FlobileComponent;
	import com.custardbelly.as3flobile.controls.label.renderer.ILabelRenderer;
	import com.custardbelly.as3flobile.controls.label.renderer.MultilineLabelRenderer;
	import com.custardbelly.as3flobile.controls.label.renderer.TruncationLabelRenderer;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.text.engine.BreakOpportunity;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	/**
	 * Label is a textual base component utilizing the Flash Text Engine to render a single or multiple line of text. 
	 * @author toddanderson
	 */
	public class Label extends AS3FlobileComponent
	{
		protected var _textElement:TextElement;
		
		protected var _text:String;
		protected var _format:ElementFormat;
		
		protected var _truncate:Boolean = true;
		protected var _truncationText:String = "...";
		
		protected var _autosize:Boolean;
		protected var _multiline:Boolean;
		protected var _textAlign:String;
		
		protected var _renderer:ILabelRenderer;
		protected var _truncationRenderer:ILabelRenderer;
		protected var _multilineRenderer:ILabelRenderer;
		protected var _rendererWidth:int;
		protected var _rendererHeight:int;
		
		protected var _measuredWidth:int;
		protected var _measuredHeight:int;
		
		protected var _hasRequestForInvalidationOnDisplay:Boolean;
		
		/**
		 * Constructor.
		 */
		public function Label() { super(); }
		
		/**
		 * @inherit
		 */
		override protected function initialize():void
		{	
			super.initialize();
			
			_width = 100;
			_height = 20;
			
			_format = new ElementFormat( new FontDescription("COD Font") );
			_format.breakOpportunity = BreakOpportunity.NONE;
			_format.fontSize = 28;
			
			_textElement = new TextElement();
			_truncationText = "...";
			_textAlign = TextFormatAlign.LEFT;
			
			_truncationRenderer = new TruncationLabelRenderer( this );
			_multilineRenderer = new MultilineLabelRenderer( this );
			_renderer = _truncationRenderer;
			_renderer.truncationText = _truncationText;
			_renderer.textAlign = _textAlign;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function invalidate( method:Function, args:Array = null ):void
		{
			// Override to limit invalidate of text display to one time per frame as it is requsted to be invoked through many poroperties.
			var hasArgs:Boolean = ( args && args.length > 0 );
			var isRequestForInvalidationOnDisplay:Boolean = ( method == invalidateTextDisplay );
			var addInvalidationToQueue:Boolean = !isRequestForInvalidationOnDisplay;
			if( isRequestForInvalidationOnDisplay && !_hasRequestForInvalidationOnDisplay )
			{	
				_hasRequestForInvalidationOnDisplay = true;
				addInvalidationToQueue = true;
			}
			if( addInvalidationToQueue )
			{
				if( hasArgs ) 	super.invalidate( method, args );
				else			super.invalidate( method );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function render(evt:Event=null):void
		{
			// Flip flag for invalidate on text display. Limit is once per frame.
			_hasRequestForInvalidationOnDisplay = false;
			super.render( evt );
		}
		
		/**
		 * @private 
		 * 
		 * Validates the textual content and its formatting.
		 */
		protected function invalidateTextDisplay():void
		{
			_textElement.text = _text;
			_textElement.elementFormat = _format;
			
			_rendererWidth = ( _autosize && !_multiline ) ? 0 : _width;
			_rendererHeight = ( _autosize ) ? 0 : _height;
			_renderer.render( _textElement, _rendererWidth, _rendererHeight );
			
			if( numChildren > 0 )
			{
				// Updates measured bounds.
				var bounds:Rectangle = getBounds(this);
				var lastChild:TextLine = getChildAt( numChildren - 1 ) as TextLine;
				_measuredWidth = bounds.width;
				_measuredHeight = bounds.height + ( lastChild.ascent - ( lastChild.descent * 2 ) );
			}
		}
		/**
		 * @private 
		 * 
		 * Validate the scrollable area of the content.
		 */
		override protected function invalidateSize():void
		{
			_measuredWidth = _width;
			_measuredHeight = _height;
			invalidateTextDisplay();
		}
		
		/**
		 * @private
		 * 
		 * Updates the renderer state used for display layout. 
		 * @param renderer ILabelRenderer
		 */
		protected function setRendererState( renderer:ILabelRenderer ):void
		{
			_renderer = renderer;
		}
		
		/**
		 * @inherit
		 */
		override public function dispose():void
		{
			super.dispose();
			
			while( numChildren > 0 )
				removeChildAt( 0 );
			
			_format = null;
			
			_truncationRenderer.dispose();
			_truncationRenderer = null;
			
			_renderer = null;
		}
		
		/**
		 * Retruns the measured width of this instance based on autosize flag. 
		 * If autosize is set to true the measured width of this control is based on the content.
		 * @return int
		 */
		public function get measuredWidth():int
		{
			return _measuredWidth;
		}
		
		/**
		 * Returns the measured height of this instance based on autosize flag.
		 * If autosize is set to true and multiline set to true the measured height of this control is based on the content. 
		 * @return int
		 */
		public function get measuredHeight():int
		{
			return _measuredHeight;
		}
		
		/**
		 * @inherit
		 * 
		 * Override to return the determined measured width based on content when autosize is specified.
		 */
		override public function get width():Number
		{
			return ( _autosize ) ? _measuredWidth : _width;
		}
		/**
		 * @inherit
		 * 
		 * Override to return the determined measured height based on content when autosize is specified.
		 */
		override public function get height():Number
		{
			return ( _autosize ) ? _measuredHeight : _height;
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
			if( _text != null ) invalidate( invalidateTextDisplay );
		}
		
		/**
		 * Accessor/Modifier for the textual content represented within truncation. Default is '...' 
		 * @return String
		 */
		public function get truncationText():String
		{
			return _truncationText;
		}
		public function set truncationText( value:String ):void
		{
			if( _truncationText == value ) return;
			
			_truncationText = value;
			_truncationRenderer.truncationText = _truncationText;
			if( _truncate ) invalidate( invalidateTextDisplay );
		}

		/**
		 * Accessor/Modifier flag to truncate text on render. 
		 * @return Boolean
		 */
		public function get truncate():Boolean
		{
			return _truncate;
		}
		public function set truncate(value:Boolean):void
		{
			if( _truncate == value ) return;
			
			_truncate = value;
			setRendererState( _truncationRenderer );
			if( _text != null ) invalidate( invalidateTextDisplay );
		}

		/**
		 * Accessor/Modifier of autosize flag for render. 
		 * @return Boolean
		 */
		public function get autosize():Boolean
		{
			return _autosize;
		}
		public function set autosize( value:Boolean ):void
		{
			if( _autosize == value ) return;
			
			_autosize = value;
			if( _text != null ) invalidate( invalidateTextDisplay );
		}

		/**
		 * Accessor/Modifier flag to display multiple lines. 
		 * @return Boolean
		 */
		public function get multiline():Boolean
		{
			return _multiline;
		}
		public function set multiline( value:Boolean ):void
		{
			if( _multiline == value ) return;
		
			_multiline = value;
			setRendererState( ( value ) ? _multilineRenderer : _truncationRenderer );
			if( _text != null ) invalidate( invalidateTextDisplay );	
		}
		
		/**
		 * Accessor/Modifier for the alignment of text within a single or multiline Label. 
		 * @return String Value values are from flash.text.TextFormatAlign
		 */
		public function get textAlign():String
		{
			return _textAlign;
		}
		public function set textAlign( value:String ):void
		{
			if( _textAlign == value ) return;
			
			_textAlign = value;
			_truncationRenderer.textAlign = _textAlign;
			_multilineRenderer.textAlign = _textAlign;
			if( _text != null ) invalidate( invalidateTextDisplay );
		}		
	}
}