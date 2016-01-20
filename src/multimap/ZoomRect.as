/*
 *  2008 
 * $Id:
 */

package com.repilac.multimap
{
	
	/**
	 * This class represents a rect in the Zoomify (or other) pyramid of tiles.
	 * Five numbers (tier,left,top,right,bottom) specifies a rect in a certain tier (zoom level).
	 * 
	 */
	public class ZoomRect extends Object
	{
		/** 
		 * x0: left position in tier (usually pixel)
		 * @default 0
		 */ 
	    public var x0:Number;
	    /** 
	    * y0: top position in tier (usually pixel)
	    * @default 0
	    */
	    public var y0:Number;
	    /** 
	    * x1: right position
	    * @default 0
	    */
	    public var x1:Number;
	    /**
	    * y1: bottom position
	    * @default 0
	    */
	    public var y1:Number;
	    /** 
	    * tier (float)
	    * @default 0
	    */
	    public var zoom:Number;
	    
	    //public static const MAX_TIER:Number = 20;
	    public function ZoomRect(zoom:Number=0, left:Number=0, top:Number=0, 
	    						right:Number=0, bottom:Number=0)
	    {
	        this.zoom = zoom;
	        this.x0 = Math.min(left,right);
	        this.y0 = Math.min(top,bottom);
	        this.x1 = Math.max(left,right);
	        this.y1 = Math.max(top,bottom);
	    }
	    
	    public function toString():String
	    {
	        return '(' +x0+ ',' +y0+ ',' +x1+ ',' +y1+ ' @' + zoom + ')';
	    }
	    
	    public function clone():ZoomRect
	    {
	        return new ZoomRect(zoom, x0, y0, x1, y1);
	    }
	   	
	   	public function get width():Number
	   	{
	   		return (this.x1 - this.x0);
	   	}
	   	
	   	public function set width(w:Number):void
	   	{
	   		var middle:Number = (this.x0+this.x1)/2.0; 
	   		this.x0 = middle - w/2.0;
	   		this.x1 = middle + w/2.0;
	   	}
	   	
	   	public function get height():Number
	   	{
	   		return (this.y1 - this.y0);
	   	}
	   	
	   	public function set height(h:Number):void
	   	{
	   		var middle:Number = (this.y0+this.y1)/2.0;
	   		this.y0 = middle - h/2.0;
	   		this.y1 = middle + h/2.0;	
	   	}
	   	
	   	public function get center():ZoomXY
	   	{
	   		return new ZoomXY(this.zoom, this.x0+this.width/2, this.y0+this.height/2);
	   	}
	   	
	   	public function set center(c:ZoomXY):void
	   	{
	   		this.zoomTo(c.zoom);
	   		var c2:ZoomXY = this.center;
	   		this.panBy(c.x - c2.x, c.y - c2.y)
	   	}
	   	
	    public function zoomBy(diff:Number):ZoomRect
	    {
 	    	var scale:Number = Math.pow(2, diff);
	    	this.x0	*= scale;
	    	this.x1 *= scale;
	    	this.y0 *= scale;
	    	this.y1 *= scale;
			this.zoom += diff;
			return this;	    	 
	    }

   	    public function zoomTo(dst:Number):ZoomRect
	    {
	    	return this.zoomBy(dst - this.zoom);
	    }
	    
	    public function panBy(dx:Number, dy:Number):ZoomRect
	    {
	    	this.x0 += dx;
	    	this.x1 += dx;
	    	this.y0 += dy;
	    	this.y1 += dy;
	    	return this;
	    }

	    public function boundWith(o:ZoomRect):ZoomRect
	    {
	    	var tl:ZoomXY = new ZoomXY(this.zoom, this.x0, this.y0);
	    	var br:ZoomXY = new ZoomXY(this.zoom, this.x1, this.y1);
	    	tl.boundWith(o);
	    	br.boundWith(o);
	    	this.x0 = tl.x;
	    	this.y0 = tl.y;
	    	this.x1 = br.x;
	    	this.y1 = br.y;
	    	this.zoom = tl.zoom;
	    	return this;
	    }

	    public function equalTo( o : ZoomRect ) : Boolean
	    {
	    	if ( ! o ){
	    		return false;
	    	}
	    	return (o.x0 == this.x0 && o.y0 == this.y0 &&
	    			o.x1 == this.x1 && o.y1 == this.y1 && 
	    			o.zoom == this.zoom);
	    }
	    
	    public function contain(v:ZoomRect):Boolean
	    {
	    	if(!v){
	    		return false;
	    	}
	    	return (this.zoom == v.zoom &&
	    			this.x0 <= v.x0 && this.y0 <= v.y0 &&
	    			this.x1 >= v.x1 && this.y1 >= v.y1);
	    }
	}
}