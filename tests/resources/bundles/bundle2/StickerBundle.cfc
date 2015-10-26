component {

	public function configure( bundle ) {

		bundle.addAsset(
			  id   = "jquery-ui-css"
			, url  = "http://jquery.com/jqueryui.min.css"
		);

		bundle.addAssets(
			  directory   = "/css"
			, match       = "*.min.css"
			, idGenerator = function( path ){
				var id = ReplaceNoCase( arguments.path, "/", "-", "all" );
				id = ReReplace( id, "^-", "" );
				id = ReReplace( id, "\.min\.css$", "" );

				return id;
			  }
		);

		bundle.addAssets(
			  directory   = "/js"
			, match       = "*.min.js"
			, idGenerator = function( path ){
				var id = ReplaceNoCase( arguments.path, "/", "-", "all" );
				id = ReReplace( id, "^-", "" );
				id = ReReplace( id, "\.min\.js$", "" );

				return id;
			  }
		);

		bundle.asset( "jquery-ui-css"      ).before( "*" );
		bundle.asset( "css-some"           ).before( "*" ).dependsOn( "jquery-ui-css" );
		bundle.asset( "css-subfolder-more" ).before( "subfolder-another" ).dependsOn( "css-some" );
		bundle.asset( "js-someplugin"      ).dependents( "jquery" );
	}

}