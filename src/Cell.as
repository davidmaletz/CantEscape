package  {
	/**
	 * ...
	 * @author David Maletz
	 */
	public class Cell {
		public static const EMPTY:int=-1, FLOOR:int=0, DOOR:int=1, WALL:int=2, PIT:int=3, TRAP_DOOR:int=4;
		public static const BACK:int = 0; public static const LEFT:int = 1; public static const FRONT:int = 2;
		public static const RIGHT:int = 3; public static const BOTTOM:int = 1; public static const TOP:int = 3;
		public var type:int; public var x:int, y:int; public var unlock:Cell; public var visited:Boolean;
		public var sides:int=-1, floor:int=-1, ceiling:int=-1;
		public function Cell(t:int,_x:int,_y:int){type = t; x = _x; y = _y;}
		public function Set(t:int, s:int=-1, f:int=-1, c:int=-1, u:Cell=null):void {type = t; unlock = u; sides = s; floor = f; ceiling = c;}
		public function clear():void {type = EMPTY; unlock = null; sides = -1; floor = -1; ceiling = -1;}
		public function copy(c:Cell):void {
			type = c.type; sides = c.sides; floor = c.floor; ceiling = c.ceiling; unlock = c.unlock;
		}
		public function Unlock(m:Main):void {if(unlock != null){m.unlockSfx(sides); copy(unlock);}}
		public function drawWalls(m:Main):void {if(sides != -1) m.drawSides(sides,x,y);}
		public function drawFloor(m:Main):void {if(floor != -1) m.drawFloor(floor, BOTTOM, x, y);}
		public function drawCeiling(m:Main):void {if(ceiling != -1) m.drawFloor(ceiling, TOP, x, y);}
	}

}