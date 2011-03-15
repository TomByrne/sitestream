package 
{
	import flash.display.Sprite;
	
	import org.tbyrne.core.IPendingResult;
	import org.tbyrne.siteStream.IXmlReaderTest;
	import org.tbyrne.siteStream.SiteStream;
	import org.tbyrne.siteStream.core.SiteStreamNodeProxy;
	import org.tbyrne.siteStream.detailsTests.*;
	import org.tbyrne.siteStream.objectTests.*;
	import org.tbyrne.siteStream.summaryTests.*;
	import org.tbyrne.siteStream.xml.*;
	import org.tbyrne.utils.methodClosure;
	
	public class XmlReaderTest extends Sprite
	{
		private var xmlReader:XmlReader;
		
		private var tests:Vector.<IXmlReaderTest>;
		private var currentTest:int = 0;
		
		public function XmlReaderTest(){
			super();
			
			var namespace:Namespace = new Namespace("s","http://www.tbyrne.org/sitestream");
			
			xmlReader = new XmlReader(true);
			xmlReader.metadataNamespace = namespace;
			
			tests = Vector.<IXmlReaderTest>([	
												// summary tests
												new PathIdTest(),
												new XmlUrlTest(),
												
												// details tests
												new LibraryLiteralTest(),
												new LibraryNodeTest1(),
												new LibraryNodeTest2(),
												
												// object tests
												new NativeObjectNodeTest(),
												new ObjectLiteralTest(),
												new ArrayLiteralTest(),
												new NumberLiteralTest(),
												new ClassNodeTest(),
												new ClassAttributeTest(),
												new PropertySetterTest(),
												new TypedObjectLiteralTest()]);
			
			doNextTest();
		}
		
		private function doNextTest():void{
			var test:IXmlReaderTest = tests[currentTest];
			doTest(test);
		}
		private function doTest(test:IXmlReaderTest):void{
			var result:IPendingResult;
			var summary:IXmlNodeSummary = xmlReader.readRootNode(test.xml);
			if(!test.testSummary(summary)){
				Log.error("Summary error");
			}
			if(!test.checkDetails() && !test.checkObject()){
				testFinished();
				return;
			}
			
			// load xml
			result = xmlReader.readNodeDetails(test.xml,summary);
			result.success.addHandler(methodClosure(onDetailsSuccess,test));
			result.fail.addHandler(onDetailsFault);
		}
		protected function onDetailsSuccess(from:IPendingResult, test:IXmlReaderTest):void{
			if(!test.testDetails(from.result as IXmlNodeDetails)){
				Log.error("Details error");
			}
			if(!test.checkObject()){
				testFinished();
				return;
			}
			// load swfs
			result = xmlReader.readObject(details,null);
			result.success.addHandler(methodClosure(onObjectSuccess,test));
			result.fail.addHandler(onObjectFault);
		}
		protected function onDetailsFault(from:IPendingResult):void{
			Log.error("Details failed");
			testFinished();
		}
		protected function onObjectSuccess(from:IPendingResult, test:IXmlReaderTest):void{
			if(!test.testObject(from.result)){
				Log.error("Object error");
			}
			testFinished();
		}
		protected function onObjectFault(from:IPendingResult):void{
			Log.error("Parse failed");
			testFinished();
		}
		
		private function testFinished():void{
			++currentTest;
			doNextTest();
		}
		
	}
}