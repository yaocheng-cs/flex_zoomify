
 
 
package com.repilac.multimap
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	/**
	 * MultiResolutionMap shows map (or tiled images) which consists of 
	 * multiple level of resolution (such as Zoomify images or Google maps).
	 * 
	 * <p>Those multi resolution images form a pyramid with multiple  
	 * zoom or tier levels (resolution levels). Tier 0 will be the highest
	 * resolution level (usually the original image in Zoomify). As tier is 
	 * increased by1 the resolution (or scale) will be decreased by 1/2. </p>
	 * 
	 * <p>Tier will always be integer (>=0). Zoom is similar to tier but 
	 * allows non-integer value. This represents arbitrary horizontal plane of
	 * the multiresolution pyramid. </p>
	 * 
	 * <p>Each plane of the pyramid consists of tiles of images. Each tile is 
	 * usually 256x256 pixels in size.</p>
	 * 
	 */
	public class StaticZoomifyImage extends UIComponent
	{
		
		protected var _imageURL:String;
		protected var _mapSource:IMapSource;		
		protected var mapSourceReady:Boolean = false;
		protected var pendingView:ZoomRect = null;
		protected var fitViewFlag:Boolean = false;
		
		//protected var cTileGrid:TileGrid = null;
			
		protected var tierSprite:Tier;
		
		protected var _mask:Sprite;
		protected var _view:ZoomRect;
		protected var viewChanged:Boolean = false;
		protected var tileCache:TileCache;
		
		
		public function StaticZoomifyImage(path:String = null, v:ZoomRect = null)
		{			
			super();
			//cTileGrid = new TileGrid();
			//buildMask();
			_mask = new Sprite();
			this.addChild(_mask);
			this.mask = _mask;
			this.mask.x = 0;
			this.mask.y = 0;
			if (path){
				this.imageURL = path;
			}
			trace("mask"+this.width+","+this.height);
			if ( v != null){
				this.view = v;
			}else{
				this.fitViewFlag = true;
			}
			this.tileCache = new TileCache(128);
		}
		/**
		 * mapSource is where the Tile Data is provided
		 */
		public function set mapSource(s:IMapSource):void
		{
			mapSourceReady = false;
			_mapSource = s;
			s.addEventListener("init_success", onMapSourceInit);
			s.addEventListener("init_error", onMapSourceInitError);
		}
		public function get mapSource():IMapSource
		{
			return _mapSource;
		}
		public function set imageURL(path:String):void{
			this._imageURL = path;
			this.mapSource = new ZoomifySource(path);
		}
		public function get imageURL():String{
			return this._imageURL;
		}
		
		
		public function onMapSourceInit(e:Event):void
		{
			mapSourceReady = true;
			if ( pendingView ){
				this.view = pendingView;
				return;
			}
			if ( fitViewFlag ){
				this.fitView();
				return;
			}
			
		}		
		public function onMapSourceInitError(e:Event):void
		{
			Alert.show("map source initialization failed");	
		}

		public function fitView():void
		{
			// fit everything (bottomWidth, bottomHeight) into
			// current display
			var b:ZoomRect = _mapSource.bound;
			
			var xscale:Number = b.width/this.width;
			var yscale:Number = b.height/this.height;
			var logscale:Number = Math.log(Math.max(xscale, yscale))/Math.log(2);
			var zoom:Number = b.zoom - logscale;
			view = b.copy().zoomTo(zoom);
			trace("fitView:"+view);
		}
		
		/** 
		 * "view" specifies zoom level and view rect in that zoom plane
		 * in pixel. "view" is purely in the abstract pyramid space.
		 *  (i.e. view and display is independent. However, "view" size and display
		 * size (width and height) usually matches.
		 */
		public function set view(v:ZoomRect):void
		{
			// check bounds on zoom level
			if (! this.mapSourceReady){
				pendingView = v;
			}else{
				v.boundWith(_mapSource.bound);
				// set the origin of the view and update
				if (! v.equalTo(_view) ){	
					_view = v;
					viewChanged = true;
					this.invalidateProperties();
				}
			}
		}
		/**
		 * @private
		 */ 
		public function get view():ZoomRect
		{
			return _view;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties()
			if (viewChanged && mapSourceReady){
				viewChanged = false;
				updateView();
			}
		}

		protected function unloadPrevious():void{
 			if (! this.tierSprite) return;
 			this.removeChild(this.tierSprite);
 			this.tierSprite.unload(); 
 			this.tierSprite = null;
 		}		
		protected function updateView():void
		{
			trace("MultiResolutionMap.updateView");
			if (! this.mapSourceReady ) return;
			// clean up previous tiles
			unloadPrevious();
			// create a new tier and load tiles
			this.tierSprite = new Tier(Math.ceil(_view.zoom), _mapSource, this.tileCache);
			this.tierSprite.zoomTo(_view.zoom);
			this.addChild(this.tierSprite);
			this.tierSprite.loadTiles(_view)
			//this.tierSprite.alpha = 0.5
			// tell Flex to update the view
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			// draw mask
			with (_mask.graphics)
			{
				clear();
				lineStyle(1,0x000000);
				beginFill(0x000000);
				drawRect(0,0,this.width,this.height);
				trace("mask"+this.width+","+this.height);
				endFill();
			}

			// draw frame for debugging purpose
			this.graphics.clear();
			this.graphics.lineStyle(2,0x0000FF);
			this.graphics.drawRect(0,0,this.width,this.height);

			if (this.tierSprite)
			{
				// center the TileGrid
				this.tierSprite.moveTo(((this.width - _view.width)/2) - _view.x0,
									   ((this.height - _view.height)/2) - _view.y0);
			}
		}
		
	}
}