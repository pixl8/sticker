component output=false {

	public function configure( bundle ) output=false {

		bundle.addAsset(
			  id   = "jquery"
			, url  = "http://jquery.com/jquery.js"
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