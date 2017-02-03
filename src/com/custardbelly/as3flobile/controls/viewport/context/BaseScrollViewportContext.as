/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: BaseScrollViewportContext.as</p>
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
package com.custardbelly.as3flobile.controls.viewport.context
{
	import com.custardbelly.as3flobile.controls.viewport.IScrollViewport;
	
	import flash.geom.Point;

	/**
	 * BaseScrollViewportContext is an IScrollViewportContext implementation with templated methods meant for override. 
	 * @author toddanderson
	 */
	public class BaseScrollViewportContext implements IScrollViewportContext
	{
		protected var _isActive:Boolean;
		protected var _viewport:IScrollViewport;
		protected var _strategy:IScrollViewportStrategy;
		
		/**
		 * Constructor. 
		 * @param strategy IScrollViewportStrategy The Strategy implementation that handles scrolling action.
		 */
		public function BaseScrollViewportContext( strategy:IScrollViewportStrategy )
		{
			_strategy = strategy;
		}
		
		/**
		 * Initializes the context with a target IScrollViewport instance. 
		 * @param viewport
		 * 
		 */
		public function initialize( viewport:IScrollViewport ):void
		{
			_viewport = viewport;
		}
		
		/**
		 * @copy IScrollViewportContext#reset()
		 */
		public function reset():void
		{
			_strategy.reset();
		}
		
		/**
		 * Runs an update on held IScrollViewportStrategy.
		 */
		public function update():void
		{
			if( _isActive )
				_strategy.mediate( _viewport );
		}
		
		/**
		 * Activates the mediating IScrollViewportStrategy handling scroll operations.
		 */
		public function activate():void
		{
			_isActive = true;
			_strategy.mediate( _viewport );
		}
		
		/**
		 * Deactivates the mediating IScrollViewportStrategy handling scroll operations. 
		 */
		public function deactivate():void
		{
			_isActive = false;	
			_strategy.unmediate();
		}
		
		/**
		 * @copy IScrollViewportContext#isActive()
		 */
		public function isActive():Boolean
		{
			return _isActive;
		}
		
		/**
		 * Performs any clean up necessary.
		 */
		public function dispose():void
		{
			deactivate();
			_strategy.dispose();
		}
		
		/**
		 * @copy IScrollViewportContext#position
		 */
		public function get position():Point
		{
			return ( _strategy != null ) ? _strategy.position : null;
		}
		public function set position( value:Point ):void
		{
			if( _strategy ) _strategy.position = value;
		}
		
		/**
		 * Accessor/Modifier for the IScrollViewportStrategy instances that is mediating scroll operations. 
		 * @return IScrollViewportStrategy
		 */
		public function get strategy():IScrollViewportStrategy
		{
			return _strategy;
		}
		public function set strategy( value:IScrollViewportStrategy ):void
		{
			_strategy = value;
		}
	}
}