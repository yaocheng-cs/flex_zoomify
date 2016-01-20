package com.repilac.multimap
{
	import flash.display.Sprite;

	/** 
	 * This class deals with the logic of the geometry of the muti-resolution
	 * image pyramid. 
	 * 
	 * <p>Tiles only exists at integer zoom. When specified a point (top-left) 
	 * and width&height in the pyramid, this class finds nearby integer plane
	 * and finds necessary tiles, then it scales itself to match the required
	 * zoom level.</p>
	 * 
	 */
	public class Tier extends Sprite
	{
		public var level:int;
		//public var tileSize:int;
		//protected var scale:Number;
		//protected var loadedTiles:Object; // associative array
		//protected var mapSource:IMapSource;
		protected var _tileCache:TileCache;
		public function get tileCache():TileCache
		{
			return this._tileCache;
		}
		
		public function Tier(t:int, tc:TileCache=null)
		{
			super();
			x = 0;
			y = 0;
			
			this.level = t;
			//this.mapSource = ms;
			//this.tileSize = ms.tileSize;
			//this.loadedTiles = new Array();
			if(tileCache){
				this._tileCache = tc;
			} else{  // happens when this tier is the background tier, which uses a independant tiles cache
				this._tileCache = new TileCache();
			}
		}
		
		public function zoomTo(zoom:Number):void
		{
			//this.scale = Math.pow(2, zoom - tier);
			var scale:Number = 0;
			var temp:Number = Math.pow(2, zoom - this.level);
			for(var i:int=-1; i>=-8; i--){
				while(temp >= Math.pow(2, i)){
					temp = temp - Math.pow(2, i);
					scale = scale + Math.pow(2, i); 
				}
			}
			if(temp >= Math.pow(2, -9)){
				scale = scale + Math.pow(2, -8);
			}
			scaleX = scale;
			scaleY = scale;
		}
		
		public function moveTo(x0:Number, y0:Number):void
		{
			x = x0;
			y = y0;
		}
		
		public function unload():void
		{
			/*var t:Tile;
			for each (t in this.loadedTiles)
			{
				this.mapSource.unloadTile(t);
			} */
			for (var i:int=0; i<this.numChildren; i++){
				this.removeChildAt(i);  // Tier only has Tiles as children
			}
		}
		
	}
}
		
		/*public function loadTiles(view:ZoomRect):void
		{
			var tierView:ZoomRect = view.copy().zoomTo(this.tier);
			// calc tiles
			var startCol:int = Math.floor(tierView.x0/this.tileSize);
			var startRow:int = Math.floor(tierView.y0/this.tileSize);
			var endCol:int = Math.floor((tierView.x1)/this.tileSize);
			var endRow:int = Math.floor((tierView.y1)/this.tileSize);

			var t:Tile;
			
			// deactivate loaded tiles
			this.tileCache.deactivate();
			
			// load tiles
			for(var col:int = startCol; col<=endCol; col++)
			{
				for(var row:int = startRow; row<=endRow; row++)
				{
					t = new Tile(this.tier, col, row, col*this.tileSize, row*this.tileSize);
					if (this.tileCache.exists(t.id)){
						t = this.tileCache.getTile(t.id); 
						t.active = true;
					}else{
						this.mapSource.loadTile(t);
						this.tileCache.append(t);
					}
					this.addChild(t);
				}
			}
			// cancel non-active pending loading
			for each (t in this.tileCache.tiles)
			{
				if (! t.active ){ // not currently viewable
					if (this.mapSource.cancelPendingTile(t)){ // try to cancel loading if it's still pending
						this.tileCache.remove(t);
					}
				}
			}
		}*/
		
