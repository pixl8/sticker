/**
 * I am an Asset bean, I represent a single asset in a bundle
 *
 */
component accessors=true {

	property name="type"             type="string";
	property name="url"              type="string";
	property name="path"             type="string" default="";
	property name="beforeAssert"     type="array";
	property name="afterAssert"      type="array";
	property name="dependsOnAssert"  type="array";
	property name="dependentsAssert" type="array";
	property name="extraAttributes"  type="struct";
	property name="renderedInclude"  type="string" default="";
	property name="ie"               type="string" default="";
	property name="media"            type="string" default="";

	public Asset function before() {
		var bf = getBeforeAssert() ?: arrayNew(1);
		for( var i=1; i <= structCount( arguments ); i++ ) {
			bf.append( arguments[ i ] );
		}
		setBeforeAssert( bf );
		return this;
	}

	public Asset function after() {
		var af = getAfterAssert() ?: arrayNew(1);
		for( var i=1; i <= structCount( arguments ); i++ ) {
			af.append( arguments[ i ] );
		}
		setAfterAssert( af );
		return this;
	}

	public Asset function dependents() {
		this.before( argumentCollection=arguments );

		var dp = getDependentsAssert() ?: arrayNew(1);
		for( var i=1; i <= structCount( arguments ); i++ ) {
			dp.append( arguments[ i ] );
		}
		setDependentsAssert( dp );
		return this;
	}

	public Asset function dependsOn() {
		this.after( argumentCollection=arguments );

		var dp = getDependsOnAssert() ?: arrayNew(1);
		for( var i=1; i <= structCount( arguments ); i++ ) {
			dp.append( arguments[ i ] );
		}
		setDependsOnAssert( dp );
		return this;
	}

	public struct function getMemento() {
		return {
			  type            = getType()
			, url             = getUrl()
			, path            = getPath()
			, before          = getBeforeAssert()
			, after           = getAfterAssert()
			, dependsOn       = getDependsOnAssert()
			, dependents      = getDependentsAssert()
			, renderedInclude = getRenderedInclude()
			, ie              = getIe()
			, media           = getMedia()
			, extraAttributes = getExtraAttributes()
		};
	}

}