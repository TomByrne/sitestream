package org.tbyrne.siteStream.xml
{
	import org.tbyrne.core.IPendingResult;

	/**
	 * A utility class used to step through XML and generate IXmlElementInfo objects
	 *  
	 * @author Tom Byrne
	 * 
	 */
	public class XmlReader
	{
		public function XmlReader(){
		}
		
		public function readNodeSummary(xml:XML):IXmlNodeSummary{
			return null;
		}
		public function readNodeDetails(xml:XML, summary:IXmlNodeSummary):IXmlNodeDetails{
			return null;
		}
		public function readObject(xml:IXmlNodeSummary, oldObject:Object):IPendingResult{
			return null;
		}
	}
}
/*import org.tbyrne.acting.actTypes.IAct;
import org.tbyrne.acting.acts.Act;
import org.tbyrne.core.IPendingResult;
import org.tbyrne.hoborg.ObjectPool;
import org.tbyrne.siteStream2.xml.ISiteStreamNode;
import org.tbyrne.siteStream2.xml.IXmlElementInfo;

class PendingResult implements ISiteStreamNode{
	private static const pool:ObjectPool = new ObjectPool(PendingResult);
	public static function getNew():PendingResult{
		var ret:PendingResult = pool.takeObject();
		return ret;
	}
	
	/**
	 * @inheritDoc
	 */
	/*public function get success():IAct{
		return (_success || (_success = new Act()));
	}
	
	/**
	 * @inheritDoc
	 */
	/*public function get fail():IAct{
		return (_fail || (_fail = new Act()));
	}
	
	
	public function get result():*{
		return null;
	}
	
	protected var _fail:Act;
	protected var _success:Act;
	
	
	public function release():void{
		pool.releaseObject(this);
	}
}*/

/*class XmlElementInfo implements IXmlElementInfo{
	private static const pool:ObjectPool = new ObjectPool(XmlElementInfo);
	public static function getNew():XmlElementInfo{
		var ret:XmlElementInfo = pool.takeObject();
		return ret;
	}
	
	
	public function release():void{
		pool.releaseObject(this);
	}
}*/