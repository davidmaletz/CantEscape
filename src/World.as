package  {
	/**
	 * ...
	 * @author David Maletz
	 */
	public class World {
		public static const WALL:int=0, WALL2:int=1, FLOOR:int=2, FLOOR2:int=3, CEILING:int=4, OBJECT:int=5; public static const SIZE:int = 7;
		private var cells:Vector.<Cell>;
		public function World(m:Main){
			var sz:int = SIZE*2+1; cells = new Vector.<Cell>(sz*sz, true); initMap(m);
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
		private function updateMap(m:Main, openList:Vector.<Cell>):void {
			var i:int, c:Cell; for(i=0; i<cells.length; i++) cells[i].visited = false;
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
				c = openList[i]; if(c.type == Cell.FLOOR){c.floor = m.textures[FLOOR]; c.ceiling = m.textures[CEILING];}
				else{c.floor = m.textures[FLOOR]; c.ceiling = m.textures[CEILING]; c.sides = m.textures[WALL2];}
			}
		}
		private function initMap(m:Main):void {
			var openList:Vector.<Cell> = new Vector.<Cell>(); //TODO: initial map fixed
			for(var y:int=-SIZE; y<=SIZE; y++) for(var x:int=-SIZE; x<=SIZE; x++){
				var c:Cell = new Cell(Cell.EMPTY,x,y); cells[(y+SIZE)*(SIZE*2+1)+x+SIZE] = c; openList.push(c);
			} updateMap(m, openList);
		}
		public function shift(m:Main, dir:int):void {
			var openList:Vector.<Cell> = new Vector.<Cell>(); var x:int, y:int; var c:Cell;
			if(dir == 0){
				for(y=SIZE; y>-SIZE; y--) for(x=-SIZE; x<=SIZE; x++) getCell(x,y).copy(getCell(x, y-1));
				for(x=-SIZE; x<=SIZE; x++){c = getCell(x,-SIZE); c.clear(); openList.push(c);}
			} else if(dir == 1){
				for(x=-SIZE; x<SIZE; x++) for(y=-SIZE; y<=SIZE; y++) getCell(x,y).copy(getCell(x+1, y));
				for(y=-SIZE; y<=SIZE; y++){c = getCell(SIZE,y); c.clear(); openList.push(c);}
			} else if(dir == 2){
				for(y=-SIZE; y<SIZE; y++) for(x=-SIZE; x<=SIZE; x++) getCell(x,y).copy(getCell(x, y+1));
				for(x=-SIZE; x<=SIZE; x++){c = getCell(x,SIZE); c.clear(); openList.push(c);}
			} else if(dir == 3){
				for(x=SIZE; x>-SIZE; x--) for(y=-SIZE; y<=SIZE; y++) getCell(x,y).copy(getCell(x-1, y));
				for(y=-SIZE; y<=SIZE; y++){c = getCell(-SIZE,y); c.clear(); openList.push(c);}
			} updateMap(m, openList);
		}
		public function moveTo(x:int, y:int):int {
			switch(getCell(x,y).type){
				case Cell.FLOOR: return 1;
				case Cell.WALL: return 0;
			} return -1;
		}
	}
}