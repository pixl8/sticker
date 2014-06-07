/**
 * I exist to render registered assets as an HTML include
 * 
 */

component output=false {


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
	) output=false {
		var rendered = '<link rel="stylesheet" type="text/css" href="#arguments.href#"';

		if ( Len( Trim( arguments.media ) ) ) {
			rendered &= ' media="#arguments.media#"';
		}
		if ( arguments.includeTrailingSlash ) {
			rendered &= " /";
		}

		return rendered & ">";
	}
}