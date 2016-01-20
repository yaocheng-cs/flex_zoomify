package com.repilac.multimap
{
	import flash.events.MouseEvent;
	
	public class ReferenceROILayer extends AnnotationLayer
	{
		public function ReferenceROILayer()
		{
			super();
		}
		
		public function onMouseClick(e:MouseEvent):void
		{
			if(e.target is Annotation){
				e.target.alpha = 1
			}
		}
		
	}
}