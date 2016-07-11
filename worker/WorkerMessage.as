package com.worker
{
	public class WorkerMessage
	{	
		public static const NUMBER_TYPE:String = "number_type";
		public static const FUNCTION_TYPE:String = "function_type";
		public static const WORKER_READY:String = "worker_ready";
		
		private var _type:String;
		private var _data:*;
		private var _msg:String;
		
		/**
		 * 
		 * @param type
		 * @param data
		 * @param msg
		 * 
		 */
		public function WorkerMessage(type:String, data:*=null, msg:String=null)
		{
			_type = type;
			_data = data;
			_msg = msg;
		}
		
		public function get msg():String
		{
			return _msg;
		}

		public function set msg(value:String):void
		{
			_msg = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get data():*
		{
			return _data;
		}

		public function set data(value:*):void
		{
			_data = value;
		}
	}
}