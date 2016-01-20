package com.repilac.multimap
{
	import flash.events.IEventDispatcher;

	public interface IAnnotationShape extends IEventDispatcher
	{
		function reset(x1:Number, y1:Number):void;
		function resize(w:Number, h:Number):void;
		function draw():void;
		function getType():int;
	}
}