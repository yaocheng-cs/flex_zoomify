package com.repilac.multimap
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import mx.core.Application;
	
	public class ROI extends Annotation
	{
		public var proxy:Annotation;
		
		public function ROI()
		{
			super();
			
			term.textColor = 0x0000FF;
			term.borderColor = 0x0000FF;
			term.visible = false;
			
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			removeEventListener("frame_adjusted", onFrameAdjusted);
			addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
		}
		
		/*public function onMouseClick(e:MouseEvent):void
		{
			trace("mouseclick+++++++++");
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			
			if(e.target is TextField){
				return;
			}
			
			var f:Event = new Event("ROI_selected", true);
			dispatchEvent(f);
		}*/
		
		override public function onMouseDown(e:MouseEvent):void
		{
			trace("mousedown+++++++");
			(parent as ROILayer).emptyFocusList();
			this.focus();
			var f:Event = new Event("ROI_focus", true);
			dispatchEvent(f);
			
			//addEventListener(MouseEvent.CLICK, this.onMouseClick);
			if(Application.application.modeSwitch.label == "Exclude Reference"){
				stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			}
		}
		
		override public function onMouseMove(e:MouseEvent):void
		{
			trace("mousemove++++++");
			//removeEventListener(MouseEvent.CLICK, this.onMouseClick);
			
			if(!this.proxy){
				var ml:MapLayer = parent.parent as MapLayer;
				var atm:Matrix;
				if(ml.affineTM){
					atm = ml.affineTM.clone();
				} else{
					atm = new Matrix();
				}
				
				var info_copy:AnnotationInfo = this.info.clone();
				var oc:Point = ml.localToGlobal(new Point(info_copy.x * this.zoomScale, info_copy.y * this.zoomScale));
				info_copy.x = e.stageX;
				info_copy.y = e.stageY;
				var delta_x:Number = oc.x - e.stageX;
				var delta_y:Number = oc.y - e.stageY;
				var path:String = '';
				for each (var seg in info_copy.segments){
					var a1:Point = atm.deltaTransformPoint(new Point(seg.anchor1.x * this.zoomScale, seg.anchor1.y * this.zoomScale));
					seg.anchor1.x = a1.x + delta_x;
					seg.anchor1.y = a1.y + delta_y;
					var a2:Point = atm.deltaTransformPoint(new Point(seg.anchor2.x * this.zoomScale, seg.anchor2.y * this.zoomScale));
					seg.anchor2.x = a2.x + delta_x;
					seg.anchor2.y = a2.y + delta_y;
					
					var s:String = '';
					if(seg is QuadraticBezier){
						var c:Point = atm.deltaTransformPoint(new Point(seg.control.x * this.zoomScale, seg.control.y * this.zoomScale));
						seg.control.x = c1.x + delta_x;
						seg.control.y = c1.y + delta_y;
						if(path == ''){
							s = seg.anchor1.x.toPrecision(4) + ',' + seg.anchor1.y.toPrecision(4) + ' ' + seg.control.x.toPrecision(4) + ',' + seg.control.y.toPrecision(4) + ' ' + seg.anchor2.x.toPrecision(4) + ',' + seg.anchor2.y.toPrecision(4);
						} else{
							s = seg.control.x.toPrecision(4) + ',' + seg.control.y.toPrecision(4) + ' ' + seg.anchor2.x.toPrecision(4) + ',' + seg.anchor2.y.toPrecision(4);
						}
					} else if(seg is CubicBezier){
						var c1:Point = atm.deltaTransformPoint(new Point(seg.control1.x * this.zoomScale, seg.control1.y * this.zoomScale));
						seg.control1.x = c1.x + delta_x;
						seg.control1.y = c1.y + delta_y;
						var c2:Point = atm.deltaTransformPoint(new Point(seg.control2.x * this.zoomScale, seg.control2.y * this.zoomScale));
						seg.control2.x = c2.x + delta_x;
						seg.control2.y = c2.y + delta_y;
						if(path == ''){
							s = seg.anchor1.x.toPrecision(4) + ',' + seg.anchor1.y.toPrecision(4) + ' ' + seg.control1.x.toPrecision(4) + ',' + seg.control1.y.toPrecision(4) + ' ' + seg.control2.x.toPrecision(4) + ',' + seg.control2.y.toPrecision(4) + ' ' + seg.anchor2.x.toPrecision(4) + ',' + seg.anchor2.y.toPrecision(4);
						} else{
							s = seg.control1.x.toPrecision(4) + ',' + seg.control1.y.toPrecision(4) + ' ' + seg.control2.x.toPrecision(4) + ',' + seg.control2.y.toPrecision(4) + ' ' + seg.anchor2.x.toPrecision(4) + ',' + seg.anchor2.y.toPrecision(4);
						}
					} else{
						if(path == ''){
							s = seg.anchor1.x.toPrecision(4) + ',' + seg.anchor1.y.toPrecision(4) + ' ' + seg.anchor2.x.toPrecision(4) + ',' + seg.anchor2.y.toPrecision(4);
						} else{
							s = seg.anchor2.x.toPrecision(4) + ',' + seg.anchor2.y.toPrecision(4);
						}
					}
				
					path = path + s + ';';
				}
				info_copy.path = path.slice(0, path.length - 1);
				this.proxy = new Annotation();
				stage.addChild(this.proxy);
				this.proxy.term.visible = false;
				this.proxy.info = info_copy;
				this.proxy.zoomScale = 1;
				this.proxy.update();
				this.proxy.startDrag();
				this.deFocus();
			}
			
			e.updateAfterEvent();
		}
		
		override public function onMouseUp(e:MouseEvent):void
		{
			trace("mouseup++++++++");
			if(!this.proxy){
				var f:Event = new Event("ROI_selected", true);
				dispatchEvent(f);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
				return;
			}
			this.proxy.stopDrag();
			var target:MapLayer = Application.application.showingMapLayers[1];
			if(target.ZL.getBounds(stage).contains(e.stageX, e.stageY) && (target.parent as Map).mask.getBounds(stage).contains(e.stageX, e.stageY)){
				target.AL.addChild(this.proxy);
				this.proxy.info.zoom = target.AL.zoom;
				this.proxy.info.x = target.mouseX;
				this.proxy.info.y = target.mouseY;
				target.AL.annotationInfoList.push(this.proxy.info);
				target.AL.modifiedInfoList.push(this.proxy.info);
				this.proxy.update();
				this.proxy.term.visible = true;
				target.AL.annotationList.push(this.proxy);
				target.AL.emptyFocusList();
				this.proxy.focus();
				target.AL.focusList.push(this.proxy);
			} else{
				stage.removeChild(this.proxy);
			}
			this.proxy = null;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		
		override public function update():void
		{
			super.locate();
			draw(1, 0x000000, 0);
		}
		
		override public function focus():void
		{
			draw(3, 0xFF0000);
			term.scaleX = 3;
			term.scaleY = 3;
			term.visible = true;
			term.mouseEnabled = true;
			parent.addChild(this);  //re-add this ROI as a child, to put it on top of other ROIs
		}
		
		override public function deFocus():void
		{
			draw(1, 0x000000, 0);
			if(termOpen){
				closeTermInput();
			}
			term.visible = false;
			term.mouseEnabled = false;
		}
	}
}