package com.repilac.multimap
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	public class Navigator extends UIComponent
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
		
		protected var _originChanged:Boolean;
		
		protected var _ORIGIN:Point;
		public function get ORIGIN():Point
		{
			return this._ORIGIN;
		}
		public function set ORIGIN(value:Point):void
		{
			if(this._ORIGIN == value){
				return
			} else{
				this._originChanged = true;
				this._ORIGIN = value;
				invalidateProperties();
			}
		}
		
		protected var _VIEW:ZoomRect;
		public function get VIEW():ZoomRect
		{
			return this._VIEW;
		}
		public function set VIEW(value:ZoomRect):void
		{
			this._VIEW = value;
			//following line must NOT be ommited, because when users stop dragging by releasing the mouse button,
			//navigator should notify the application that zoomify properity (which is VIEW here) changes
			invalidateProperties();
		}
		
		protected var _mapSizeChanged:Boolean;
		protected var _mapWidth:Number;
		public function set mapWidth(value:Number):void
		{
			this._mapWidth = value;
			this._mapSizeChanged = true;
			invalidateProperties();
		}
		
		protected var _mapHeight:Number;
		public function set mapHeight(value:Number):void
		{
			this._mapHeight = value;
			this._mapSizeChanged = true;
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
		
		protected var _thumbnail:Tile;
		public function get thumbnail():Tile
		{
			return this._thumbnail;
		}
		
		protected var _mask:Sprite;
		protected var _win:Sprite;
		protected var _winWidth:Number;
		protected var _winHeight:Number;
		
		public function Navigator():void
		{
			super();
			
			this._mask = new Sprite();
			addChild(this._mask);
			mask = this._mask;
			this._thumbnail = new Tile(0, 0, 0, 20, 20);
			addChild(this._thumbnail);
			this._win = new Sprite();
			this._thumbnail.addChild(this._win);
			
			this.enable();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this._changeInitiator){
				var e:Event = new Event("zoomify_property_change", true);
				dispatchEvent(e);
			}
			
			if(this._zoomChanged){
				this.setWinSize(this._ZOOM);
				this._zoomChanged = false;
				invalidateDisplayList();
			}
			
			if(this._originChanged){
				this.setWinOrigin(this._ORIGIN.x, this._ORIGIN.y);
				this._originChanged = false;
			}
			
			if(this._mapSizeChanged){
				this.setWinSize(this._ZOOM);
				this._mapSizeChanged = false;
				invalidateDisplayList();
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		
			with(graphics){
				clear();
				lineStyle(1,0x4B999A);
				beginFill(0x4B999A, 0.5);
				drawRect(0, 0, width, height);
				endFill();
			}
			
			with(this._mask.graphics){
				clear();
				lineStyle(1, 0x4B999A);
				beginFill(0x4B999A, 1);
				drawRect(-1, 0, width + 2,height + 1);
				endFill();
			}
			
			with(this._win.graphics){
				clear();
				lineStyle(1, 0xFF0000);
				beginFill(0x0000FF, 0);  //remember to fill the window, or the inside part of the window will not respond to mouse action
				drawRect(0, 0, this._winWidth, this._winHeight);
				endFill();
			}
		}
		
		public function updateFromSource(zs:ZoomifySource):void
		{
			width = zs.imageWidth / Math.pow(2, zs.maxTier) + 40;
			height = zs.imageHeight / Math.pow(2, zs.maxTier) + 40;
			this.thumbnail.removeChildAt(0);
			zs.loadTile(this._thumbnail);
			this._thumbnail.addChild(this._win);  //add the moving window as a child again, make sure it is on top of the thumbnail image
		}
		
		public function setZoomifyProperties(z:Number, o:Point, v:ZoomRect):void
		{
			this.ZOOM = z;
			this.ORIGIN = o;
			this.VIEW = v;
		}
		
		protected function setWinSize(z:Number):void
		{
			this._winWidth = this._mapWidth / Math.pow(2, z);
			this._winHeight = this._mapHeight / Math.pow(2, z);
		}
		
		protected function setWinOrigin(x0:Number, y0:Number):void
		{
			this._win.x = -x0 / Math.pow(2, this._ZOOM);
			this._win.y = -y0 / Math.pow(2, this._ZOOM);
		}
		
		/*
		//this method binds to mapviewer.bindableViewOrigin
		public function resetNaviWin(p:ZoomXY):void
		{
			this.curZoom = p.zoom;
			this._winWidth = this.mapWidth / Math.pow(2, this.curZoom);
			this._winHeight = this.mapHeight / Math.pow(2, this.curZoom);
			var x0:Number = -p.x / Math.pow(2, this.curZoom);
			var y0:Number = -p.y / Math.pow(2, this.curZoom);
			this._winPos = new Point(20 + x0, 20 + y0);
			invalidateDisplayList();
		}
		
		public function resizeNaviWin():void
		{
			this._winWidth = this.mapWidth / Math.pow(2, this.curZoom);
			this._winHeight = this.mapHeight / Math.pow(2, this.curZoom);
			invalidateDisplayList();
		}
		
		public function markInitView(iv:ZoomRect):void
		{
			var temp:ZoomRect = iv.copy().zoomTo(0);
			//RectLayer.drawBorder(this._initViewTile, temp, 1);
		}
		*/
		
		protected function onMouseDown(e:MouseEvent):void
		{	
			e.stopPropagation();  //prevent mouse down event from "popping down"
			
			this._changeInitiator = true;
			
			this._win.startDrag();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		
		protected function onMouseMove(e:MouseEvent):void
		{
			this._changeInitiator = true;
			
			this.ORIGIN = new Point(-this._win.x * Math.pow(2, this._ZOOM), -this._win.y * Math.pow(2, this._ZOOM));
			
			e.updateAfterEvent();
		}
		
		protected function onMouseUp(e:MouseEvent):void
		{
			this._changeInitiator = true;
			
			this._win.stopDrag();
			this.VIEW = new ZoomRect(this._ZOOM, -this._ORIGIN.x, -this._ORIGIN.y, -this._ORIGIN.x + this._mapWidth, -this._ORIGIN.y + this._mapHeight);
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		
		public function mute():void
		{
			this._win.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		public function enable():void
		{
			this._win.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
	}
}