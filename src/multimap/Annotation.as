package com.repilac.multimap
{
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;

	public class Annotation extends Sprite
	{
		protected var _info:AnnotationInfo;
		public function get info():AnnotationInfo
		{
			return this._info;
		}
		public function set info(value:AnnotationInfo):void
		{
			this._info = value;
			this.term.text = value.term;
			this.term.x = 0;
			this.term.y = 0;
			this.term.width = this.term.textWidth + 6;
			this.term.height = this.term.textHeight + 4;
			
			/*
			if(this.info.zoom == (parent as AnnotationLayer).zoom){
				this.zoomScale = 1;
			} else{
				this.zoomScale = Math.pow(2, (parent as AnnotationLayer).zoom - this.info.zoom);
			}
			*/
		}
		public var frame:DragFrame;
		public var zoomScale:Number;
		public var term:TextField;
		public var termOpen:Boolean;
		public var moved:Boolean;
		
		public function Annotation()
		{
			super();
			
			this.term = new TextField();
			this.term.textColor = 0x000000;
			this.term.borderColor = 0x000000;
			this.term.selectable = false;
			this.term.doubleClickEnabled = true;
			this.term.addEventListener(MouseEvent.DOUBLE_CLICK, this.onTermDoubleClick);
			this.term.mouseEnabled = false;
			addChild(this.term);
			
			addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			addEventListener("frame_adjusted", this.onFrameAdjusted);
			//addEventListener("drag_point_down", this.onDragPointDown);
		}
		
		public function focus():void
		{
			if(!this.frame && this.info.type != 3){
				this.addFrame();
				//this.term.doubleClickEnabled = true;
				//this.term.addEventListener(MouseEvent.DOUBLE_CLICK, this.onTermDoubleClick);
				this.term.mouseEnabled = true;
			}
			if(this.info.type == 3){
				draw(3, 0xFFFF00);
				this.term.mouseEnabled = true;
			}
		}
		
		public function deFocus():void
		{
			if(this.termOpen){
				this.closeTermInput();
			}
			if(this.frame){
				this.removeFrame();
				//this.term.removeEventListener(MouseEvent.DOUBLE_CLICK, this.onTermDoubleClick);
				//this.term.doubleClickEnabled = false;
				this.term.mouseEnabled = false;
			}
			if(this.info.type == 3){
				draw();
				this.term.mouseEnabled = false;
			}
		}
		
		public function addFrame():void
		{
			this.frame = new DragFrame();
			this.frame.annotation = this;
			//CAUTION: the frame has to be annotation layer's child, NOT annotation's child
			(this.parent as AnnotationLayer).addChild(this.frame);
		}
		
		public function removeFrame():void
		{
			(this.parent as AnnotationLayer).removeChild(this.frame);
			this.frame = null;
		}
		
		/*
		public function onDragPointDown(e:Event):void
		{
			var a:Annotation;
			var t:Annotation = DragFrame(e.target.parent).annotation;
			while(this._focusList.length > 0){
				a = this._focusList.pop();
				if(a != t){
					a.removeFrame();
				}
			}
			this._focusList.push(t);
		}
		*/
		
		public function onFrameAdjusted(e:Event):void
		{
			this.info.updateFields(this.frame);
			this.update();
		}
		
		public function locate():void
		{
			x = this.info.x * this.zoomScale;
			y = this.info.y * this.zoomScale;
		}
		
		public function draw(line_thickness:Number=1, line_color:uint=0x000000, line_alpha:Number=1.0, fill_alpha:Number=0):void
		{
			/*var width:Number;
			var height:Number;
			var apex_Xs:Array;
			var apex_Ys:Array;
			if(this.info.zoom == Map(this.parent.parent).curZoom){
				width = this.info.width;
				height = this.info.height;
				apex_Xs = this.info.apex_Xs;
				apex_Ys = this.info.apex_Ys;
			} else{
				var zoomFactor:Number = Math.pow(2, Map(this.parent.parent).curZoom - this.info.zoom);
				width = this.info.width * zoomFactor;
				height = this.info.height * zoomFactor;
				apex_Xs = new Array();
				apex_Ys = new Array();
				var i:int;
				for(i=0; i<this.info.apex_Xs.length; i++){
					apex_Xs[i] = this.info.apex_Xs[i];
					apex_Ys[i] = this.info.apex_Ys[i];
				}
			}*/
			
			graphics.clear();
			switch(this.info.type)
			{
				case 0:
				graphics.beginFill(0xFFFFFF, fill_alpha);
				graphics.lineStyle(line_thickness, line_color, line_alpha, false, LineScaleMode.NONE);
				graphics.drawEllipse(-this.info.width / 2, -this.info.height / 2, this.info.width, this.info.height);
				graphics.endFill();
				break;
				
				case 1:
				graphics.beginFill(0xFFFFFF, fill_alpha);
				graphics.lineStyle(line_thickness, line_color, line_alpha, false, LineScaleMode.NONE);
				graphics.drawRect(-this.info.width / 2, -this.info.height / 2, this.info.width, this.info.height);
				graphics.endFill();
				break;
				
				case 2:
				graphics.beginFill(0xFFFFFF, fill_alpha);
				graphics.lineStyle(line_thickness, line_color, line_alpha, false, LineScaleMode.NONE);
				graphics.moveTo(this.info.apex_Xs[0], this.info.apex_Ys[0]);
				for(var i:int=1; i<this.info.apex_Xs.length; i++){
					graphics.lineTo(this.info.apex_Xs[i], this.info.apex_Ys[i]);
				}
				graphics.lineTo(this.info.apex_Xs[0], this.info.apex_Ys[0]);
				graphics.endFill();
				break;
				
				case 3:
				/*
				if(this.info.segments == null){
					var pairs:Array = this.info.path.split(" ");
					var cps:Array = new Array();
					for each (var pair:String in pairs){
						var p:Array = pair.split(",");
						var cp:Point = new Point(p[0], p[1]); // ??? Use String to construct Point ???
						cps.push(cp);
					}
					var numCurves:int = (cps.length - 1) / 3;
					var cb:CubicBezier;
					this.info.segments = new Array();
					for(var j:int=0; j<numCurves; j++){
						cb = new CubicBezier(cps[j * 3], cps[j * 3 + 1], cps[j * 3 + 2], cps[j * 3 + 3]);
						this.info.segments.push(cb);
					}
					this.info.path = null;
				}
				*/
				graphics.lineStyle(line_thickness, line_color, line_alpha, false, LineScaleMode.NONE);
				graphics.beginFill(0xFFFF00, 0);
				for (var k:int=0; k<this.info.segments.length; k++){
					var segment = this.info.segments[k];
					if(!k){
						graphics.moveTo(segment.anchor1.x, segment.anchor1.y);
					}
					if(segment is StraightLine){
						graphics.lineTo(segment.anchor2.x, segment.anchor2.y);
					} else if(segment is QuadraticBezier){
						graphics.curveTo(segment.control.x, segment.control.y, segment.anchor2.x, segment.anchor2.y);
					} else{
						var approximation:Array = segment.approximate(3);
						for each (var qb:QuadraticBezier in approximation){
							graphics.lineTo(qb.anchor2.x, qb.anchor2.y);
						}
					}
				}
				graphics.endFill();
				break;
				
				//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				/*
				case 4:  //This is temporary, for drawing reference ROI. Eventually should be merged with case 3
				if(this.info.segments == null){
					var words:Array = this.info.path.split(" ");
					var elements:Array = new Array();
					for each (var word:String in words){
						if(word.indexOf(",") == -1){
							elements.push(word)
						} else{
							var coord:Array = word.split(",");
							var point:Point = new Point(Number(coord[0]) - 411, Number(coord[1]) - 172);
							elements.push(point);
						}
					}
					//var cubic:CubicBezier;
					//var straight:StraightLine;
					var seg;
					var index:int = -1;
					this.info.segments = new Array();
					for each (var e in elements){
						index = index + 1;
						if(e == "C"){
							seg = new CubicBezier(elements[index - 1], elements[index + 1], elements[index + 2], elements[index + 3]);
							this.info.segments.push(seg);
						}
						if(e == "L"){
							seg = new StraightLine(elements[index - 1], elements[index + 1]);
							this.info.segments.push(seg);
						}
					}
					this.info.path = null;
				}
				if(this.info.isClose){
					graphics.beginFill(0xFFFF00, 0);
					graphics.lineStyle(1, 0x000000, 1, false, LineScaleMode.NONE);
				} else{
					graphics.lineStyle(2, 0x000000, 1, false, LineScaleMode.NONE);
				}
				graphics.moveTo(this.info.segments[0].anchor1.x, this.info.segments[0].anchor1.y);
				var approx:Array;
				for (var k:int=0; k<this.info.segments.length; k++){
					seg = this.info.segments[k];
					if( seg is CubicBezier){
						approx = seg.approximate(3);
						for each (var qb:QuadraticBezier in approx){
							graphics.lineTo(qb.anchor2.x, qb.anchor2.y);
						}
					} else{
						graphics.lineTo(seg.anchor2.x, seg.anchor2.y);
					}
				}
				if(this.info.isClose){
					graphics.endFill();
				}
				break;
				*/
				/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
			}
			scaleX = this.zoomScale;
			scaleY = this.zoomScale;
		}
		
		public function zoomTo(z:Number):void
		{
			this.zoomScale = Math.pow(2, z - this.info.zoom);
			scaleX = this.zoomScale;
			scaleY = this.zoomScale;
			this.locate();
		}
		
		public function update():void
		{
			this.locate();
			this.draw();
		}
		
		public function onMouseDown(e:MouseEvent):void
		{
			if(this.termOpen){
				this.closeTermInput();
			}
			
			if(e.target is TextField){
				e.stopPropagation();
			}
			
			//do not stop mouse down event here, because we may need it pop down to trigger the currentAL change
			
			if(e.shiftKey){
				//if(this.frame){
				//	this.deFocus();
				//} else{
				//	this.focus();
				//}
				
				var f1:Event = new Event("update_focus_list", true);
				dispatchEvent(f1);
			} else{
				(parent as AnnotationLayer).emptyFocusList();
				//this.focus();
				
				var f2:Event = new Event("update_focus_list", true);
				dispatchEvent(f2);
			}
			
			if(this.frame || this.info.type == 3){
				startDrag();
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			}
		}
		
		public function onMouseMove(e:MouseEvent):void
		{
			e.stopPropagation();
			if(this.frame){
				this.frame.follow();
			}
			
			if(!this.moved){
				var f:Event = new Event("annotation_modified", true);
				dispatchEvent(f);
				this.moved = true;
			}
		}
		
		public function onMouseUp(e:MouseEvent):void
		{
			e.stopPropagation();
			stopDrag();
			this.moved = false;
			if(this.frame){
				this.frame.stopFollow();
			}
			if(this.info.type == 3){
				this.info.x = this.x / this.zoomScale;
				this.info.y = this.y / this.zoomScale;
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		
		public function onTermDoubleClick(e:MouseEvent):void
		{
			this.openTermInput();
			
			var f:Event = new Event("annotation_modified", true);
			dispatchEvent(f);
		}
		
		public function openTermInput():void
		{
			this.term.type = TextFieldType.INPUT;
			this.term.selectable = true;
			this.term.border = true;
			this.term.addEventListener(MouseEvent.MOUSE_DOWN, this.onTermMouseDown);  //prevent the select action on term from triggering "selector" in AnnotationLayer
			this.term.addEventListener(KeyboardEvent.KEY_DOWN, this.onTermKeyDown);
			this.termOpen = true;
			this.term.doubleClickEnabled = false;
		}
		
		public function closeTermInput():void
		{
			this.term.border = false;
			this.term.setSelection(0, 0);
			this.term.selectable = false;
			this.term.type = TextFieldType.DYNAMIC;
			if(this.term.text != ""){
				this.info.term = this.term.text;
			} else{
				this.info.term = "Empty";
				this.term.text = this.info.term;
			}
			this.term.removeEventListener(MouseEvent.MOUSE_DOWN, this.onTermMouseDown);
			this.term.removeEventListener(KeyboardEvent.KEY_DOWN, this.onTermKeyDown);
			this.termOpen = false;
			this.term.doubleClickEnabled = true;
		}
		
		public function onTermMouseDown(e:MouseEvent):void
		{
			e.stopPropagation();
		}
		
		public function onTermKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.ESCAPE){
				this.closeTermInput();
			}
		}
	}
}