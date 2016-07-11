package com.worker
{
	import flash.events.Event;

	public class WorkerEvent extends Event
	{
		// 自定义事件
		public static const	RECIEVER_RECIEVE_MESSAGE:String = "reciever_recieve_message";	
		public static const	SENDER_RECIEVE_MESSAGE:String = "sender_recieve_message";
		public static const RECIEVER_RECIEVE_BYTEARRAY:String = "reciever_recieve_byteArray";
		public static const RECIEVER_RECIEVE_ACTION:String = "reciever_recieve_action";
		public static const WORKER_RUNNING:String = "worker_running";
		public static const WORKER_READY:String = "worker_ready";
		public static const WORKER_INIT:String = "worker_init";
		public static const WORKER_STOP:String = "worker_stop";
		public static const WORKER_MEMORY_FREE_ACTION:String = "worker_memory_free_action";
		
		// 自定义object变量，用来传递参数
		private var object:Object;
		
		/**
		 * 
		 * @param type
		 * @param _object
		 * @param bubbles
		 * @param cancelable
		 * 
		 */
		public function WorkerEvent(type:String, _object:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			object = _object;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get params():Object { 
			return object; 
		} 
	}
}