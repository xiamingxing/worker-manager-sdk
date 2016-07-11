package com.worker
{
	public class WorkerUtils
	{
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function generateRandomString():String {
			return "_" + new Date().time + "_" + Math.random() * 1000;
		}
		
		/**
		 * 
		 * @param url
		 * @return 
		 * 
		 */
		public static function parseUrl(url:String):Object {
			var reg:RegExp = /^(\w+):\/\/([^\/:]*)(?::(\d+))?\/([^\/]*)(\/.*)/i,
				res:Object = reg.exec(url) || {};
			
			return {  
				url: res[0],
				protocal: res[1],  
				domain: res[2],  
				port: res[3],  
				webContext: res[4],  
				uri: res[5]
			}  
		}
	}
}