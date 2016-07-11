package com.worker
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public interface WorkerManagerImpl 
	{
		/**
		 * 
		 * @return 
		 * 
		 */
		function isMain():Boolean;
		
		/**
		 * 
		 * @return 
		 * 
		 */
		function isReady():Boolean;
		
		/**
		 * 
		 * @param handleFunction
		 * 
		 */
		function onByteArray(handleFunction:Function):void;
		
		/**
		 * 
		 * @param byteArray
		 * 
		 */
		function sendByteArray(byteArray:ByteArray):void;
		
		/**
		 * 
		 * @param workMessage
		 * 
		 */
		function sendMessage(workMessage:WorkerMessage):void;
		
		/**
		 * 
		 * @param handleFunction
		 * 
		 */
		function onMessage(handleFunction:Function):void;
		
		/**
		 * 
		 * @param key
		 * @param args
		 * @param callback
		 * 
		 */
		function call(key:String, args:Array = null, callback:Function = null):void;
		
		/**
		 * 
		 * @param key
		 * @param runnableFunc
		 * @param isTempfunction
		 * 
		 */
		function register(key:String, runnableFunc:Function, isTempfunction:Boolean = false):void;
		
		/**
		 * 
		 * @param object
		 * 
		 */
		function registers(object:Object):void;
		
		/**
		 * 
		 * @param callback
		 * 
		 */
		function onReady(callback:Function):void;
		
		/**
		 * 
		 * 
		 */
		function ready():void;
		
		/**
		 * 
		 * @param key
		 * @param value
		 * @param isAvaiableForFreeMemory
		 * 
		 */
		function share(key:String, value:*, isAvaiableForFreeMemory:Boolean = true):void;
		
		/**
		 * 
		 * @param key
		 * @return 
		 * 
		 */
		function getShare(key:String):*;
		
		/**
		 * 
		 * 
		 */
		function freeMemory():void;
	
		/**
		 * 
		 * 
		 */
		function start():void;
		
		/**
		 * 
		 * 
		 */
		function stop():void;
	}
}