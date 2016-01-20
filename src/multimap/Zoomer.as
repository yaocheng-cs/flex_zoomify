package com.repilac.multimap
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.VSlider;
	import mx.events.SliderEvent;

	public class Zoomer extends VSlider
	{
		protected var _zoomChanged:Boolean;
		
		protected var _ZOOM:Number;
		public function get ZOOM():Number
		{
			return this._ZOOM;
		}
		public function set ZOOM(value:Number):void
		{
			if(this._ZOOM == value){
				return;
			} else{
				this._zoomChanged = true;
				this._ZOOM = value;
				invalidateProperties();
			}
		}
		
		protected var _ORIGIN:Point;
		public function get ORIGIN():Point
		{
			return this._ORIGIN;
		}
		public function set ORIGIN(value:Point):void
		{
			this._ORIGIN = value;
			invalidateProperties();  //this could be omitted
		}
		
		protected var _VIEW:ZoomRect;
		public function get VIEW():ZoomRect
		{
			return this._VIEW;
		}
		public function set VIEW(value:ZoomRect):void
		{
			this._VIEW = value;
			invalidateProperties();
		}
		
		protected var _changeInitiator:Boolean;
		public function get changeInitiator():Boolean
		{
			return this._changeInitiator;
		}
		public function set changeInitiator(value:Boolean):void
		{
			this._changeInitiator = value;
		}
		
		public var mapWidth:Number;
		public var mapHeight:Number;
		
		public function Zoomer()
		{
			super();
			
			this.scaleX = 1.5;
			this.scaleY = 1.2;
			
			this.enable();
			addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);  //prevent mouse down event from "popping down"
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this._changeInitiator){
				var e:Event = new Event("zoomify_property_change", true);
				dispatchEvent(e);
			}
			
			if(this._zoomChanged){
				this.value = this._ZOOM;
				this._zoomChanged = false;
			}
		}
		
		public function setZoomifyProperties(z:Number, o:Point, v:ZoomRect):void
		{
			this.ZOOM = z;
			this.ORIGIN = o;
			this.VIEW = v;
		}
		
		protected function originAfterZoom(z:Number):Point
		{
			var w:Number = this.mapWidth / 2;
			var h:Number = this.mapHeight / 2;
			var c:ZoomXY = new ZoomXY(this._ZOOM, w - this._ORIGIN.x, h - this._ORIGIN.y);
			c.zoomTo(z);
			var o:Point = new Point(w - c.x, h - c.y);
			return o;
		}
		
		public function onThumbChange(e:SliderEvent):void
		{
			this._changeInitiator = true;
			
			this.ORIGIN = this.originAfterZoom(e.value);
			this.VIEW = new ZoomRect(e.value, -this._ORIGIN.x, -this._ORIGIN.y, -this._ORIGIN.x + this.mapWidth, -this._ORIGIN.y + this.mapHeight);
			this.ZOOM = e.value;  //the ZOOM must be set after the new ORIGIN has been calculated
		}
		
		public function onThumbDrag(e:SliderEvent):void
		{
			this._changeInitiator = true;
			
			this.ORIGIN = this.originAfterZoom(e.value);
			this.ZOOM = e.value;  //the ZOOM must be set after the new ORIGIN has been calculated
		}
		
		public function onThumbRelease(e:SliderEvent):void
		{
			this._changeInitiator = true;
			
			this.VIEW = new ZoomRect(this._ZOOM, -this._ORIGIN.x, -this._ORIGIN.y, -this._ORIGIN.x + this.mapWidth, -this._ORIGIN.y + this.mapHeight);
		}
		
		public function onMouseDown(e:MouseEvent):void
		{
			e.stopPropagation();
		}
		
		public function mute():void
		{
			this.enabled = false;
			removeEventListener(SliderEvent.THUMB_DRAG, this.onThumbDrag);
			removeEventListener(SliderEvent.CHANGE, this.onThumbChange);
			removeEventListener(SliderEvent.THUMB_RELEASE, this.onThumbRelease);
		}
		
		public function enable():void
		{
			this.enabled = true;
			addEventListener(SliderEvent.THUMB_DRAG, this.onThumbDrag);
			addEventListener(SliderEvent.CHANGE, this.onThumbChange);
			addEventListener(SliderEvent.THUMB_RELEASE, this.onThumbRelease);
		}
	}
}