package com.repilac.multimap
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	
	public class DragPoint extends Sprite
	{
		public var id:int;
		public var type:String;
		public var row:int;
		public var col:int;
		
		public var deltaX:Number;
		public var deltaY:Number;
		
		public function DragPoint()
		{
			super();
			
			graphics.clear();
			graphics.beginFill(0xFFFF00);
			graphics.drawRect(-2, -2, 5, 5);  //the size of a drag point is 5 * 5
			graphics.endFill();
			
			addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
		}
		
		protected function onMouseDown(e:MouseEvent):void
		{
			e.stopPropagation();
			
			var f:Event = new Event("drag_point_down", true);
			dispatchEvent(f);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		
		protected function onMouseMove(e:MouseEvent):void
		{
			this.deltaX = parent.mouseX - x;
			this.deltaY = parent.mouseY - y;
			
			if(DragFrame(parent).type == "rect"){
				if(this.type == "horizontal"){
					x = x + deltaX / 2;
					this.deltaY = 0;
				}
				if(this.type == "vertical"){
					y = y + deltaY / 2;
					this.deltaX = 0;
				}
				if(this.type == "random"){
					x = x + deltaX / 2;
					y = y + deltaY / 2;
				}
			} else{
				x = parent.mouseX;
				y = parent.mouseY;
			}
			
			var f:Event = new Event("drag_point_moved", true);
			dispatchEvent(f);
		}
		
		protected function onMouseUp(e:MouseEvent):void
		{
 			trace("onMouseUp");
 			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
	}
}