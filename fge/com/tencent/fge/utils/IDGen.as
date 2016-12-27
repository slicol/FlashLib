package com.tencent.fge.utils
{
	/**
	 * ...
	 * @author DonaldWu
	 */
	
	/*=============================================================================
	*	Class:	IDGen
	*	Desc:	IDGen is a singleton.
	*			It generates random string as an ID.
	*============================================================================*/
	public class IDGen
	{
		 //{ region singleton
		 private static var ms_instance:IDGen = null;
		 private static var ms_bSigletonCreated:Boolean = false;
		 private static var ms_iCountInstances:int = 0;
		 
		 public function IDGen() 
		 {   
			  ++ms_iCountInstances;   
			  if(!ms_bSigletonCreated || ms_iCountInstances != 1)
			  {
				   --ms_iCountInstances;
				   throw new Error( "Access KeyGen by KeyGen.singleton!" );
			  }
		 }
		  
		 public static function get singleton():IDGen
		 {
			  if(IDGen.ms_instance == null)
			  {
				   IDGen.ms_bSigletonCreated = true;
				   IDGen.ms_instance = new IDGen;
			  }
			   
			  return ms_instance;
		 }
		 //} endregion
		 
	
		 
		 public static const METHOD_SIMPLE:String = "METHOD_SIMPLE";
		 public static const METHOD_GUID:String = "METHOD_GUID";
		 
		 public function initialize():void 
		 {
			 // add additional initialization here
		 }
		 
		 
		 
		 public function finalize():void
		 {
			 // finalize the singleton
		 }
		 
		 public function generate(method:String = METHOD_SIMPLE):String
		 {
			 switch(method)
			 {
			 case METHOD_SIMPLE:
				 return idAlgorithm_Simple();
			 case METHOD_GUID:
				 return keyAlgorithm_GUID();
			 default:
				 return "";
			 }
		 }
		 
		 private static const KEY_ELEMENTS:Array = [
			 "a", "b", "c", "d", "e", "f", "g", "h", 
			 "i", "j", "k", "l", "m", "n", "o", "p", 
			 "q", "r", "s", "t", "u", "v", "w", "x", 
			 "y", "z", 
			 
			 "A", "B", "C", "D", "E", "F", "G", "H", 
			 "I", "J", "K", "L", "M", "N", "O", "P", 
			 "Q", "R", "S", "T", "U", "V", "W", "X", 
			 "Y", "Z", 
			 
			 "0", "1", "2", "3", "4",
			 "5", "6", "7", "8", "9"
		 ];
		 
		 
		 /*---------------------------------------------------------
		 * 	Func:	keyAlgorithm_Simple
		 * 	Desc:	generate a string key whose length is (0, 16),
		 *			containing random elements defined in KEY_ELEMENTS
		 * 	Param:	
		 *	Return:	
		 * 	Remark:	
		 *--------------------------------------------------------*/
		 private function idAlgorithm_Simple():String
		 {
			 var result:String = new String;
			 
			 var length:int = 0;
			 while(length == 0)
			 {
				 length = Math.random() * 16;
			 }
			 
			 var date:Date = new Date;
			 var index:int;
			 for(var i:int = 0; i < length; ++i)
			 {
				 index = (date.getTime() + Math.random() * KEY_ELEMENTS.length) % KEY_ELEMENTS.length;
				 result += KEY_ELEMENTS[index];
			 }
			 
			 return result;
		 }
		 
		 private function keyAlgorithm_GUID():String
		 {
			 //	not implemented
			 return "";
		 }
	}
	
}