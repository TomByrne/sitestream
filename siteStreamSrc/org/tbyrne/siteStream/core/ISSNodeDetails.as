package org.tbyrne.siteStream.core
{

	public interface ISSNodeDetails extends ISSNodeSummary
	{
		function get childNodes():Vector.<ISSNodeSummary>;
		function get libraries():Vector.<String>;
	}
}