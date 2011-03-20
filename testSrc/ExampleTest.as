package
{
   import org.flexunit.Assert;
   
   public class ExampleTest
   {
      [Test]
      public function alwaysPasses(): void
	  {
         Assert.assertTrue(true);
      }

      /*[Test]
      public function testSampleError(): void
	  {
         throw new Error("ERROR! - This is an error");
      }*/
      
      /*[Ignore]
      [Test]
      public function testSampleIgnore() : void {
         
      }*/
   }
}