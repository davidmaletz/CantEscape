package  {
	/**
	 * ...
	 * @author David Maletz
	 */
	public class Cell {
		public static const EMPTY:int=-1, FLOOR:int=0, DOOR:int=1, LADDER:int=2, KEY:int=3, WALL:int=4, PIT:int=5, TRAP_DOOR:int=6;
		public static const BACK:int = 0; public static const LEFT:int = 1; public static const FRONT:int = 2;
		public static const RIGHT:int = 3; public static const BOTTOM:int = 1; public static const TOP:int = 3;
		public var type:int; public var x:int, y:int; public var unlock:Cell; public var visited:Boolean; public var eye:int=-1;
		public var sides:int=-1, floor:int=-1, ceiling:int=-1;
		public function Cell(t:int,_x:int,_y:int){type = t; x = _x; y = _y;}
		public function Set(t:int, s:int=-1, f:int=-1, c:int=-1, u:Cell=null):void {type = t; unlock = u; sides = s; eye = -1; floor = f; ceiling = c;}
		public function clear():void {type = EMPTY; unlock = null; sides = -1; eye = -1; floor = -1; ceiling = -1;}
		public function copy(c:Cell):void {
			type = c.type; sides = c.sides; eye = c.eye; floor = c.floor; ceiling = c.ceiling; unlock = c.unlock;
		}
		public function Unlock(m:Main):void {if(unlock != null){m.unlockSfx(sides); Set(unlock.type, unlock.sides, floor, ceiling, unlock.unlock);}}
		public function drawWalls(m:Main):void {if(sides != -1) m.drawSides(sides,x,y);}
		public function drawFloor(m:Main):void {if(floor != -1) m.drawFloor(floor, BOTTOM, x, y);}
		public function drawCeiling(m:Main):void {if(ceiling != -1) m.drawFloor(ceiling, TOP, x, y);}
		public function drawSprite(m:Main):void {
			if(eye != -1 && Main.level != 0 && Main.level != 12){
				var dx:int = m.getDx(m.getFacing()), dy:int = m.getDy(m.getFacing()), tx:int = (x>0)?1:((x<0)?-1:0), ty:int = (y>0)?1:((y<0)?-1:0);
				var frame:int = eye>>2, dir:int = eye&3; if(dx == tx && dy == ty){if(frame < 47) frame++;} else if(frame > 0) frame--; eye = (frame<<2)|dir;
				m.setDarkness(m.getDarkness()*0.5); m.drawWall(World.EYE1_SPRITE+(frame>>4), dir, x, y, true);
			}
			if(ceiling == World.CEILING_HOLE_TEX) m.drawSprite(World.LIGHTSHAFT_SPRITE, x, y);
		}
	}

}