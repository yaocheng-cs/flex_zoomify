package com.repilac.multimap
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class MatchPoint extends Sprite
	{	
		public function MatchPoint()
		{
			super();
			
			graphics.clear();
			graphics.beginFill(0x333333);
			graphics.drawCircle(0, 0, 4);
			graphics.endFill();
			
			//addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
		}
		
		public function onMouseDown(e:MouseEvent):void
		{
			e.stopPropagation();
			
			startDrag();
			
			var f:Event = new Event("match_point_start", true);
			dispatchEvent(f);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		
		public function onMouseMove(e:MouseEvent):void
		{
			var f:Event = new Event("match_point_move", true);
			dispatchEvent(f);
		}
		
		public function onMouseUp(e:MouseEvent):void
		{
			e.stopPropagation();
			
			stopDrag();
			
			var f:Event = new Event("match_point_stop", true);
			dispatchEvent(f);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		
	}
}