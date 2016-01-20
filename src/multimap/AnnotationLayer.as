package com.repilac.multimap
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.ui.Keyboard;
	
	import mx.core.Application;
	
	//import org.as3yaml.YAML;  //a third party library for converting AS3 object to/from YAML

	public class AnnotationLayer extends Sprite
	{
		protected var _annotationList:Array;
		public function get annotationList():Array
		{
			return this._annotationList;
		}
		
		protected var _annotationInfoList:Array;
		public function get annotationInfoList():Array
		{
			return this._annotationInfoList;
		}
		
		protected var _focusList:Array;
		public function get focusList():Array
		{
			return this._focusList;
		}
		
		protected var _modifiedInfoList:Array;
		public function get modifiedInfoList():Array
		{
			return this._modifiedInfoList;
		}
		
		protected var _deltaFocusList:Array;
		public var annotationLoaded:Boolean;
		
		protected var _drawer:Drawer;
		//when setting the drawer, remember to disable the selector
		public function set drawer(value:Drawer):void
		{
			if(value){
				this._drawer = value;
				this.addChild(this._drawer);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, this._drawer.onMouseDown);
			} else{
				this.removeChild(this._drawer);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, this._drawer.onMouseDown);
			}
		}
		
		protected var _selector:DottedRect;
		public function setSelector():void
		{
			if(!this._selector){
				this._selector = new DottedRect();
				this.addChild(this._selector);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, this._selector.onMouseDown);
			}
		}
		public function unsetSelector():void
		{
			if(this._selector){
				this.removeChild(this._selector);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, this._selector.onMouseDown);
				this._selector = null;
			}
		}
		
		public var imageURL:String;
		public var zoom:Number;
		public var serverOperationType:int = 0;
		public var data:String;
		public var deletingID:Array;
		
		public function AnnotationLayer(url:String=null)
		{
			super();
			
			this.imageURL = url;
			this._annotationInfoList = new Array();
			this._annotationList = new Array();
			this._focusList = new Array();
			this._modifiedInfoList = new Array();
			this.annotationLoaded = false;
			
			addEventListener("drawing_done", this.onDrawingDone);
			addEventListener("update_focus_list", this.updateFocusList);
			addEventListener("frame_adjusted", this.onFrameAdjusted);
			addEventListener("annotation_modified", this.onAnnotationModified);
		}
		
		public function createAnnotationInfo(td:Drawer):AnnotationInfo
		{
			var ai:AnnotationInfo = new AnnotationInfo(td.type,
						  							   this.zoom,
						  							   td.pos_X,
						  							   td.pos_Y,
						  							   td.drawingWidth,
						  							   td.drawingHeight,
						  							   td.apex_Xs,
						  							   td.apex_Ys);
			return ai;
		}
		
		public function createAnnotation(ai:AnnotationInfo, roi:Boolean=false):Object
		{
			var a;
			if(!roi){
				a = new Annotation();
			} else{
				a = new ROI();
			}
			addChild(a);
			a.info = ai;
			if(ai.zoom == this.zoom){
				a.zoomScale = 1;
			} else{
				a.zoomScale = Math.pow(2, this.zoom - ai.zoom);
			}
			a.update();
			
			return a;
		}
		
		public function onDrawingDone(e:Event):void
		{
			var ai:AnnotationInfo = this.createAnnotationInfo(this._drawer);
			this.annotationInfoList.push(ai);
			this.modifiedInfoList.push(ai);
			var a:Annotation = this.createAnnotation(ai) as Annotation;
			this.annotationList.push(a);
			a.focus();
			this.focusList.push(a);
			//event will pop, and let the application to set the drawer to null
		}
		
		/*
		public function onAnnotationDown(e:Event):void
		{
			if(e.type == "empty_current_list"){
				this.emptyFocusList();
			}
			var a:Annotation = e.target as Annotation;
			this._deltaFocusList = new Array();
			this._deltaFocusList.push(a);
			this.updateFocusList();
		}
		*/
		
		public function emptyFocusList():void
		{
			var a:Annotation;
			while(this._focusList.length > 0){
				a = this._focusList.pop();
				a.deFocus();
			}
		}
		
		public function updateFocusList(e:Event):void
		{
			var i:int;
			var j:int;
			var deFocused:Array;
			
			this._deltaFocusList = new Array();
			if(e.target is Annotation){
				this._deltaFocusList.push(e.target)
			} else{
				var n:Rectangle;
				for(i=0; i<this._annotationList.length; i++){
					var a:Annotation = this._annotationList[i];
					n = a.getBounds(stage);
					if((e.target as DottedRect).area.intersects(n)){
						this._deltaFocusList.push(a);
					}
				}
			}
			
			for(i=0; i<this._deltaFocusList.length; i++){
				j = this._focusList.indexOf(this._deltaFocusList[i]);
				if(j == -1){
					this._focusList.push(this._deltaFocusList[i]);
					(this._deltaFocusList[i] as Annotation).focus();
				} else{
					deFocused = this._focusList.splice(j, 1);
					(deFocused[0] as Annotation).deFocus();
				}
			}
		}
		
		public function onFrameAdjusted(e:Event):void
		{
			var df:DragFrame = e.target as DragFrame;
			df.annotation.info.updateFields(df);
			df.annotation.update();
		}
		
		public function onAnnotationModified(e:Event):void
		{
			var ai:AnnotationInfo = e.target.info;
			if(this.modifiedInfoList.indexOf(ai) == -1){
				this.modifiedInfoList.push(ai);
			}
		}
		
		/*
		public function onMouseDown(e:MouseEvent):void
		{
			//if mouse down on an annotation (or text inside the annotation), we don't want to draw the rubberband since we just want to drag an annotation,
			//but still, the currentAL might be changing
			//so just return at the AnnotationLayer level, and let the mouse event "pop" to application  
			if(e.target is Annotation || e.target is TextField){
				return;
			}
			
			//although currentAL is set, and only currentAL's mouse down event handler has been registered, following code is still necessary
			//because user may press down mouse at a place outside any Map's area, such as the Zoomer or Navigator. we don't want a rubberband start from there
			e.stopPropagation();
			var m:Rectangle = (parent.parent as Map).mask.getBounds(stage);
			if(!m.contains(e.stageX, e.stageY)){
				return;
			} else{
				//sometimes, Zoomer or Navigator may be inside the area of currentAL's Map
				//we still don't want rubberband to start from there
				if(e.target is Zoomer){
					return;
				}
			}
			
			//remove focus from annotations
			if(!e.ctrlKey && !e.shiftKey){
				this.emptyFocusList();
			}
			this._selector = new DottedRect();
			this._selector.setLineStyle(2, 0x00FFFF, 3);
			this._selector.setStart(mouseX, mouseY);
			addChild(this._selector);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		
		protected function onMouseMove(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			
			this._selector.setEnd(mouseX, mouseY);
			this._selector.draw();
		}
		
		protected function onMouseUp(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			
			var a:Annotation;
			var i:int;
			
			var m:Rectangle = this._selector.getBounds(stage);
			//var m1:Rectangle = this._selector.getRect(this);
			var n:Rectangle;
			this._deltaFocusList = new Array();
			for(i=0; i<this._annotationList.length; i++){
				a = this._annotationList[i];
				n = a.getBounds(stage);
				if(m.intersects(n)){
					this._deltaFocusList.push(a);
				}
			}
			removeChild(this._selector);
			
			this.updateFocusList();
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			//parent.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			//parent.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}
		*/
		
		public function onKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.DELETE){
				this.deleteAnnotation();
			}
		}
		
		public function deleteAnnotation():void
		{
			var i:int;
			var a:Annotation;
			while(this._focusList.length > 0){
				a = this._focusList.pop();
				this._annotationList.splice(this._annotationList.indexOf(a), 1);
				removeChild(a);
			}
		}
		
		public function zoomTo(z:Number):void
		{
			//super.zoomTo(z);
			
			var a:Annotation;
			for(var i:int=0; i<this._annotationList.length; i++){
				a = this._annotationList[i];
				a.zoomTo(z);
				if(a.frame){
					a.frame.zoomToo();
				}
			}
			this.zoom = z;
		}
		
		public function erase():void
		{
			var k:int;
			var t:int;
			var a:Annotation;
			while(this.focusList.length > 0){
				a = this.focusList.pop();
				a.deFocus();
				this.removeChild(a);
				k = this.annotationList.indexOf(a);
				this.annotationList.splice(k, 1);
				this.annotationInfoList.splice(k, 1);
				t = this.modifiedInfoList.indexOf(a.info);
				this.modifiedInfoList.splice(t, 1);
			}
		}
		
		public function save():void
		{
			this.serverOperationType = 1;
			
			var aiString:String;
			var ai:AnnotationInfo;
			this.data = '';
			while(this.modifiedInfoList.length > 0){
				ai = this.modifiedInfoList.pop();
				aiString = this.annotInfo2String(ai);
				this.data = this.data + '----------' + aiString;
			}
			this.serverOperation(this.serverOperationType);
		}
		
		public function load():void
		{
			if(!this.annotationLoaded){
				this.serverOperationType = 2;
				this.serverOperation(this.serverOperationType);
				
				//this.loadFromLocal();
			}
		}
		
		///////////////////////////////////////////////////////////////////////
		// temporary function for loading roi from local
		protected function loadFromLocal():void
		{		
			if(this.imageURL.search("ARA-Sagittal-020") > -1){
				
				var now:Date = new Date();
				trace('start time:');
				trace(now.getSeconds());
				trace(now.getMilliseconds());
				trace('---------------------');
				
				var s010:String = Application.application.s010;
				
				var ai:AnnotationInfo;
				var a:ROI;
				for each (var line:String in s010.split('\n')){
					var segs_term_pos:Array = line.split('   ');
					var truncated_path:String = this.truncate(segs_term_pos[0]);
					var segments:Array = this.path2Segs(truncated_path);
					var term:String = segs_term_pos[1].slice(1, segs_term_pos[1].length - 1);
					if(term == ''){
						term = "Empty";
					} else {
						var temp:String = '';
						for each (var t:String in term.split(', ')){
							temp = temp + t.slice(1, t.length - 1) + ' ';
						}
						term = temp.slice(0, temp.length - 1);
					}
					var pos:Array = segs_term_pos[2].split(',');
					pos[0] = Number(pos[0]).toPrecision(5);
					pos[1] = Number(pos[1]).toPrecision(5);
					
					/*
					var segs:Array = segs_term_pos[0].split(';');
					var segments = new Array();
					var segment;
					for each (var seg:String in segs){
						var ps:Array = seg.split(' ');
						var cps:Array = new Array();
						var cp:Point;
						for each (var p:String in ps){
							var x_y:Array = p.split(',');
							cp = new Point(Number(x_y[0]), Number(x_y[1]));
							cps.push(cp);
						}
						if(cps.length == 2){
							segment = new StraightLine(cps[0], cps[1]);
						}
						if(cps.length == 3){
							segment = new QuadraticBezier(cps[0], cps[1], cps[2]);
						}
						if(cps.length == 4){
							segment = new CubicBezier(cps[0], cps[1], cps[2], cps[3]);
						}
						segments.push(segment);
					}
					*/
					
					ai = new AnnotationInfo(3, 4, Number(pos[0]), Number(pos[1]), 0, 0, null, null, segments, truncated_path, term);
					this.annotationInfoList.push(ai);
					this.modifiedInfoList.push(ai);
					a = this.createAnnotation(ai, true) as ROI;
					this.annotationList.push(a);
				}
				
				now = new Date();
				trace('end time:');
				trace(now.getSeconds());
				trace(now.getMilliseconds());
				trace('---------------------');
			}
		}
		////////////////////////////////////////////////////////////////////////
		
		public function del():void
		{
			this.serverOperationType = 3;
				
			var a:Annotation;
			var ai:AnnotationInfo;
			this.deletingID = new Array();
			while(this.focusList.length > 0){
				a = this.focusList.pop();
				a.deFocus();
				this.removeChild(a);
				var i:int = this.annotationList.indexOf(a);
				this.annotationList.splice(i, 1);
				ai = this.annotationInfoList.splice(i, 1)[0];
				if(ai.id > 0){
					this.deletingID.push(ai.id);
				}
				var j:int = this.modifiedInfoList.indexOf(ai);
				this.modifiedInfoList.splice(j, 1);
			}
			if(this.deletingID.length > 0){
				this.serverOperation(this.serverOperationType);
			}
		}
		
		protected function annotInfo2String(ai:AnnotationInfo):String
		{
			var aiPropertyArray:Array = new Array();
			aiPropertyArray.push('');
			aiPropertyArray.push(ai.id.toString());
			aiPropertyArray.push(ai.term);
			aiPropertyArray.push(ai.type.toString());
			aiPropertyArray.push(ai.zoom.toString());
			aiPropertyArray.push(ai.x.toString());
			aiPropertyArray.push(ai.y.toString());
			aiPropertyArray.push(ai.width.toString());
			aiPropertyArray.push(ai.height.toString());
			if(ai.apex_Xs || ai.apex_Ys){
				var n:Number;
				var xs:Array = new Array();
				for each (n in ai.apex_Xs){
					//xs.push(n.toPrecision(4));
					xs.push(n.toString());
				}
				aiPropertyArray.push(xs.join(','));
				var ys:Array = new Array();
				for each (n in ai.apex_Ys){
					//ys.push(n.toPrecision(4));
					ys.push(n.toString());
				}
				aiPropertyArray.push(ys.join(','));
			} else{
				aiPropertyArray.push('null');
				aiPropertyArray.push('null');
			}
			aiPropertyArray.push(ai.path);
			aiPropertyArray.push('');
			
			var aiString:String = aiPropertyArray.join('\n');
			return aiString;
		}
		
		protected function string2AnnotInfo(s:String):AnnotationInfo
		{
			var aiPropertyArray:Array = s.split('\n');
			aiPropertyArray = aiPropertyArray.slice(1, aiPropertyArray.length - 1);
			var xs:Array;
			var ys:Array;
			var i:int;
			if(aiPropertyArray[8] == 'null' || aiPropertyArray[9] == 'null'){
				xs = null;
				ys = null;
			} else{
				xs = aiPropertyArray[8].split(',');
				for(i=0; i<xs.length; i++){
					xs[i] = Number(xs[i]);
				}
				ys = aiPropertyArray[9].split(',');
				for(i=0; i<ys.length; i++){
					ys[i] = Number(ys[i]);
				}
			}
			var segs:Array;
			if(aiPropertyArray[10] == ''){
				segs = null
			} else{
				segs = this.path2Segs(aiPropertyArray[10]);
			}
			var ai:AnnotationInfo = new AnnotationInfo(int(aiPropertyArray[2]),
													   Number(aiPropertyArray[3]),
													   Number(aiPropertyArray[4]),
													   Number(aiPropertyArray[5]),
													   Number(aiPropertyArray[6]),
													   Number(aiPropertyArray[7]),
													   xs,
													   ys,
													   segs,
													   aiPropertyArray[10],
													   aiPropertyArray[1]);
			ai.id = int(aiPropertyArray[0]);
			return ai;
		}
		
		protected function path2Segs(path:String):Array
		{
			var segments = new Array();
			var segment;
			var cursor:Point;
			for each (var seg:String in path.split(';')){
				var cps:Array = new Array();
				for each (var p:String in seg.split(' ')){
					var x_y:Array = p.split(',');
					var cp:Point = new Point(Number(x_y[0]), Number(x_y[1]));
					cps.push(cp);
				}
				if(cursor == null){
					if(cps.length == 2){
						segment = new StraightLine(cps[0], cps[1]);
					}
					if(cps.length == 3){
						segment = new QuadraticBezier(cps[0], cps[1], cps[2]);
					}
					if(cps.length == 4){
						segment = new CubicBezier(cps[0], cps[1], cps[2], cps[3]);
					}
				} else{
					if(cps.length == 1){
						segment = new StraightLine(cursor, cps[0]);
					}
					if(cps.length == 2){
						segment = new QuadraticBezier(cursor, cps[0], cps[1]);
					}
					if(cps.length == 3){
						segment = new CubicBezier(cursor, cps[0], cps[1], cps[2]);
					}
				}
				cursor = cps[cps.length - 1];
				segments.push(segment);
			}
			return segments;
		}
		
		protected function truncate(path:String):String
		{
			var new_path:String = '';
			for each (var seg:String in path.split(';')){
				var new_seg:String = '';
				for each (var p:String in seg.split(' ')){
					var x_y:Array = p.split(',');
					var new_p:String = Number(x_y[0]).toPrecision(4) + ',' + Number(x_y[1]).toPrecision(4);
					new_seg = new_seg + new_p + ' ';
				}
				new_path = new_path + new_seg.slice(0, new_seg.length - 1) + ';';
			}
			return new_path.slice(0, new_path.length - 1);
		}
		
		public function serverOperation(type:int):void
		{
			var url_r:URLRequest;
			var url_v:URLVariables;
			var url_l:URLLoader;
			
			url_v = new URLVariables();
			switch(type)
			{
				case 1:
				url_r = new URLRequest("http://www.credrivermice.org/characterizations/saveannotation");
				url_r.method = URLRequestMethod.POST;
				url_v.imagepath = this.imageURL.replace("http://www.credrivermice.org", "");
				url_v.data = this.data;
				break;
				
				case 2:
				url_r = new URLRequest("http://www.credrivermice.org/characterizations/getannotation");
				url_r.method = URLRequestMethod.GET; 
				url_v.imagepath = this.imageURL.replace("http://www.credrivermice.org", "");
				break;
				
				case 3:
				url_r = new URLRequest("http://www.credrivermice.org/characterizations/deleteannotation");
				url_r.method = URLRequestMethod.GET;
				url_v.id = this.deletingID.join();
				break;
				
				default:
				trace("The serverOperationType is not in [1, 2, 3]");
				break;
			}
			url_r.data = url_v;
			
			url_l = new URLLoader();
			url_l.addEventListener("complete", this.onURLRequestSucceed);
			url_l.addEventListener("ioError", this.onURLRequestFail);
			url_l.load(url_r);
			
			var now:Date = new Date();
			trace('remote load start time:');
			trace(now.getSeconds());
			trace(now.getMilliseconds());
			trace('---------------------');
		}
		
		public function onURLRequestSucceed(e:Event):void
		{
			var ai:AnnotationInfo;
			var a;
			switch(this.serverOperationType)
			{
				case 1:
				break;
				
				case 2:
				
				var now:Date = new Date();
				trace('remote load end time:');
				trace(now.getSeconds());
				trace(now.getMilliseconds());
				trace('---------------------');
				
				this.emptyFocusList();
				while(this.annotationList.length > 0){
					a = this.annotationList.pop();
					this.removeChild(a);
					this.annotationInfoList.pop();
				}
				while(this.modifiedInfoList.length > 0){
					this.modifiedInfoList.pop();
				}
				
				var aiStrings:Array = (e.target.data as String).split('----------');
				for(var i:int=1; i < aiStrings.length; i++){
					ai = this.string2AnnotInfo(aiStrings[i]);
					this.annotationInfoList.push(ai);
					if(ai.type == 3 && this.imageURL.search('ARA') > -1){
						a = this.createAnnotation(ai, true) as ROI;
					} else{
						a = this.createAnnotation(ai) as Annotation;
					}
					this.annotationList.push(a);
				}
				this.annotationLoaded = true;
				
				now = new Date();
				trace('render end time:');
				trace(now.getSeconds());
				trace(now.getMilliseconds());
				trace('---------------------');
				
				break;
				
				case 3:
				break;
				
				default:
				break;
			}
			this.serverOperationType = 0;
		}
				
		public function onURLRequestFail(e:IOErrorEvent):void
		{
			this.serverOperationType = 0;
			trace("annotation layer url request fail");
		}
		
		public function mute():void
		{
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		public function enable():void
		{
			this.mouseEnabled = true;
			this.mouseChildren = true;
		}
		
		
		
		
		
		
		/*protected function onAnnotationAddedToFocus(e:Event):void
		{
			var a:Annotation = Annotation(e.target);
			this.addToFocus(a);
		}
		
		protected function onAnnotationFocused(e:Event):void
		{
			this.removeAllFocus();
			var a:Annotation = Annotation(e.target);
			this.addToFocus(a);
		}
		
		protected function onAnnotationRemovedFromFocus(e:Event):void
		{
			var a:Annotation = Annotation(e.target);
			this.removeFromFocus(a);
		}
		
		protected function addToFocus(a:Annotation):void
		{
			a.focus = true;
			a.background.visible = true;
			if(this._currentFocus.length > 0){
				a.inMultiSelect = true;
				if(this._currentFocus.length == 1){
					this._currentFocus[0].inMultiSelect = true;
					this._multiSelect = true;
				}
			}
			this._currentFocus.push(a);
		}
		
		protected function removeFromFocus(a:Annotation):void
		{
			if(a.editingText){
				a.disableEditingText();
			}
			a.focus = false;
			a.inMultiSelect = false;
			a.background.visible = false;
			var i:int = this._currentFocus.indexOf(a);
			this._currentFocus.splice(i, 1);
			if(this._currentFocus.length == 1){
				this._currentFocus[0].inMultiSelect = false;
				this._multiSelect = false;
			}
		}
		
		public function removeAllFocus():void
		{
			var a:Annotation;
			while(this._currentFocus.length > 0){
				a = this._currentFocus.pop();
				if(a.editingText){
					a.disableEditingText();
				}
				a.focus = false;
				a.inMultiSelect = false;
				a.background.visible = false;
			}
		}*/
		
		/*protected function onMultiMoveStart(e:Event):void
		{
			for(var i:int=0; i<this._currentFocus.length; i++){
				this._deltaXs.push(this._currentFocus[i].x - e.target.x);
				this._deltaYs.push(this._currentFocus[i].y - e.target.y);
			}
		}
		
		protected function onMultiMoveGoing(e:Event):void
		{
			if(this._multiSelect){
				for(var i:int=0; i<this._currentFocus.length; i++){
					this._currentFocus[i].x = e.target.x + this._deltaXs[i];
					this._currentFocus[i].y = e.target.y + this._deltaYs[i];
				}
			}
		}
		
		protected function onMultiMoveStop(e:Event):void
		{
			while(this._deltaXs.length > 0){
				this._deltaXs.pop();
				this._deltaYs.pop();
			}
		}*/
		
		/*public function saveToXML():void
		{
			if(this._existedAnnotations.length == 0){
				trace("nothing to save");
			} else{
				var qName:QName = new QName("root");
				var document:XMLDocument = new XMLDocument();
				var encoder:SimpleXMLEncoder = new SimpleXMLEncoder(document);
				for(var i:int=0; i<this._existedAnnotations.length; i++){
					var xmlNode:XMLNode = encoder.encodeValue(this._existedAnnotations[i], qName, document);
				}
                var xml:XML = new XML(document.toString());
                this._bufferXML = xml.toXMLString();
			}
		}
		
		public function loadFromXML():void
		{
			if(this._bufferXML == null){
				trace("nothing to load");
			} else{
				while(this._existedAnnotations.length > 0){
					this._existedAnnotations.pop();
				}
				var document:XMLDocument = new XMLDocument(this._bufferXML);
				var decoder:SimpleXMLDecoder = new SimpleXMLDecoder();
				var result:Object = decoder.decodeXML(document);
				this._existedAnnotations = Array(result);
				for(var i:int=0; i<this._existedAnnotations.length; i++){
					var a:Annotation = Annotation(this._existedAnnotations[i]);
					this.addChild(a);
				}
				trace("hello");
			}
		}*/
		
		/*
		protected function onMultipleAnnotationMove(e:MouseEvent):void
		{
			var dx:Number = e.stageX - this._lastX;
			var dy:Number = e.stageY - this._lastY;
			
			for(var i:int=0; i<this._currentFocus.length; i++){
				this._currentFocus[i].x = this._currentFocus[i].x + dx;
				this._currentFocus[i].y = this._currentFocus[i].y + dy;
			}
			this._selectedArea.x = this._selectedArea.x + dx;
			this._selectedArea.y = this._selectedArea.y + dy;
			
			this._lastX = e.stageX;
			this._lastY = e.stageY;
		}
		
		protected function onMultipleAnnotationUp(e:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_MOVE, this.onMultipleAnnotationMove);
			removeEventListener(MouseEvent.MOUSE_UP, this.onMultipleAnnotationUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMultipleAnnotationMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMultipleAnnotationUp);
		}
		*/
		
		//protected function onMouseClick(e:MouseEvent):void
		//{
		//	graphics.clear();
		//	graphics.lineStyle(1, 0xFF0000);
		//	graphics.drawRect(100, 100, 50, 50);
		//}
	}
}