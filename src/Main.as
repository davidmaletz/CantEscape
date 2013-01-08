package {
	import com.adobe.utils.AGALMiniAssembler;
    import com.adobe.utils.PerspectiveMatrix3D;
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.display.StageDisplayState;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import flash.events.Event;
	import flash.events.ErrorEvent;
	
	import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DRenderMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
	
	import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author David Maletz
	 */
	public class Main extends Sprite {
		/** TODO:
		 * Integrate art and assets, and we're done WOHOO!
		 */
		public static const DEBUG:Boolean = true;
		
		private var viewWidth:int;
		private var viewHeight:int;
		private const zNear:Number = 0.25;
        private const zFar:Number = 20;
		private const fov:Number = 45;
		
		private var stage3D:Stage3D;
        private var context:Context3D;
        private var indicesWall:IndexBuffer3D;
        private var indicesSides:IndexBuffer3D;
		private var vertices:VertexBuffer3D;
		private var cur_tex:int=-1;
		public var textures:Vector.<Texture>;
		
		private var projection:PerspectiveMatrix3D = new PerspectiveMatrix3D();
        private var view:Matrix3D = new Matrix3D();
		private var projView:Matrix3D = new Matrix3D();
        private var trans:Matrix3D = new Matrix3D();
		
		private var up_dir:Vector3D = new Vector3D(0,1,0);
		private var right_dir:Vector3D = new Vector3D(1,0,0);
		private var zero:Vector3D = new Vector3D(0,0,0);
		
		private const VERTEX_SHADER:String =
            "m44 vt0, va0, vc1\n"+
			"mov op, vt0\n"+
			"mul vt0.w, vt0.w, vc0.w\n"+
			"mov v0, vt0.wwww\n"+
            "mov v1, va1";
		private const FRAGMENT_SHADER:String = 
			"tex ft0, v1, fs0 <2d,nomip,nearest,clamp>\n"+
			"sub ft1.x, ft0.w, fc0.x\n"+
			"kil ft1.x\n"+
			"exp ft1.x, v0.x\n"+
			"mul ft0.xyz, ft0.xyz, ft1.xxx\n"+
			//"tex ft1, v1, fs1 <2d,miplinear,nearest,clamp>\n"+
			//"add ft0.xyz, ft1.xyz\n"+
            "mov oc, ft0";
			
		private var vertexAssembly:AGALMiniAssembler = new AGALMiniAssembler();
        private var fragmentAssembly:AGALMiniAssembler = new AGALMiniAssembler();
        private var programPair:Program3D;
		
		[Embed(source = '../lib/A1_wall.png')]
		private var L1Wall1:Class;
		[Embed(source = '../lib/A1_windowwall.png')]
		private var L1Wall2:Class;
		[Embed(source = '../lib/A1_lockeddoor.png')]
		private var L1Door1:Class;
		[Embed(source = '../lib/A1_hiddendoor.png')]
		private var L1Door2:Class;
		[Embed(source = '../lib/A1_opendoor.png')]
		private var L1DoorOpen:Class;
		[Embed(source = '../lib/A1_floor.png')]
		private var L1Floor:Class;
		[Embed(source = '../lib/A1_ceiling.png')]
		private var L1Ceiling:Class;
		[Embed(source = '../lib/A1_openpit.png')]
		private var L1Pit1:Class;
		[Embed(source = '../lib/A1_hiddenpit.png')]
		private var L1Pit2:Class;
		
		[Embed(source='../lib/I Can\'t Escape_track 3.mp3')] 
		private var bgm:Class;
		
		[Embed(source = "../lib/GypsyCurse.ttf",fontName = "Gypsy Curse",mimeType = "application/x-font",
		fontWeight="normal",fontStyle="normal", unicodeRange="U+0027,U+0041-U+005a",advancedAntiAliasing="true",embedAsCFF="false")] 
		public static var Gypsy_Curse:Class;
		
		private var world:World; private var new_game:Boolean = true;
		
		public function Main():void {
			if (stage) init(); else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE; stage.align = StageAlign.TOP_LEFT;
			mainMenu();
		}
		private var current_channel:SoundChannel, menu:Sprite;
		private function mainMenu():void {
			stage.displayState=StageDisplayState.NORMAL;
			if(context != null){context.dispose(); context = null;}
			if(menu != null){menu.parent.removeChild(menu); menu = null;}
			if(current_channel != null){current_channel.stop(); current_channel = null;} stage.removeEventListener(Event.ENTER_FRAME, render);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, key_down); stage.removeEventListener(KeyboardEvent.KEY_UP, key_up);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouse_check); stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouse_check);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouse_check);
			var s:Sprite = new Sprite(); s.graphics.beginFill(0); s.graphics.drawRect(0,0,5000,5000); s.graphics.endFill();
			var t:TextField = new TextField(); t.embedFonts = true; var tf:TextFormat = new TextFormat("Gypsy Curse",80,0xffffff);
			tf.align = TextFormatAlign.CENTER; t.defaultTextFormat = tf; t.text = "I CAN'T ESCAPE"; t.width = stage.stageWidth;
			t.height = stage.stageHeight; t.mouseEnabled = false; t.y = 100; s.addChild(t); t = new TextField(); tf = new TextFormat(null, 24, 0xffffff);
			tf.align = TextFormatAlign.CENTER; t.defaultTextFormat = tf; t.text = "We recommend playing in a dimly lit room\nwith your speaker or headphone volume turned up.";
			t.width = stage.stageWidth; t.height = stage.stageHeight; t.mouseEnabled = false; t.y = 240; s.addChild(t); t = new TextField();
			t.embedFonts = true; tf = new TextFormat("Gypsy Curse", 60, 0x990000); t.defaultTextFormat = tf; t.text = "BEGIN";
			t.x = (stage.stageWidth-t.textWidth)/2; t.width = t.textWidth; t.height = t.textHeight; t.mouseEnabled = false; t.y = 330;
			var b:Sprite = new Sprite(); b.buttonMode = true; b.useHandCursor = true; b.addChild(t); s.addChild(b);
			b.addEventListener(MouseEvent.CLICK, newGame); menu = s; stage.addChild(s);
		}
		public function newGame(e:Event):void {
			stage.displayState=StageDisplayState.FULL_SCREEN; stage.focus = stage;
			if(menu != null){menu.parent.removeChild(menu); menu = null;}
			new_game = true; var s:* = stage; if(s.hasOwnProperty("nativeWindow")) s.nativeWindow.activate();
			move_ct = 0; kup = mup = kdown = mdown = kleft = mleft = kright = mright = false; stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, contextCreated);
			stage3D.requestContext3D();
			vertexAssembly.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER, false);
			fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER, false);
		}
		private function contextCreated(event:Event):void {
			context = Stage3D(event.target).context3D; if(DEBUG) context.enableErrorChecking = true; initContext();
			if(new_game){
				setLevel(0); world = new World(); current_channel = (new bgm() as Sound).play(0, int.MAX_VALUE);
				stage.addEventListener(Event.ENTER_FRAME, render);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, key_down); stage.addEventListener(KeyboardEvent.KEY_UP, key_up);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, mouse_check); stage.addEventListener(MouseEvent.MOUSE_MOVE, mouse_check);
				stage.addEventListener(MouseEvent.MOUSE_UP, mouse_check); new_game = false;
			} else setLevel(level);
		}
		private function initContext():void {
			viewWidth = stage.stageWidth; viewHeight = stage.stageHeight;
			context.configureBackBuffer(viewWidth, viewHeight, 2, true); context.setDepthTest(true, Context3DCompareMode.LESS);
			context.setCulling(Context3DTriangleFace.BACK);
			var trianglesWall:Vector.<uint> = Vector.<uint>([2,1,0,3,2,0]);
			indicesWall = context.createIndexBuffer(trianglesWall.length);
			indicesWall.uploadFromVector(trianglesWall, 0, trianglesWall.length);
			var trianglesSides:Vector.<uint> = Vector.<uint>([
				2,1,0,
                3,2,0,
				
                4,7,5,
                7,6,5,
				
                8,11,9,
                9,11,10,
				
                12,15,13,
                13,15,14]);
			indicesSides = context.createIndexBuffer(trianglesSides.length);
			indicesSides.uploadFromVector(trianglesSides, 0, trianglesSides.length);
			const dataPerVertex:int = 5; var vertexData:Vector.<Number> = Vector.<Number>([
                    -1,-1,-1, 1,0,
                    -1,1,-1, 1,1,
                    1,1,-1, 0,1,
                    1,-1,-1, 0,0,
                    
                    -1,-1,1, 0,0,
                    1,-1,1, 1,0,
                    1,1,1, 1,1,
                    -1,1,1, 0,1,
                    
                    -1,1,1, 1,1,
                    -1,1,-1, 0,1,
                    -1,-1,-1, 0,0,
                    -1,-1,1, 1,0,
                    
                    1,1,-1, 1,1,
                    1,1,1, 0,1,
                    1,-1,1, 0,0,
                    1,-1,-1, 1,0
			]);
			vertices = context.createVertexBuffer(vertexData.length/dataPerVertex, dataPerVertex);
			vertices.uploadFromVector(vertexData, 0, vertexData.length/dataPerVertex);
			context.setVertexBufferAt(0, vertices, 0, Context3DVertexBufferFormat.FLOAT_3);
			context.setVertexBufferAt(1, vertices, 3, Context3DVertexBufferFormat.FLOAT_2);
			
			programPair = context.createProgram();
			programPair.upload(vertexAssembly.agalcode, fragmentAssembly.agalcode);
			context.setProgram(programPair);
			var t:Number = 0.5; var thresh:Vector.<Number> = Vector.<Number>([t,t,t,t]);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,thresh);
			
			createTextures();
			
			projection.perspectiveFieldOfViewRH(fov, viewWidth/viewHeight, zNear, zFar);
		}
		public function drawSides(tex:int, x:Number, y:Number):void {
			trans.identity(); trans.appendTranslation(x*2,0,y*2); trans.append(projView);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, trans, true);
			if(tex != cur_tex){context.setTextureAt(0, textures[tex]); cur_tex = tex;} context.drawTriangles(indicesSides, 0, 8);
		}
		public function drawWall(tex:int, side:int, x:Number, y:Number):void {
			trans.identity(); trans.appendRotation(side*90,up_dir,zero);
			trans.appendTranslation(x*2,0,y*2); trans.append(projView);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, trans, true);
			if(tex != cur_tex){context.setTextureAt(0, textures[tex]); cur_tex = tex;} context.drawTriangles(indicesWall, 0, 2);
		}
		public function drawFloor(tex:int, side:int, x:Number, y:Number):void {
			trans.identity(); trans.appendRotation(side*90,right_dir,zero); trans.appendScale(1,-1,1);
			trans.appendTranslation(x*2,0,y*2); trans.append(projView);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, trans, true);
			if(tex != cur_tex){context.setTextureAt(0, textures[tex]); cur_tex = tex;} context.drawTriangles(indicesWall, 0, 2);
		}
		private var move_ct:int = 0, move_dir:int, max_move:int, blocked:Boolean=false, facing:int=0, move_speed:int, rot_speed:int,
			fall_ct:int=12, halt:Boolean = false, kup:Boolean = false, kdown:Boolean = false, kleft:Boolean = false, kright:Boolean = false,
			mup:Boolean = false, mdown:Boolean = false, mleft:Boolean = false, mright:Boolean = false, level:int = 0;
		private function setLevel(l:int):void {level = l; setDarkness(-0.5-0.1*l); l >>= 1; move_speed = 27-3*l; rot_speed = 15-3*l;}
		private function setDarkness(f:Number):void {
			var vc:Vector.<Number> = Vector.<Number>([f,f,f,f]); context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,0,vc);
		}
		public function fall():void {move_dir = 4; max_move = move_ct = fall_ct;}
		private function getDx(f:int):int {return (f&1)*((f>=2)?-1:1);}
		private function getDy(f:int):int {return ((f+1)&1)*((f>=2)?1:-1);}
		private function render(event:Event):void {
			view.identity(); if(move_ct == 0){
				var t:int; if(kup || mup){
					t = world.moveTo(getDx(facing), getDy(facing)); if(t >= 0){
						move_dir = 0; max_move = move_speed; blocked = t == 0; if(blocked) max_move/=3; move_ct = max_move;
					} else if(t == -2) fall(); else {if(kup) halt = true; kup = mup = kdown = mdown = kleft = mleft = kright = mright = false;}
				} else if(kdown || mdown){
					t = world.moveTo(-getDx(facing), -getDy(facing)); if(t >= 0){
						move_dir = 1; max_move = move_speed; blocked = t == 0; if(blocked) max_move/=3; move_ct = max_move;
					} else if(t == -2) fall(); else {if(kdown) halt = true; kup = mup = kdown = mdown = kleft = mleft = kright = mright = false;}
				} else if(kleft || mleft){move_dir = 2; facing--; if(facing < 0) facing = 3; max_move = move_ct = rot_speed;}
				else if(kright || mright){move_dir = 3; facing++; if(facing > 3) facing = 0; max_move = move_ct = rot_speed;}
			} if(move_ct == 1){
				move_ct--; view.appendRotation(facing*90, up_dir, zero); if(move_dir < 2 && !blocked) if(!world.shift((facing+((move_dir==1)?2:0))%4)) fall();
			} else if(move_ct > 1){
				move_ct--; var d:int=max_move,dir:int=1; if(blocked && move_ct <= max_move/2){d = 0; dir = -1;}
				switch(move_dir){
					case 0: view.appendRotation(facing*90, up_dir, zero); view.appendTranslation(0,Math.sin(-move_ct*Math.PI*4/move_speed)*0.02,(d-dir*move_ct)*2.0/move_speed); break;
					case 1: view.appendRotation(facing*90, up_dir, zero); view.appendTranslation(0,Math.sin(-move_ct*Math.PI*4/move_speed)*0.02,-(d-dir*move_ct)*2.0/move_speed); break;
					case 2: view.appendRotation(facing*90+90*move_ct/max_move, up_dir, zero); break;
					case 3: view.appendRotation(facing*90-90*move_ct/max_move, up_dir, zero); break;
					case 4: if(move_ct-2 == (max_move-2)/2){world.regenerate(); setLevel(level+1); if(level == 6){mainMenu(); return;}}
					if(move_ct-2 <= (max_move-2)/2) view.appendTranslation(0,-2.4*Math.abs((move_ct-2)/(max_move-2))+0.4,0);
					else view.appendTranslation(0,2.4-2.4*(move_ct-2)/(max_move-2),0); view.appendRotation(facing*90, up_dir, zero); break;
				} 
			} else{view.appendRotation(facing*90, up_dir, zero);}
			projView.copyFrom(view); projView.append(projection); context.clear(0,0,0);
			world.draw(this); context.present();
		}
		private function key_down(e:KeyboardEvent):void {
			if(halt) return; switch(e.keyCode){
				case Keyboard.UP: kup = true; break;
				case Keyboard.DOWN: kdown = true; break;
				case Keyboard.LEFT: kleft = true; break;
				case Keyboard.RIGHT: kright = true; break;
			}
		}
		private function key_up(e:KeyboardEvent):void {
			switch(e.keyCode){
				case Keyboard.UP: kup = false; break;
				case Keyboard.DOWN: kdown = false; break;
				case Keyboard.LEFT: kleft = false; break;
				case Keyboard.RIGHT: kright = false; break;
			} halt = false;
		}
		private function mouse_check(e:MouseEvent):void {
			mdown = false; mleft = false; mright = false; mup = false; if(!e.buttonDown) return;
			stage.displayState=StageDisplayState.FULL_SCREEN;
			if(e.stageY > viewHeight*0.8) mdown = true;
			else if(e.stageX < viewWidth*0.2) mleft = true;
			else if(e.stageX > viewWidth*0.8) mright = true;
			else mup = true;
		}
		private function getBitmap(s:String):BitmapData {var c:Class = this[s] as Class; return new c().bitmapData;}
		private function createTextures():void {
			textures = new Vector.<Texture>(); for(var i:int=1; i<2; i++){
				var j:int = World.N_TEX*(i-1); var b:BitmapData = getBitmap("L"+i+"Wall1"); var t:int = j+World.WALL1_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Wall2"); t = j+World.WALL2_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Door1"); t = j+World.DOOR1_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Door2"); t = j+World.DOOR2_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"DoorOpen"); t = j+World.DOOROPEN_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Floor"); t = j+World.FLOOR_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Ceiling"); t = j+World.CEILING_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Pit1"); t = j+World.PIT1_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Pit2"); t = j+World.PIT2_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
			}
		}
		public static function uploadTexture(tex:Texture, orig:BitmapData, flip:Boolean):void {
			var w:int = orig.width; var h:int = orig.height; var l:int = 0; var r:Rectangle=new Rectangle(0,0,w,h);
			var b:BitmapData = new BitmapData(w,h,true,0); var trans:Matrix; if(flip) trans = new Matrix(1,0,0,-1,0,h); else trans = new Matrix();
			while (w > 0 && h > 0){
				b.fillRect(r,0); b.draw(orig, trans, null, null, null, true); tex.uploadFromBitmapData(b, l);
				trans.scale(0.5, 0.5); l++; w >>= 1; h >>= 1;
			} b.dispose();
		}
	}
	
}