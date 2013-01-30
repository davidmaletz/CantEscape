package  {
	/**
	 * ...
	 * @author David Maletz
	 */
	public class World {
		public static const WALL1_TEX:int=0, WALL2_TEX:int=1, WALL3_TEX:int=2, WINDOW_TEX:int=3, DOOR1_TEX:int=4, DOOR2_TEX:int=5,
			DOOROPEN_TEX:int=6, FLOOR_TEX:int=7, FLOOR_KEY_TEX:int=8, CEILING_TEX:int=9, CEILING_HOLE_TEX:int=10, PIT1_TEX:int=11,
			PIT2_TEX:int=12, PIT3_TEX:int=13, LADDER_TEX:int=14, N_TEX:int=15;
		public static const LIGHTSHAFT_SPRITE:int=0, GHOST_SPRITE:int=1, MONSTER_SPRITE:int=2, EYE1_SPRITE:int=3, EYE2_SPRITE:int=4, EYE3_SPRITE:int=5;
		public static const SIZE:int = 7;
		private var cells:Vector.<Cell>;
		private var open_door_cell:Cell;
		public function World(){
			var sz:int = SIZE*2+1; cells = new Vector.<Cell>(sz*sz, true); open_door_cell = new Cell(Cell.FLOOR,0,0);
			open_door_cell.sides = DOOROPEN_TEX; initMap();
		}
		public function getCell(x:int, y:int):Cell {return cells[(y+SIZE)*(SIZE*2+1)+x+SIZE];}
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
		private var monster_x:Number=Number.POSITIVE_INFINITY, monster_y:Number=0, monster_z:Number=0,
			ghost_x:Number=Number.POSITIVE_INFINITY, ghost_y:Number=0, ghost_ang:Number=0;
		private function showMonster(x:int, y:int):void {monster_x = x; monster_y = y; monster_z = -1;}
		public function drawSprites(m:Main):void {
			var r:int, i:int, st:int, st2:int; for(r=SIZE*2-2; r>=0; r--){st = Math.max(r-7,0); st2 = Math.max(r-7,1);
				for(i=st; i<=r-st; i++) getCell(i-r,i).drawSprite(m);
				for(i=st2; i<=r-st; i++) getCell(i,r-i).drawSprite(m);
				for(i=st2; i<=r-st; i++) getCell(r-i,-i).drawSprite(m);
				for(i=st2; i<=r-st2; i++) getCell(-i,i-r).drawSprite(m);
			}
			if(monster_x != Number.POSITIVE_INFINITY){
				m.drawSprite(MONSTER_SPRITE, monster_x, monster_y, monster_z);
				monster_z += 0.03; if(monster_z > 1){
					if(Math.abs(monster_x) <= SIZE && Math.abs(monster_y) <= SIZE) getCell(int(monster_x), int(monster_y)).type = Cell.PIT;
					monster_x = Number.POSITIVE_INFINITY;
				}
			} if(ghost_x != Number.POSITIVE_INFINITY){
				m.drawSprite(GHOST_SPRITE, ghost_x, ghost_y); var len:Number = ghost_x*ghost_x+ghost_y*ghost_y; if(len > 16){
					len = 1.0/Math.sqrt(len); ghost_x -= ghost_x*len*0.03; ghost_y -= ghost_y*len*0.03;
				} else {ghost_ang += Math.random()*0.2-0.09; ghost_x += Math.cos(ghost_ang)*0.03; ghost_y += Math.sin(ghost_ang)*0.03;}
			}
		}
		private function initGhost():void {
			var a:Number = Math.random()*Math.PI*2; ghost_x = Math.cos(a)*4; ghost_y = Math.sin(a)*4; ghost_ang = Math.random()*Math.PI*2;
		}
		private function doorFloor(c:Cell, s:int):Boolean {return s == -1 || (s == LADDER_TEX && c.type >= Cell.WALL);}
		private function isSolid(s:int):Boolean {return s >= WALL1_TEX && s <= WALL3_TEX;}
		private function canDoor(c:Cell):Boolean {
			return ((c.x == -SIZE || isSolid(getCell(c.x-1,c.y).sides)) && (c.x == SIZE || isSolid(getCell(c.x+1,c.y).sides))
			&& (c.y == -SIZE || doorFloor(c, getCell(c.x,c.y-1).sides)) && (c.y == SIZE || doorFloor(c, getCell(c.x,c.y+1).sides)))
			|| ((c.y == -SIZE || isSolid(getCell(c.x,c.y-1).sides)) && (c.y == SIZE || isSolid(getCell(c.x,c.y+1).sides))
			&& (c.x == -SIZE || doorFloor(c, getCell(c.x-1,c.y).sides)) && (c.x == SIZE || doorFloor(c, getCell(c.x+1,c.y).sides)));
		}
		private function canLadder(c:Cell):Boolean {
			return (c.x == -SIZE || getCell(c.x-1,c.y).type >= Cell.WALL) && (c.x == SIZE || getCell(c.x+1,c.y).type >= Cell.WALL)
			&& (c.y == -SIZE || getCell(c.x,c.y-1).type >= Cell.WALL) && (c.y == SIZE || getCell(c.x,c.y+1).type >= Cell.WALL);
		}
		private function adjacentLadder(c:Cell):Boolean {
			return (c.x != -SIZE && getCell(c.x-1,c.y).sides == LADDER_TEX) || (c.x != SIZE && getCell(c.x+1,c.y).sides == LADDER_TEX)
			|| (c.y != -SIZE && getCell(c.x,c.y-1).sides == LADDER_TEX) || (c.y != SIZE && getCell(c.x,c.y+1).sides == LADDER_TEX);
		}
		private function getWallSides():int {
			var r:Number = Math.random(); var p:Number = 1.0-(Main.level+1)*0.03; return (r<=p*0.5)?WALL1_TEX:((r<=p)?WALL2_TEX:WALL3_TEX);
		}
		private function checkDoor(c:Cell,dx:int,dy:int):void {
			var c2:Cell = getCell(c.x+dx,c.y+dy); if(c2.sides >= WINDOW_TEX && c2.sides <= DOOROPEN_TEX){
				if(getCell(c.x+dx*2,c.y+dy*2).sides == -1) c.type = Cell.FLOOR; else{c.type = Cell.WALL; c.sides = getWallSides();}
			}
		}
		private function checkLadder(c:Cell,dx:int,dy:int):void {
			var c2:Cell = getCell(c.x+dx,c.y+dy); if(c2.sides == LADDER_TEX) c.type = Cell.WALL;
		}
		private function pickupKey():void {
			for(var i:int=0; i<cells.length; i++){
				var c:Cell = cells[i]; if(((Main.level > 0 && ladder_ct > 0) || !adjacentLadder(c)) && c.type == Cell.WALL && c.sides == DOOR1_TEX){
					c.type = Cell.DOOR; c.unlock = open_door_cell;
				}
			}
		}
		private var ladder_ct:int=2;
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
				c = openList[i]; if(c.type == Cell.FLOOR){
					c.floor = FLOOR_TEX; c.ceiling = CEILING_TEX; if(Math.random() < 0.025){c.floor = FLOOR_KEY_TEX; c.type = Cell.KEY;}
					else if(Math.random() < 0.02) c.floor = PIT3_TEX;
				}
				else if(c.sides == -1){
					if(Math.random() < 0.1){
						c.floor = (Math.random()>0.2)?PIT1_TEX:PIT2_TEX;
						if(Main.level > 0 && c.floor == PIT1_TEX && Math.random() < 0.2) c.ceiling = CEILING_HOLE_TEX;
						else {c.ceiling = CEILING_TEX; c.type = Cell.PIT;}
					}
					else c.sides = getWallSides();
				}
			}
			for(i=0; i<openList.length; i++){
				c = openList[i]; if((canLadder(c) || (ladder_ct > 0 && (dx != 0 || dy != 0) && c.type == Cell.WALL && Main.level > 0 && Math.random()<0.025)) && Math.random() < 0.6){
					c.Set(Cell.LADDER, LADDER_TEX);
					if(c.x != -SIZE && getCell(c.x-1,c.y).ceiling == CEILING_TEX) getCell(c.x-1,c.y).ceiling = CEILING_HOLE_TEX;
					if(c.x != SIZE && getCell(c.x+1,c.y).ceiling == CEILING_TEX) getCell(c.x+1,c.y).ceiling = CEILING_HOLE_TEX;
					if(c.y != -SIZE && getCell(c.x,c.y-1).ceiling == CEILING_TEX) getCell(c.x,c.y-1).ceiling = CEILING_HOLE_TEX;
					if(c.y != SIZE && getCell(c.x,c.y+1).ceiling == CEILING_TEX) getCell(c.x,c.y+1).ceiling = CEILING_HOLE_TEX;
				} else if(c.type == Cell.FLOOR && (c.x != 0 || c.y != 0) && canDoor(c)){
					c.type = Cell.DOOR; c.sides = (Math.random()>0.3)?DOOR1_TEX:DOOR2_TEX; c.unlock = open_door_cell;
				}
			}
			for(i=0; i<openList.length; i++){
				c = openList[i]; if(c.type == Cell.WALL && canDoor(c)){
					c.floor = FLOOR_TEX; c.ceiling = CEILING_TEX;
					var r:Number = Math.random(); c.sides = (r>0.2)?WINDOW_TEX:DOOR1_TEX;
					if(c.sides != WINDOW_TEX && Math.random() < 0.1) c.type = Cell.TRAP_DOOR;
				}
				if(c.ceiling == CEILING_TEX && adjacentLadder(c)) c.ceiling = CEILING_HOLE_TEX;
				if(isSolid(c.sides) && Math.random()<0.05*Main.level) c.eye = int(Math.random()*4);
			} for(i=0; i<openList.length; i++){
				c = openList[i]; if(c.ceiling == CEILING_TEX && Math.random() < 0.08) c.ceiling = CEILING_HOLE_TEX;
			}
		}
		private function initMap():void {
			for(var y:int=-SIZE; y<=SIZE; y++) for(var x:int=-SIZE; x<=SIZE; x++){
				var c:Cell = new Cell(Cell.EMPTY,x,y); cells[(y+SIZE)*(SIZE*2+1)+x+SIZE] = c;
			} getCell(0,-1).sides = -2; getCell(0,0).floor = PIT1_TEX;
		}
		private function loadStart():void {
			var openList:Vector.<Cell> = new Vector.<Cell>();
			for(var y:int=-SIZE; y<=SIZE; y++) for(var x:int=-SIZE; x<=SIZE; x++){
				var c:Cell = getCell(x,y); c.clear();
				if(x == 0 && y == -1) c.Set(Cell.WALL, DOOR1_TEX, FLOOR_TEX, CEILING_HOLE_TEX);
				else if(x == 0 && y == -3) c.Set(Cell.WALL, WINDOW_TEX, FLOOR_TEX, CEILING_HOLE_TEX);
				else if(x == 0 && y == -2) c.Set(Cell.LADDER, LADDER_TEX);
				else if(Math.abs(x) <= 1 && Math.abs(y+2) <= 1) c.Set(Cell.WALL, (Math.random()<=0.5)?WALL1_TEX:WALL2_TEX);
				else if(Math.abs(x) <= 2 && Math.abs(y+2) <= 2) c.Set(Cell.FLOOR, -1, FLOOR_TEX, CEILING_TEX);
				else if(y == -2 && Math.abs(x) == 3) c.Set(Cell.DOOR, DOOR1_TEX, FLOOR_TEX, CEILING_TEX, open_door_cell);
				else if(x == 0 && Math.abs(y+2) == 3) c.Set(Cell.DOOR, DOOR2_TEX, FLOOR_TEX, CEILING_TEX, open_door_cell);
				else if(y == -2 && Math.abs(x) == 4) c.Set(Cell.FLOOR, -1, FLOOR_TEX, CEILING_TEX);
				else if(x == 0 && Math.abs(y+2) == 4) c.Set(Cell.FLOOR, -1, FLOOR_TEX, CEILING_TEX);
				else if(Math.abs(x) <= 3 && Math.abs(y+2) <= 3) c.Set(Cell.WALL, (Math.random()<=0.5)?WALL1_TEX:WALL2_TEX);
				else openList.push(c);
			}  updateMap(openList,0,0); getCell(0,0).ceiling = CEILING_HOLE_TEX;
		}
		public function regenerate(climb:Boolean=false):void {
			if(climb) ladder_ct--;
			if(!climb && Main.level == 0) loadStart(); else if(Main.level == 12) loadEnd(); else if(Main.level == -1){
				getCell(0,-1).Set(Cell.WALL, -2); getCell(0,0).Set(Cell.FLOOR, -1, PIT1_TEX);
			} else {
				var openList:Vector.<Cell> = new Vector.<Cell>();
				for(var y:int=-SIZE; y<=SIZE; y++) for(var x:int=-SIZE; x<=SIZE; x++){
					var c:Cell = getCell(x,y); c.clear(); openList.push(c);
				} monster_x = ghost_x = Number.POSITIVE_INFINITY; updateMap(openList,0,0);
				if(Main.level > 0 && Main.level%2 == 0) initGhost();
				if(climb) getCell(0,0).floor = PIT3_TEX; else getCell(0,0).ceiling = CEILING_HOLE_TEX;
			}
		}
		public function loadEnd():void {
			var openList:Vector.<Cell> = new Vector.<Cell>();
			for(var y:int=-SIZE; y<=SIZE; y++) for(var x:int=-SIZE; x<=SIZE; x++){
				var c:Cell = getCell(x,y); c.clear(); if(x == 0 && y == 0){c.type = Cell.FLOOR; c.floor = FLOOR_TEX; c.ceiling = CEILING_HOLE_TEX;}
				else if((Math.abs(x) == 1 && y == 0) || (Math.abs(y) == 1 && x == 0)){
					c.type = Cell.WALL; c.floor = FLOOR_TEX; c.ceiling = CEILING_TEX; c.sides = DOOR1_TEX;
				} else openList.push(c);
			} monster_x = ghost_x = Number.POSITIVE_INFINITY; updateMap(openList,0,0);
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
			} updateMap(openList,dx,dy); monster_x += dx; monster_y += dy; ghost_x += dx; ghost_y += dy;
			return getCell(0,0).type != Cell.PIT;
		}
		public function moveTo(m:Main, x:int, y:int):int {
			var c:Cell = getCell(x,y); switch(c.type){
				case Cell.FLOOR: return 1;
				case Cell.DOOR: c.Unlock(m); return -1;
				case Cell.LADDER: return -3;
				case Cell.KEY: pickupKey(); m.pickupKey(); c.type = Cell.FLOOR; c.floor = FLOOR_TEX; return 1;
				case Cell.WALL: if(c.sides == -1 && monster_x == Number.POSITIVE_INFINITY) showMonster(x,y); return 0;
				case Cell.PIT: return 1;
				case Cell.TRAP_DOOR: return -2;
			} return -1;
		}
	}
}