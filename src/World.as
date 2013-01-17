package  {
	/**
	 * ...
	 * @author David Maletz
	 */
	public class World {
		public static const WALL1_TEX:int=0, WALL2_TEX:int=1, DOOR1_TEX:int=2, DOOR2_TEX:int=3, DOOROPEN_TEX:int = 4,
			FLOOR_TEX:int=5, CEILING_TEX:int=6, PIT1_TEX:int=7, PIT2_TEX:int=8, LADDER_TEX:int=9, N_TEX:int=10;
		public static const SIZE:int = 7;
		private var cells:Vector.<Cell>;
		private var open_door_cell:Cell;
		public function World(){
			var sz:int = SIZE*2+1; cells = new Vector.<Cell>(sz*sz, true); open_door_cell = new Cell(Cell.FLOOR,0,0);
			open_door_cell.floor = FLOOR_TEX; open_door_cell.ceiling = CEILING_TEX; open_door_cell.sides = DOOROPEN_TEX; initMap();
		}
		private function getCell(x:int, y:int):Cell {return cells[(y+SIZE)*(SIZE*2+1)+x+SIZE];}
		public function draw(m:Main):void {
			var r:int, i:int, st:int, st2:int; for(r=0; r<SIZE*2-1; r++){st = Math.max(r-7,0); st2 = Math.max(r-7,1);
				for(i=st; i<=r-st; i++) getCell(i-r,i).drawWalls(m);
				for(i=st2; i<=r-st; i++) getCell(i,r-i).drawWalls(m);
				for(i=st2; i<=r-st; i++) getCell(r-i,-i).drawWalls(m);
				for(i=st2; i<=r-st2; i++) getCell(-i,i-r).drawWalls(m);
			} for(r=0; r<SIZE*2-1; r++){st = Math.max(r-7,0); st2 = Math.max(r-7,1);
				for(i=st; i<=r-st; i++) getCell(i-r,i).drawFloor(m);
				for(i=st2; i<=r-st; i++) getCell(i,r-i).drawFloor(m);
				for(i=st2; i<=r-st; i++) getCell(r-i,-i).drawFloor(m);
				for(i=st2; i<=r-st2; i++) getCell(-i,i-r).drawFloor(m);
			} for(r=0; r<SIZE*2-1; r++){st = Math.max(r-7,0); st2 = Math.max(r-7,1);
				for(i=st; i<=r-st; i++) getCell(i-r,i).drawCeiling(m);
				for(i=st2; i<=r-st; i++) getCell(i,r-i).drawCeiling(m);
				for(i=st2; i<=r-st; i++) getCell(r-i,-i).drawCeiling(m);
				for(i=st2; i<=r-st2; i++) getCell(-i,i-r).drawCeiling(m);
			}
		}
		private function doorFloor(c:Cell, s:int):Boolean {return s == -1 || (s == LADDER_TEX && c.type >= Cell.WALL);}
		private function canDoor(c:Cell):Boolean {
			return ((c.x == -SIZE || getCell(c.x-1,c.y).sides == WALL1_TEX) && (c.x == SIZE || getCell(c.x+1,c.y).sides == WALL1_TEX)
			&& (c.y == -SIZE || doorFloor(c, getCell(c.x,c.y-1).sides)) && (c.y == SIZE || doorFloor(c, getCell(c.x,c.y+1).sides)))
			|| ((c.y == -SIZE || getCell(c.x,c.y-1).sides == WALL1_TEX) && (c.y == SIZE || getCell(c.x,c.y+1).sides == WALL1_TEX)
			&& (c.x == -SIZE || doorFloor(c, getCell(c.x-1,c.y).sides)) && (c.x == SIZE || doorFloor(c, getCell(c.x+1,c.y).sides)));
		}
		private function canLadder(c:Cell):Boolean {
			return (c.x == -SIZE || getCell(c.x-1,c.y).type >= Cell.WALL) && (c.x == SIZE || getCell(c.x+1,c.y).type >= Cell.WALL)
			&& (c.y == -SIZE || getCell(c.x,c.y-1).type >= Cell.WALL) && (c.y == SIZE || getCell(c.x,c.y+1).type >= Cell.WALL);
		}
		private function checkDoor(c:Cell,dx:int,dy:int):void {
			var c2:Cell = getCell(c.x+dx,c.y+dy); if(c2.sides >= WALL2_TEX && c2.sides <= DOOROPEN_TEX){
				if(getCell(c.x+dx*2,c.y+dy*2).sides == -1) c.type = Cell.FLOOR; else{c.type = Cell.WALL; c.sides = WALL1_TEX;}
			}
		}
		private function checkLadder(c:Cell,dx:int,dy:int):void {
			var c2:Cell = getCell(c.x+dx,c.y+dy); if(c2.sides == LADDER_TEX) c.type = Cell.WALL;
		}
		private function updateMap(openList:Vector.<Cell>, dx:int, dy:int):void {
			var i:int, c:Cell; for(i=0; i<cells.length; i++) cells[i].visited = false;
			if(dx != 0 || dy != 0) for(i=0; i<openList.length; i++){checkDoor(openList[i],dx,dy); checkLadder(openList[i],dx,dy);}
			var paths:Vector.<Vector.<Cell> > = new Vector.<Vector.<Cell> >(); var st:Vector.<Cell> = new Vector.<Cell>();
			st.push(getCell(0,0)); paths.push(st); while(paths.length > 0){
				var idx:int = Math.random()*paths.length; var tmp:Vector.<Cell> = paths[idx]; paths[idx] = paths[paths.length-1];
				paths[paths.length-1] = tmp; var path:Vector.<Cell> = paths.pop(); c = path[path.length-1];
				if(Math.abs(c.x) == SIZE || Math.abs(c.y) == SIZE){
					for(i=0; i<path.length; i++){c = path[i]; if(c.type == Cell.EMPTY) c.type = Cell.FLOOR;} break;
				} var ar:Vector.<Cell>; var c2:Cell;
				c2 = getCell(c.x-1, c.y); if(c2.type <= Cell.DOOR && !c2.visited){c2.visited = true; ar = path.concat(); ar.push(c2); paths.push(ar);}
				c2 = getCell(c.x+1, c.y); if(c2.type <= Cell.DOOR && !c2.visited){c2.visited = true; ar = path.concat(); ar.push(c2); paths.push(ar);}
				c2 = getCell(c.x, c.y-1); if(c2.type <= Cell.DOOR && !c2.visited){c2.visited = true; ar = path.concat(); ar.push(c2); paths.push(ar);}
				c2 = getCell(c.x, c.y+1); if(c2.type <= Cell.DOOR && !c2.visited){c2.visited = true; ar = path.concat(); ar.push(c2); paths.push(ar);}
			}
			for(i=0; i<openList.length; i++){
				c = openList[i]; if(c.type == Cell.EMPTY){if(Math.random() < 0.5) c.type = Cell.FLOOR; else c.type = Cell.WALL;}
			}
			for(i=0; i<openList.length; i++){
				c = openList[i]; if(c.type == Cell.FLOOR){c.floor = FLOOR_TEX; c.ceiling = CEILING_TEX;}
				else if(c.sides == -1){
					if(Math.random() < 0.1){c.floor = (Math.random()>0.2)?PIT1_TEX:PIT2_TEX; c.ceiling = CEILING_TEX; c.type = Cell.PIT;}
					else c.sides = WALL1_TEX;
				}
			}
			for(i=0; i<openList.length; i++){
				c = openList[i]; if(canLadder(c) && Math.random() < 0.6) c.Set(Cell.WALL, LADDER_TEX);
				else if(c.type == Cell.FLOOR && (c.x != 0 || c.y != 0) && canDoor(c)){
					c.type = Cell.DOOR; c.sides = (Math.random()>0.3)?DOOR1_TEX:DOOR2_TEX; c.unlock = open_door_cell;
				}
			}
			for(i=0; i<openList.length; i++){
				c = openList[i]; if(c.type == Cell.WALL && canDoor(c)){
					c.floor = FLOOR_TEX; c.ceiling = CEILING_TEX;
					var r:Number = Math.random(); c.sides = (r>0.2)?WALL2_TEX:((r > 0.06)?DOOR1_TEX:DOOR2_TEX);
					if(c.sides != WALL2_TEX && Math.random() < 0.1) c.type = Cell.TRAP_DOOR;
				}
			}
		}
		private function initMap():void {
			var openList:Vector.<Cell> = new Vector.<Cell>();
			for(var y:int=-SIZE; y<=SIZE; y++) for(var x:int=-SIZE; x<=SIZE; x++){
				var c:Cell = new Cell(Cell.EMPTY,x,y); cells[(y+SIZE)*(SIZE*2+1)+x+SIZE] = c;
				if(x == 0 && y == -1) c.Set(Cell.WALL, DOOR1_TEX, FLOOR_TEX, CEILING_TEX);
				else if(x == 0 && y == -3) c.Set(Cell.WALL, WALL2_TEX, FLOOR_TEX, CEILING_TEX);
				else if(x == 0 && y == -2) c.Set(Cell.WALL, LADDER_TEX);
				else if(Math.abs(x) <= 1 && Math.abs(y+2) <= 1) c.Set(Cell.WALL, WALL1_TEX);
				else if(Math.abs(x) <= 2 && Math.abs(y+2) <= 2) c.Set(Cell.FLOOR, -1, FLOOR_TEX, CEILING_TEX);
				else if(y == -2 && Math.abs(x) == 3) c.Set(Cell.DOOR, DOOR1_TEX, FLOOR_TEX, CEILING_TEX, open_door_cell);
				else if(x == 0 && Math.abs(y+2) == 3) c.Set(Cell.DOOR, DOOR2_TEX, FLOOR_TEX, CEILING_TEX, open_door_cell);
				else if(y == -2 && Math.abs(x) == 4) c.Set(Cell.FLOOR, -1, FLOOR_TEX, CEILING_TEX);
				else if(x == 0 && Math.abs(y+2) == 4) c.Set(Cell.FLOOR, -1, FLOOR_TEX, CEILING_TEX);
				else if(Math.abs(x) <= 3 && Math.abs(y+2) <= 3) c.Set(Cell.WALL, WALL1_TEX);
				else openList.push(c);
			}  updateMap(openList,0,0);
		}
		public function regenerate():void {
			var openList:Vector.<Cell> = new Vector.<Cell>();
			for(var y:int=-SIZE; y<=SIZE; y++) for(var x:int=-SIZE; x<=SIZE; x++){
				var c:Cell = getCell(x,y); c.clear(); openList.push(c);
			} updateMap(openList,0,0);
		}
		public function loadEnd():void {
			var openList:Vector.<Cell> = new Vector.<Cell>();
			for(var y:int=-SIZE; y<=SIZE; y++) for(var x:int=-SIZE; x<=SIZE; x++){
				var c:Cell = getCell(x,y); c.clear(); if(x == 0 && y == 0){c.type = Cell.FLOOR; c.floor = FLOOR_TEX; c.ceiling = CEILING_TEX;}
				else if((Math.abs(x) == 1 && y == 0) || (Math.abs(y) == 1 && x == 0)){
					c.type = Cell.WALL; c.floor = FLOOR_TEX; c.ceiling = CEILING_TEX; c.sides = DOOR1_TEX;
				} else openList.push(c);
			} updateMap(openList,0,0);
		}
		public function shift(dir:int):Boolean {
			var openList:Vector.<Cell> = new Vector.<Cell>(); var x:int, y:int, dx:int=0, dy:int=0; var c:Cell;
			if(dir == 0){
				for(y=SIZE; y>-SIZE; y--) for(x=-SIZE; x<=SIZE; x++) getCell(x,y).copy(getCell(x, y-1));
				for(x=-SIZE; x<=SIZE; x++){c = getCell(x,-SIZE); c.clear(); openList.push(c);} dx = 0; dy = 1;
			} else if(dir == 1){
				for(x=-SIZE; x<SIZE; x++) for(y=-SIZE; y<=SIZE; y++) getCell(x,y).copy(getCell(x+1, y));
				for(y=-SIZE; y<=SIZE; y++){c = getCell(SIZE,y); c.clear(); openList.push(c);} dx = -1; dy = 0;
			} else if(dir == 2){
				for(y=-SIZE; y<SIZE; y++) for(x=-SIZE; x<=SIZE; x++) getCell(x,y).copy(getCell(x, y+1));
				for(x=-SIZE; x<=SIZE; x++){c = getCell(x,SIZE); c.clear(); openList.push(c);} dx = 0; dy = -1;
			} else if(dir == 3){
				for(x=SIZE; x>-SIZE; x--) for(y=-SIZE; y<=SIZE; y++) getCell(x,y).copy(getCell(x-1, y));
				for(y=-SIZE; y<=SIZE; y++){c = getCell(-SIZE,y); c.clear(); openList.push(c);} dx = 1; dy = 0;
			} updateMap(openList,dx,dy); return getCell(0,0).type != Cell.PIT;
		}
		public function moveTo(m:Main, x:int, y:int):int {
			var c:Cell = getCell(x,y); switch(c.type){
				case Cell.FLOOR: return 1;
				case Cell.DOOR: c.Unlock(m); return -1;
				case Cell.WALL: return 0;
				case Cell.PIT: return 1;
				case Cell.TRAP_DOOR: return -2;
			} return -1;
		}
	}
}