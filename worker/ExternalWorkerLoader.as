package com.worker
{
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.ByteArray;

	public class ExternalWorkerLoader
	{
		private static var workerManagerMap:Object = new Object;
		private static var context:Sprite;
		private static var loaderInfo:LoaderInfo;
		private static var currentSwfUrl:String;
		private static var currentDomain:String;
		private static var loadingSwfTemp:Object = {};
		private static var defaultSourceUrlAliasMap:Object = {};
		private static var defaultDomainPolicyFileMap:Object = {};
		
		/**
		 * 
		 * @param _context
		 * @param sourceUrlAliasMap
		 * @param domainPolicyFileList
		 * @param prepareLoadPolicyFiles
		 * 
		 */
		public static function initialize(_context:Sprite, sourceUrlAliasMap:Object = null, domainPolicyFileList:Array = null, prepareLoadPolicyFiles:Boolean = false):void {
			try {
				context = _context;
				loaderInfo = context.loaderInfo;
				currentSwfUrl = loaderInfo.loaderURL;
				currentDomain = WorkerUtils.parseUrl(currentSwfUrl).domain;
				MonsterDebugger.trace(ExternalWorkerLoader, "initializeWorkerLoader");
			}
			catch(e:Error){
				MonsterDebugger.trace(ExternalWorkerLoader, "initializeWorkerLoader fail");
			}
			initsourceUrlAliasMap(sourceUrlAliasMap);
			initDomainPolicyFiles(domainPolicyFileList);
			if (prepareLoadPolicyFiles){
				loadAllDomainPolicyFiles();
			}
		}
		
		/**
		 * 
		 * @param sourceKey
		 * @param isAdaptCurrentSwfDomain
		 * @return 
		 * 
		 */
		public static function getWorkerManagerIns(sourceKey:String, isAdaptCurrentSwfDomain:Boolean = true):WorkerManager{
			var sourceUrl:String = generatSourceUrl(sourceKey, isAdaptCurrentSwfDomain);
			return workerManagerMap[sourceUrl];
		}
		
		/**
		 * 
		 * @param sourceUrlAliasMap
		 * 
		 */
		private static function initsourceUrlAliasMap(sourceUrlAliasMap:Object):void {
			if (sourceUrlAliasMap == null){
				return ;
			}
			
			for (var sourceUrl:String in sourceUrlAliasMap){
				var aliasName:String = sourceUrlAliasMap[sourceUrl];
				aliasSourcrUrlName(sourceUrl, aliasName);
			}
		}
		
		/**
		 * 
		 * @param aliasName
		 * @return 
		 * 
		 */
		private static function getsourceUrlByAliasName(aliasName:String):String {
			for (var sourceUrl:String in defaultSourceUrlAliasMap){
				if (defaultSourceUrlAliasMap[sourceUrl] == aliasName){
					return sourceUrl;
				}
			}
			return aliasName;
		}
		
		/**
		 * 
		 * @param sourceKey
		 * @param isAdaptCurrentSwfDomain
		 * @return 
		 * 
		 */
		private static function generatSourceUrl(sourceKey:String, isAdaptCurrentSwfDomain:Boolean = true):String {
			var sourceUrl:String = getsourceUrlByAliasName(sourceKey),
				sourceUrlDomain:String;
			
			if (isAdaptCurrentSwfDomain){
				sourceUrlDomain = WorkerUtils.parseUrl(sourceUrl).domain;
				if (sourceUrlDomain && currentDomain && currentDomain != sourceUrlDomain){
					return sourceUrl.replace(sourceUrlDomain, currentDomain);
				}
			}
			return sourceUrl;
		}
		
		/**
		 * 
		 * @param sourceUrl
		 * @param aliasName
		 * 
		 */
		public static function aliasSourcrUrlName(sourceUrl:String, aliasName:String):void{
			defaultSourceUrlAliasMap[sourceUrl] = aliasName;
		}
		
		/**
		 * 
		 * @param domainPolicyFileList
		 * 
		 */
		private static function initDomainPolicyFiles(domainPolicyFileList:Array):void {
			if (domainPolicyFileList == null || domainPolicyFileList.length == 0){
				return ;
			}
			domainPolicyFileList.forEach(function(item:String, index:int, array:Array):void {
				var domain:String = WorkerUtils.parseUrl(item).domain;
				defaultDomainPolicyFileMap[domain] = {
					isLoaded: false,
					url: item,
					domain: domain
				};
			});
		}
		
		/**
		 * 
		 * @param domain
		 * @param autoGenerate
		 * @return 
		 * 
		 */
		private static function getDomainPolicyFile(domain:String, autoGenerate:Boolean = false):Object{
			var policyFile:Object = defaultDomainPolicyFileMap[domain];
			
			if (policyFile != null){
				return policyFile;
			}
			
			if (autoGenerate && domain){
				defaultDomainPolicyFileMap[domain] = {
					url: "http://" + domain + "/crossdomain.xml",
					isLoaded: false
				};
				return defaultDomainPolicyFileMap[domain];
			}
			
			return null;
		}
		
		/**
		 * 
		 * @param sourceUrl
		 * @param autoGenerate
		 * 
		 */
		public static function loadDomainPolicyFile(sourceUrl:String, autoGenerate:Boolean = true):void {
			var domain:String = WorkerUtils.parseUrl(sourceUrl).domain,
				policyFile:Object = getDomainPolicyFile(domain, autoGenerate);

			if (policyFile == null){
				trace("loadDomainPolicyFile fail: from " + sourceUrl);
				return ;
			}
			
			if (policyFile.isLoaded){
				return ;
			}
			
			MonsterDebugger.trace(ExternalWorkerLoader, policyFile, "load policyFile " + policyFile.url);
			Security.loadPolicyFile(policyFile.url);
			policyFile.isLoaded = true;
		}
		
		/**
		 * 
		 * 
		 */
		protected static function loadAllDomainPolicyFiles():void {
			for (var domain:String in defaultDomainPolicyFileMap){
				var policyFile:Object = defaultDomainPolicyFileMap[domain];
				if (policyFile && !policyFile.isLoaded){
					loadDomainPolicyFile(policyFile.url);
					policyFile.isLoaded = true;
				}
			}
		}
		
		/**
		 * 
		 * @param sourceKey
		 * @param onReady
		 * @param isAdaptCurrentSwfDomain
		 * 
		 */
		public static function load(sourceKey:String, onReady:Function, isAdaptCurrentSwfDomain:Boolean = true):void {
			var sourceUrl:String = generatSourceUrl(sourceKey, isAdaptCurrentSwfDomain);
			
			if (workerManagerMap[sourceUrl]){
				run(workerManagerMap[sourceUrl], onReady);
			}
			else {
				loadDomainPolicyFile(sourceUrl);
				loadSwf(sourceUrl, function (workerBytes:ByteArray):void{
					if (workerManagerMap[sourceUrl]){
						run(workerManagerMap[sourceUrl], onReady);
					}
					else {
						var workerManager:WorkerManager = workerManagerMap[sourceUrl] = new WorkerManager(workerBytes);
						workerManager.onReady(onReady);
						workerManager.start();
					}
				});
			}
		}
		
		private static function run(workerManager:WorkerManager, onReady:Function):void {
			if (workerManager.isReady()){
				onReady.call(workerManager, workerManager);
			}
			else {
				workerManager.onReady(onReady);
			}
		}
		
		/**
		 * 
		 * @param sourceUrl
		 * @param loadComplete
		 * 
		 */
		private static function loadSwf(sourceUrl:String, loadComplete:Function):void{
			var workerLoader:URLLoader = loadingSwfTemp[sourceUrl], 
				handle:Function = function (evt:Event):void{
					delete loadingSwfTemp[sourceUrl];
					workerLoader.removeEventListener(Event.COMPLETE, handle);
					loadComplete(evt.target.data as ByteArray);
				};
			if (workerLoader){
				workerLoader.addEventListener(Event.COMPLETE, handle);
			}
			else {
				workerLoader = new URLLoader();
				workerLoader.dataFormat = URLLoaderDataFormat.BINARY;
				workerLoader.addEventListener(Event.COMPLETE, handle);
				workerLoader.load(new URLRequest(sourceUrl));
				loadingSwfTemp[sourceUrl] = workerLoader;
			}
		}
		
	
	}
}