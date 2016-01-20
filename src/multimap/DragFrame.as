package com.repilac.multimap
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * this illustrates how drag points are allocated in a frame
	 * 
	 *          col -1    col 0     col +1
	 * 
	 *  row -1     0         1         2
	 * 
	 * 
	 *  row 0      7                   3
	 * 
	 * 
	 *  row +1     6         5         4
	 * 
	 * 
	 **/
	
	public class DragFrame extends Sprite
	{
		public var type:String;
		protected var _DPs:Array;
		protected var _cornerPoints:Array;
		protected var _edgePoints:Array;
		protected var _annotation:Annotation;
		protected var _zoomScale:Number;
		
		public function get DPs():Array
		{
			return this._DPs;
		}
		public function get edgePoints():Array
		{
			return this._edgePoints;
		}
		public function get annotation():Annotation
		{
			return this._annotation;
		}
		public function set annotation(value:Annotation):void
		{
			this._annotation = value;
			this._zoomScale = value.zoomScale;
			if(this._annotation.info.type == 2){
				this.type = "rand";
			} else{
				this.type = "rect";
			}
			x = this._annotation.info.x * this._zoomScale;
			y = this._annotation.info.y * this._zoomScale;
			
			var dp:DragPoint;
			if(this.type == "rect"){
				dp = new DragPoint();
				this.markDragPoint(dp, 0, "random", -1, -1);
				this._DPs.push(dp);
				this._cornerPoints.push(dp);
				addChild(dp);
				
				dp = new DragPoint();
				this.markDragPoint(dp, 1, "vertical", -1, 0);
				this._DPs.push(dp);
				this._edgePoints.push(dp);
				addChild(dp);
				
				dp = new DragPoint();
				this.markDragPoint(dp, 2, "random", -1, 1);
				this._DPs.push(dp);
				this._cornerPoints.push(dp);
				addChild(dp);
				
				dp = new DragPoint();
				this.markDragPoint(dp, 3, "horizontal", 0, 1);
				this._DPs.push(dp);
				this._edgePoints.push(dp);
				addChild(dp);
				
				dp = new DragPoint();
				this.markDragPoint(dp, 4, "random", 1, 1);
				this._DPs.push(dp);
				this._cornerPoints.push(dp);
				addChild(dp);
				
				dp = new DragPoint();
				this.markDragPoint(dp, 5, "vertical", 1, 0);
				this._DPs.push(dp);
				this._edgePoints.push(dp);
				addChild(dp);
				
				dp = new DragPoint();
				this.markDragPoint(dp, 6, "random", 1, -1);
				this._DPs.push(dp);
				this._cornerPoints.push(dp);
				addChild(dp);
				
				dp = new DragPoint();
				this.markDragPoint(dp, 7, "horizontal", 0, -1);
				this._DPs.push(dp);
				this._edgePoints.push(dp);
				addChild(dp);
				
				this.allocateAsRect();
			} else{
				for(var i:int=0; i<this._annotation.info.apex_Xs.length; i++){
					dp = new DragPoint();
					this.markDragPoint(dp, i, "random", 0, 0);
					dp.x = this._annotation.info.apex_Xs[i] * this._zoomScale;
					dp.y = this._annotation.info.apex_Ys[i] * this._zoomScale;
					this._DPs.push(dp);
					addChild(dp);
				}
			}
		}
		
		public function DragFrame()
		{
			super();
			
			this._DPs = new Array();
			this._cornerPoints = new Array();
			this._edgePoints = new Array();
			
			addEventListener("drag_point_moved", this.onDragPointMoved);
		}
		
		protected function markDragPoint(dp:DragPoint, i:int, t:String, r:int, c:int):void
		{
			dp.id = i;
			dp.type = t;
			dp.row = r;
			dp.col = c;
		}
		
		protected function allocateAsRect():void
		{
			var halfWidth:Number = this._annotation.info.width * this._zoomScale / 2;
			var halfHeight:Number = this._annotation.info.height * this._zoomScale / 2;
			
			this._DPs[0].x = -halfWidth;
			this._DPs[0].y = -halfHeight;
			this._DPs[1].x = 0;
			this._DPs[1].y = -halfHeight;
			this._DPs[2].x = halfWidth;
			this._DPs[2].y = -halfHeight;
			this._DPs[3].x = halfWidth;
			this._DPs[3].y = 0;
			this._DPs[4].x = halfWidth;
			this._DPs[4].y = halfHeight;
			this._DPs[5].x = 0;
			this._DPs[5].y = halfHeight;
			this._DPs[6].x = -halfWidth;
			this._DPs[6].y = halfHeight;
			this._DPs[7].x = -halfWidth;
			this._DPs[7].y = 0;
		}
		
		public function onDragPointMoved(e:Event):void
		{
			var movedDP:DragPoint = DragPoint(e.target);
			var i:int;
			var dp:DragPoint;
			
			if(this.type == "rect"){
				x = x + movedDP.deltaX / 2;
				y = y + movedDP.deltaY / 2;
				for(i=0; i<4; i++){
					dp = this._cornerPoints[i];
					if(movedDP.row != 0){
						dp.y = dp.row / movedDP.row * movedDP.y;
					}
					if(movedDP.col != 0){
						dp.x = dp.col / movedDP.col * movedDP.x;
					}
				}
				for(i=0; i<4; i++){
					dp = this._edgePoints[i];
					if(dp.type == "vertical"){
						dp.x = (this._DPs[dp.id-1].x + this._DPs[dp.id+1].x) / 2;
						dp.y = this._DPs[dp.id-1].y;
					}
					trace("i =", i, "dp.id =", dp.id);
					if(dp.type == "horizontal"){
						if(dp.id == 7){
							dp.y = (this._DPs[6].y + this._DPs[0].y) / 2;  //_DPs[8] does not exist
						} else{
							dp.y = (this._DPs[dp.id-1].y + this._DPs[dp.id+1].y) / 2;
						}
						dp.x = this._DPs[dp.id-1].x;
					}
				}
				//this._annotation.info.updateFields(this);
				var e:Event = new Event("frame_adjusted", true);
				dispatchEvent(e);
			} else{
				var apex_Xs:Array = new Array();
				var apex_Ys:Array = new Array();
				for(i=0; i<this._DPs.length; i++){
					apex_Xs.push(this._DPs[i].x);
					apex_Ys.push(this._DPs[i].y);
				}
				var sorted_apex_Xs:Array = apex_Xs.slice(0, apex_Xs.length).sort(Array.NUMERIC);
				var sorted_apex_Ys:Array = apex_Ys.slice(0, apex_Ys.length).sort(Array.NUMERIC);
				var deltaX:Number = (sorted_apex_Xs[sorted_apex_Xs.length - 1] + sorted_apex_Xs[0]) / 2;
				var deltaY:Number = (sorted_apex_Ys[sorted_apex_Ys.length - 1] + sorted_apex_Ys[0]) / 2;
				x = x + deltaX;
				y = y + deltaY;
				for(i=0; i<this._DPs.length; i++){
					this._DPs[i].x = this._DPs[i].x - deltaX;
					this._DPs[i].y = this._DPs[i].y - deltaY;
				}
				//this._annotation.info.updateFields(this);
				var f:Event = new Event("frame_adjusted", true);
				dispatchEvent(f);
			}
		}
		
		public function follow():void
		{
			x = this._annotation.x;
			y = this._annotation.y;
		}
		
		public function stopFollow():void
		{
			x = this._annotation.x;
			y = this._annotation.y;
			this._annotation.info.updateLocation(this);
		}
		
		public function zoomToo():void
		{
			this.follow();
			this._zoomScale = this._annotation.zoomScale;
			if(this.type == "rect"){
				this.allocateAsRect();
			} else{
				for(var i:int=0; i<this.DPs.length; i++){
					this.DPs[i].x = this._annotation.info.apex_Xs[i] * this._zoomScale;
					this.DPs[i].y = this._annotation.info.apex_Ys[i] * this._zoomScale;
				}
			}
		}
		
		/*protected function updateAnnotationInfo():void
		{
			if(this.type == "rect"){
				this._annotation.info.width = Math.abs(this._edgePoints[1].x - this._edgePoints[3].x) / this._annotation.zoomScale;
				this._annotation.info.height = Math.abs(this._edgePoints[0].y - this._edgePoints[2].y) / this._annotation.zoomScale;
			} else{
				for(var i:int; i<this._DPs.length; i++){
					this._annotation.info.apex_Xs[i] = this._DPs[i].x / this._annotation.zoomScale;
					this._annotation.info.apex_Ys[i] = this._DPs[i].y / this._annotation.zoomScale;
				}
			}
			this._annotation.info.x = x / this._annotation.zoomScale;
			this._annotation.info.y = y / this._annotation.zoomScale;
			
			var e:Event = new Event("frame_adjusted", true);
			dispatchEvent(e);
		}*/
		
	}
}