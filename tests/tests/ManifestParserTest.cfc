component extends="testbox.system.BaseSpec"{

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
		describe( "parseManifest()", function(){
			it( "should throw useful error, when passed manifest file path is not a valid file path", function(){
				expect( function(){
					parser.parseManifest( "/i/do/not/exist", "/" );
				}).toThrow( type="Sticker.missingManifest", regex="Manifest file .* does not exist or is not available" );
			} );

			it( "should validate the manifest file", function(){
				// very rough test for now
				expect( function(){
					parser.parseManifest( "/resources/manifests/bad_1.json", "/" );
				}).toThrow( type="Sticker.badManifest", regex="invalid JSON" );
			} );

			it( "should return a CFML structure of the manifest, along with expanded URLs, when passed a valid manifest file", function(){
				var actual = parser.parseManifest( "/resources/manifests/good_1.json", "http://www.baseurl.com/assets" );
				var expected = {
					someasset = {
						  path = "/some/path.js"
						, url  = "http://www.baseurl.com/assets/some/path.js"
						, type = "js"
					},
					core = {
						  url  = "http://core.com/js"
						, type = "js"
					}

				}

				expect( actual ).toBe( expected );
			} );
		} );

		describe( "mergeManifests()", function(){

			it( "should combine manifests, expanding any wildcard ""before"" and ""after"" mappings", function(){
				var actual = parser.mergeManifests( [ {
					someasset = {
						  path = "/some/path.js"
						, type = "js"
					},
					core = {
						  url  = "http://core.com/js"
						, type = "js"
					}
				}, {
					anotherasset = {
						  url    = "http://www.google.com"
						, type   = "js"
						, before = ["*"]
						, after  = ["forkicks"]
					},
					someasset = {
						  path  = "/some/path.js"
						, type  = "js"
						, after = "*"
					},
					justonemore = {
						  path   = "/some/other/path.js"
						, type   = "js"
						, before = "anotherasset"
					},
					forkicks = {
						  url  = "http://thisisforkicks.com"
						, type = "js"
					}
				} ] );

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



		} );
	}

}
