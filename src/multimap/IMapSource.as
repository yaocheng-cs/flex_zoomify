package com.repilac.multimap
{
	import flash.events.IEventDispatcher;	
	 
 	[Event(name="init_success", type="flash.events.Event")]	
	[Event(name="init_error", type="flas.events.Event")]

	
	/**
	 * MapSouce interface is implemented by classes which supply multi-resolution tiled
	 * images (like Zoomify image or Google maps).
	 * 
	 * <p>This interface is used from MultiResolutionMap class.</p>
	 * 
	 */
	public interface IMapSource extends IEventDispatcher
	{
		function get tileSize():int;
		function get bound():ZoomRect;
		
		function get imageWidth():Number;
		function get imageHeight():Number;
		function get maxTier():int;

		function loadTiles(t:Tier, v:ZoomRect):void;
		function loadTile(t:Tile):void;
		function cancelPendingTile(t:Tile):Boolean;
		function unloadTile(t:Tile):void;
	}
}