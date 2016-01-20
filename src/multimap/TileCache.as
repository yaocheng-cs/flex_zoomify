package com.repilac.multimap
{
	public class TileCache
	{
		public var tiles:Object; // id-> tiles
		protected var ids:Array; // array of ids to keep track of orders
		protected var cacheSize:int;
		
		public function TileCache(){
			super();
			
			this.cacheSize = 128;
			this.ids = new Array();
			this.tiles = new Object();
		}
		
		public function exists(tid:String):Boolean{
			//trace("Cache query:"+tid+" Cache size:"+this.ids.length);
			return tiles.hasOwnProperty(tid);
		}
		
		public function getTile(tid:String):Tile{
			//trace("Cache hit:"+tid);
			return tiles[tid];
		}
		
		public function append(t0:Tile):void{
			trace("tileCache.append:"+t0.id+", cacheSize:"+ids.length)
			if (ids.length +1 > cacheSize){// remove the first one which is not active
				var t:Tile;
				for (var i:int = 0;i<ids.length; i++){
					t = tiles[ids[i]];
					if (! t.active ){
						trace("Cache removing:"+i);
						ids.splice(i,1);
						remove(t);
						break
					}
				}
			}
			ids.push(t0.id);
			tiles[t0.id] = t0;
		}
		
		public function remove(t:Tile):void{
			if ( t.parent ){
				t.parent.removeChild(t);
			}
			delete tiles[t.id];
			trace("TileCache.remove:"+t.id+", cacheSize:"+ids.length);			
		}
		
		public function clear():void{
			for each (var t:Tile in this.tiles){
				remove(t);
			}
			ids = new Array();
			tiles = new Object();
		}
		
		public function deactivate():void{
			for each (var t:Tile in this.tiles){
				t.active = false;
			}
		}
		

	}
}