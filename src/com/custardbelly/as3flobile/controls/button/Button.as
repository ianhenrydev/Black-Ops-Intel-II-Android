/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: Button.as</p>
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
package com.custardbelly.as3flobile.controls.button
{
	import com.custardbelly.as3flobile.controls.core.AS3FlobileComponent;
	import com.custardbelly.as3flobile.controls.label.Label;
	import com.custardbelly.as3flobile.enum.BasicStateEnum;
	import com.custardbelly.as3flobile.helper.ITapMediator;
	import com.custardbelly.as3flobile.helper.MouseTapMediator;
	import com.custardbelly.as3flobile.skin.ButtonSkin;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.events.GenericEvent;
	
	/**
	 * Button is a component that renders a graphic and textual display to represent an interactable object. 
	 * @author toddanderson
	 */
	public class Button extends AS3FlobileComponent
	{
		protected var _labelDisplay:Label;
		
		protected var _label:String;
		protected var _labelPadding:int;
		
		protected var _tapMediator:ITapMediator;
		
		protected var _tap:DeluxeSignal;
		protected var _tapEvent:GenericEvent;
		
		/**
		 * Constructor.
		 */
		public function Button()
		{
			super();
		}
		
		/**
		 * Static convenience method to instantiate a new instance of Button with an assigned tap delegate method. 
		 * @param handler Function The delegate function to add to the tap signal.
		 * @return Button
		 */
		static public function initWithTapHandler( handler:Function ):Button
		{
			var button:Button = new Button();
			button.tap.add( handler );
			return button;
		}
		
		/**
		 * @inherit
		 */
		override protected function initialize():void
		{
			super.initialize();
			
			mouseChildren = false;
			mouseEnabled = true;
			
			_width = 100;
			_height = 48;
			
			_labelPadding = 5;
			
			_tapMediator = new MouseTapMediator();
			
			_skin = new ButtonSkin();
			_skin.target = this;
			
			_tap = new DeluxeSignal( this );
			_tapEvent = new GenericEvent();
		}
		
		/**
		 * @inherit
		 */
		override protected function createChildren():void
		{
			_labelDisplay = new Label();
			_labelDisplay.autosize = true;
			_labelDisplay.multiline = true;
			addChild( _labelDisplay );
		}
		
		/**
		 * @private 
		 * 
		 * Invalidates the label text for the label display.
		 */
		protected function invalidateLabel():void
		{
			_labelDisplay.text = _label;
			updateDisplay();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplay():void
		{	
			_labelDisplay.draw();
			super.updateDisplay();
		}
		
		/**
		 * @private
		 * 
		 * Validates the ITapMediator instance used in deiscovering a tap gestue on this control. 
		 * @param newValue ITapMediator
		 */
		protected function invalidateTapMediator( newValue:ITapMediator ):void
		{
			// Clear out mediation on old ITapMediator instance if currently mediating.
			if( _tapMediator && _tapMediator.isMediating( this ) )
				_tapMediator.unmediateTapGesture( this );
			
			// Set new ITapMediator instance reference.
			_tapMediator = newValue;
			// Start mediating if we are on the display list.
			if( isActiveOnDisplayList() )
				_tapMediator.mediateTapGesture( this, handleTap );
		}
		
		/**
		 * @inherit
		 */
		override protected function addDisplayHandlers():void
		{
			addEventListener( MouseEvent.MOUSE_DOWN, handleDown, false, 0, true );
			addEventListener( MouseEvent.MOUSE_OUT, handleOut, false, 0, true );
			addEventListener( MouseEvent.MOUSE_UP, handleOut, false, 0, true );
			if( _tapMediator && !_tapMediator.isMediating( this ) ) _tapMediator.mediateTapGesture( this, handleTap );
		}
		
		/**
		 * @inherit
		 */
		override protected function removeDisplayHandlers():void
		{
			removeEventListener( MouseEvent.MOUSE_DOWN, handleDown, false );
			removeEventListener( MouseEvent.MOUSE_OUT, handleOut, false );
			removeEventListener( MouseEvent.MOUSE_UP, handleOut, false );
			if( _tapMediator && _tapMediator.isMediating( this ) ) _tapMediator.unmediateTapGesture( this );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for down state of button. 
		 * @param evt MouseEvent
		 */
		protected function handleDown( evt:MouseEvent ):void
		{
			_skinState = BasicStateEnum.DOWN;
			updateDisplay();
		}
		
		/**
		 * @private
		 * 
		 * Event handler for mouse out of button. 
		 * @param evt MouseEvent
		 */
		protected function handleOut( evt:MouseEvent ):void
		{
			_skinState = BasicStateEnum.NORMAL;
			updateDisplay();
		}
		
		/**
		 * @private
		 * 
		 * Event handle for click detection on label display. 
		 * @param evt Event
		 */
		protected function handleTap( evt:Event ):void
		{
			_tap.dispatch( _tapEvent );
		}
		
		/**
		 * @inherit
		 */
		override public function dispose():void
		{
			super.dispose();
			
			while( numChildren > 0 )
				removeChildAt( 0 );
			
			if( _tapMediator && _tapMediator.isMediating( this ) )
				_tapMediator.unmediateTapGesture( this );
			
			_tap.removeAll();
			_tap = null;
			_tapEvent = null;
		}
		
		/**
		 * Returns signal reference for handle of tap action. 
		 * @return DeluxeSignal
		 */
		public function get tap():DeluxeSignal
		{
			return _tap;
		}
		
		/**
		 * Accessor/Modifier for the textual display of the label. 
		 * @return String
		 */
		public function get label():String
		{
			return _label;
		}
		public function set label( value:String ):void
		{
			if( _label == value ) return;
			
			_label = value;
			invalidate( invalidateLabel );
		}
		
		/**
		 * Accessor/Modifier for the padding offset for the label display. 
		 * @return int
		 */
		public function get labelPadding():int
		{
			return _labelPadding;
		}
		public function set labelPadding( value:int ):void
		{
			if( _labelPadding == value ) return;
			
			_labelPadding = value;
			invalidate( updateDisplay );
		}
		
		/**
		 * Accessor for the label display that can be used in skinning process. 
		 * @return Label
		 */
		public function get labelDisplay():Label
		{
			return _labelDisplay;
		}
		
		/**
		 * Accessor for the buttonDisplay that can be used in the skinning process. 
		 * @return Sprite
		 */
		public function get backgroundDisplay():Graphics
		{
			return graphics;
		}

		/**
		 * Accessor/Modifier for the mediator for a tap gesture. Default MouseTapMediator. 
		 * @return ITapMediator
		 */
		public function get tapMediator():ITapMediator
		{
			return _tapMediator;
		}
		public function set tapMediator( value:ITapMediator ):void
		{
			if( _tapMediator == value ) return;
			
			invalidateTapMediator( value );
		}
	}
}