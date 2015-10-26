component extends="testbox.system.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){}

	// executes after all suites+specs in the run() method
	function afterAll(){}

/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "getAssets()", function(){

			it( "should return an empty struct when no assets have been added", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/" );

				expect( bundle.getAssets() ).toBe( {} );
			} );

			it( "should return a structure of simple asset definitions defined with the addAsset() method", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				bundle.addAsset( id="jquery", url="http://www.jquery.com/jquery.js" );
				bundle.addAsset( id="somejs", path="/js/javascript.js" );

				expect( _assetsToStruct( bundle.getAssets() ) ).toBe( {
					  somejs = { type="js", path="/js/javascript.js", url="/assets/js/javascript.js", before=[], after=[], ie="", media="", renderedInclude="", dependsOn=[], dependents=[] }
					, jquery = { type="js", path="", url="http://www.jquery.com/jquery.js", before=[], after=[], ie="", media="", renderedInclude="", dependsOn=[], dependents=[] }
				} );
			} );
		} );

		describe( "addAsset()", function(){
			it( "should resolve any paths containing wildcards", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				bundle.addAsset( id="somejs", path="/js/subfolder/*-myfile.min.js" );

				expect( _assetsToStruct( bundle.getAssets() ) ).toBe( {
					  somejs = { type="js", path="/js/subfolder/fa56e8c-myfile.min.js", url="/assets/js/subfolder/fa56e8c-myfile.min.js", before=[], after=[], ie="", media="", renderedInclude="", dependsOn=[], dependents=[] }
				} );
			} );

			it( "should throw informative error, when passed path does not exist", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				expect( function(){
					bundle.addAsset( id="somejs", path="/js/subfolder/*-idonotexist.min.js" );
				} ).toThrow( type="Sticker.missingAsset" );
			} );

			it( "should throw informative error, when passed wildcard path matches more than one file", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				expect( function(){
					bundle.addAsset( id="somejs", path="/js/subfolder/*.js" );
				} ).toThrow( type="Sticker.multipleAssets" );
			} );

			it( "should allow for adding media and IE restrictions", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				bundle.addAsset( id="jquery", url="http://www.jquery.com/jquery.js", ie="!IE", media="print" );

				expect( _assetsToStruct( bundle.getAssets() ) ).toBe( {
					jquery = { type="js", path="", url="http://www.jquery.com/jquery.js", before=[], after=[], ie="!IE", media="print", renderedInclude="", dependsOn=[], dependents=[] }
				} );
			})

		} );

		describe( "addAssets()", function(){

			it( "should add a single asset for each file that matches its wildcard pattern for the given directory, setting its id to the result of the ID generator closure", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle2", rootUrl="http://static.mysite.com" );

				bundle.addAssets(
					  directory   = "/css"
					, match       = "*.min.css"
					, idGenerator = function( path ){
						var fileName = ListLast( path, "/" );
						return LCase( ReReplaceNoCase( fileName, "^(.*?)\.min\.css", "\1" ) )
					  }
				);

				expect( _assetsToStruct( bundle.getAssets() ) ).toBe( {
					  some    = { type="css", path="/css/some.min.css"             , url="http://static.mysite.com/css/some.min.css"             , before=[], after=[], ie="", media="", renderedInclude="", dependsOn=[], dependents=[] }
					, another = { type="css", path="/css/subfolder/another.min.css", url="http://static.mysite.com/css/subfolder/another.min.css", before=[], after=[], ie="", media="", renderedInclude="", dependsOn=[], dependents=[] }
					, more    = { type="css", path="/css/subfolder/more.min.css"   , url="http://static.mysite.com/css/subfolder/more.min.css"   , before=[], after=[], ie="", media="", renderedInclude="", dependsOn=[], dependents=[] }
				} );
			} );

			it( "should add a single asset for each file that passes its match closure function when passing a function for the 'match' argument", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle2", rootUrl="http://static.mysite.com" );

				bundle.addAssets(
					  directory   = "/css"
					, match       = function( path ){ return ReFindNoCase( ".*?\.min\.css$", arguments.path ); }
					, idGenerator = function( path ){
						var fileName = ListLast( path, "/" );
						return LCase( ReReplaceNoCase( fileName, "^(.*?)\.min\.css", "\1" ) )
					  }
				);

				expect( _assetsToStruct( bundle.getAssets() ) ).toBe( {
					  some    = { type="css", path="/css/some.min.css"             , url="http://static.mysite.com/css/some.min.css"             , before=[], after=[], ie="", media="", renderedInclude="", dependsOn=[], dependents=[] }
					, another = { type="css", path="/css/subfolder/another.min.css", url="http://static.mysite.com/css/subfolder/another.min.css", before=[], after=[], ie="", media="", renderedInclude="", dependsOn=[], dependents=[] }
					, more    = { type="css", path="/css/subfolder/more.min.css"   , url="http://static.mysite.com/css/subfolder/more.min.css"   , before=[], after=[], ie="", media="", renderedInclude="", dependsOn=[], dependents=[] }
				} );
			} );

		} );

		describe( "asset()", function(){
			it( "should return Asset object that is associated with the passed ID", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				bundle.addAsset( id="somejs", path="/js/subfolder/*-myfile.min.js" );

				var asset = bundle.asset( "somejs" );
				expect( asset.getMemento() ).toBe( { type="js", path="/js/subfolder/fa56e8c-myfile.min.js", url="/assets/js/subfolder/fa56e8c-myfile.min.js", before=[], after=[], ie="", media="", renderedInclude="", dependsOn=[], dependents=[] } );
			} );

			it( "should throw a helpful error when passed id to the asset does not exist", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				expect( function(){
					bundle.asset( "anyoldfile" );
				} ).toThrow( type="Sticker.missingAsset" );
			} );
		} );

		describe( "asset( 'someasset' ).after( 'list', 'of', 'assets' ).before( 'list', 'of', 'assets' )", function(){

			it( "should populate the given asset's before and after arrays", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				bundle.addAsset( id="somejs", path="/js/subfolder/*-myfile.min.js" );

				var asset = bundle.asset( "somejs" ).before( "assetx", "assety", "assetz" ).after( "asset1", "*" );

				expect( asset.getMemento() ).toBe( {
					  type            = "js"
					, path            = "/js/subfolder/fa56e8c-myfile.min.js"
					, url             = "/assets/js/subfolder/fa56e8c-myfile.min.js"
					, before          = [ "assetx", "assety", "assetz" ]
					, after           = [ "asset1", "*" ]
					, ie              = ""
					, media           = ""
					, renderedInclude = ""
					, dependsOn       = []
					, dependents      = []
				} );
			} );

		} );

		describe( "asset( 'someasset' ).dependsOn( 'list', 'of', 'assets' ).dependents( 'list', 'of', 'assets' )", function(){
			it( "should populate the given asset's before, after, dependsOn and dependents arrays with passed values", function(){
				var bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				bundle.addAsset( id="somejs", path="/js/subfolder/*-myfile.min.js" );

				var asset = bundle.asset( "somejs" ).dependents( "assetx", "assety", "assetz" ).dependsOn( "asset1", "*" );

				expect( asset.getMemento() ).toBe( {
					  type            = "js"
					, path            = "/js/subfolder/fa56e8c-myfile.min.js"
					, url             = "/assets/js/subfolder/fa56e8c-myfile.min.js"
					, before          = [ "assetx", "assety", "assetz" ]
					, after           = [ "asset1", "*" ]
					, dependsOn       = [ "asset1", "*" ]
					, dependents      = [ "assetx", "assety", "assetz" ]
					, ie              = ""
					, media           = ""
					, renderedInclude = ""
				} );
			} );
		} );

	}

/************************************ PRIVATE HELPERS ***************************************/

	private struct function _assetsToStruct( required struct assets ) {
		var a = {};

		for( var asset in arguments.assets ){
			a[ asset ] = arguments.assets[ asset ].getMemento();
		}

		return a;
	}
}