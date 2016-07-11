package com.worker
{
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	
	public class WorkerMessageManager extends EventDispatcher
	{
		
		public static const MAIN_TO_WORKER_CHANNEL_KEY:String = "mainToWorkerChannel";
		public static const WORKER_TO_MAIN_CHANNEL_KEY:String = "workerToMainChannel";
		
		private var receiver:MessageChannel;
		private var sender:MessageChannel;
		
		/**
		 * 
		 * @param worker
		 * 
		 */
		public function WorkerMessageManager(worker:Worker){
			if (Worker.current.isPrimordial){
				sender = Worker.current.createMessageChannel(worker);
				receiver = worker.createMessageChannel(Worker.current);
				
				//现在我们有两个通信对象，把它们作为共享属性注入到worker线程
				//这样，worker线程就能在另一边获取它们
				worker.setSharedProperty(WorkerMessageManager.MAIN_TO_WORKER_CHANNEL_KEY, sender);
				worker.setSharedProperty(WorkerMessageManager.WORKER_TO_MAIN_CHANNEL_KEY, receiver);
			}
			else {
				receiver = worker.getSharedProperty(WorkerMessageManager.MAIN_TO_WORKER_CHANNEL_KEY);
				sender = worker.getSharedProperty(WorkerMessageManager.WORKER_TO_MAIN_CHANNEL_KEY);
			}
			bindEvt();
		}
		
		/**
		 * 
		 * 
		 */
		private function bindEvt():void {
			receiver.addEventListener(Event.CHANNEL_MESSAGE, function (evt:Event):void {
				var receiveData:* =  receiver.receive(),
					messageType:String = WorkerEvent.RECIEVER_RECIEVE_MESSAGE;
					
				if (receiveData is ByteArray){
					messageType = WorkerEvent.RECIEVER_RECIEVE_BYTEARRAY;
				}
				else {
					receiveData = new WorkerMessage(receiveData.type, receiveData.data, receiveData.msg);
				}
				
				dispatchEvent(new WorkerEvent(messageType, {
					data: receiveData
				}));
			});
		}
		
		/**
		 * 
		 * @param byteArray
		 * 
		 */
		public function sendByteArray(byteArray:ByteArray):void {
			MonsterDebugger.trace(this, byteArray, "sengByteArray");
			sender.send(byteArray);
		}
		
		/**
		 * 
		 * @param message
		 * 
		 */
		public function sendMessage(message:WorkerMessage):void {
			sender.send(message);
		}
		
		/**
		 * 
		 * @param handleFunction
		 * 
		 */
		public function onMessage(handleFunction:Function):void {
			if (handleFunction != null && handleFunction is Function){
				addEventListener(WorkerEvent.RECIEVER_RECIEVE_MESSAGE, function (evt:WorkerEvent):void{
					handleFunction(evt.params.data);
				});
			}
		}
		
		/**
		 * 
		 * @param handleFunction
		 * 
		 */
		public function onByteArray(handleFunction:Function):void {
			if (handleFunction != null && handleFunction is Function){
				addEventListener(WorkerEvent.RECIEVER_RECIEVE_BYTEARRAY, function (evt:WorkerEvent):void{
					handleFunction(evt.params.data);
				});
			}
		}
	}
}