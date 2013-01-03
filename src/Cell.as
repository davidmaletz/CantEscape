package  {
	import flash.display3D.textures.Texture;
	/**
	 * ...
	 * @author David Maletz
	 */
	public class Cell {
		public static const EMPTY:int=-1, FLOOR:int=0, DOOR:int=1, WALL:int=2, PIT:int=3, TRAP_DOOR:int=4;
		public static const BACK:int = 0; public static const LEFT:int = 1; public static const FRONT:int = 2;
		public static const RIGHT:int = 3; public static const BOTTOM:int = 1; public static const TOP:int = 3;
		public var type:int; public var x:int, y:int; public var unlock:Cell; public var visited:Boolean;
		public var sides:Texture, floor:Texture, ceiling:Texture;
		public function Cell(t:int,_x:int,_y:int){type = t; x = _x; y = _y;}
		public function clear():void {type = EMPTY; unlock = null; sides = null; floor = null; ceiling = null;}
		public function copy(c:Cell):void {
			type = c.type; sides = c.sides; floor = c.floor; ceiling = c.ceiling; unlock = c.unlock;
		}
		public function Unlock():void {if(unlock != null) copy(unlock);}
		public function drawWalls(m:Main):void {if(sides != null) m.drawSides(sides,x,y);}
		public function drawFloor(m:Main):void {if(floor != null) m.drawFloor(floor, BOTTOM, x, y);}
		public function drawCeiling(m:Main):void {if(ceiling != null) m.drawFloor(ceiling, TOP, x, y);}
	}

}