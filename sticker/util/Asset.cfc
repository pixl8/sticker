/**
 * I am an Asset bean, I represent a single asset in a bundle
 */
component accessors=true output=false {

	property name="type"            type="string";
	property name="url"             type="string";
	property name="path"            type="string" default="";
	property name="path"            type="string" default="";
	property name="before"          type="array";
	property name="after"           type="array";
	property name="renderedInclude" type="string" default="";
	property name="ie"              type="string" default="";
	property name="media"           type="string" default="";

	public Asset function before() output=false {
		var bf = getBefore();
		for( var i=1; i <= arguments.len(); i++ ) {
			bf.append( arguments[ i ] );
		}
		setBefore( bf );
		return this;
	}

	public Asset function after() output=false {
		var af = getAfter();
		for( var i=1; i <= arguments.len(); i++ ) {
			af.append( arguments[ i ] );
		}
		setAfter( af );
		return this;
	}

	public struct function getMemento() output=false {
		return {
			  type            = getType()
			, url             = getUrl()
			, path            = getPath()
			, before          = getBefore()
			, after           = getAfter()
			, renderedInclude = getRenderedInclude()
			, ie              = getIe()
			, media           = getMedia()
		};
	}

}