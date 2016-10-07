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
		,          string  integrity            = ""
		,          string  crossorigin          = ""
		,          boolean includeTrailingSlash = false
	) {

		var rendered = '<link rel="stylesheet" type="text/css" href="#arguments.href#"';

		if ( !isEmpty( arguments.media ) ) {
			rendered &= ' media="#arguments.media#"';
		}
		if ( !isEmpty( arguments.integrity ) ) {
			rendered &= ' integrity="#arguments.integrity#"';
		}
		if ( !isEmpty( arguments.crossorigin ) ) {
			rendered &= ' crossorigin="#arguments.crossorigin#"';
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
	public string function renderJsInclude(
		  required string src
		,          string integrity   = ""
		,          string crossorigin = ""
	) {
		var rendered = '<script src="#arguments.src#" ';

		if ( !isEmpty( arguments.integrity ) ) {
			rendered &= ' integrity="#arguments.integrity#"';
		}
		if ( !isEmpty( arguments.crossorigin ) ) {
			rendered &= ' crossorigin="#arguments.crossorigin#"';
		}

		return rendered & "></script>";
	}

	/**
	 * I render CFML data as javascript data in a script block
	 *
	 * @data.hint Structure of data to be available to javascript
	 */
	public string function renderData( required struct data, string variableName="cfrequest" ) {
		return '<script>#arguments.variableName#=#SerializeJson( arguments.data )#</script>';
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
			var rendered = asset.getType() == "js" ? renderJsInclude( src=asset.getUrl(), integrity= asset.getIntegrity(), crossorigin= asset.getCrossOrigin() ) : renderCssInclude( href=asset.getUrl(), media=asset.getMedia(), integrity= asset.getIntegrity(), crossorigin= asset.getCrossOrigin() );

			if ( Len( Trim( asset.getIe() ) ) ) {
				rendered = wrapWithIeConditional( rendered, asset.getIe() );
			}

			arguments.assets[ assetId ].setRenderedInclude( rendered );
		}
		return arguments.assets;
	}
}