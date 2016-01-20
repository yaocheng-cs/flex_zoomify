package com.repilac.multimap
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import mx.binding.utils.*;
	import mx.core.UIComponent;
	
	public class Map extends UIComponent
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
				return;
			} else{
				this._originChanged = true;
				this._ORIGIN = value;
				invalidateProperties();
			}
		}
		
		protected var _viewChanged:Boolean;
		
		/** 
		 * "view" specifies zoom level and view rect in that zoom plane
		 * in pixel. "view" is purely in the abstract pyramid space.
		 *  (i.e. view and display is independent. However, "view" size and display
		 * size (width and height) usually matches.
		 */
		protected var _VIEW:ZoomRect;
		public function get VIEW():ZoomRect
		{
			return this._VIEW;
		}
		public function set VIEW(value:ZoomRect):void
		{
			if(this._VIEW == value){
				return;
			} else{
				if(this._VIEW && this._VIEW.contain(value)){
					return;
				}
				this._viewChanged = true;
				this._VIEW = value;
				invalidateProperties();
			}
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
		
		protected var _layers:Array;
		protected var _mask:Sprite;
		protected var _frame:Sprite;
		
		/*protected var _bound:ZoomRect;
		public function get bound():ZoomRect
		{
			return this._bound;
		}
		public function set bound(value:ZoomRect):void
		{
			this._bound = value;
		}
		
		
		protected var _view:ZoomRect;
		public function get view():ZoomRect
		{
			return this._view;
		}
		public function set view(value:ZoomRect):void
		{
			// check bounds on zoom level
			value.boundWith(this._bound);
			
			if (!value.equalTo(this._view)){	
				_view = value;
				_viewChanged = true;
				invalidateProperties();
				this.curZoom = _view.zoom;  //when setting the "view", set "curZoom" at the same time
				
				if(this._changeInitiator){
					var f:PropertyChangeEvent = new PropertyChangeEvent("change", false, false, PropertyChangeEventKind.UPDATE, this._view);
					dispatchEvent(f);
				}
			}
		}
		
		
		public function set viewChanged(value:Boolean):void
		{
			this._viewChanged = value;
		}
		
		protected var _viewOrigin:ZoomXY;
		[Bindable] public var bindableViewOrigin:ZoomXY;  //bound by navigator.resetNaviWin
		public function get viewOrigin():ZoomXY
		{
			return _viewOrigin;
		}
		public function set viewOrigin(o:ZoomXY):void
		{
			if (! o.equalTo(_viewOrigin)){
				_viewOrigin = o;
				_viewOriginChanged = true;
				this.bindableViewOrigin = this._viewOrigin;  //this will trigger the binding method in navigator to run
				invalidateProperties();
				
				if(this._changeInitiator){
					var f:PropertyChangeEvent = new PropertyChangeEvent("change", false, false, PropertyChangeEventKind.UPDATE, this._viewOrigin);
					dispatchEvent(f);
				}
			}
		}
		protected var _viewOriginChanged:Boolean = false;
		public function set viewOriginChanged(s:Boolean):void
		{
			this._viewOriginChanged = s;
		}
		
		protected var _curZoom:Number;
		[Bindable] public var bindableCurZoom:Number;  //bound by navigator.curZoom and zoomSlider.value
		public function get curZoom():Number
		{
			return this._curZoom;
		}
		public function set curZoom(cz:Number):void
		{
			if(this._curZoom != cz){
				this._curZoom = cz;
				this.bindableCurZoom = this._curZoom;
			}
		}
		*/
		
		//helper variables for the mouse dragging action
		protected var _deltaX:Number;
		protected var _deltaY:Number;
		
		public var clickZoomEnable:Boolean = true;
		
		
		public function Map(pw:Number, ph:Number)
		{			
			super();
			
			percentWidth = pw;
			percentHeight = ph;
			
			//create layers array
			this._layers = new Array();
			
			//do not add the frame to display list yet, add it when the map is focused
			this._frame = new Sprite();
			BindingUtils.bindSetter(this.drawFrame, this, "width");
			BindingUtils.bindSetter(this.drawFrame, this, "height");
			
			this._mask = new Sprite();
			addChild(this._mask);
			mask = this._mask;
			
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
				//this setLayerZoom() MUST happen first, since it will modify the value of "originDelta",
				//which will be used in calculating proper origin and view of a tranformed layer
				this.setLayerZoom(this._ZOOM);
				this._zoomChanged = false;
			}
			
			if(this._originChanged){
				this.setLayerOrigin(this._ORIGIN.x, this._ORIGIN.y);
				this._originChanged = false;
			}
			
			if(this._viewChanged){
				this.setLayerView(this._VIEW);
				this._viewChanged = false;
			}
			
			//if (_viewOriginChanged){
			//	_viewOriginChanged = false;
			//	setLayerOrigin(_viewOrigin.x, _viewOrigin.y);
				//this.invalidateDisplayList();
			//}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			with(this._mask.graphics){
				clear();
				lineStyle(1, 0x000000);
				beginFill(0x000000);
				drawRect(0, 0, width, height);
				endFill();
			}
			
			/*
			//draw frame for debugging purpose
			with(graphics){
				clear();
				lineStyle(6, 0x0000FF);
				moveTo(0, 0);
				lineTo(2000, 0);
				moveTo(0, 0);
				lineTo(0, 2000);
				lineStyle(1, 0x0000FF);
				drawRect(0, 0, width - 2, height - 1);
				var i:int = 1;
				while(100 * i < width){
					moveTo(100 * i, 0);
					lineTo(100 * i, height - 1);
					i++;
				}
				i = 1;
				while(100 * i < height){
					moveTo(0, 100 * i);
					lineTo(width - 2, 100 * i);
					i++;
				}
			}
			*/
		}
		
		public function setZoomifyProperties(z:Number=0, o:Point=null, v:ZoomRect=null):void
		{
			if(z == 0 && o == null && v == null){
				this.VIEW = this.fitInView();  //the "view" calculation must be done first
				this.ORIGIN = this.fitInOrigin();
				this.ZOOM = this._VIEW.zoom;
			} else{
				this.ZOOM = z;
				this.ORIGIN = o;
				this.VIEW = v;
			}
		}
		
		public function addLayer(ml:MapLayer):void
		{
			addChild(ml);
			this._layers.push(ml);
			if(ml is AnnotationLayer){
				ml.moveTo(this._ORIGIN.x, this._ORIGIN.y);
			}
		}
		
		public function addLayerAt(ml:MapLayer, idx:int):void
		{
			//if (idx<0){
			//	idx = _layers.length + idx + 1;
			//}
			addChildAt(ml, idx + 1);  //"idx + 1" is because Map has one extra child, mask, before all MapLayers (and possibly one child after, frame)
			this._layers.splice(idx, 0, ml);
			if(ml is AnnotationLayer){
				ml.moveTo(this._ORIGIN.x, this._ORIGIN.y);
			}
			/*if (_view){
				l.load(_view);
				invalidateDisplayList();
				
				this._viewChanged = true;
				this._viewOriginChanged = true;
				invalidateProperties();
			}
			if (addBackground){
				ZoomifyLayer(l).addBackground();
			}*/
		}
		
		public function getLayerAt(idx:int):MapLayer
		{
			return this._layers[idx];
		}
		
		public function removeLayer(l:MapLayer):MapLayer
		{
			removeChild(l);
			var idx:int = this._layers.indexOf(l);
			this._layers.splice(idx,1);
			return l;
		}
		
		public function removeLayerAt(idx:int):MapLayer
		{
			var l:MapLayer = this.getLayerAt(idx);
			removeChild(l);
			this._layers.splice(idx,1);
			return l;
		}
		
		protected function setLayerZoom(z:Number):void
		{
			for each (var l:MapLayer in this._layers){
				l.zoomTo(z);
			}
		}
		
		protected function setLayerOrigin(x0:Number,y0:Number):void
		{
			for each (var l:MapLayer in this._layers){
				l.moveTo(x0, y0);
			}
		}
		
		protected function setLayerView(v:ZoomRect):void
		{
			//for each (var l:MapLayer in this._layers){
			for each (var l:MapLayer in this._layers){
				l.load(v);
			}
		}
		
		//implements drag pan
		public function onMouseDown(e:MouseEvent):void
		{
			if(e.shiftKey || e.target is Annotation || e.target is TextField){
				return;
			}
			
			this._changeInitiator = true;
			
			//this._deltaX = this._viewOrigin.x - mouseX;
			//this._deltaY = this._viewOrigin.y - mouseY;
			this._deltaX = this._ORIGIN.x - mouseX;
			this._deltaY = this._ORIGIN.y - mouseY;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			if(this.clickZoomEnable){
				addEventListener(MouseEvent.CLICK, this.onMouseClick);
			}
			//addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		
			trace("mousedown--------------------------------------");
		}
		
		public function onMouseMove(e:MouseEvent):void
		{
			this._changeInitiator = true;
			
			if(this.clickZoomEnable){
				removeEventListener(MouseEvent.CLICK, this.onMouseClick);
			}
			
			this.ORIGIN = new Point(this._deltaX + mouseX, this._deltaY + mouseY);
			
			e.updateAfterEvent();  //this is important, since it makes "the drag" look smoother
		}
		
		public function onMouseUp(e:MouseEvent):void
		{
			trace("mouseup-----------------------------------------");
			// consolidate view
			//var x0:Number = -this._viewOrigin.x; // this is new view left
			//var y0:Number = -this._viewOrigin.y; // this is new view top
			//var v:ZoomRect = new ZoomRect(this._curZoom, x0, y0, x0 + this.width, y0 + this.height);
			//this.view = v;
			
			this._changeInitiator = true;
			
			var x0:Number = -this._ORIGIN.x; // this is new view left
			var y0:Number = -this._ORIGIN.y; // this is new view top
			this.VIEW = new ZoomRect(this._ZOOM, x0, y0, x0 + width, y0 + height);
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			//removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		
		public function onMouseClick(e:MouseEvent):void
		{
			this._changeInitiator = true;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			
			var layer:MapLayer = this._layers[0] as MapLayer;
			var c:ZoomXY = new ZoomXY(this._ZOOM, layer.mouseX, layer.mouseY);
			var z:Number;
			
			var atm:Matrix;
			var c1:Point;
			var td:ZoomXY;
			
			if(e.ctrlKey == false){
				z = Math.floor(this._ZOOM) + 1;
				if(z > layer.ZL.mapSource.bound.zoom){
					this._changeInitiator = false;
					removeEventListener(MouseEvent.CLICK, this.onMouseClick);
					return;
				}
				c.zoomTo(z);
				this.ZOOM = z;
				
				if(layer.affineTM){
					atm = layer.affineTM.clone();
					td = layer.originDelta.clone().zoomTo(z)
					atm.tx = atm.tx + td.x;
					atm.ty = atm.ty + td.y;
					//atm.invert();
					c1 = atm.transformPoint(new Point(c.x, c.y));
					c = new ZoomXY(c.zoom, c1.x, c1.y);
				}
				
				this.ORIGIN = new Point(width / 2 - c.x, height / 2 - c.y);
				this.VIEW = new ZoomRect(z, c.x - width / 2, c.y - height / 2, c.x + width / 2, c.y + height / 2);
			} else{
				z = Math.ceil(this._ZOOM) - 1;
				if(z < 0){
					this._changeInitiator = false;
					removeEventListener(MouseEvent.CLICK, this.onMouseClick);
					return;
				}
				c.zoomTo(z);
				this.ZOOM = z;
				
				if(layer.affineTM){
					atm = layer.affineTM.clone();
					td = layer.originDelta.clone().zoomTo(z)
					atm.tx = atm.tx + td.x;
					atm.ty = atm.ty + td.y;
					//atm.invert();
					c1 = atm.transformPoint(new Point(c.x, c.y));
					c = new ZoomXY(c.zoom, c1.x, c1.y);
				}
				
				this.ORIGIN = new Point(mouseX - c.x, mouseY - c.y);
				this.VIEW = new ZoomRect(z, c.x - mouseX, c.y - mouseY, c.x - mouseX + width, c.y - mouseY + height);
			}
			
			removeEventListener(MouseEvent.CLICK, this.onMouseClick);
		}
		
		/*public function onNaviWinMove(e:PropertyChangeEvent):void
		{
			//var x0:Number = (e.property.x - 20) * Math.pow(2, this._curZoom);  //position of the thumbnail in the navigator is always (20, 20)
			//var y0:Number = (e.property.y - 20) * Math.pow(2, this._curZoom);
			//this.viewOrigin = new ZoomXY(this._curZoom, -x0, -y0);
			//this._viewOriginChanged = true;
			//invalidateProperties();
		}
		
		public function onNaviWinStop(e:Event):void
		{
			//this.view = new ZoomRect(this._curZoom, -this._viewOrigin.x, -this._viewOrigin.y, -this._viewOrigin.x + this.width, -this._viewOrigin.y + this.height);
			//this._viewChanged = true;
			//invalidateProperties();
		}
		
		
		
		public function mouseDownOnSlider(e:MouseEvent):void
		{
			e.stopPropagation();
		}
		
		public function onThumbChange(e:SliderEvent):void
		{
			//var w:Number = width / 2;
			//var h:Number = height / 2;
			//var newCenter:ZoomXY = this.centerAfterZoom(e.value);
			//this.view = new ZoomRect(e.value, newCenter.x - w, newCenter.y - h, newCenter.x + w, newCenter.y + h);
		}
		
		public function onThumbDrag(e:SliderEvent):void
		{
			//var v:Number = e.value;
			//if(v == this._curZoom ){
			//	return
			//}
			//this.centerAfterZoom(v);
			//setLayerZoom(v);
			//invalidateProperties();
		}
		
		public function onThumbRelease(e:SliderEvent):void
		{
			//this.view = new ZoomRect(this._curZoom, -this._viewOrigin.x, -this._viewOrigin.y, -this._viewOrigin.x + this.width, -this._viewOrigin.y + this.height);
			//this._viewChanged = true;
			//invalidateProperties();
		}*/
		
		public function resetInitView(iv:ZoomRect):void
		{
			//using this way is because when this method is being called for the first time
			//"this.width" and "this.height" might be 0, which will lead to wrong values of "this.viewOrigin" and "this.view"
			//var w:Number = parent.width * percentWidth / 100;
			//var h:Number = parent.height * percentHeight / 100;
			
			var w:Number = width;
			var h:Number = height;
			
			var o:ZoomXY = new ZoomXY(iv.zoom, (w - iv.width) / 2 - iv.x0, (h - iv.height) / 2 - iv.y0);
			var v:ZoomRect = new ZoomRect(o.zoom, -o.x, -o.y, -o.x + w, -o.y + h);
			//this.viewOrigin = o;
			//this.view = v;
		}
		
		/*public function onSourceReady(e:Event):void
		{
			//var curLayer:MapLayer = MapLayer(e.target);
			//var p:Panel = Panel(this.parent);
			this._imageLayer = ZoomifyLayer(e.target);
			this.bound = this._imageLayer.mapSource.bound;
			
			if(this._initView){
				var rl:RectLayer = new RectLayer(this._initView);
				this.resetInitView();
				this.addLayerAt(rl, 1, false);
			} else{
				var fit:ZoomRect = this._imageLayer.fitView(width, height);
				this.view = fit;
				this.viewOrigin = this.centeredViewOrigin();
			}
			this.addLayerAt(this._imageLayer, 0);
			
			if(this._mainMap){
				var f:Event = new Event("main_map_ready");
				dispatchEvent(f);
			}
		}*/
		
		protected function fitInView():ZoomRect
		{
			var fv:ZoomRect = ZoomifyLayer(this._layers[0].ZL).fitView(width, height);
			return fv;
		}
		
		protected function fitInOrigin():Point
		{
			var fo:Point = new Point((width - this._VIEW.width)/2 - this._VIEW.x0, (height - this._VIEW.height)/2 - this._VIEW.y0);
			return fo;
		}
		
		public function mute():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
		}
		
		public function enable():void
		{
			addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
		}
		
		public function focus():void
		{
			addChild(this._frame);
			this.drawFrame();
		}
		
		public function deFocus():void
		{
			removeChild(this._frame);
		}
		
		protected function drawFrame(dummy:Number=0):void
		{
			if(this._frame.parent){
				with(this._frame.graphics){
					clear();
					lineStyle(3, 0x4B999A);
					drawRect(1, 1, width - 3, height - 3);
				}
			}
		}
		
		/*public function calculateView(zl:ZoomifyLayer):void
		{
			var fit:ZoomRect = zl.fitView(width, height);
			this.view = fit;
			this.viewOrigin = this.centeredViewOrigin();
		}
		
		public function centeredViewOrigin():ZoomXY
		{
			if (_view){
				var p:ZoomXY = new ZoomXY(this._curZoom, (width - _view.width)/2 - _view.x0, (height - _view.height)/2 - _view.y0);
				return p;
			}
			return new ZoomXY();
		}
		
		//the center of the view stay unchanged, but due to the change in map's size,
		//view can be bigger/smaller, and viewOrigin changes as well
		public function afterMapSizeChange(nw:Number, nh:Number):void
		{
			var center:Point = new Point(width / 2 - this._viewOrigin.x, height / 2 - this._viewOrigin.y);
			this.viewOrigin = new ZoomXY(this._curZoom, nw / 2 - center.x, nh / 2 - center.y);
			this.view = new ZoomRect(this._curZoom, center.x - nw / 2, center.y - nh / 2, center.x + nw / 2, center.y + nh / 2);
		}
		
		protected function centerAfterZoom(newCurZoom:Number):ZoomXY
		{
			var w:Number = width / 2;
			var h:Number = height / 2;
			var center:ZoomXY = new ZoomXY(this._curZoom, w - this._viewOrigin.x, h - this._viewOrigin.y);
			center.zoomTo(newCurZoom);
			this.curZoom = newCurZoom;
			this.viewOrigin = new ZoomXY(this._curZoom, w - center.x, h - center.y);
			return center;
		}*/
	}
}
		
		/*
		protected function centerAfterZoom(dst:Number,src:Number):ZoomXY
		{
			var w:Number = this.width / 2;
			var h:Number = this.height / 2;
			// find display center in view coordinate
			var c:ZoomXY = new ZoomXY(src, w - this._viewOrigin.x, h - this._viewOrigin.y);
			c.zoomTo(dst);
			// match c (center) to diplay center
			this.curZoom = dst;
			this.viewOrigin = new Point(w - c.x, h - c.y);
			this.bindableViewOrigin = this.viewOrigin;  //this will trigger the binding method in navigator to run
			return c;
		}
		
		// zoomDrag, calcZoomRect, zoomChange handle slider zooming
		public function zoomDrag(e:SliderEvent):void
		{
			var v:Number = e.value;
			if ( v == curZoom ){
				return
			}
			setLayerZoom(v);
			centerAfterZoom(v, curZoom);
			curZoom = v;
			invalidateProperties();
		}
		
		public function zoomChange(e:SliderEvent):void
		{
			var c:ZoomXY = this.centerAfterZoom(Number(e.value),this.curZoom);
			// find new view rect
			var w:Number = this.width / 2;
			var h:Number = this.height / 2;
			this.view = new ZoomRect(c.zoom, c.x-w, c.y-h, c.x+w, c.y+h);
		}
		*/
		
		
		/*
		public function resetLocation(n:Number):void
		{
			this.navigator.x = x + width - this.navigator.width - 4;
			this.navigator.y = y + 4;
			this.zoomSlider.x = x + width - this.zoomSlider.width - 4;
			this.zoomSlider.y = y + this.navigator.height + 20;
		}
		*/
		
	/*
	public function onDragEnter(e:DragEvent):void
	{	
		if (e.dragSource.hasFormat("Annotation_Std"))
		{
			DragManager.acceptDragDrop(Map(e.currentTarget));
		}
		this.newAnnotation = true;
	}
	
	public function onDragOver(e:DragEvent):void
	{
		if (e.dragSource.hasFormat("Annotation_Std")){
			if (this.newAnnotation){                    
				DragManager.showFeedback(DragManager.COPY);
				this.newAnnotation = false;
				return;
			}
			else{
				DragManager.showFeedback(DragManager.MOVE);
				return;
			}
		}
		DragManager.showFeedback(DragManager.NONE);
	}

	public function onDragDrop(e:DragEvent):void
	{
		if (e.dragSource.hasFormat("Annotation_Std")) {
			var oldA:Annotation_Std = e.dragSource.dataForFormat("Annotation_Std") as Annotation_Std;
			var des:Map = e.currentTarget as Map;
              
			var newA:Annotation_Std = new Annotation_Std();
			newA.locateAt(this.curZoom, des.mouseX, des.mouseY)
			des.addChild(newA);
		}
	}
	*/
