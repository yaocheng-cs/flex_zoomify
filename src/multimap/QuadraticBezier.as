package com.repilac.multimap
{
	import flash.geom.Point;
	
	public class QuadraticBezier extends Object
	{
		public var anchor1:Point;
		public var control:Point;
		public var anchor2:Point;
		
		public function QuadraticBezier(a1:Point, c:Point, a2:Point)
		{
			super();
			
			this.anchor1 = a1;
			this.control = c;
			this.anchor2 = a2;
		}
		
		public function clone():QuadraticBezier
		{
			var c:QuadraticBezier = new QuadraticBezier(this.anchor1.clone(), this.control.clone(), this.anchor2.clone());
			return c;
		}
		
	}
}