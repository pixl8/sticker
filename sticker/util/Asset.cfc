/**
 * I am an Asset bean, I represent a single asset in a bundle
 *
 */
component accessors=true {

	property name="type"            type="string";
	property name="url"             type="string";
	property name="path"            type="string" default="";
	property name="path"            type="string" default="";
	property name="before"          type="array";
	property name="after"           type="array";
	property name="dependsOn"       type="array";
	property name="dependents"      type="array";
	property name="extraAttributes" type="struct";
	property name="renderedInclude" type="string" default="";
	property name="ie"              type="string" default="";
	property name="media"           type="string" default="";

	public Asset function before() {
		var bf = getBefore();
		for( var i=1; i <= arguments.len(); i++ ) {
			bf.append( arguments[ i ] );
		}
		setBefore( bf );
		return this;
	}

	public Asset function after() {
		var af = getAfter();
		for( var i=1; i <= arguments.len(); i++ ) {
			af.append( arguments[ i ] );
		}
		setAfter( af );
		return this;
	}

	public Asset function dependents() {
		this.before( argumentCollection=arguments );

		var dp = getDependents();
		for( var i=1; i <= arguments.len(); i++ ) {
			dp.append( arguments[ i ] );
		}
		setDependents( dp );
		return this;
	}

	public Asset function dependsOn() {
		this.after( argumentCollection=arguments );

		var dp = getDependsOn();
		for( var i=1; i <= arguments.len(); i++ ) {
			dp.append( arguments[ i ] );
		}
		setDependsOn( dp );
		return this;
	}

	public struct function getMemento() {
		return {
			  type            = getType()
			, url             = getUrl()
			, path            = getPath()
			, before          = getBefore()
			, after           = getAfter()
			, dependsOn       = getDependsOn()
			, dependents      = getDependents()
			, renderedInclude = getRenderedInclude()
			, ie              = getIe()
			, media           = getMedia()
			, extraAttributes = getExtraAttributes()
		};
	}

}