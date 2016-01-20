package com.repilac.multimap
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	
	[Event(name="init_success", type="flash.events.Event")]
	[Event(name="init_error", type="flas.events.Event")]
	
	/**
	 * ZoomifySource implements IMapSource. It takes care of retrieving image tile
	 * from a server providing multi-resolution tiled image in Zoomify format.
	 */
	public class ZoomifySource extends EventDispatcher implements IMapSource
	{
		/** 
		 * imageWidth is the width of the image (in pixel) at the bottom of the pyramid
		 * of multiresolution images, i.e. the highest resolution image.
		 */
		public function get imageWidth():Number
		{
			return _imageWidth;
		}
		protected var _imageWidth:Number = 0;
		/**
		 * imageHeight is the height of the image (in pixel) at heighest resolution of the
		 * image.
		 */
		public function get imageHeight():Number
		{
			return _imageHeight;
		}
		protected var _imageHeight:Number = 0;
		/**
		 * tileSize is the width, height of one tile in pixel
		 */
		public function get tileSize():int{
			return _tileSize
		}
		protected var _tileSize:int = 256;
		
		/**
		 * Returns pyramid bound (max tier, bottomWidth, bottomHeight)
		 */
		public function get bound():ZoomRect
		{
			return new ZoomRect(this._maxTier, 0, 0, this._imageWidth, this._imageHeight);
		}
		
		
		/**
		 * This is the folder prefix for the folders which group tiled images.
		 */
		protected static var _folderPrefix:String = "TileGroup"

		/**
		 * maxTier is the maximum possible tier. It can be calculated as:
		 * maxTier = ceil ( log2(max(imageWidth,imageHeight)) - log2(tileSize) )
		 * maxTier corresponds to the highest resolution (biggest) image in the 
		 * multi-resolution image pyramid.
		 * 
		 * <p>minTier is 0 and corresponds to the smallest image, the size of which
		 * is < 256x256.</p>
		 * 
		 */		
		public function get maxTier():int
		{
			return _maxTier;
		}
		protected var _maxTier:int;
		/** 
		 * tileCountX is an array of size maxTier+1. This array keeps tile count 
		 * in X (width) direction.
		 */
		protected var _tileCountsX:Array;
		/**
		 * tileCountY is an array of size maxTier+1. This array keeps tile count
		 * in Y (height) direction.
		 */
		protected var _tileCountsY:Array;
		/** 
		 * tileCounts array keeps number of tiles in each tier. Used in calculation of URL.
		 *  
		 */
		protected var _tileCounts:Array;
		/**
		 * tierWidths array keeps width of the image at each tier. (in pixel)
		 */
		protected var _tierWidths:Array;
		/** 
		 * tierHeights array keeps height of the image at each tier. (in pixel)
		 */
		protected var _tierHeights:Array;
		
		/**
		 * imageURL is the baseURL of the Zoomify Image folder in the server
		 * Setting imageURL property triggers retrieval of the ImageProperties.xml file
		 * from the server.
		 * 
		 */
		protected var _imageURL:String;
		
		public function set imageURL(path:String):void
		{
			_imageURL = path;
			if (path.charAt(path.length-1) != "/"){
				_imageURL +="/";
			}
			getImageProperties();
		}
		public function get imageURL():String
		{
			return _imageURL;
		}
		
		/**
		 * Constructor.
		 */
		public function ZoomifySource(path:String = null)
		{
			super();
			
			if (path){
				imageURL = path;
			}
		}
		
		/** 
		 * read ImageProperties.xml under _imageURL
		 * and set imageWidth, imageHeight, tileSize
		 */
		protected function getImageProperties():void
		{
			var XML_URL:String = _imageURL + "ImageProperties.xml";
			var myXMLURL:URLRequest = new URLRequest(XML_URL);
			var myLoader:URLLoader = new URLLoader();
			function xmlLoaded(event:Event):void
			{
				var myXML:XML = new XML();
	    		myXML = XML(myLoader.data);
	    		trace("ZoomifySource: ImageProperties.xml loaded");
	    		_imageWidth = myXML.@WIDTH;
	    		_imageHeight = myXML.@HEIGHT;
	    		_tileSize = myXML.@TILESIZE;
	    		trace("ZoomifySource: imageWidth = " + imageWidth);
	    		trace("ZoomifySource: imageHeight = " + imageHeight);
	    		trace("ZoomifySource: tileSize = " + _tileSize);
	    		buildPyramid();
	    		var e:Event = new Event("init_success");
	    		dispatchEvent(e);
			}
			function xmlLoadError(event:Event):void
			{
				trace("ZoomifySource: Could not retrieve ImageProperties.xml");
				var e:Event = new Event("init_error");
				dispatchEvent(e); 
			}
			myLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoadError);
			myLoader.addEventListener(Event.COMPLETE, xmlLoaded);
			myLoader.load(myXMLURL)
		}
		/**
		 * pre-calculate numbers used for later calculation
		 */
		protected function buildPyramid():void
		{
			// resolution step is 1/2, i.e. imagesize in the next tier = half the previous size
			// tier 0 is the first image smaller than tileSize
			//Set up our heirarchy
			var tempWidth:Number = imageWidth;
			var tempHeight:Number = imageHeight;
			var tierCount:Number = 1;
			while (tempWidth> tileSize || tempHeight> tileSize) 
			{
				tempWidth = Math.floor(tempWidth/2);
				tempHeight = Math.floor(tempHeight/2);
				tierCount++;
			}
			_maxTier = tierCount-1;
			trace("maxTier="+_maxTier);
			
			tempWidth = imageWidth;
			tempHeight = imageHeight;
			this._tileCountsX = new Array(tierCount);
			this._tileCountsY = new Array(tierCount);
			this._tileCounts = new Array(tierCount);
			this._tierWidths = new Array(tierCount);
			this._tierHeights = new Array(tierCount);
			
			for (var j:int = tierCount-1; j>=0; j--) 
			{
				_tileCountsX[j] = Math.ceil(tempWidth/tileSize);
				_tileCountsY[j] = Math.ceil(tempHeight/tileSize);
				_tileCounts[j] = _tileCountsX[j]*_tileCountsY[j];
				_tierWidths[j] = tempWidth;
				_tierHeights[j] = tempHeight;
				tempWidth = Math.floor(tempWidth/2);
				tempHeight = Math.floor(tempHeight/2);
			}			
		}
		
		/**
		 * This function construct URL from supplied tier, and tile coordinate.
		 * 
		 * @param t Tile
		 * @return string URL for the image corresponding to supplied TileXY
		 * 
		 */
		protected function getImageURL(t:Tile):String
		{
			// TileGroupN/(tier)-(col)-(row).jpg
			// first count how many tiles before this one
			var theOffset:int = t.row*this._tileCountsX[t.tier]+t.col;
			for (var theTier:int =0; theTier<t.tier; theTier++)
			{ 
				theOffset += this._tileCounts[theTier];
			}
			// those are sorted into folders in group of 256 files
			var theOffsetChunk:int = Math.floor(theOffset/256);
			var tilePath:String= this._imageURL + "TileGroup" + theOffsetChunk + "/" + t.id +".jpg"
			return tilePath;
		}
		
		public function loadTiles(tier:Tier, view:ZoomRect):void
		{
			//deactivate loaded tiles
			tier.tileCache.deactivate();
			
			view = view.clone().zoomTo(tier.level);  //tier.level is always integer, but view.zoom could be float
			//calc tiles
			var startCol:int = Math.floor(view.x0 / this.tileSize);
			var startRow:int = Math.floor(view.y0 / this.tileSize);
			var endCol:int = Math.floor(view.x1 / this.tileSize);
			var endRow:int = Math.floor(view.y1 / this.tileSize);

			var t:Tile;
			//load tiles
			for(var col:int = startCol; col<=endCol; col++)
			{
				for(var row:int = startRow; row<=endRow; row++)
				{
					t = new Tile(tier.level, col, row, col*this.tileSize, row*this.tileSize);
					if(tier.tileCache.exists(t.id)){
						t = tier.tileCache.getTile(t.id); 
						t.active = true;
					} else{
						this.loadTile(t);
						tier.tileCache.append(t);
					}
					tier.addChild(t);
				}
			}
			//cancel non-active pending loading
			for each (t in tier.tileCache.tiles)
			{
				if (!t.active ){ //not currently viewable
					if(this.cancelPendingTile(t)){ //try to cancel loading if it's still pending
						tier.tileCache.remove(t);
					}
				}
			}
		}
		
		public function loadTile(t:Tile):void
		{
			var url:URLRequest = new URLRequest(this.getImageURL(t));
			var loader:Loader = new Loader();
			function onLoaded(e:Event):void
			{
				t.pending = false;
				trace("loaded: " + t.id);
			}
			function onLoadFail(e:IOErrorEvent):void
			{
				trace("loading " + t.id + " failed");
			}
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadFail);
			loader.name = "loader";
			loader.load(url);
			t.addChild(loader);
		}
		
		public function cancelPendingTile(t:Tile):Boolean
		{
			if (t.pending)
			{
				trace("cancelPendingTile:"+t.id);
				try{
					Loader(t.getChildByName("loader")).close();
				}catch(e:Error){
					trace("Error:"+e);
				}
				return true
			}
			return false;
		}
		
		public function unloadTile(t:Tile):void
		{
			trace("unloadTile:"+t.id);
			var l:Loader = Loader(t.getChildByName("loader"));
			if (t.pending){
				trace("closingLoader:"+t.id);
				try{
					l.close();	
				}catch(e:Error){
					trace("Error:"+e);
				}
				
			}
			l.unload();
			t.removeChild(l);
		}
	}
}