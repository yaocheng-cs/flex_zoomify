package com.repilac.multimap
{
	import flash.display.Sprite;

	/**
	 * container for drawing tile
	 */
	public class Tile extends Sprite
	{
		public var tier:int;
		public var col:int;
		public var row:int;
		public var active:Boolean;
		public var pending:Boolean;
		
		public function Tile(tier:int, col:int, row:int, x:Number, y:Number)
		{
			super();
			
			this.tier = tier;
			this.col = col;
			this.row = row;
			this.x = x;
			this.y = y;
			this.active = true;
			this.pending = false;
		}
		
		public function get id():String
		{
			return tier + "-" + col + "-" + row;
		}
	}
}