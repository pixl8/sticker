component extends="testbox.system.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){


		describe( "calling addBundle() multiple times followed by load()", function(){
			it( "should setup the API ready to use", function(){
				var sticker = new sticker.Sticker();

				sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
				       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
				       .load();

				expect( sticker.ready() ).toBe( true );
			} );
		} );

		describe( "getAssetUrl()", function(){

			it( "should return full URL of given asset id", function(){
				var sticker = new sticker.Sticker();

				expect( sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .load()
			       .getAssetUrl( "js-someplugin" )

				).toBe( "http://bundle2.com/assets/js/someplugin.min.js" );
			} );

			it( "should throw a useful error when the given asset does not exist", function(){
				var sticker = new sticker.Sticker();

				expect( function(){
					sticker.load().getAssetUrl( "someasset" );
				}).toThrow( type="Sticker.missingAsset", regex="asset \[someasset\] not found" );
			} );

			it( "should throw a useful error when the Sticker API has not yet been loaded", function(){
				var sticker = new sticker.Sticker();

				expect( function(){
					sticker.getAssetUrl( "someasset" );
				}).toThrow( type="Sticker.notReady", regex="The sticker API instance has not yet been loaded\. Please use the load\(\) method before calling any of the per-request inclusion methods" );
			} );
		} );
	}

	describe( "include()", function(){

		it ( "should throw useful error when asset does not exist", function(){
			var sticker = new sticker.Sticker();

			expect( function(){
				sticker.load().include( "testing" );
			}).toThrow( type="Sticker.missingAsset", regex="asset \[testing\] not found" );
		} );

		it ( "should silently do nothing when asset does not exist and 'throwOnMissing' is passed as false", function(){
			var sticker = new sticker.Sticker();

			sticker.load().include( assetId="testing", throwOnMissing=false );
		} );

		it( "should throw a useful error when the Sticker API has not yet been loaded", function(){
			var sticker = new sticker.Sticker();

			expect( function(){
				sticker.include( "someasset" );
			}).toThrow( type="Sticker.notReady", regex="The sticker API instance has not yet been loaded\. Please use the load\(\) method before calling any of the per-request inclusion methods" );
		} );
	} );

	describe( "renderIncludes()", function(){

		it( "should return all the gathered static includes as HTML includes in the correct order", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .load();

			sticker.include( "css-some"              )
			       .include( "css-subfolder-another" )
			       .include( "css-subfolder-more"    )
			       .include( "jquery"                )
			       .include( "jquery-ui-css"         )
			       .include( "js-someplugin"         )
			       .include( "js-subfolder-myfile"   );

			expect( sticker.renderIncludes() ).toBe(
				'<link rel="stylesheet" type="text/css" href="http://jquery.com/jqueryui.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/some.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/subfolder/another.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/subfolder/more.min.css">' & Chr(13) & Chr(10) &
				'<script src="http://bundle1.com/assets/js/subfolder/fa56e8c-myfile.min.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://bundle2.com/assets/js/someplugin.min.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://jquery.com/jquery.js" crossorigin="anonymous" integrity="sha384-R4/ztc4ZlRqWjqIuvf6RX5yb/v90qNGx6fS48N0tRxiGkqveZETq72KgDVJCp2TC"></script>' & Chr(13) & Chr(10)
			);
		} );

		it( "should append adhoc includes as HTML includes after those defined in Sticker", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .load();

			sticker.include( "css-some"              )
			       .include( "css-subfolder-another" )
			       .include( "css-subfolder-more"    )
			       .include( "jquery"                )
			       .include( "jquery-ui-css"         )
			       .include( "js-someplugin"         )
			       .include( "js-subfolder-myfile"   )
			       .includeUrl( "http://example.com/adhoc.js"  )
			       .includeUrl( "http://example.com/adhoc.css" );

			expect( sticker.renderIncludes() ).toBe(
				'<link rel="stylesheet" type="text/css" href="http://jquery.com/jqueryui.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/some.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/subfolder/another.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/subfolder/more.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://example.com/adhoc.css">' & Chr(13) & Chr(10) &
				'<script src="http://bundle1.com/assets/js/subfolder/fa56e8c-myfile.min.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://bundle2.com/assets/js/someplugin.min.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://jquery.com/jquery.js" crossorigin="anonymous" integrity="sha384-R4/ztc4ZlRqWjqIuvf6RX5yb/v90qNGx6fS48N0tRxiGkqveZETq72KgDVJCp2TC"></script>' & Chr(13) & Chr(10) &
				'<script src="http://example.com/adhoc.js"></script>' & Chr(13) & Chr(10)
			);
		} );

		it( "should return all the gathered CSS includes as HTML includes in the correct order, when type is set to'CSS' ", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .load();

			sticker.include( "css-some"              )
			       .include( "css-subfolder-another" )
			       .include( "css-subfolder-more"    )
			       .include( "jquery"                )
			       .include( "jquery-ui-css"         )
			       .include( "js-someplugin"         )
			       .include( "js-subfolder-myfile"   );

			expect( sticker.renderIncludes( "css" ) ).toBe(
				'<link rel="stylesheet" type="text/css" href="http://jquery.com/jqueryui.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/some.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/subfolder/another.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/subfolder/more.min.css">' & Chr(13) & Chr(10)
			);
		} );

		it( "should append adhoc CSS includes after the ordered CSS includes, when type is set to'CSS' ", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .load();

			sticker.include( "css-some"              )
			       .include( "css-subfolder-another" )
			       .include( "css-subfolder-more"    )
			       .include( "jquery"                )
			       .include( "jquery-ui-css"         )
			       .include( "js-someplugin"         )
			       .include( "js-subfolder-myfile"   )
			       .includeUrl( "http://example.com/adhoc.js"  )
			       .includeUrl( "http://example.com/adhoc.css" );

			expect( sticker.renderIncludes( "css" ) ).toBe(
				'<link rel="stylesheet" type="text/css" href="http://jquery.com/jqueryui.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/some.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/subfolder/another.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/subfolder/more.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://example.com/adhoc.css">' & Chr(13) & Chr(10)
			);
		} );

		it( "should return all the gathered JS includes as HTML includes in the correct order, when type is set to'JS' ", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .load();

			sticker.include( "css-some"              )
			       .include( "css-subfolder-another" )
			       .include( "css-subfolder-more"    )
			       .include( "jquery"                )
			       .include( "jquery-ui-css"         )
			       .include( "js-someplugin"         )
			       .include( "js-subfolder-myfile"   );

			expect( sticker.renderIncludes( type="js" ) ).toBe(
				'<script src="http://bundle1.com/assets/js/subfolder/fa56e8c-myfile.min.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://bundle2.com/assets/js/someplugin.min.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://jquery.com/jquery.js" crossorigin="anonymous" integrity="sha384-R4/ztc4ZlRqWjqIuvf6RX5yb/v90qNGx6fS48N0tRxiGkqveZETq72KgDVJCp2TC"></script>' & Chr(13) & Chr(10)
			);
		} );

		it( "should append adhoc JS includes after the ordered JS includes, when type is set to'JS' ", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .load();

			sticker.include( "css-some"              )
			       .include( "css-subfolder-another" )
			       .include( "css-subfolder-more"    )
			       .include( "jquery"                )
			       .include( "jquery-ui-css"         )
			       .include( "js-someplugin"         )
			       .include( "js-subfolder-myfile"   )
			       .includeUrl( "http://example.com/adhoc.js"  )
			       .includeUrl( "http://example.com/adhoc.css" );

			expect( sticker.renderIncludes( type="js" ) ).toBe(
				'<script src="http://bundle1.com/assets/js/subfolder/fa56e8c-myfile.min.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://bundle2.com/assets/js/someplugin.min.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://jquery.com/jquery.js" crossorigin="anonymous" integrity="sha384-R4/ztc4ZlRqWjqIuvf6RX5yb/v90qNGx6fS48N0tRxiGkqveZETq72KgDVJCp2TC"></script>' & Chr(13) & Chr(10) &
				'<script src="http://example.com/adhoc.js"></script>' & Chr(13) & Chr(10)
			);
		} );

		it( "should prepend JS includes with JS variables include when includeData() has been called", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .load();

			sticker.include( "js-someplugin" )
			       .includeData( { key1="key1" } )
			       .includeData( { key2="key2" } )
			       .includeData( { key3="key3" } );

			expect( sticker.renderIncludes( "js" ) ).toBe(
				'<script>cfrequest={"key1":"key1","key2":"key2","key3":"key3"}</script>' & Chr(13) & Chr(10) &
				'<script src="http://bundle2.com/assets/js/someplugin.min.js"></script>' & Chr(13) & Chr(10)
			);
		} );

		it( "should render any dependencies that have not been explicity included", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .load();

			sticker.include( "jquery" )
			       .include( "css-subfolder-more" );

			expect( sticker.renderIncludes() ).toBe(
				'<link rel="stylesheet" type="text/css" href="http://jquery.com/jqueryui.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/some.min.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://bundle2.com/assets/css/subfolder/more.min.css">' & Chr(13) & Chr(10) &
				'<script src="http://bundle2.com/assets/js/someplugin.min.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://jquery.com/jquery.js" crossorigin="anonymous" integrity="sha384-R4/ztc4ZlRqWjqIuvf6RX5yb/v90qNGx6fS48N0tRxiGkqveZETq72KgDVJCp2TC"></script>' & Chr(13) & Chr(10)
			);
		} );

		it( "should render includes in specified groups", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .load();

			sticker.includeData( { some="data that will live in default group and should not get rendered when asking for 'top' group" } );
			sticker.include( assetId="jquery", group="top");
			sticker.include( assetId="css-some", group="anotherGroup");
			sticker.includeUrl( url="http://example.com/adhoc.js" , group="top" );
			sticker.includeUrl( url="http://example.com/adhoc.css", group="anotherGroup" );

			expect( sticker.renderIncludes( group="top" ) ).toBe(
				'<script src="http://bundle2.com/assets/js/someplugin.min.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://jquery.com/jquery.js" crossorigin="anonymous" integrity="sha384-R4/ztc4ZlRqWjqIuvf6RX5yb/v90qNGx6fS48N0tRxiGkqveZETq72KgDVJCp2TC"></script>' & Chr(13) & Chr(10) &
				'<script src="http://example.com/adhoc.js"></script>' & Chr(13) & Chr(10)
			);
		} );



	} );

}
