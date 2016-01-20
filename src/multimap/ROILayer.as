package com.repilac.multimap
{
	import flash.events.*;
	
	public class ROILayer extends AnnotationLayer
	{
		
		
		public function ROILayer(url:String=null)
		{
			super(url);
			
			removeEventListener("drawing_done", onDrawingDone);
			//removeEventListener("update_focus_list", updateFocusList);
			removeEventListener("fram_adjusted", onFrameAdjusted);
			//removeEventListener("annotation_modified", this.onAnnotationModified);
			addEventListener("ROI_focus", this.onRoiFocus);
		}
		
		public function onRoiFocus(e:Event):void
		{
			focusList.push(e.target);
		}
		
	}
}