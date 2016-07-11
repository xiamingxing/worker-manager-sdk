package com.worker
{
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	public class WorkerManager extends EventDispatcher implements WorkerManagerImpl
	{
		public static const MAX_SHARE_LENGTH:int = 300;
		protected const REGISTER_FUNCTION_PREFIX:String = "__function__";
		protected const CALLBACK_FUNCTION_PREFIX:String = "__callback__";
		protected const BYTEARRAY_ARGS_PREFIX:String = "__ByteArray__";
		
		protected var worker:Worker;
		protected var workerMessageManager:WorkerMessageManager;
		protected var workerState:String;
		protected var memoryControlQueue:Array;
		
		/**
		 * 
		 * @param loadInfoBytes
		 * @param runnableFunctionObject
		 * 
		 */
		public function WorkerManager(loadInfoBytes:ByteArray, runnableFunctionObject:Object = null)
		{
			super(this);
			initWorker(loadInfoBytes);
			initWorkerManagerState();
			initWorkerMessageManager();
			initMemoryControl();
			initRunnableFucntions(runnableFunctionObject);
			bindEvt();
		}
		
		/**
		 * 
		 * @param runnableFunctionObject
		 * 
		 */
		protected function initRunnableFucntions(runnableFunctionObject:Object):void{
			registers(runnableFunctionObject);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function isMain():Boolean {
			return Worker.current.isPrimordial;
		}
		
		/**
		 * 
		 * @param loadInfoBytes
		 * 
		 */
		protected function initWorker(loadInfoBytes:ByteArray):void {
			if (isMain() && loadInfoBytes != null){
				worker = WorkerDomain.current.createWorker(loadInfoBytes, true);
			}
			else {
				worker = Worker.current;
			}
		}
		
		/**
		 * 
		 * 
		 */
		protected function initWorkerMessageManager():void {
			workerMessageManager = new WorkerMessageManager(worker);
		}
		
		/**
		 * 
		 * 
		 */
		protected function initMemoryControl():void {
			memoryControlQueue = new Array;
		}
		
		/**
		 * 
		 * 
		 */
		protected function initWorkerManagerState():void {
			workerState = WorkerEvent.WORKER_INIT;
		}
		
		/**
		 * 
		 * @param _workerState
		 * 
		 */
		protected function updateWorkerState(_workerState:String):void{
			workerState = _workerState;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function isReady():Boolean {
			return (workerState == WorkerEvent.WORKER_READY) as Boolean;
		}
		
		/**
		 * 
		 * 
		 */
		protected function bindEvt():void {
			worker.addEventListener(Event.WORKER_STATE, handleWorkerState);
			workerMessageManager.onMessage(function (workerMessage:WorkerMessage):void{
				switch (workerMessage.type){
					case WorkerMessage.FUNCTION_TYPE:
						var obj:Object = workerMessage.data;
						run(obj.key, obj.args, obj.callbackKey);
						break;
					case WorkerEvent.WORKER_READY:
						updateWorkerState(WorkerEvent.WORKER_READY);
						dispatchEvent(new WorkerEvent(WorkerEvent.WORKER_READY, null));
						break;
				}
			});
		}
		
		/**
		 * 
		 * @param evt
		 * 
		 */
		protected function handleWorkerState(evt:Event):void {
			switch (worker.state) {
				case WorkerState.RUNNING:
					updateWorkerState(WorkerEvent.WORKER_RUNNING);
					break;
				case WorkerState.NEW:
					updateWorkerState(WorkerEvent.WORKER_INIT);
					break;
				case WorkerState.TERMINATED:
					updateWorkerState(WorkerEvent.WORKER_STOP);
					break;
			}
		}
		
		/**
		 * 
		 * @param handleFunction
		 * 
		 */
		public function onByteArray(handleFunction:Function):void{
			workerMessageManager.onByteArray(handleFunction);
		}
		
		/**
		 * 
		 * @param byteArray
		 * 
		 */
		public function sendByteArray(byteArray:ByteArray):void {
			byteArray.shareable = true;
			workerMessageManager.sendByteArray(byteArray);
		}
		
		/**
		 * 
		 * @param workerMessage
		 * 
		 */
		public function sendMessage(workerMessage:WorkerMessage):void {
			workerMessageManager.sendMessage(workerMessage);
		}
		
		/**
		 * 
		 * @param handleFunction
		 * 
		 */
		public function onMessage(handleFunction:Function):void {
			workerMessageManager.onMessage(handleFunction);
		}
		
		/**
		 * 
		 * @param key
		 * @param args
		 * @param callback
		 * 
		 */
		public function call(key:String, args:Array = null, callback:Function = null):void{
			
			var byteArrayKey:String = null,
				callbackKey:String = null;
			
			if (args != null){
				args.map(function (item:*, index:int, array:Array):*{
					if (item is ByteArray){
						byteArrayKey = key + BYTEARRAY_ARGS_PREFIX + index + "_" + WorkerUtils.generateRandomString();
						share(byteArrayKey, item);
						return byteArrayKey;
					}
					else {
						return item;
					}
				});
			}
			
			if (callback != null){
				callbackKey = key + CALLBACK_FUNCTION_PREFIX  + WorkerUtils.generateRandomString();
				register(callbackKey, callback, true);
			}
			
			sendMessage(new WorkerMessage(WorkerMessage.FUNCTION_TYPE, {
				key: key,
				args: args,
				callbackKey: callbackKey
			}));
		}
		
		/**
		 * 
		 * @param key
		 * @param args
		 * @param callbackKey
		 * 
		 */
		protected function run(key:String, args:Array = null, callbackKey:String = null):void{
			if (args != null){
				args.map(function (item:*, index:int, array:Array):*{
					if (item is String && item.indexOf(BYTEARRAY_ARGS_PREFIX)){
						return getShare(item);
					}
					else {
						return item;
					}
				});
			}
			
			MonsterDebugger.trace(this, REGISTER_FUNCTION_PREFIX + key, 'run');
			dispatchEvent(new WorkerEvent(REGISTER_FUNCTION_PREFIX + key, {
				args: args,
				callbackKey: callbackKey
			}));
			
		}
		
		/**
		 * 
		 * @param key
		 * @param runnableFunc
		 * @param isTempfunction
		 * 
		 */
		public function register(key:String, runnableFunc:Function, isTempfunction:Boolean = false):void {
			var self:WorkerManager = this,
				registerFunctionKey:String = REGISTER_FUNCTION_PREFIX + key,
				handle:Function = function (workerEvent:WorkerEvent):void{
					var params:Object = workerEvent.params,
						args:Array = params.args,
						callbackKey:String = params.callbackKey,
						result:* = runnableFunc.apply(WorkerManager, args);
					if (isTempfunction){
						removeEventListener(registerFunctionKey, handle);
					}
					if (callbackKey){
						call(callbackKey, [result]);
					}
					
				};
			MonsterDebugger.trace(this, registerFunctionKey , 'register');
			addEventListener(registerFunctionKey, handle);
		}
		
		/**
		 * 
		 * @param object
		 * 
		 */
		public function registers(object:Object):void {
			for (var key:String in object){
				var value:* = object[key];
				if (value != null && value is Function){
					register(key, value);
				}
			}
		}
		
		/**
		 * 
		 * @param callback
		 * 
		 */
		public function onReady(callback:Function):void {
			var self:WorkerManager = this,
				handle:Function = function (evt:WorkerEvent):void{
					callback.call(self, self);
					removeEventListener(WorkerEvent.WORKER_READY, handle);
				};
			addEventListener(WorkerEvent.WORKER_READY, handle);
		}
		
		/**
		 * 
		 * 
		 */
		public function ready():void {
			updateWorkerState(WorkerEvent.WORKER_READY);
			sendMessage(new WorkerMessage(WorkerEvent.WORKER_READY));
		}
		
		/**
		 * 
		 * @param key
		 * @param value
		 * @param isAvaiableForFreeMemory
		 * 
		 */
		public function share(key:String, value:*, isAvaiableForFreeMemory:Boolean = true):void{
			worker.setSharedProperty(key, value);
			if (isAvaiableForFreeMemory){
				memoryControlQueue.push(key);
				if (memoryControlQueue.length > MAX_SHARE_LENGTH){
					MonsterDebugger.trace(this, memoryControlQueue.length, "force free memory");
					freeMemory();
				}
			}
		}
		
		/**
		 * 
		 * @param key
		 * @return 
		 * 
		 */
		public function getShare(key:String):*{
			return worker.getSharedProperty(key);
		}
		
		/**
		 * 
		 * 
		 */
		public function freeMemory():void {
			excuteFreeMemory();
			sendMessage(new WorkerMessage(WorkerEvent.WORKER_MEMORY_FREE_ACTION));
		}
		
		/**
		 * 
		 * 
		 */
		protected function excuteFreeMemory():void {
			memoryControlQueue.slice(0, MAX_SHARE_LENGTH / 2).forEach(function (item:String, index:int, array:Array):void {
				worker.setSharedProperty(item, null);
			});
			memoryControlQueue = memoryControlQueue.slice(-MAX_SHARE_LENGTH / 2);
		}
		
		/**
		 * 
		 * 
		 */
		public function start():void {
			if (isMain() && worker.state != WorkerState.RUNNING){
				//启动worker线程.
				worker.start();
				MonsterDebugger.trace(this, worker.state, "state");
			}
		}
		
		/**
		 * 
		 * 
		 */
		public function stop():void {
			//终止worker线程.
			if (worker.state != WorkerState.TERMINATED){
				worker.terminate();
			}
		}
		
	}
}