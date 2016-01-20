package com.repilac.multimap
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	public class Drawer extends Sprite
	{
		protected var _type:int;
		protected var _startX:Number;
		protected var _startY:Number;
		protected var _closeArea:Rectangle;
		protected var _drawingWidth:Number;
		protected var _drawingHeight:Number;
		protected var _apex_Xs:Array;
		protected var _apex_Ys:Array;
		protected var _pos_X:Number;
		protected var _pos_Y:Number;
		
		public function get type():int
		{
			return this._type;
		}
		public function set type(value:int):void
		{
			this._type = value;
			if(this._type < 2){
				//stage.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown, false, 1);
				this._apex_Xs = null;
				this._apex_Ys = null;
			} else{
				//during the "click" event, there is a "down" event generated.
				//It needs to be handled properly, or it will bubble to TempDrawer's parent
				//stage.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown, false, 1);
				//stage.addEventListener(MouseEvent.CLICK, this.onMouseClick, false, 1);
				this._apex_Xs = new Array();
				this._apex_Ys = new Array();
			}
		}
		public function get pos_X():Number
		{
			return this._pos_X;
		}
		public function get pos_Y():Number
		{
			return this._pos_Y;
		}
		public function get drawingWidth():Number
		{
			return this._drawingWidth;
		}
		public function get drawingHeight():Number
		{
			return this._drawingHeight;
		}
		public function get apex_Xs():Array
		{
			return this._apex_Xs;
		}
		public function get apex_Ys():Array
		{
			return this._apex_Ys;
		}
		
		public function Drawer()
		{
			super();
		}
		
		protected function update(e:MouseEvent):void
		{
			this._drawingWidth = mouseX - this._startX;
			this._drawingHeight = mouseY - this._startY;
		}
		
		/*
		protected function mouseDownBlocker(e:CloseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			return;
		}
		*/
		
		public function onMouseDown(e:MouseEvent):void
		{
			/*
			var m:Rectangle = parent.parent.mask.getBounds(stage);
			if(!m.contains(e.stageX, e.stageY)){
				//here, must remove the mouse down event listener temporarily, or clicking on the alert window will trigger the event processing again
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				Alert.show("Please work on the chosen Map.", "Alert", Alert.OK, this.parent.parent as Map, this.mouseDownBlocker);
				return;
			}
			*/
			
			if(e.target is Navigator || e.target is Zoomer || e.target is Annotation || e.target is TextField){
				return;
			}
			
			e.stopPropagation(); //stop the event at the application level
			
			(parent as AnnotationLayer).emptyFocusList();
			
			e.stopImmediatePropagation();
			if(this._type < 2){
				this._startX = mouseX;
				this._startY = mouseY;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			} else{
				stage.addEventListener(MouseEvent.CLICK, this.onMouseClick);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			}
		}
		
		public function onMouseMove(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			
			if(this._type < 2){
				stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			}
			
			this.update(e);
			graphics.clear();
			graphics.lineStyle(2, 0xFF0000);
			switch(this._type)
			{
				case 0:
				graphics.drawEllipse(this._startX, this._startY, this._drawingWidth, this._drawingHeight);
				break;
				
				case 1:
				graphics.drawRect(this._startX, this._startY, this._drawingWidth, this._drawingHeight);
				break;
				
				case 2:
				graphics.moveTo(this._apex_Xs[0], this._apex_Ys[0]);
				if(this._apex_Xs.length > 1){
					for(var i:int=1; i<this._apex_Xs.length; i++){
						graphics.lineTo(this._apex_Xs[i], this._apex_Ys[i]);
					}
				}
				graphics.lineTo(mouseX, mouseY);
				break;
			}
		}
		
		public function onMouseUp(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			
			this.update(e);
			this._pos_X = (this._startX + mouseX) / 2;  //position(center) of the annotation, in annotation layer's coordinate system
			this._pos_Y = (this._startY + mouseY) / 2;  //position(center) of the annotation, in annotation layer's coordinate system
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			
			
			var f:Event = new Event("drawing_done", true);
			dispatchEvent(f);
		}
		
		public function onMouseClick(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			
			if(this._apex_Xs.length < 3){
				if(this._apex_Xs.length == 0){
					stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
					this._closeArea = new Rectangle(mouseX - 4, mouseY - 4, 9, 9);
				}
				this._apex_Xs.push(mouseX);
				this._apex_Ys.push(mouseY);
			} else{
				if(!this._closeArea.contains(mouseX, mouseY)){
					this._apex_Xs.push(mouseX);
					this._apex_Ys.push(mouseY);
				} else{
					var sorted_apex_Xs:Array = this._apex_Xs.slice(0, this._apex_Xs.length).sort(Array.NUMERIC);
					var sorted_apex_Ys:Array = this._apex_Ys.slice(0, this._apex_Ys.length).sort(Array.NUMERIC);
					this._drawingWidth = sorted_apex_Xs[sorted_apex_Xs.length - 1] - sorted_apex_Xs[0];
					this._drawingHeight = sorted_apex_Ys[sorted_apex_Ys.length - 1] - sorted_apex_Ys[0];
					this._pos_X = (sorted_apex_Xs[sorted_apex_Xs.length - 1] + sorted_apex_Xs[0]) / 2  //In annotation layer's coordinate system
					this._pos_Y = (sorted_apex_Ys[sorted_apex_Ys.length - 1] + sorted_apex_Ys[0]) / 2  //In annotation layer's coordinate system
					//coordinates of apexes relative to the "center" of the annotation
					for(var i:int=0; i<this._apex_Xs.length; i++){
						this._apex_Xs[i] = this._apex_Xs[i] - this._pos_X;
						this._apex_Ys[i] = this._apex_Ys[i] - this._pos_Y;
					}
					
					stage.removeEventListener(MouseEvent.CLICK, this.onMouseClick);
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
					//stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
					
					var f:Event = new Event("drawing_done", true);
					dispatchEvent(f);
				}
			}
		}
	}
}