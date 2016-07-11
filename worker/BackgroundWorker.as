package com.worker
{
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.net.registerClassAlias;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	
	public class BackgroundWorker extends WorkerManager
	{	
		/**
		 * 
		 * @param runnable
		 * 
		 */
		public function BackgroundWorker(runnable:Object = null)
		{
			super(null, runnable);
		}
	}
}