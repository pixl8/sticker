component {

	public function configure( bundle, config ) {
		var assertConfig = arguments.config;
		var skipAssets = assertConfig.skipAllAssets ?: "";
		if ( IsBoolean( skipAssets ) && skipAssets ) {
			return;
		}

		bundle.addAsset(
			  id          = "jquery"
			, url         = "http://jquery.com/jquery.js"
			, integrity   = "sha384-R4/ztc4ZlRqWjqIuvf6RX5yb/v90qNGx6fS48N0tRxiGkqveZETq72KgDVJCp2TC"
			, crossorigin = "anonymous"
		);

		bundle.addAssets(
			  directory   = "/js"
			, match       = "*.min.js" // or a closure
			, idGenerator = function( path ){
				var filename = ListLast( arguments.path, "/" );
				var id       = ReplaceNoCase( arguments.path, "/", "-", "all" );

				id = ReReplace( id, "^-", "" );
				id = Replace( id, filename, ListRest( filename, "-" ) );
				id = ReReplace( id, "\.min\.js$", "" );

				return id;
			  }
		);

		bundle.asset( "js-subfolder-myfile" ).before( "*" );
	}

}