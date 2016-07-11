package com.worker
{
	import avmplus.getQualifiedClassName;
	
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.net.registerClassAlias;
	import flash.system.ApplicationDomain;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	
	public class NativeWorkerLoader
	{
		private static var workerManager:WorkerManagerImpl;
		
		/**
		 * 
		 * @param loadInfoBytes
		 * @param runnableFunctions
		 * @param createWorkerManager
		 * 
		 */
		public static function initialize(loadInfoBytes:ByteArray, runnableFunctions:Object, createWorkerManager:Function):void{
			if(Worker.current.isPrimordial){
				try {
					workerManager = new WorkerManager(loadInfoBytes, runnableFunctions);
				}
				catch (e:Error){
					MonsterDebugger.trace(NativeWorkerLoader, "加载worker失败！", "initialize");
				}
			}
			else {
				workerManager = createWorkerManager.call(NativeWorkerLoader) as WorkerManagerImpl;
			}	
		}
		
		/**
		 * 
		 * @param loadInfoBytes
		 * @param bgWorkerManager
		 * 
		 */
		private static function simpleInitialize(loadInfoBytes:ByteArray, bgWorkerManager:WorkerManagerImpl):void{
			var app:ApplicationDomain = ApplicationDomain.currentDomain;
			if(Worker.current.isPrimordial){
				try {
					workerManager = new WorkerManager(loadInfoBytes);
				}
				catch (e:Error){
					MonsterDebugger.trace(NativeWorkerLoader, "加载worker失败！", "simpleInitialize");
				}
			}
			else {
				workerManager = bgWorkerManager;
			}	
		}
		
		
		/**
		 * 
		 * @param mainFunction
		 * 
		 */
		public static function loadMain(mainFunction:Function):void {
			if (workerManager != null && workerManager.isMain() && mainFunction != null){
				if (!workerManager.isReady()){
					workerManager.onReady(function ():void{
						mainFunction.call(workerManager, workerManager);
					});
					workerManager.start();
				}
				else {
					mainFunction.call(workerManager, workerManager);
				}
			}
		}
		
		/**
		 * 
		 * @param workerFunciton
		 * 
		 */
		public static function loadWorker(workerFunciton:Function):void {
			if (workerManager != null && !workerManager.isMain() && workerFunciton != null){
				if (!workerManager.isReady()){
					workerManager.ready();
				}
				workerFunciton.call(workerManager, workerManager);
			}
		}
		
		/**
		 * 
		 * @param mainFunction
		 * @param workerFunciton
		 * 
		 */
		public static function load(mainFunction:Function, workerFunciton:Function):void {
			loadMain(mainFunction);
			loadWorker(workerFunciton);
		}
	}
}