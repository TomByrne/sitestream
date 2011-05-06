package org.tbyrne.utils
{
	public function ConstructorApply(type:Class, args:Array):*{
		if(!args)return new type();
		switch(args.length){
			case 0: return new type();
			case 1: return new type(args[0]);
			case 2: return new type(args[0],args[1]);
			case 3: return new type(args[0],args[1],args[2]);
			case 4: return new type(args[0],args[1],args[2],args[3]);
			case 5: return new type(args[0],args[1],args[2],args[3],args[4]);
			case 6: return new type(args[0],args[1],args[2],args[3],args[4],args[5]);
			case 7: return new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
			case 8: return new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
			case 9: return new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8]);
			case 10: return new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9]);
		}
	}
}