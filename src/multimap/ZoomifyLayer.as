package com.repilac.multimap
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class ZoomifyLayer extends Sprite
	{	
		public var mapSourceReady:Boolean;
		protected var _mapSource:IMapSource;
		public function get mapSource():IMapSource
		{
			return _mapSource;
		}
		public function set mapSource(s:IMapSource):void
		{
			this.mapSourceReady = false;
			this._mapSource = s;
		}
		
		protected var _imageURL:String;
		protected var _tiers:Array;
		protected var _view:ZoomRect;
		protected var _pendingView:ZoomRect;
		protected var _background:Tier;
		protected var _tileCache:TileCache;
		/**
		 * following are two flags helping to decide whether this layer is the "bottom" layer of a map
		 * if yes, this layer should allow all its tiers to be visiable
		 * if no (when there are other layers under this layer in the same map), it should allow only the top tier to be visiable
		 */ 
		protected var _internalFlag:Boolean;
		public var externalFlag:Boolean;
		
		public function get imageURL():String
		{
			return this._imageURL;
		}
		public function set imageURL(path:String):void
		{
			this._imageURL = path;
			mapSource = new ZoomifySource(path);
			mapSource.addEventListener("init_success", this.onMapSourceInit);
			mapSource.addEventListener("init_error", this.onMapSourceInitError);
		}
		
				
		public function ZoomifyLayer(path:String = null)
		{
			super();
			
			this._tileCache = new TileCache();
			
			this._internalFlag = true;
			this.externalFlag = true;
			
			if(path){
				this.imageURL = path;
			}
			
			/*for debug purpose
			with (graphics){
				clear();
				lineStyle(3, 0xFF0000);
				moveTo(0, 0);
				lineTo(2000, 0);
				moveTo(0, 0);
				lineTo(0, 2000);
				lineStyle(1, 0xFF0000);
				var j:int = 1;
				while(100 * j < width){
					moveTo(100 * j, 0);
					lineTo(100 * j, height);
					j++;
				}
				j = 1;
				while(100 * j < height){
					moveTo(0, 100 * j);
					lineTo(width, 100 * j);
					j++;
				}
			}*/
		}
		
		public function onMapSourceInit(e:Event):void
		{
			mapSourceReady = true;
			this._tiers = new Array(mapSource.bound.zoom + 1 + 1);  //tier starts from "tier 0", and one more tier for background
			if(this._pendingView){
				load(this._pendingView);
				this._pendingView = null;
			}
			dispatchEvent(e);
		}
		
		public function onMapSourceInitError(e:Event):void
		{
			trace("ZoomifyLayer: map source initialization failed");
			dispatchEvent(e);
		}
		
		public function fitView(w:Number, h:Number):ZoomRect
		{
			//fit everything (bottomWidth, bottomHeight) into current Map
			var b:ZoomRect = mapSource.bound.clone();
			var xscale:Number = b.width / w;
			var yscale:Number = b.height / h;
			var logscale:Number = Math.log(Math.max(xscale, yscale)) / Math.log(2);
			var zoom:Number = b.zoom - logscale;
			return b.zoomTo(zoom);
		}
		
		public function addBackground():void
		{
			if(this._background){
				return;
			}
			var bgv:ZoomRect = this.fitView(parent.width, parent.height);
			this._background = new Tier(Math.ceil(bgv.zoom));  // background doesn't use the layer tile cache
			this._tiers[mapSource.bound.zoom + 1] = this._background;  //store the background in the highest index of "tiers array"
			addChildAt(this._background, 0);  //put background at bottom
			trace("ZoomifyLayer.loadBackground");
			if(!mapSourceReady){
				trace("Map source is not ready!");
			} else{
				mapSource.loadTiles(this._background, bgv);
			}
		}
		
		public function zoomTo(z:Number):void
		{
			//super.zoomTo(z);
			
			for each (var t:Tier in this._tiers){
				if(t){
					t.zoomTo(z);
				}
			}
		}
		
		public function load(v:ZoomRect):void
		{
			v = v.clone();  //use a copy of the VIEW, so the following code won't mess up the original VIEW
			//super.load(v);
			
			// check bounds on zoom level
			if(!mapSourceReady){
				_pendingView = v;
			}else{
				if(!this._background){
					this.addBackground();
				}
				v.boundWith(mapSource.bound);	
				this._view = v;
				loadView();
			}
		}
		
		protected function loadView():void
		{
			var t:Tier;
			var level:Number = Math.ceil(this._view.zoom);
			var load_level:Number;
			var load_view:ZoomRect;
			if(level > mapSource.bound.zoom){
				load_level = mapSource.bound.zoom;
				load_view = this._view.clone().zoomTo(load_level);
			} else{
				load_level = level;
				load_view = this._view;
			}
			if(this._tiers[load_level]){
				t = this._tiers[load_level];
			} else{
				t = new Tier(load_level, _tileCache);
				this._tiers[load_level] = t;
			}
			this.zoomTo(this._view.zoom);  //scale everything to the right level, including the background
			t.name = "tier:" + t.level;
			addChild(t);  //put current tier at the top
			mapSource.loadTiles(t, load_view);
			
			var i:int;
			if(this.externalFlag != this._internalFlag){
				if(this.externalFlag){
					for(i=0; i<numChildren; i++){
						getChildAt(i).visible = true;  //ZoomifyLayer(MapLayer) only has Tiers as children
						this._internalFlag = this.externalFlag;
					}
				} else{
					for(i=0; i<numChildren-1; i++){
						getChildAt(i).visible = false;
						this._internalFlag = this.externalFlag;
					}
				}
			} else{
				if(!this.externalFlag){
					getChildAt(numChildren-1).visible = true;
					getChildAt(numChildren-2).visible = false;
				}
			}
		}
	}
}