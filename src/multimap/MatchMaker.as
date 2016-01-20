package com.repilac.multimap
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import mx.core.UIComponent;
	
	/**
	 * This illustrates the accurate notation in the transformation matrix
	 * CAUTION: There is a bug in Flex Builder 3's help documentation. The poisitions of "b" and "c" are inversed there, and that's NOT right!
	 * 
	 *    a     c     tx
	 * 
	 *    b     d     ty
	 * 
	 *    0     0     1
	 *  
	 **/
	
	public class MatchMaker extends UIComponent
	{
		protected var _OS:Sprite;  //Origin Sprite
		protected var _TS:Sprite;  //Target Sprite
		//record points in MatchMaker's coordinate system
		protected var _startPoints:Array;
		protected var _endPoints:Array;
		//record points in either origin Sprite or target Sprite's coordinate system
		protected var _X:Array;
		protected var _Y:Array;
		protected var _counter:int;
		
		protected var _a:Number;
		protected var _b:Number;
		protected var _c:Number;
		protected var _d:Number;
		protected var _tx:Number;
		protected var _ty:Number;
		
		public var inLineDrawingMode:Boolean;
		
		public function MatchMaker(os:Sprite, ts:Sprite)
		{
			super();
						
			this._OS = os;
			this._TS = ts;
			this._startPoints = new Array(3);
			this._endPoints = new Array(3);
			this._X = new Array(6);
			this._Y = new Array(6);
			this._counter = 0;
			
			this.hitArea = this._OS;
			
			addEventListener(MouseEvent.CLICK, this.onMouseClick);
			//addEventListener("match_point_move", this.onMatchPointMove);
		}
		
		protected function markOn(s:Sprite):MatchPoint
		{
			var mp:MatchPoint = new MatchPoint();
			mp.x = mouseX;
			mp.y = mouseY;
			addChild(mp);
			return mp;
		}
		
		public function onMouseClick(e:MouseEvent):void
		{
			if(this._counter < 6){
				var mp:MatchPoint;
				if(this._counter % 2 == 0){
					mp = this.markOn(this._OS);
					this._startPoints[this._counter / 2] = mp;
					this._X[this._counter] = this._OS.mouseX;
					this._Y[this._counter] = this._OS.mouseY;
					this.hitArea = this._TS;
					this.inLineDrawingMode = true;
					stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
				} else{
					mp = this.markOn(this._TS);
					this._endPoints[Math.floor(this._counter / 2)] = mp;
					this._X[this._counter] = this._TS.mouseX;
					this._Y[this._counter] = this._TS.mouseY;
					this.hitArea = this._OS;
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
					this.inLineDrawingMode = false;
				}
				this._counter++;
			}
			if(this._counter == 6){
				this.hitArea = null;
				removeEventListener(MouseEvent.CLICK, this.onMouseClick);
				var f:Event = new Event("ready_to_match", true);
				dispatchEvent(f);
			}
		}
		
		public function updateLinkLine():void
		{
			graphics.clear();
			graphics.lineStyle(1, 0x333333);
			for(var i:int=0; i<3; i++){
				if(!this._startPoints[i]){
					return;
				} else{
					//var sp:Point = this._OS.localToGlobal(new Point(this._startPoints[i].x, this._startPoints[i].y));
					graphics.moveTo(this._startPoints[i].x, this._startPoints[i].y);
					if(!this._endPoints[i]){
						graphics.lineTo(mouseX, mouseY);
					} else{
						//var ep:Point = this._TS.localToGlobal(new Point(this._endPoints[i].x, this._endPoints[i].y));
						graphics.lineTo(this._endPoints[i].x, this._endPoints[i].y);
					}
				}
			}
		}
		
		public function onMouseMove(e:MouseEvent):void
		{
			this.updateLinkLine();
		}
		
		public function onMatchPointMove(e:Event):void
		{
			this.updateLinkLine();
		}
		
		public function calculate():Matrix
		{
			var X:Array = this._X;
			var Y:Array = this._Y;
			//This process of calculation needs to be rewrote into the form of "a serial of mathmatical procedure", such as innerProduct(m1, m2), outerProduct(m1, m2)
			//Index 0, 2 and 4 are of origin points, and index 1, 3 and 5 are of corresponding target points
			var det:Number = ((X[0] - X[2]) * (Y[0] - Y[4]) - (X[0] - X[4]) * (Y[0] - Y[2]));
			this._a = ((X[1] - X[3]) * (Y[0] - Y[4]) - (X[1] - X[5]) * (Y[0] - Y[2])) / det;
			this._b = ((Y[1] - Y[3]) * (Y[0] - Y[4]) - (Y[1] - Y[5]) * (Y[0] - Y[2])) / det;
			this._c = -((X[1] - X[3]) * (X[0] - X[4]) - (X[1] - X[5]) * (X[0] - X[2])) / det;
			this._d = -((Y[1] - Y[3]) * (X[0] - X[4]) - (Y[1] - Y[5]) * (X[0] - X[2])) / det;
			this._tx = X[1] - this._a * X[0] - this._c * Y[0];
			this._ty = Y[1] - this._b * X[0] - this._d * Y[0];
			
			var m:Matrix = new Matrix(this._a, this._b, this._c, this._d, this._tx, this._ty);
			return m;
		}
		
		public function mute():void
		{
			if(this.inLineDrawingMode){
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			}
		}
		
		public function enable():void
		{
			if(this.inLineDrawingMode){
				stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			}
		}
	}
}