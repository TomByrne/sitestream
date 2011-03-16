package 
{
	import flash.display.Sprite;
	
	import org.tbyrne.debug.logging.TraceLogger;
	import org.tbyrne.siteStream.IXmlReaderTest;
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
		private var failedTests:int = 0;
		
		public function XmlReaderTest(){
			super();
			
			Log.setLogger(new TraceLogger());
			
			var namespace:Namespace = new Namespace("s","http://www.tbyrne.org/sitestream");
			
			xmlReader = new XmlReader(true);
			xmlReader.metadataNamespace = namespace;
			
			tests = Vector.<IXmlReaderTest>([	
												// summary tests
												/*new PathIdTest(),
												new XmlUrlTest(),
												
												// details tests
												new LibraryLiteralTest(),
												new LibraryNodeTest1(),
												new LibraryNodeTest2(),
												new NestedNodeTest(),
												
												// object tests
												new NativeObjectNodeTest(),
												new ObjectLiteralTest(),
												new ArrayLiteralTest(),
												new NumberLiteralTest(),
												new ClassNodeTest(),
												new ClassAttributeTest(),
												new PropertySetterTest(),
												new TypedObjectLiteralTest(),
												new TypedArrayTest1(),
												new TypedArrayTest2(),
												new TypedVectorTest1(),*/
												new TypedVectorTest2()
												
												]);
			
			doNextTest();
		}
		
		private function doNextTest():void{
			if(currentTest<tests.length){
				var test:IXmlReaderTest = tests[currentTest];
				doTest(test);
			}else{
				if(failedTests){
					Log.log(Log.DEV_INFO, "Tests finished, "+failedTests+" tests failed");
				}else{
					Log.log(Log.DEV_INFO, "Tests finished successfully");
				}
			}
		}
		private function doTest(test:IXmlReaderTest):void{
			var result:IXmlPendingResult;
			var summary:IXmlNodeSummary = xmlReader.readRootNode(test.xml);
			if(!test.testSummary(summary)){
				Log.error("Summary test failed: "+test);
				++failedTests;
			}
			if(!test.checkDetails() && !test.checkObject()){
				testFinished();
				return;
			}
			
			// load xml
			result = xmlReader.readNodeDetails(test.xml,summary);
			result.succeeded.addHandler(methodClosure(onDetailsSuccess,test));
			result.failed.addHandler(onDetailsFault);
			result.begin();
		}
		protected function onDetailsSuccess(from:IXmlPendingResult, test:IXmlReaderTest):void{
			var details:IXmlNodeDetails = (from.result as IXmlNodeDetails);
			var result:IXmlPendingResult;
			if(!test.testDetails(from.result as IXmlNodeDetails)){
				Log.error("Details test failed: "+test);
				++failedTests;
			}
			if(!test.checkObject()){
				testFinished();
				return;
			}
			// load swfs
			result = xmlReader.readObject(details,null);
			result.succeeded.addHandler(methodClosure(onObjectSuccess,test));
			result.failed.addHandler(onObjectFault);
			result.begin();
		}
		protected function onDetailsFault(from:IXmlPendingResult):void{
			Log.error("Details failed");
			testFinished();
		}
		protected function onObjectSuccess(from:IXmlPendingResult, test:IXmlReaderTest):void{
			if(!test.testObject(from.result)){
				Log.error("Object test failed: "+test);
				++failedTests;
			}
			testFinished();
		}
		protected function onObjectFault(from:IXmlPendingResult):void{
			Log.error("Parse failed");
			testFinished();
		}
		
		private function testFinished():void{
			++currentTest;
			doNextTest();
		}
		
	}
}