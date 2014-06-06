component extends="testbox.system.testing.BaseSpec"{
	
/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		variables.validator = new sticker.ManifestValidator();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "validate()", function(){
			it( "should throw useful error when input is invalid JSON", function(){
				expect( function(){
					validator.validate( 'i {am not valid JSON' );
				}).toThrow( type="Sticker.badManifest", regex="invalid JSON" );
			});

			it( "should throw useful error when input does not evaluate to a structure", function(){
				expect( function(){
					validator.validate( '[1,2,3,4]' );
				}).toThrow( type="Sticker.badManifest", regex="incorrect format" );
			} );
		});
	}
	
}
