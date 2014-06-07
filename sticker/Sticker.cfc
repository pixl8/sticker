/**
 * I am the Sticker API and am all you need to interact with in order
 * to work with Sticker.
 * 
 */
component output=false {

	/**
	 * I am the sticker constructor
	 * 
	 */
	public Sticker function init() output=false {
		return this;
	}

}

/* THE API

	// initializing Sticker
	sticker = new Sticker();

	sticker.addBundle( "/path/to/bundle", "/assets/path/to/bundle" );
	sticker.addBundle( "/path/to/bundle", "/assets/path/to/bundle" );
	sticker.addBundle( "/path/to/bundle", "/assets/path/to/bundle" );
	sticker.addBundle( "/path/to/bundle", "/assets/path/to/bundle" );
	sticker.addResource( fullyValidResourceDescriptor, rootPath, rootUrl );
	sticker.load();

	// per request, including resources & data for js
	sticker.includeResource( uri="core-js" );
	sticker.includeResource( uri="specific-js.#someDynamic#", throwOnMissing=false );
	sticker.includeResource( uri="core-css", group="top" );
	sticker.includeData( {} );

	// a little utility to fetch URL of any resource
	sticker.getResourceUrl( uri="core-js" );

	// rendering includes
	sticker.renderIncludes( );
	sticker.renderIncludes( type="js" );
	sticker.renderIncludes( type="css", group="top" );

*/
