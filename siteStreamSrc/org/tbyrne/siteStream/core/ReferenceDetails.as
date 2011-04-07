package org.tbyrne.siteStream.core
{
	import org.tbyrne.hoborg.ObjectPool;

	public class ReferenceDetails extends PropDetails{
		private static const pool:ObjectPool = new ObjectPool(ReferenceDetails);
		public static function getNew():ReferenceDetails{
			var ret:ReferenceDetails = pool.takeObject();
			ret.pool = pool;
			return ret;
		}
		
		override public function release(deepRelease:Boolean):void{
			super.release(deepRelease);
		}
	}
}