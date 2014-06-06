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
				}).toThrow( type="Sticker.badManifest", regex="invalid JSON" );
			});

			it( "should throw useful error when input is not a string", function(){
				expect( function(){
					manifestParser.parseManifests( [ '{ "valid":"json here" }', { Iamnot = "a string!" } ] );
				}).toThrow( type="Sticker.badManifest", regex="not a JSON string" );
			} );

			it( "should throw useful error when input does not evaluate to a structure", function(){
				expect( function(){
					manifestParser.parseManifests( [ '{ "valid":"json here" }', '[1,2,3,4]' ] );
				}).toThrow( type="Sticker.badManifest", regex="incorrect format" );
			} );
		});
	}
	
}
