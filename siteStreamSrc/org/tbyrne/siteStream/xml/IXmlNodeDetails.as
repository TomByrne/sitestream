package org.tbyrne.siteStream.xml
{
	import org.tbyrne.siteStream.xml.IXmlNodeSummary;

	public interface IXmlNodeDetails extends IXmlNodeSummary
	{
		function get childNodes():Vector.<IXmlNodeSummary>;
		function get libraries():Vector.<String>;
	}
}