package com.repilac.multimap
{
	import flash.geom.Point;
	
	public class CubicBezier extends Object
	{
		public var anchor1:Point;
		public var control1:Point;
		public var control2:Point;
		public var anchor2:Point;
		
		public function CubicBezier(a1:Point, c1:Point, c2:Point, a2:Point)
		{
			super();
			
			this.anchor1 = a1;
			this.control1 = c1;
			this.control2 = c2;
			this.anchor2 = a2;
		}
		
		protected function divide(dFactor:int):Array
		{
			var componentCurves:Array = new Array(this);
			while(dFactor > 0){
				var tempCurves:Array = new Array();
				for each (var curve:CubicBezier in componentCurves){
					var a1:Point = curve.anchor1;
					var c1:Point = curve.control1;
					var c2:Point = curve.control2;
					var a2:Point = curve.anchor2;
					var a1c1:Point = Point.interpolate(a1, c1, 0.5);
					var c1c2:Point = Point.interpolate(c1, c2, 0.5);
					var c2a2:Point = Point.interpolate(c2, a2, 0.5);
					var a1c1c1c2:Point = Point.interpolate(a1c1, c1c2, 0.5);
					var c1c2c2a2:Point = Point.interpolate(c1c2, c2a2, 0.5);
					var a1c1c1c2c1c2c2a2:Point = Point.interpolate(a1c1c1c2, c1c2c2a2, 0.5);
					var newCurve1:CubicBezier = new CubicBezier(a1, a1c1, a1c1c1c2, a1c1c1c2c1c2c2a2);
					var newCurve2:CubicBezier = new CubicBezier(a1c1c1c2c1c2c2a2, c1c2c2a2, c2a2, a2);
					tempCurves.push(newCurve1);
					tempCurves.push(newCurve2);
				}
				componentCurves = tempCurves;
				dFactor -= 1;
			}
			return componentCurves;
		}
		
		public function approximate(dFactor:int=2):Array
		{
			var componentCurves:Array = this.divide(dFactor);
			var approximation:Array = new Array();
			for each (var curve:CubicBezier in componentCurves){
				var l1:StraightLine = new StraightLine(curve.anchor1, curve.control1);
				var l2:StraightLine = new StraightLine(curve.control2, curve.anchor2);
				var control:Point = StraightLine.cross(l1, l2);
				var qb:QuadraticBezier = new QuadraticBezier(curve.anchor1, control, curve.anchor2);
				approximation.push(qb);
			}
			return approximation;
		}
		
		public function pointAtT(t:Number):Point
		{
			if(t < 0 || t > 1){
				trace("invalid t value");
				return new Point(0, 0);
			}
			var x:Number = Math.pow(1 - t, 3) * this.anchor1.x + 3 * Math.pow(1 - t, 2)* t * this.control1.x + 3 * (1 - t) * Math.pow(t, 2) * this.control2.x + Math.pow(t, 3) * this.anchor2.x;
			var y:Number = Math.pow(1 - t, 3) * this.anchor1.y + 3 * Math.pow(1 - t, 2)* t * this.control1.y + 3 * (1 - t) * Math.pow(t, 2) * this.control2.y + Math.pow(t, 3) * this.anchor2.y;
			return new Point(x, y);
		}
		
		public function inverse():CubicBezier
		{
			return new CubicBezier(this.anchor2, this.control2, this.control1, this.anchor1);
		}
		
		public function clone():CubicBezier
		{
			var c:CubicBezier = new CubicBezier(this.anchor1.clone(), this.control1.clone(), this.control2.clone(), this.anchor2.clone());
			return c;
		}
	}
}