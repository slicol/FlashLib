package com.tencent.fge.engine.ui
{
	import com.greensock.TweenLite;
	import com.tencent.fge.debug.Debugger;
	import com.tencent.fge.engine.ui.keyboard.KeyCode;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.describeType;

	/**
	 * ...
	 * @author DonaldWu
	 */
	
	/*=============================================================================
	*	Class:	UIDebugger
	*	Desc:	UIDebugger is a singleton.
	*============================================================================*/
	public class UIDebugger extends UISprite
	{
		 //{ region singleton
		 private static var ms_instance:UIDebugger = null;
		 private static var ms_bSigletonCreated:Boolean = false;
		 private static var ms_iCountInstances:int = 0;
		 
		 public function UIDebugger() 
		 {   
			  ++ms_iCountInstances;   
			  if(!ms_bSigletonCreated || ms_iCountInstances != 1)
			  {
				   --ms_iCountInstances;
				   throw new Error( "Access UIDebugger by UIDebugger.singleton!" );
			  }
		 }
		  
		 public static function get me():UIDebugger
		 {
			  if(UIDebugger.ms_instance == null)
			  {
				   UIDebugger.ms_bSigletonCreated = true;
				   UIDebugger.ms_instance = new UIDebugger;
				   UIDebugger.ms_instance.init();
			  }
			   
			  return ms_instance;
		 }
		 //} endregion
		 
	
		 
		 
		 private var m_bMouseTraceEnabled:Boolean;
		 private var m_arrDispObjs:Array;
		 private var m_txtInfo:TextField;
		 
		 override public function init():void
		 {
			 super.init();
			 m_txtInfo = new TextField;
			 m_txtInfo.alpha = 0.6;
			 m_txtInfo.textColor = 0xFF9B00;
			 m_txtInfo.width = 300;
			 m_txtInfo.height = 200;
			 m_txtInfo.wordWrap = true;
			 m_txtInfo.mouseEnabled = false;
			 m_txtInfo.selectable = false;
			 m_txtInfo.filters = [new GlowFilter(0, 0.6, 6, 6, 70)];
			 addChild(m_txtInfo);
			 this.mouseEnabled = false;
			 this.mouseChildren = false;
		 }
		 
		 /*---------------------------------------------------------
		 *	Setter and Getter: mouseTraceEnabled
		 *--------------------------------------------------------*/
		 public function set mouseTraceEnabled(value:Boolean):void
		 {
			 m_bMouseTraceEnabled = value;
			 setMouseTraceEnabled(m_bMouseTraceEnabled);
		 }
		 public function get mouseTraceEnabled():Boolean { return m_bMouseTraceEnabled; }
		 
		 
		 private function setMouseTraceEnabled(bMouseTraceEnabled:Boolean):void
		 {
			 if(bMouseTraceEnabled == true)
			 {
				 UISystem.getInstance().stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				 UISystem.getInstance().stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			 }
			 else
			 {
				 UISystem.getInstance().stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				 UISystem.getInstance().stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			 }
		 }
		 
		 private function onMouseMove(e:MouseEvent):void
		 {
			 m_txtInfo.text = "UIDebugger:\n";
			 m_arrDispObjs = UISystem.getInstance().stage.getObjectsUnderPoint(new Point(e.stageX, e.stageY));
			 if(m_arrDispObjs != null)
			 {
				 var i:int;
				 var oneDo:DisplayObject;
				 var oneDoc:DisplayObjectContainer;
				 for(i = 0; i < m_arrDispObjs.length; ++i)
				 {
					 oneDo = m_arrDispObjs[i] as DisplayObject;
					 oneDoc = m_arrDispObjs[i] as DisplayObjectContainer;
//					 if(oneDoc != null)
//					 {
//						 m_txtInfo.appendText(dump(oneDoc) + "\n");
//					 }
//					 else
						 if(oneDo != null)
					 {
						 m_txtInfo.appendText(oneDo.toString() + ": " +
							 oneDo.name + ", (x, y)=(" + oneDo.x + ", " + oneDo.y + "), " +
							 "visible=" + oneDo.visible + ", alpha=" + oneDo.alpha + ", " +
							 "filters=" + oneDo.filters + ", scale=(" + oneDo.scaleX + ", " + oneDo.scaleY + ")" +
							 "\n");
					 }
				 }
			 }
		 }
		 
		 private function onKeyDown(e:KeyboardEvent):void
		 {
			 if(true == e.ctrlKey)
			 {
				 if(KeyCode.C == e.keyCode)
				 {
					 if(null != m_arrDispObjs)
					 {
						 var str:String = "";
						 for each(var dispObj:DisplayObject in m_arrDispObjs)
						 {
							 str += dumpUp(dispObj);
						 }
						 Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, str);
					 }
					 
				 }
			 }
		 }
		 
		 public static function dumpUp(dispObj:DisplayObject):String
		 {
			 var strRet:String = "";
			 var lstDispPath:Vector.<DisplayObject> = new Vector.<DisplayObject>;
			 var curDispObj:DisplayObject = dispObj;
			 do
			 {
				 if(null != curDispObj)
				 {
					 lstDispPath.push(curDispObj);
					 curDispObj = curDispObj.parent;
				 }
				 else
				 {
					 break;
				 }
			 }while(true);
			 
			 var strTabs:String = "";
			 for(var i:int = 0; i < lstDispPath.length; ++i)
			 {
				 curDispObj = lstDispPath[i];
				 strRet += strTabs + (i).toString() + ". " +
					 curDispObj.toString() + ": " +
					 curDispObj.name + ", (x, y)=(" + curDispObj.x + ", " + curDispObj.y + "), " +
					 "visible=" + curDispObj.visible + ", alpha=" + curDispObj.alpha + ", " +
					 "(w, h)=(" + curDispObj.width + ", " + curDispObj.height + "), " +
					 "scale=(" + curDispObj.scaleX + ", " + curDispObj.scaleY + "), " +
					 "filters=" + curDispObj.filters + "\n";
				 if(0 == i)
				 {
					 strTabs += "\t";
				 }
					 
			 }
			 return strRet;
		 }
		 
		 public static function dumpDown(doc:DisplayObjectContainer):String
		 {
			 var vDispObj:Vector.<DisplayObject> = new Vector.<DisplayObject>;
			 var vDoc:Vector.<DisplayObjectContainer> = new Vector.<DisplayObjectContainer>;
			 var vIndex:Vector.<int> = new Vector.<int>;
			 
			 vDispObj.push(doc);
			 vDoc.push(doc);
			 vIndex.push(0);
			 
			 var strRet:String = "";
			 
			 var curDispObj:DisplayObject;
			 var curDoc:DisplayObjectContainer;
			 var strTabs:String;
			 do
			 {
				 curDispObj = vDispObj.pop();
				 curDoc = curDispObj as DisplayObjectContainer;
				 
				 
				 if(curDoc != null)
				 {
					 var i:int;
					 for(i = vDoc.length - 1; i >= 0; --i)
					 {
						 if(curDoc.parent == vDoc[i])
						 {
							 var formerLength:int = vDoc.length;
							 vDoc.splice(i + 1, formerLength - 1 - i, curDoc);
							 vIndex.splice(i + 1, formerLength - 1 - i, 0);
							 break;
						 }
					 }
					 
					 strTabs = "";
					 for(i = 0; i < vDoc.length; ++i)
					 {
						 strTabs += "\t";
					 }
					 
					 
					 
					 var oneDo:DisplayObject;
					 for(i = curDoc.numChildren - 1; i >= 0; --i)
					 {
						 oneDo = curDoc.getChildAt(i);
						 vDispObj.push(oneDo);
					 }
				 }
				 
				 ++vIndex[vDoc.length - 1];
				 
				 strRet += strTabs + vDoc.length + ". " +
					 curDispObj.toString() + ": " +
					 curDispObj.name + ", (x, y)=(" + curDispObj.x + ", " + curDispObj.y + "), " +
					 "visible=" + curDispObj.visible + ", alpha=" + curDispObj.alpha + ", " +
					 "(w, h)=(" + curDispObj.width + ", " + curDispObj.height + "), " +
					 "scale=(" + curDispObj.scaleX + ", " + curDispObj.scaleY + "), " +
					 "filters=" + curDispObj.filters + 
					 "\n";
				 
			 }while(vDispObj.length > 0);
			 
			 return strRet;
		 }
		 
		 
		 public static function getDebugSprite(size:int = 32):Sprite
		 {
			 var sp:Sprite = new Sprite;
			 sp.graphics.clear();
			 sp.graphics.beginFill(0xff0000);
			 sp.graphics.drawCircle(0, 0, size);
			 sp.graphics.endFill();
			 
			 sp.scaleX = 10;
			 sp.scaleY = 10;
			 
			 TweenLite.to(sp, 2, {scaleX:1, scaleY:1, ease:"linear"});
			 
			 
			 return sp;
		 }
		 
		 public static function dumpVisible(dispObj:DisplayObject):String
		 {
			 var str:String = "\n";
			 
			 var curr:DisplayObject = dispObj;
			 while(null != curr)
			 {
				 str += curr + "\n";
				 
				 var parent:DisplayObjectContainer = curr.parent;
				 var stagePos:Point;
				 if(null != parent)
				 {
					 stagePos = parent.localToGlobal(new Point(curr.x, curr.y));
				 }
				 str += (null == stagePos ? "\t stagePos=null" : "\t stagePos=(" + stagePos.x + ", " + stagePos.y + ")");
				 
				 if(false == curr.visible)
				 {
					 str += "\t visible=false";
				 }
				 if(0 >= curr.width)
				 {
					 str += "\t width=0";
				 }
				 if(0 >= curr.height)
				 {
					 str += "\t height=0";
				 }
				 if(0 >= curr.alpha)
				 {
					 str += "\t alpha=0";
				 }
				 if(0 >= curr.scaleX)
				 {
					 str += "\t scaleX=0";
				 }
				 if(0 >= curr.scaleY)
				 {
					 str += "\t scaleY=0";
				 }
				 if(null != curr.mask)
				 {
					 str += "\t mask != null";
				 }
				 
				 str += "\n";
				 
				 curr = parent;
			 }
			 
			 str += "end";
			 
			 return str;
		 }
		 
		 public static function watchRemove(obj:DisplayObject):void
		 {
			 obj.addEventListener(Event.REMOVED, onRemoved);
		 }
		 private static function onRemoved(e:Event):void
		 {
			 Debugger.traceStack();
		 }
	}
}