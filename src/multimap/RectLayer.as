package com.repilac.multimap
{
	import flash.geom.Point;
	
	public class RectLayer extends MapLayer
	{
		protected var _initBorder:ZoomRect;
		protected var _curBorder:ZoomRect;
		protected var _tier:Tier;
		protected var _tile:Tile;
		
		public function RectLayer(iv:ZoomRect):void
		{
			super();
			
			this._initBorder = iv;
			this._curBorder = this._initBorder.copy();
			
			this._tier = new Tier(0, _tileCache);
			this._tile = new Tile(0, 0, 0, 0, 0);
			this._tier.addChild(_tile);
			addChild(this._tier);
		}
		
		/*public static function drawBorder(t:Tile, border:ZoomRect, thickness:Number):void
		{
			t.graphics.clear();
			
			t.graphics.moveTo(border.x0, border.y0);
			drawDottedLine(t, thickness, 3, border.x0, border.y0, border.x1, border.y0);
			t.graphics.moveTo(border.x1, border.y0);
			drawDottedLine(t, thickness, 3, border.x1, border.y0, border.x1, border.y1);
			t.graphics.moveTo(border.x0, border.y0);
			drawDottedLine(t, thickness, 3, border.x0, border.y0, border.x0, border.y1);
			t.graphics.moveTo(border.x0, border.y1);
			drawDottedLine(t, thickness, 3, border.x0, border.y1, border.x1, border.y1);
		}
		
		public static function drawDottedLine(t:Tile, thickness:Number, inteval:Number, x0:Number, y0:Number, x1:Number, y1:Number):void
		{
			var x:Number = x0;
			var y:Number = y0;
			var draw:Boolean = true;
			
			with(t.graphics){
				lineStyle(thickness,0xFFFFFF);
				moveTo(x, y);
				if(y0 == y1){
					while(x < x1){
						if(draw){
							if(x + inteval <= x1){
								lineTo(x + inteval, y);
							} else{
								lineTo(x1, y);
							}
							draw = false;
						} else{
							moveTo(x + inteval, y);
							draw = true;
						}
						x = x + inteval;
					}
					return;
				}
				if(x0 == x1){
					while(y < y1){
						if(draw){
							if(y + inteval <= y1){
								lineTo(x, y + inteval);
							} else{
								lineTo(x, y1);
							}
							draw = false;
						} else{
							moveTo(x, y + inteval);
							draw = true;
						}
						y = y + inteval;
					}
					return;
				}
			}
		}*/
		
		override public function zoomTo(z:Number):void
		{
			this._curBorder = this._curBorder.zoomTo(z);
			//drawBorder(this._tile, this._curBorder, 2);
		}
		
		/*override public function load(v:ZoomRect):void
		{
			this.drawBorder(this._tile, this._curBorder);
		}*/
		
		/*override public function moveTo(x0:Number, y0:Number)
		{
			super.moveTo(x0, y0);
			
			this.drawBoder(this._tile, this._curView);
		}*/
	}
}