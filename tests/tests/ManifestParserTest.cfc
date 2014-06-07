component extends="testbox.system.testing.BaseSpec"{
	
/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		variables.parser = new sticker.util.ManifestParser();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "parseFiles()", function(){

			it( "should combine manifests from multiple manifest file paths, expanding wildcards in before and after definitions", function(){
				var actual   = parser.parseFiles( [ "/resources/manifests/good_1.json", "/resources/manifests/good_2.json" ] );
				var expected = {
					core = {
						  url    = "http://core.com/js"
						, type   = "js"
						, before = []
						, after  = []
					},
					anotherasset = {
						  url    = "http://www.google.com"
						, type   = "js"
						, before = [ "core", "someasset" ]
						, after  = [ "forkicks" ]
					},
					someasset = {
						  path   = "/some/path.js"
						, type   = "js"
						, before = []
						, after  = [ "anotherasset", "core", "forkicks", "justonemore" ]
					},
					justonemore = {
						  path   = "/some/other/path.js"
						, type   = "js"
						, before = [ "anotherasset" ]
						, after  = []
					},
					forkicks = {
		  				  url = "http://thisisforkicks.com"
		  				, type = "js"
		  				, before = []
						, after  = []
					}
				};

				expect( actual ).toBe( expected );
			} );

			it( "should throw useful error, when passed manifest file path is not a valid file path", function(){
				expect( function(){
					parser.parseFiles( [ "/resources/manifests/good_1.json", "/resources/manifests/good_2.json", "/i/do/not/exist" ] )
				}).toThrow( type="Sticker.missingManifest", regex="manifest file \[\""\/i\/do\/not\/exist\""\] does not exist or is not available" );
			} );

			it( "should validate each manifest file", function(){
				// very rough test for now
				expect( function(){
					parser.parseFiles( [ "/resources/manifests/good_1.json", "/resources/manifests/good_2.json", "/resources/manifests/bad_1.json" ] )
				}).toThrow( type="Sticker.badManifest", regex="invalid JSON" );
			} );

		} );
	}
	
}
