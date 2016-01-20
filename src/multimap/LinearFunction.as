package com.repilac.multimap
{
	import flash.geom.Point;
	
	public class LinearFunction extends Object
	{
		protected var _a:Number;
		public function get a():Number
		{
			return this._a;
		}
		public function set a(value:Number):void
		{
			this._a = value;
		}
		
		protected var _b:Number;
		public function get b():Number
		{
			return this._b;
		}
		public function set b(value:Number):void
		{
			this._b = value;
		}
		
		/*public function LinearFunction(a:Number=0, b:Number=0)
		{
			super();
			
			this._a = a;
			this._b = b;
		}*/
		
		public function LinearFunction(p1:Point, p2:Point)
		{
			super();
			
			var a:Number = (p1.y - p2.y) / (p1.x - p2.x);
			var b:Number = (p1.x * p2.y - p2.x * p1.y) / (p1.x - p2.x);
			this._a = a;
			this._b = b;
		}
		
		static public function cross(l1:LinearFunction, l2:LinearFunction):Point
		{
			var x:Number = (l2.b - l1.b) / (l1.a - l2.a);
			var y:Number = (l1.a * l2.b - l1.b * l2.a) / (l1.a - l2.a);
			var cross:Point = new Point(x, y);
			return cross;
		}
	}
}