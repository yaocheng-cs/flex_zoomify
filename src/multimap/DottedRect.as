package com.repilac.multimap
{
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class DottedRect extends Shape
	{
		protected var _dragStartX:Number;
		protected var _dragStartY:Number;
		
		protected var _dragEndX:Number;
		protected var _dragEndY:Number;
		
		protected var _lineThickness:Number;
		protected var _lineColor:uint;
		protected var _lineInterval:Number;
		
		public var area:Rectangle;
		
		public function DottedRect()
		{
			super();
		}
		
		public function setStart(x0:Number, y0:Number):void
		{
			this._dragStartX = x0;
			this._dragStartY = y0;
		}
		
		public function setEnd(x1:Number, y1:Number):void
		{
			this._dragEndX = x1;
			this._dragEndY = y1;
		}
		
		public function setLineStyle(t:Number, c:uint, i:Number):void
		{
			this._lineThickness = t;
			this._lineColor = c;
			this._lineInterval = i;
		}
		
		protected function drawDottedLine(p0:Point, p1:Point):void
		{
			var x:Number = p0.x < p1.x ? p0.x : p1.x;
			var y:Number = p0.y < p1.y ? p0.y : p1.y;
			var x1:Number = p0.x > p1.x ? p0.x : p1.x;
			var y1:Number = p0.y > p1.y ? p0.y : p1.y;
			var draw:Boolean = true;
			
			with(graphics){
				moveTo(x, y);
				if(y == y1){
					while(x < x1){
						if(draw){
							if(x + this._lineInterval <= x1){
								lineTo(x + this._lineInterval, y);
							} else{
								lineTo(x1, y);
							}
							draw = false;
						} else{
							moveTo(x + this._lineInterval, y);
							draw = true;
						}
						x = x + this._lineInterval;
					}
					return;
				}
				if(x == x1){
					while(y < y1){
						if(draw){
							if(y + this._lineInterval <= y1){
								lineTo(x, y + this._lineInterval);
							} else{
								lineTo(x, y1);
							}
							draw = false;
						} else{
							moveTo(x, y + this._lineInterval);
							draw = true;
						}
						y = y + this._lineInterval;
					}
					return;
				}
			}
		}
		
		public function draw():void
		{
			var p0:Point = new Point(this._dragStartX, this._dragStartY);
			var p1:Point = new Point(this._dragEndX, this._dragStartY);
			var p2:Point = new Point(this._dragEndX, this._dragEndY);
			var p3:Point = new Point(this._dragStartX, this._dragEndY);
			
			graphics.clear();
			graphics.lineStyle(this._lineThickness, this._lineColor);
			drawDottedLine(p0, p1);
			drawDottedLine(p1, p2);
			drawDottedLine(p0, p3);
			drawDottedLine(p3, p2);
		}
		
		public function onMouseDown(e:MouseEvent):void
		{
			if(e.target is Loader){
				(parent as AnnotationLayer).emptyFocusList();
			}
			
			if(e.shiftKey){
				this.setLineStyle(2, 0x00FFFF, 3);
				this.setStart(mouseX, mouseY);
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			}
		}
		
		protected function onMouseMove(e:MouseEvent):void
		{
			//e.stopImmediatePropagation();
			
			this.setEnd(mouseX, mouseY);
			this.draw();
		}
		
		protected function onMouseUp(e:MouseEvent):void
		{
			//e.stopImmediatePropagation();
			
			this.area = this.getBounds(stage);
			var f:Event = new Event("update_focus_list", true);
			dispatchEvent(f);
			graphics.clear();
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		
		/*public function calculateRect():Rectangle
		{
			var x0:Number = this._dragStartX < this._dragEndX ? this._dragStartX : this._dragEndX;
			var y0:Number = this._dragStartY < this._dragEndY ? this._dragStartY : this._dragEndY;
			var x1:Number = this._dragStartX > this._dragEndX ? this._dragStartX : this._dragEndX;
			var y1:Number = this._dragStartY > this._dragEndY ? this._dragStartY : this._dragEndY;
			this.area = new Rectangle(x0, y0, x1 - x0 + 1, y1 - y0 + 1);
			return this.area
		}*/
		
	}
}