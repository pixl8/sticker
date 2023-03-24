/**
 * I exist to render registered assets as an HTML include
 *
 */

component {


	/**
	 * I render a CSS include
	 *
	 * @href.hint                 The URL of the CSS to include
	 * @includeTrailingSlash.hint Whether or not to include a trailing HTML element slash (i.e. for XHTML documents)
	 * @media.hint                Target devices for the CSS
	 */
	public string function renderCssInclude(
		  required string  href
		,          string  media                = ""
		,          boolean includeTrailingSlash = false
		,          struct  extraAttributes      = {}
	) {
		var rendered = '<link rel="stylesheet" type="text/css" href="#arguments.href#"';
		var extraAttributeNames = arguments.extraAttributes.keyArray().sort( "textnocase" );

		if ( Len( Trim( arguments.media ) ) ) {
			rendered &= ' media="#arguments.media#"';
		}

		for( var attributeName in extraAttributeNames ) {
			rendered &= ' ' & LCase( attributeName ) & '="#HTMLEditFormat( arguments.extraAttributes[ attributeName ] )#"';
		}

		if ( arguments.includeTrailingSlash ) {
			rendered &= " /";
		}

		return rendered & ">";
	}

	/**
	 * I render a JS include
	 *
	 * @src.hint The URL of the javacript to include
	 */
	public string function renderJsInclude( required string src, struct extraAttributes = {} ) {
		var rendered            = '<script src="#arguments.src#"';
		var extraAttributeNames = arguments.extraAttributes.keyArray().sort( "textnocase" );

		for( var attributeName in extraAttributeNames ) {
			rendered &= ' ' & LCase( attributeName ) & '="#HTMLEditFormat( arguments.extraAttributes[ attributeName ] )#"';
		}

		return rendered & '></script>';
	}

	/**
	 * I render CFML data as javascript data in a script block
	 *
	 * @data.hint Structure of data to be available to javascript
	 */
	public string function renderData( required struct data, string variableName="cfrequest" ) {
		return '<script>#arguments.variableName#=#SerializeJson( _sanitizeJsData( arguments.data ) )#</script>';
	}

	/**
	 * I wrap passed content in IE conditional tags
	 *
	 * @content.hint The content, i.e. a script or link tag, to be wrapped
	 * @condition.hint The condition with which to wrap the content, e.g. "IE lt 7" or "!IE"
	 */
	public string function wrapWithIeConditional( required string content, required string condition ) {
		if ( arguments.condition == "!IE" ) {
			return '<!--[if #arguments.condition#]>-->#arguments.content#<!-- <![endif]-->';
		}
		return "<!--[if #arguments.condition#]>#arguments.content#<![endif]-->";
	}

	/**
	 * I take a collection of assets and render includes for each one
	 *
	 * @assets.hint A collection of sticker assets
	 */
	public struct function addRenderedIncludesToAssets( required struct assets ) {
		for ( var assetId in arguments.assets ) {
			var asset    = arguments.assets[ assetId ];
			var rendered = asset.getType() == "js" ? renderJsInclude( asset.getUrl(), asset.getExtraAttributes() ) : renderCssInclude( href=asset.getUrl(), media=asset.getMedia(), extraAttributes=asset.getExtraAttributes() );

			if ( Len( Trim( asset.getIe() ) ) ) {
				rendered = wrapWithIeConditional( rendered, asset.getIe() );
			}

			arguments.assets[ assetId ].setRenderedInclude( rendered );
		}
		return arguments.assets;
	}

// HELPERS
	private any function _sanitizeJsData( any data ) {
		if ( IsStruct( arguments.data ) ) {
			for( var key in arguments.data ) {
				if ( !IsNull( arguments.data[ key ] ) ) {
					arguments.data[ key ] = _sanitizeJsData( arguments.data[ key ] );
				}
			}
		} else if ( IsArray( arguments.data ) ) {
			for( var i=1; i<=ArrayLen( arguments.data ); i++ ) {
				if ( !IsNull( arguments.data[ i ] ) ) {
					arguments.data[ i ] = _sanitizeJsData( arguments.data[ i ] );
				}
			}
		} else if ( IsSimpleValue( arguments.data ) && ReFindNoCase( "[<>""]+", arguments.data ) ) { // we really only care about ability to escape the json with double quotes and html tags
			return HTMLEditFormat( arguments.data );
		}

		return arguments.data;
	}
}