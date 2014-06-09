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
				       .addBundle( rootDirectory="/resources/bundles/bundle3/", rootUrl="/"                         )
				       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
				       .addBundle( rootDirectory="/resources/bundles/bundle4/", rootUrl="/assets"                   )
				       .load();

				expect( sticker.ready() ).toBe( true );
			} );
		} );

		describe( "getAssetUrl()", function(){

			it( "should return full URL of given asset id", function(){
				var sticker = new sticker.Sticker();

				expect( sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle3/", rootUrl="/"                         )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle4/", rootUrl="/assets"                   )
			       .load()
			       .getAssetUrl( "someasset" )

				).toBe( "http://bundle2.com/assets/some/path.js" );
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
			       .addBundle( rootDirectory="/resources/bundles/bundle3/", rootUrl="/"                         )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle4/", rootUrl="/assets"                   )
			       .load();

			sticker.include( "core"            )
			       .include( "justonemore"     )
			       .include( "anotherasset"    )
			       .include( "someasset"       )
			       .include( "forkicks"        )
			       .include( "cssanotherasset" )
			       .include( "csssomeasset"    )
			       .include( "cssjustonemore"  )
			       .include( "cssforkicks"     );

			expect( sticker.renderIncludes() ).toBe(
				'<link rel="stylesheet" type="text/css" href="http://www.google.com">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="/assets/some/other/path.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://thisisforkicks.com">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="/assets/some/path.css">' & Chr(13) & Chr(10) &
				'<script src="http://thisisforkicks.com"></script>' & Chr(13) & Chr(10) &
				'<script src="http://bundle2.com/assets/some/other/path.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://www.google.com"></script>' & Chr(13) & Chr(10) &
				'<script src="http://core.com/js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://bundle2.com/assets/some/path.js"></script>' & Chr(13) & Chr(10)
			);
		} );

		it( "should return all the gathered CSS includes as HTML includes in the correct order, when type is set to'CSS' ", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle3/", rootUrl="/"                         )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle4/", rootUrl="/assets"                   )
			       .load();

			sticker.include( "core"            )
			       .include( "justonemore"     )
			       .include( "anotherasset"    )
			       .include( "someasset"       )
			       .include( "forkicks"        )
			       .include( "cssanotherasset" )
			       .include( "csssomeasset"    )
			       .include( "cssjustonemore"  )
			       .include( "cssforkicks"     );

			expect( sticker.renderIncludes( "css" ) ).toBe(
				'<link rel="stylesheet" type="text/css" href="http://www.google.com">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="/assets/some/other/path.css">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="http://thisisforkicks.com">' & Chr(13) & Chr(10) &
				'<link rel="stylesheet" type="text/css" href="/assets/some/path.css">' & Chr(13) & Chr(10)
			);
		} );

		it( "should return all the gathered JS includes as HTML includes in the correct order, when type is set to'JS' ", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle3/", rootUrl="/"                         )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle4/", rootUrl="/assets"                   )
			       .load();

			sticker.include( "core"            )
			       .include( "justonemore"     )
			       .include( "anotherasset"    )
			       .include( "someasset"       )
			       .include( "forkicks"        )
			       .include( "cssanotherasset" )
			       .include( "csssomeasset"    )
			       .include( "cssjustonemore"  )
			       .include( "cssforkicks"     );

			expect( sticker.renderIncludes( "js" ) ).toBe(
				'<script src="http://thisisforkicks.com"></script>' & Chr(13) & Chr(10) &
				'<script src="http://bundle2.com/assets/some/other/path.js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://www.google.com"></script>' & Chr(13) & Chr(10) &
				'<script src="http://core.com/js"></script>' & Chr(13) & Chr(10) &
				'<script src="http://bundle2.com/assets/some/path.js"></script>' & Chr(13) & Chr(10)
			);
		} );

		it( "should prepend JS includes with JS variables include when includeData() has been called", function(){
			var sticker = new sticker.Sticker();

			sticker.addBundle( rootDirectory="/resources/bundles/bundle1/", rootUrl="http://bundle1.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle3/", rootUrl="/"                         )
			       .addBundle( rootDirectory="/resources/bundles/bundle2/", rootUrl="http://bundle2.com/assets" )
			       .addBundle( rootDirectory="/resources/bundles/bundle4/", rootUrl="/assets"                   )
			       .load();

			sticker.include( "core" )
			       .includeData( { key1="key1" } )
			       .includeData( { key2="key2" } )
			       .includeData( { key3="key3" } );

			expect( sticker.renderIncludes( "js" ) ).toBe(
				'<script>cfrequest={"key1":"key1","key2":"key2","key3":"key3"}</script>' & Chr(13) & Chr(10) &
				'<script src="http://core.com/js"></script>' & Chr(13) & Chr(10)
			);
		} );



	} );

}
