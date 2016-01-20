package com.repilac.multimap
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.*;
	
	[Event(name="init_success", type="flash.events.Event")]
	[Event(name="init_error", type="flas.events.Event")]

	public class MapLayer extends Sprite
	{
		public var affineTM:Matrix;
		public var originDelta:ZoomXY;
		public var userAlpha:Number;
		
		public var AL:AnnotationLayer;
		public var ZL:ZoomifyLayer;
		public var URL:String;
		
		public function MapLayer(url:String)
		{
			super();
			
			this.URL = url;
			this.ZL = new ZoomifyLayer(this.URL);
			if(this.URL.search("ARA") > -1){
				this.AL = new ROILayer(this.URL);
			} else{
				this.AL = new AnnotationLayer(this.URL);
			}
			
			//We assume the initilization of the corresbonding annotation layer will 
			//be successfull if the initiliaztion of the zoomify layer is successful
			this.ZL.addEventListener("init_success", this.onZoomifyLayerInit);
			this.ZL.addEventListener("init_error", this.onZoomifyLayerInitError);
		}
		
		public function onZoomifyLayerInit(e:Event):void
		{
			addChild(this.ZL);
			addChild(this.AL);
			this.AL.mute();
			dispatchEvent(e);
		}
		
		public function onZoomifyLayerInitError(e:Event):void
		{
			dispatchEvent(e);
		}
		
		public function zoomTo(z:Number):void
		{
			if(this.originDelta){
				this.originDelta.zoomTo(z);
			}
			this.ZL.zoomTo(z);
			this.AL.zoomTo(z);
		}
		
		public function moveTo(x0:Number, y0:Number):void
		{
			if(this.originDelta){
				x = x0 + this.originDelta.x;
				y = y0 + this.originDelta.y;
			} else{
				x = x0;
				y = y0;
			}
		}
		
		public function load(v:ZoomRect):void
		{
			var v1:ZoomRect = v.clone(); //don't mass up the original "VIEW"
			if(this.affineTM){
				var inverseATM:Matrix = this.affineTM.clone();
				inverseATM.tx = inverseATM.tx + this.originDelta.x;
				inverseATM.ty = inverseATM.ty + this.originDelta.y;
				inverseATM.invert();
				var vertices:Array = new Array();
				vertices.push(inverseATM.transformPoint(new Point(v.x0, v.y0)));
				vertices.push(inverseATM.transformPoint(new Point(v.x1, v.y0)));
				vertices.push(inverseATM.transformPoint(new Point(v.x0, v.y1)));
				vertices.push(inverseATM.transformPoint(new Point(v.x1, v.y1)));
				var x0:Number = Number.MAX_VALUE;
				var x1:Number = Number.MIN_VALUE;
				var y0:Number = Number.MAX_VALUE;
				var y1:Number = Number.MIN_VALUE;
				for each (var p:Point in vertices){
					if(p.x < x0){
						x0 = p.x;
					}
					if(p.x > x1){
						x1 = p.x;
					}
					if(p.y < y0){
						y0 = p.y;
					}
					if(p.y > y1){
						y1 = p.y;
					}
				}
				v1.x0 = x0;
				v1.x1 = x1;
				v1.y0 = y0;
				v1.y1 = y1;
			}
			this.ZL.load(v1);
			this.AL.load();
		}
	}
}
		//var _tiers:Array;
		//protected var _pendingView:ZoomRect = null;
		//protected var _background:Boolean = false;
		// this is current view where tiles are loaded 
		//protected var _view:ZoomRect;
		
		
		// cache for tiles for entire (minus background) pyramid of tiers 
		//var _tileCache:TileCache;
		
		/*//mapSource is where the Tile Data is provided
		protected var _mapSource:IMapSource;
		protected var _mapSourceReady:Boolean = false;
		public function get mapSource():IMapSource
		{
			return _mapSource;
		}
		public function set mapSource(s:IMapSource):void
		{
			_mapSourceReady = false;
			_mapSource = s;
			_mapSource.addEventListener("init_success", onMapSourceInit);
			_mapSource.addEventListener("init_error", onMapSourceInitError);
		}*/
			
		
		/*public function MapLayer(cacheSize:int=128)
		{
			super();
			_tileCache = new TileCache(cacheSize);
		}*/
		
		/*public function onMapSourceInit(e:Event):void
		{
			_mapSourceReady = true;
			tiers = new Array(this._mapSource.bound.zoom + 2); // one more tier for background
			if ( _pendingView ){
				load(_pendingView);
				_pendingView = null;
			}
			dispatchEvent(e);
		}
		
		public function onMapSourceInitError(e:Event):void
		{
			Alert.show("map source initialization failed");
			dispatchEvent(e);
		}*/
		
		/*public function addBackground():void
		{
			_background = true;
			loadBackground();
		}
		
		protected function loadBackground():void
		{
			var b:Tier = new Tier(Math.ceil(_view.zoom), _mapSource);  //background doesn't use the layer tile cache
			b.moveTo(0, 0);//b.moveTo(-1,-1);shift the background to "cover" the white lines which might be caused by scaling tiles
			b.zoomTo(_view.zoom); // maybe no need of this, since when loading a view, it scales every tier in "tiers", including the background, to the right level
			_tiers[_mapSource.bound.zoom + 1] = b; // store the background in the highest index of "tiers array"
			addChildAt(b, 0); // put background at bottom
			trace("MapLayer.loadBackground");
			b.loadTiles(_view);
		}*/
		
		/*public function fitView(w:int, h:int):ZoomRect
		{
			// fit everything (bottomWidth, bottomHeight) into
			// current display
			var b:ZoomRect = _mapSource.bound;
			var xscale:Number = b.width / w;
			var yscale:Number = b.height / h;
			var logscale:Number = Math.log(Math.max(xscale, yscale)) / Math.log(2);
			var zoom:Number = b.zoom - logscale;
			return b.copy().zoomTo(zoom);
		}*/
		
		/*public function moveTo(x0:Number, y0:Number):void
		{
			this.x = x0;
			this.y = y0;
			//trace("MapLayer.moveTo:"+x+","+y);
		}

		public function zoomTo(z:Number):void
		{
			for each (var t:Tier in _tiers){
				if (t){
					t.zoomTo(z);
				}
			}
		}*/

		/*public function load(v:ZoomRect):void
		{
			// check bounds on zoom level
			if (!_mapSourceReady){
				_pendingView = v;
			}else{
				v.boundWith(_mapSource.bound);
				// set the origin of the view and update
				if (! v.equalTo(_view) ){	
					_view = v;
					loadView()
				}
			}
		}
		
		protected function loadView():void
		{
			var t:Tier;
			var tier:int = Math.ceil(_view.zoom);
			if (tiers[tier]){
				t = tiers[tier];
			}else{
				t = new Tier(tier, _mapSource, _tileCache);
				t.moveTo(0,0);
				tiers[tier] = t;
			}
			zoomTo(_view.zoom);  //scale everything to the right level, including the background
			t.name = "tier:"+t.tier;
			addChild(t);  //put current tier at the top
			t.loadTiles(_view);
			//trace("this should be top:"+t.name);
			//trace("MapLayer.numChildren:"+numChildren);
			//trace("current top layer:"+this.getChildAt(0).name);
			//trace("this may be top:"+this.getChildAt(this.numChildren-1).name);
			
			var i:int;
			if(this.publicFlag != this.protectedFlag){
				if(this.publicFlag){
					for(i=0; i<numChildren; i++){
						getChildAt(i).visible = true;
						this.protectedFlag = this.publicFlag;
					}
				} else{
					for(i=0; i<numChildren-1; i++){
						getChildAt(i).visible = false;
						this.protectedFlag = this.publicFlag;
					}
				}
			} else{
				if(!this.publicFlag){
					getChildAt(numChildren-1).visible = true;
					getChildAt(numChildren-2).visible = false;
				}
			}
		}*/