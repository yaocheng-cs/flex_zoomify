package com.repilac.multimap
{		
	
	public class AnnotationInfo extends Object
	{		
		public var id:int;
		public var term:String;
		public var type:int;
		public var zoom:Number;  //at which zoom level(tier) is this annotation created
		public var x:Number;
		public var y:Number;  //at which position of that level(tier) does this annotation locate
		public var width:Number;
		public var height:Number;
		public var apex_Xs:Array;
		public var apex_Ys:Array;
		public var segments:Array;
		public var path:String;
		
		public function AnnotationInfo(tp:int, z:Number, x:Number, y:Number, w:Number=0, h:Number=0, ax:Array=null, ay:Array=null, s:Array=null, p:String='', tm:String="Empty")
		{
			super();
			
			this.id = -1;
			this.term = tm;
			this.type = tp;
			this.zoom = z;
			this.x = x;
			this.y = y;
			this.width = w;
			this.height = h;
			this.apex_Xs = ax;
			this.apex_Ys = ay;
			this.segments = s;
			this.path = p;
		}
				
		public function updateFields(df:DragFrame):void
		{
			if(this.type < 2){
				this.width = Math.abs(df.edgePoints[1].x - df.edgePoints[3].x) / df.annotation.zoomScale;
				this.height = Math.abs(df.edgePoints[0].y - df.edgePoints[2].y) / df.annotation.zoomScale;
			} else{
				for(var i:int; i<df.DPs.length; i++){
					this.apex_Xs[i] = df.DPs[i].x / df.annotation.zoomScale;
					this.apex_Ys[i] = df.DPs[i].y / df.annotation.zoomScale;
				}
			}
			this.updateLocation(df);
		}
		
		public function updateLocation(df:DragFrame):void
		{
			x = df.x / df.annotation.zoomScale;
			y = df.y / df.annotation.zoomScale;
		}
		
		public function clone():AnnotationInfo
		{
			var c:AnnotationInfo = new AnnotationInfo(this.type, this.zoom, this.x, this.y);
			c.width = this.width;
			c.height = this.height;
			if(this.apex_Xs || this.apex_Ys){
				c.apex_Xs = this.apex_Xs.slice();
				c.apex_Ys = this.apex_Ys.slice();
			}
			if(this.segments){
				c.segments = new Array();
				for each (var s in this.segments){
					c.segments.push(s.clone());
				}
			}
			c.path = this.path;
			c.term = this.term;
			
			return c;
		}
		
	}
}