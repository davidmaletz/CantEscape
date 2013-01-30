package {
	import com.adobe.utils.AGALMiniAssembler;
    import com.adobe.utils.PerspectiveMatrix3D;
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.StageDisplayState;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundTransform;
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
		public static const DEBUG:Boolean = false;
		
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
		public var sprites:Vector.<Texture>;
		public var sky_tex:Texture;
		public var start_tex:Texture;
		
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
			"pow ft0.xyz, ft0.xyz, fc0.www\n"+
			//"tex ft1, v1, fs1 <2d,miplinear,nearest,clamp>\n"+
			//"add ft0.xyz, ft1.xyz\n"+
            "mov oc, ft0";
			
		private var vertexAssembly:AGALMiniAssembler = new AGALMiniAssembler();
        private var fragmentAssembly:AGALMiniAssembler = new AGALMiniAssembler();
        private var programPair:Program3D;
		
		[Embed(source = '../lib/A1_wall.png')]
		private var L1Wall1:Class;
		[Embed(source = '../lib/A1_wall2.png')]
		private var L1Wall2:Class;
		[Embed(source = '../lib/A1_crackedwall.png')]
		private var L1Wall3:Class;
		[Embed(source = '../lib/A1_windowwall.png')]
		private var L1Window:Class;
		[Embed(source = '../lib/A1_lockeddoor.png')]
		private var L1Door1:Class;
		[Embed(source = '../lib/A1_hiddendoor.png')]
		private var L1Door2:Class;
		[Embed(source = '../lib/A1_opendoor.png')]
		private var L1DoorOpen:Class;
		[Embed(source = '../lib/A1_floor.png')]
		private var L1Floor:Class;
		[Embed(source = '../lib/A1_floor_key.png')]
		private var L1FloorKey:Class;
		[Embed(source = '../lib/A1_ceiling.png')]
		private var L1Ceiling:Class;
		[Embed(source = '../lib/A1_ceiling_hole.png')]
		private var L1CeilingHole:Class;
		[Embed(source = '../lib/A1_openpit.png')]
		private var L1Pit1:Class;
		[Embed(source = '../lib/A1_hiddenpit.png')]
		private var L1Pit2:Class;
		[Embed(source = '../lib/A1_ladder_pit.png')]
		private var L1Pit3:Class;
		[Embed(source = '../lib/A1_ladder.png')]
		private var L1Ladder:Class;
		
		[Embed(source = '../lib/A3_wall.png')]
		private var L2Wall1:Class;
		[Embed(source = '../lib/A3_wall2.png')]
		private var L2Wall2:Class;
		[Embed(source = '../lib/A3_crackedwall.png')]
		private var L2Wall3:Class;
		[Embed(source = '../lib/A3_windowwall.png')]
		private var L2Window:Class;
		[Embed(source = '../lib/A3_lockeddoor.png')]
		private var L2Door1:Class;
		[Embed(source = '../lib/A3_hiddendoor.png')]
		private var L2Door2:Class;
		[Embed(source = '../lib/A3_opendoor.png')]
		private var L2DoorOpen:Class;
		[Embed(source = '../lib/A3_floor.png')]
		private var L2Floor:Class;
		[Embed(source = '../lib/A3_floor_key.png')]
		private var L2FloorKey:Class;
		[Embed(source = '../lib/A3_ceiling.png')]
		private var L2Ceiling:Class;
		[Embed(source = '../lib/A3_ceiling_hole.png')]
		private var L2CeilingHole:Class;
		[Embed(source = '../lib/A3_openpit.png')]
		private var L2Pit1:Class;
		[Embed(source = '../lib/A3_hiddenpit.png')]
		private var L2Pit2:Class;
		[Embed(source = '../lib/A3_ladder_pit.png')]
		private var L2Pit3:Class;
		[Embed(source = '../lib/A3_ladder.png')]
		private var L2Ladder:Class;
		
		[Embed(source = '../lib/A2_wall.png')]
		private var L3Wall1:Class;
		[Embed(source = '../lib/A2_wall2.png')]
		private var L3Wall2:Class;
		[Embed(source = '../lib/A2_crackedwall.png')]
		private var L3Wall3:Class;
		[Embed(source = '../lib/A2_windowwall.png')]
		private var L3Window:Class;
		[Embed(source = '../lib/A2_lockeddoor.png')]
		private var L3Door1:Class;
		[Embed(source = '../lib/A2_hiddendoor.png')]
		private var L3Door2:Class;
		[Embed(source = '../lib/A2_opendoor.png')]
		private var L3DoorOpen:Class;
		[Embed(source = '../lib/A2_floor.png')]
		private var L3Floor:Class;
		[Embed(source = '../lib/A2_floor_key.png')]
		private var L3FloorKey:Class;
		[Embed(source = '../lib/A2_ceiling.png')]
		private var L3Ceiling:Class;
		[Embed(source = '../lib/A2_ceiling_hole.png')]
		private var L3CeilingHole:Class;
		[Embed(source = '../lib/A2_openpit.png')]
		private var L3Pit1:Class;
		[Embed(source = '../lib/A2_hiddenpit.png')]
		private var L3Pit2:Class;
		[Embed(source = '../lib/A2_ladder_pit.png')]
		private var L3Pit3:Class;
		[Embed(source = '../lib/A2_ladder.png')]
		private var L3Ladder:Class;
		
		[Embed(source = '../lib/lightshaft.png')]
		private var Lightshaft:Class;
		[Embed(source = '../lib/ghost.png')]
		private var Ghost:Class;
		[Embed(source = '../lib/pitmonster.png')]
		private var Monster:Class;
		[Embed(source = '../lib/o_eye1.png')]
		private var Eye1:Class;
		[Embed(source = '../lib/o_eye2.png')]
		private var Eye2:Class;
		[Embed(source = '../lib/o_eye3.png')]
		private var Eye3:Class;
		
		[Embed(source = '../lib/surface.png')]
		private var StartTex:Class;
		
		[Embed(source='../lib/footsteps1.mp3')] 
		private var footsteps1:Class;
		[Embed(source='../lib/footsteps2.mp3')] 
		private var footsteps2:Class;
		[Embed(source='../lib/footsteps3.mp3')] 
		private var footsteps3:Class;
		[Embed(source = '../lib/Thud_3.mp3')]
		private var thud:Class;
		[Embed(source = '../lib/Gate Pass 3.mp3')]
		private var door1_sfx:Class;
		[Embed(source = '../lib/Trap Wall Pass_2.mp3')]
		private var door2_sfx:Class;
		[Embed(source='../lib/Shadow_steps.mp3')] 
		private var shadow_steps:Class;
		[Embed(source='../lib/Pit Fall Crumble_2.mp3')] 
		private var fall_pit:Class;
		[Embed(source='../lib/Gate Locked_4.mp3')] 
		private var gate_locked:Class;
		[Embed(source='../lib/Ladder Climb.mp3')] 
		private var ladder_climb:Class;
		[Embed(source='../lib/Pit Monster.mp3')] 
		private var pit_monster:Class;
		[Embed(source='../lib/Keys (pickup).mp3')] 
		private var key_pickup:Class;
		[Embed(source='../lib/Trap Door.mp3')] 
		private var trap_door:Class;
		
		[Embed(source = "../lib/settings.swf")] private static var settings:Class;
		[Embed(source = "../lib/MusicPlayer.swf")] private static var MusicPlayer:Class;
		
		private var world:World; private var new_game:Boolean = true;
		
		public function Main():void {
			if (stage) init(); else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE; stage.align = StageAlign.TOP_LEFT;
			mainMenu();
		}
		private var menu:Sprite; private var show_set:Boolean = true;
		private function setupMusicPlayer(e:Event):void {music_player = (music_player.getChildAt(0) as Loader).content; playBGM(0);}
		private function mainMenu():void {
			stage.displayState=StageDisplayState.NORMAL; if(end != null && end.parent != null) end.parent.removeChild(end);
			if(context != null){context.dispose(); context = null;}
			if(menu != null){menu.parent.removeChild(menu); menu = null;}
			playBGM(0); stage.removeEventListener(Event.ENTER_FRAME, render);
			if(music_player == null){music_player = new MusicPlayer();
			(music_player.getChildAt(0) as Loader).contentLoaderInfo.addEventListener(Event.COMPLETE,setupMusicPlayer);}
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, key_down); stage.removeEventListener(KeyboardEvent.KEY_UP, key_up);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouse_check); stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouse_check);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouse_check);
			var s:Sprite = new Sprite(); s.graphics.beginFill(0); s.graphics.drawRect(0,0,5000,5000); s.graphics.endFill();
			var t:TextField = new TextField(); t.embedFonts = true; var tf:TextFormat = new TextFormat("Gypsy Curse",80,0xffffff);
			tf.align = TextFormatAlign.CENTER; t.defaultTextFormat = tf; t.text = "I CAN'T ESCAPE"; t.width = stage.stageWidth;
			t.height = stage.stageHeight; t.mouseEnabled = false; t.y = 80; s.addChild(t); t = new TextField(); tf = new TextFormat(null, 16, 0xffffff);
			tf.align = TextFormatAlign.CENTER; t.defaultTextFormat = tf; t.text = "David Maletz * Chase Bethea * Josh Goskey * Natalie Maletz";
			t.width = stage.stageWidth; t.height = stage.stageHeight; t.mouseEnabled = false; t.y = 190; s.addChild(t); t = new TextField();
			t.embedFonts = true; tf = new TextFormat("Gypsy Curse", 60, 0x990000); t.defaultTextFormat = tf; t.text = "PLAY";
			t.x = (stage.stageWidth-t.textWidth)/2; t.width = t.textWidth; t.height = t.textHeight; t.mouseEnabled = false; t.y = 260;
			var b:Sprite = new Sprite(); b.buttonMode = true; b.useHandCursor = true; b.addChild(t); s.addChild(b);
			s.addChild(Preloader.createLogo(stage)); b.addEventListener(MouseEvent.CLICK, newGame); menu = s; stage.addChild(s);
		}
		private var cur_settings:*; private var music_player:*; private var gamma:Number = 1;
		private function getSettings():* {return (cur_settings.getChildAt(0) as Loader).content;}
		private function setupSettings(e:Event):void {getSettings().func = setGamma;}
		public function setGamma(e:Event):void {
			gamma = getSettings().getGamma(); if(cur_settings != null){cur_settings.parent.removeChild(cur_settings); cur_settings = null;} newGame(e);
		}
		public function newGame(e:Event):void {
			if(menu != null){menu.parent.removeChild(menu); menu = null;}
			if(show_set){
				show_set = false; cur_settings = new settings();
				(cur_settings.getChildAt(0) as Loader).contentLoaderInfo.addEventListener(Event.COMPLETE,setupSettings);
				stage.addChild(cur_settings); return;
			}
			stage.displayState=StageDisplayState.FULL_SCREEN; stage.focus = stage;
			new_game = true; var s:* = stage; if(s.hasOwnProperty("nativeWindow")) s.nativeWindow.activate();
			move_ct = 0; fade_ct = 0; facing = 0; kup = mup = kdown = mdown = kleft = mleft = kright = mright = false; stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, contextCreated);
			stage3D.requestContext3D();
			vertexAssembly.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER, false);
			fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER, false);
		}
		private function contextCreated(event:Event):void {
			context = Stage3D(event.target).context3D; if(DEBUG) context.enableErrorChecking = true; initContext();
			if(new_game){
				level = -1; move_dir = -1; move_ct = 60; setDarkness(0); world = new World();
				stage.addEventListener(Event.ENTER_FRAME, render);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, key_down); stage.addEventListener(KeyboardEvent.KEY_UP, key_up);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, mouse_check); stage.addEventListener(MouseEvent.MOUSE_MOVE, mouse_check);
				stage.addEventListener(MouseEvent.MOUSE_UP, mouse_check); new_game = false;
			} else setDarkness(_darkness);
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
                    -1,-1,-1, 1,1,
                    -1,1,-1, 1,0,
                    1,1,-1, 0,0,
                    1,-1,-1, 0,1,
                    
                    -1,-1,1, 0,1,
                    1,-1,1, 1,1,
                    1,1,1, 1,0,
                    -1,1,1, 0,0,
                    
                    -1,1,1, 1,0,
                    -1,1,-1, 0,0,
                    -1,-1,-1, 0,1,
                    -1,-1,1, 1,1,
                    
                    1,1,-1, 1,0,
                    1,1,1, 0,0,
                    1,-1,1, 0,1,
                    1,-1,-1, 1,1
			]);
			vertices = context.createVertexBuffer(vertexData.length/dataPerVertex, dataPerVertex);
			vertices.uploadFromVector(vertexData, 0, vertexData.length/dataPerVertex);
			context.setVertexBufferAt(0, vertices, 0, Context3DVertexBufferFormat.FLOAT_3);
			context.setVertexBufferAt(1, vertices, 3, Context3DVertexBufferFormat.FLOAT_2);
			
			programPair = context.createProgram();
			programPair.upload(vertexAssembly.agalcode, fragmentAssembly.agalcode);
			context.setProgram(programPair);
			var t:Number = 0.01; var thresh:Vector.<Number> = Vector.<Number>([t,t,t,gamma]);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,thresh);
			
			createTextures();
			
			projection.perspectiveFieldOfViewRH(fov, viewWidth/viewHeight, zNear, zFar);
		}
		public function drawSides(tex:int, x:Number, y:Number):void {
			if(level >= 8) tex += 2*World.N_TEX; else if(level >= 4) tex += World.N_TEX;
			trans.identity(); trans.appendTranslation(x*2,0,y*2); trans.append(projView);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, trans, true);
			if(tex == -2){context.setTextureAt(0, start_tex); cur_tex = -1;}
			else if(tex != cur_tex){context.setTextureAt(0, textures[tex]); cur_tex = tex;} context.drawTriangles(indicesSides, 0, 8);
		}
		public function drawWall(tex:int, side:int, x:Number, y:Number, isSprite:Boolean=false):void {
			if(!isSprite){if(level >= 8) tex += 2*World.N_TEX; else if(level >= 4) tex += World.N_TEX;}
			trans.identity(); trans.appendRotation(side*90,up_dir,zero);
			var dx:Number=0, dy:Number=0; if(isSprite){switch(side){
				case 0: dy = -0.05; break;
				case 1: dx = -0.05; break;
				case 2: dy = 0.05; break;
				case 3: dx = 0.05; break;
			}}
			trans.appendTranslation(x*2+dx,0,y*2+dy); trans.append(projView);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, trans, true);
			if(isSprite){if(-2-tex != cur_tex){context.setTextureAt(0, sprites[tex]); cur_tex = -2-tex;}}
			else if(tex != cur_tex){context.setTextureAt(0, textures[tex]); cur_tex = tex;} context.drawTriangles(indicesWall, 0, 2);
		}
		public function drawFloor(tex:int, side:int, x:Number, y:Number, isSprite:Boolean=false):void {
			if(!isSprite){if(level >= 8) tex += 2*World.N_TEX; else if(level >= 4) tex += World.N_TEX;}
			trans.identity(); trans.appendRotation(side*90,right_dir,zero); trans.appendScale(1,-1,1);
			trans.appendTranslation(x*2,((isSprite)?((side == 1)?0.05:-0.05):0),y*2); trans.append(projView);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, trans, true);
			if(isSprite){if(-2-tex != cur_tex){context.setTextureAt(0, sprites[tex]); cur_tex = -2-tex;}}
			else if(tex != cur_tex){context.setTextureAt(0, textures[tex]); cur_tex = tex;} context.drawTriangles(indicesWall, 0, 2);
		}
		public function drawSprite(tex:int, x:Number, y:Number, z:Number=0):void {
			if(level != 0 && tex == World.LIGHTSHAFT_SPRITE) return; setDarkness(0);
			trans.identity(); trans.appendTranslation(0,0,1); trans.appendRotation(180-cur_facing,up_dir,zero);
			trans.appendTranslation(x*2,z*2,y*2); trans.append(projView);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, trans, true);
			if(-2-tex != cur_tex){context.setTextureAt(0, sprites[tex]); cur_tex = -2-tex;} context.drawTriangles(indicesWall, 0, 2);
		}
		private var ss_moved:int = -1, move_ct:int = 0, move_dir:int, max_move:int, blocked:Boolean=false, facing:int=0,
			cur_facing:Number = 0, move_speed:int, rot_speed:int, fall_ct:int=12, climb_ct:int = 40, halt:Boolean = false, kup:Boolean = false,
			kdown:Boolean = false, kleft:Boolean = false, kright:Boolean = false, mup:Boolean = false, mdown:Boolean = false,
			mleft:Boolean = false, mright:Boolean = false;
		public static var level:int = 0;
		private function playBGM(i:int):void {if(music_player != null) music_player.playBGM(i);}
		private function playSE(se:Class, vol:Number=1):void {(new se() as Sound).play(0,0,new SoundTransform(vol));}
		public function getDarkness():Number {return -0.5-0.05*(Math.min(level,11)%4+Math.floor(Math.min(level,11)*0.25)*3);}
		private function setLevel(l:int):void {
			if(l == -1){level = l; facing = 0; setDarkness(0); return;}
			playBGM(Math.min(l>>1, 5)); level = l; setDarkness(getDarkness()); l >>= 2; l = Math.min(2,l); move_speed = 27-3*l; rot_speed = 15-3*l;
		}
		public function setDarkness(f:Number):void {
			if(_darkness == f) return; _darkness = f; var vc:Vector.<Number> = Vector.<Number>([f,f,f,f]);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,0,vc);
		}
		public function fall(trap:Boolean=false):void {move_dir = 4; max_move = move_ct = fall_ct; playSE((trap)?trap_door:fall_pit);}
		public function climb():void {move_dir = 5; max_move = move_ct = climb_ct; playSE(ladder_climb);}
		public function pickupKey():void {playSE(key_pickup);}
		public function getFacing():int {return facing;}
		public function getDx(f:int):int {return (f&1)*((f>=2)?-1:1);}
		public function getDy(f:int):int {return ((f+1)&1)*((f>=2)?1:-1);}
		private var _darkness:Number, fade_ct:int=0;
		private function footsteps():void {
			if(level >= 8) playSE(footsteps3, 0.5);
			else if(level >= 4) playSE(footsteps2, 0.5);
			else playSE(footsteps1, 0.5);
			if(ss_moved == -1) ss_moved = int((Math.random()+1)*(15-level)*40);
		}
		public function unlockSfx(type:int):void {
			switch(type){
				case World.DOOR1_TEX: playSE(door1_sfx, 0.5);
				case World.DOOR2_TEX: playSE(door2_sfx, 0.5);
			}
		}
		private function playThud():void {
			var c:Cell = world.getCell(getDx(facing), getDy(facing));
			if(c.sides == World.DOOR1_TEX) playSE(gate_locked);
			else if(c.sides == -1) playSE(pit_monster,0.5);
			else playSE(thud, 0.5);
		}
		private var end:TextField;
		private function render(event:Event):void {
			if(move_dir == -1 && level == -1 && move_ct > fall_ct){
				move_ct--; if(move_ct == fall_ct) fall();
			} if(level == 12){
				if(_darkness < -3){if(end == null){
					end = new TextField(); end.embedFonts = true; var tf:TextFormat = new TextFormat("Gypsy Curse",80,0xffffff);
					tf.align = TextFormatAlign.CENTER; end.defaultTextFormat = tf; end.text = "END"; end.width = stage.stageWidth; end.mouseEnabled = false;
				} if(end.parent == null) stage.addChild(end); end.height = stage.stageHeight; end.y = (stage.stageHeight-end.textHeight)*0.5;
				end.alpha = Math.min(-3-_darkness, 1);
				}
				if(fade_ct >= 100) setDarkness(_darkness-0.008); else fade_ct++; if(_darkness <= -5){mainMenu(); return;}
			} view.identity(); if(move_ct == 0){
				var t:int; if(kup || mup){
					t = world.moveTo(this,getDx(facing), getDy(facing)); if(t >= 0){
						move_dir = 0; max_move = move_speed; blocked = t == 0; if(blocked){max_move/=3; playThud();}
						else footsteps(); move_ct = max_move;
					} else if(t == -2) fall(true); else if(t == -3) climb();
					else {if(kup) halt = true; kup = mup = kdown = mdown = kleft = mleft = kright = mright = false;}
				} else if(kdown || mdown){
					t = world.moveTo(this,-getDx(facing), -getDy(facing)); if(t >= 0){
						move_dir = 1; max_move = move_speed; blocked = t == 0; if(blocked){max_move/=3; playThud();}
						else footsteps(); move_ct = max_move;
					} else if(t == -2) fall(true); else if(t == -3) climb();
					else {if(kdown) halt = true; kup = mup = kdown = mdown = kleft = mleft = kright = mright = false;}
				} else if(kleft || mleft){move_dir = 2; facing--; if(facing < 0) facing = 3; max_move = move_ct = rot_speed;}
				else if(kright || mright){move_dir = 3; facing++; if(facing > 3) facing = 0; max_move = move_ct = rot_speed;}
			} if(ss_moved > 0) ss_moved--; if((move_ct == 0 || move_dir >= 2 || blocked) && ss_moved == 0){playSE(shadow_steps,0.75); ss_moved = -1;}
			var delta:Number=0; if(move_ct == 1){
				move_ct--; view.appendRotation(facing*90, up_dir, zero); cur_facing = facing*90;
				if(move_dir < 2 && !blocked) if(!world.shift((facing+((move_dir==1)?2:0))%4)) fall();
				if(level == -1 && move_dir == 5){move_dir = -1; move_ct = 60;}
			} else if(move_dir >= 0 && move_ct > 1){
				move_ct--; var d:int=max_move,dir:int=1; if(blocked && move_ct <= max_move/2){d = 0; dir = -1;}
				switch(move_dir){
					case 0: view.appendRotation(facing*90, up_dir, zero); delta = (d-dir*move_ct)*2.0/move_speed; view.appendTranslation(0,Math.sin(-move_ct*Math.PI*4/move_speed)*0.02,delta); break;
					case 1: view.appendRotation(facing*90, up_dir, zero); delta = -(d-dir*move_ct)*2.0/move_speed; view.appendTranslation(0,Math.sin(-move_ct*Math.PI*4/move_speed)*0.02,delta); break;
					case 2: cur_facing = facing*90+90*move_ct/max_move; view.appendRotation(cur_facing, up_dir, zero); break;
					case 3: cur_facing = facing*90-90*move_ct/max_move; view.appendRotation(cur_facing, up_dir, zero); break;
					case 4: if(move_ct-2 == (max_move-2)/2){setLevel(level+1); world.regenerate();}
					if(move_ct-2 <= (max_move-2)/2) view.appendTranslation(0,-2.4*Math.abs((move_ct-2)/(max_move-2))+0.4,0);
					else view.appendTranslation(0,2.4-2.4*(move_ct-2)/(max_move-2),0); view.appendRotation(facing*90, up_dir, zero); break;
					case 5: var mm:int = max_move>>1; if(move_ct == mm){setLevel(level-1); world.regenerate(true);}
					var rev:int = max_move-move_ct-1; var mr:int = rev%8; var mc:int = (rev>>3)*4; if(mr < 4) mc += mr; else mc += 3;
					if(move_ct <= mm) view.appendTranslation(0,2-2*mc/(mm-1),0);
					else view.appendTranslation(0,-2*mc/(mm-1),0); view.appendRotation(facing*90, up_dir, zero); break;
				} 
			} else{view.appendRotation(facing*90, up_dir, zero);}
			projView.copyFrom(view); projView.append(projection); context.clear(0,0,0);
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO); world.draw(this); var _d:Number = _darkness;
			context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setDepthTest(false, Context3DCompareMode.LESS); world.drawSprites(this); context.setDepthTest(true, Context3DCompareMode.LESS);
			if(level == 0){
				trans.identity(); trans.appendRotation(3*90,right_dir,zero); trans.appendScale(World.SIZE*2,-1,World.SIZE*2);
				trans.appendTranslation(0,0.1,0); trans.append(projView); context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, trans, true);
				context.setTextureAt(0, sky_tex); cur_tex = -1; context.drawTriangles(indicesWall, 0, 2);
			} setDarkness(_d); context.present();
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
			textures = new Vector.<Texture>(); var b:BitmapData; var t:int; for(var i:int=1; i<=3; i++){
				var j:int = World.N_TEX*(i-1); b = getBitmap("L"+i+"Wall1"); t = j+World.WALL1_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Wall2"); t = j+World.WALL2_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Wall3"); t = j+World.WALL3_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Window"); t = j+World.WINDOW_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Door1"); t = j+World.DOOR1_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Door2"); t = j+World.DOOR2_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"DoorOpen"); t = j+World.DOOROPEN_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Floor"); t = j+World.FLOOR_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"FloorKey"); t = j+World.FLOOR_KEY_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Ceiling"); t = j+World.CEILING_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"CeilingHole"); t = j+World.CEILING_HOLE_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Pit1"); t = j+World.PIT1_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Pit2"); t = j+World.PIT2_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Pit3"); t = j+World.PIT3_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
				b = getBitmap("L"+i+"Ladder"); t = j+World.LADDER_TEX;
				textures[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(textures[t],b,true);
			} sprites = new Vector.<Texture>();
			b = getBitmap("Lightshaft"); t = World.LIGHTSHAFT_SPRITE;
			sprites[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(sprites[t],b,true);
			b = getBitmap("Ghost"); t = World.GHOST_SPRITE;
			sprites[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(sprites[t],b,true);
			b = getBitmap("Monster"); t = World.MONSTER_SPRITE;
			sprites[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(sprites[t],b,true);
			b = getBitmap("Eye1"); t = World.EYE1_SPRITE;
			sprites[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(sprites[t],b,true);
			b = getBitmap("Eye2"); t = World.EYE2_SPRITE;
			sprites[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(sprites[t],b,true);
			b = getBitmap("Eye3"); t = World.EYE3_SPRITE;
			sprites[t] = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(sprites[t],b,true);
			b = getBitmap("StartTex");
			start_tex = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false); uploadTexture(start_tex,b,true);
			sky_tex = context.createTexture(1, 1, Context3DTextureFormat.BGRA, false); b = new BitmapData(1,1,false,0x4eecff);
			sky_tex.uploadFromBitmapData(b, 0);
		}
		public static function uploadTexture(tex:Texture, orig:BitmapData, flip:Boolean):void {
			/*var w:int = orig.width; var h:int = orig.height; var l:int = 0; var r:Rectangle=new Rectangle(0,0,w,h);
			var b:BitmapData = new BitmapData(w,h,true,0); var trans:Matrix; if(flip) trans = new Matrix(1,0,0,-1,0,h); else trans = new Matrix();
			while (w > 0 && h > 0){
				b.fillRect(r,0); b.draw(orig, trans, null, null, null, true); tex.uploadFromBitmapData(b, l);
				trans.scale(0.5, 0.5); l++; w >>= 1; h >>= 1;
			} b.dispose();*/ tex.uploadFromBitmapData(orig);
		}
	}
	
}