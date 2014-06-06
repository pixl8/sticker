component extends="testbox.system.testing.BaseSpec"{
	
/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		variables.manifestParser = new sticker.StickerManifestParser();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "parseManifests()", function(){
			it( "should throw useful error when input is invalid JSON", function(){
				expect( function(){
					manifestParser.parseManifests( [ '{ "valid":"json here" }', 'i {am not valid JSON' ] );
				}).toThrow( type="Sticker.badManifest", regex="Invalid json" );
			});
		});
	}
	
}
