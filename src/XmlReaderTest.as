package 
{
	import flash.display.Sprite;
	
	import org.tbyrne.core.IPendingResult;
	import org.tbyrne.siteStream.SiteStream;
	import org.tbyrne.siteStream.core.SiteStreamNodeProxy;
	import org.tbyrne.siteStream.xml.IXmlNodeDetails;
	import org.tbyrne.siteStream.xml.IXmlNodeSummary;
	import org.tbyrne.siteStream.xml.XMLRootNode;
	import org.tbyrne.siteStream.xml.XmlReader;
	
	public class XmlReaderTest extends Sprite
	{
		private var xmlReader:XmlReader;
		
		private var test1:XML = <Object/>;
		
		public function XmlReaderTest(){
			super();
			
			xmlReader = new XmlReader();
			
			new SiteStream(new XMLRootNode());
			
			doTest(test1, function(object:*):Boolean{return object is Object});
		}
		
		private function doTest(xml:XML, test:Function):void{
			var summary:IXmlNodeSummary = xmlReader.readNodeSummary(xml);
			var details:IXmlNodeDetails = xmlReader.readNodeDetails(xml,summary);
			var result:IPendingResult = xmlReader.readObject(details,null);
		}
		
	}
}