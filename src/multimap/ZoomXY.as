/*
 *  2008 
 * $Id:
 */

package com.repilac.multimap
{
	
	/**
	 * This class represents a point in the Zoomify (or other) pyramid of tiles.
	 * Three number (x,y,tier) specifies a position in a certain tier (zoom level).
	 * 
	 */
	public class ZoomXY extends Object
	{
		/** 
		 * x position in tier (usually pixel)
		 * @default 0
		 */ 
	    public var x:Number;
	    /** 
	    * y position in tier (usually pixel)
	    * @default 0
	    */
	    public var y:Number;
	    /** 
	    * tier (float)
	    * @default 0
	    */
	    public var zoom:Number;
	    
	    //public static const MAX_TIER:Number = 20;
	    public function ZoomXY(zoom:Number=0, x:Number=0, y:Number=0)
	    {
	        this.zoom = zoom;
	        this.x = x;
	        this.y = y;
	    }
	    
	    public function toString():String
	    {
	        return '(' + x + ',' + y + ' @' + zoom + ')';
	    }
	    
	    public function clone():ZoomXY
	    {
	        return new ZoomXY(zoom, x, y);
	    }
	    
	    public function zoomBy(diff:Number):ZoomXY
	    {
 	    	var scale:Number = Math.pow(2, diff)
	    	this.x = this.x * scale;
	    	this.y = this.y * scale;
	    	this.zoom += diff;
	    	return this;
	    }

	    public function zoomTo(dst:Number):ZoomXY
	    {
	    	return this.zoomBy(dst-this.zoom);
	    }
	    
	    /** 
	    * Zoom in reference to a specified point (x0,y0).
	    * Keep the distance (in pixel) between current position and (x0,y0).
	    * 
	    * <p>When zooming in and out display window (view port) this will return appropriate 
	    * position of the display window. (Size in pixel of the display window will not change,
	    * so the distance in pixel between the tierXY and reference point (x0,y0) won't change.</p>
	    * 
	    */
	    public function zoomAt(x0:Number, y0:Number, diff:Number):ZoomXY
	    {
	    	var tmp:ZoomXY = new ZoomXY(this.zoom,x0,y0);
	    	tmp.zoomBy(diff);
	    	this.zoom += diff;
	    	this.x = tmp.x + (this.x - x0);
	    	this.y = tmp.y + (this.y - y0);
	    	return this;
	    }
	
 		public function panTo(x:Number, y:Number):ZoomXY
 		{
 			this.x = x;
 			this.y = y;
 			return this;
 		}
 		public function panBy(dx:Number, dy:Number):ZoomXY
 		{
 			this.x += dx;
 			this.y += dy;
 			return this;	
 		}	
 		   
 		/**
 		 * This method restrict the object's zoom level between 0
 		 * and supplied zoom level (bound.zoom) and also restrict
 		 * the point (x,y) within the supplied rect (with appropriate zooming).
 		 * 
 		 * @param bound specifies maximum zoom level and bounding rect at that level.
 		 */
 		public function boundWith(bound:ZoomRect):ZoomXY
 		{
 			/*
 			if (this.zoom < 0){
 				this.zoomTo(0);
 			}
 			if (this.zoom > bound.zoom){
 				 this.zoomTo(bound.zoom);
 			}
 			*/
 	    	var b:ZoomRect = (bound.clone()).zoomTo(this.zoom);
	    	if (this.x < b.x0) this.x = b.x0;
	    	if (this.x > b.x1) this.x = b.x1;
	    	if (this.y < b.y0) this.y = b.y0;
	    	if (this.y > b.y1) this.y = b.y1;
	    	return this;
 		}
	    
	    public function equalTo( coord : ZoomXY ) : Boolean
	    {
	    	return coord.x == this.x && coord.y == this.y && coord.zoom == this.zoom;
	    }
	}
}