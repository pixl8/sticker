/**
 * I am an Asset bean, I represent a single asset in a bundle
 */
component accessors=true output=false {

	property name="type"   type="string";
	property name="url"    type="string";
	property name="path"   type="string" default="";
	property name="before" type="array";
	property name="after"  type="array";

	public struct function getMemento() output=false {
		return {
			  type   = getType()
			, url    = getUrl()
			, path   = getPath()
			, before = getBefore()
			, after  = getAfter()
		};
	}

}