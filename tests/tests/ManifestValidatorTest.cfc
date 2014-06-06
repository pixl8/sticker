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

			it( "should throw useful error when input contains item that is not an structure", function(){
				expect( function(){
					validator.validate( '{ "somekey":"not an object" }' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition" );
			} );

			it( "should throw useful error when asset definition does not have either a url or path element", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"js" }, "anotherkey":{"url":"http//www.google.com", "type":"css"},"abadkey":{"type":"css"}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?Each asset definition should contain either a \[url\] or \[path\] element" );
			} );

			it( "should throw useful error when asset definition has both a url and path element", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"js", "url":"http://www.test.com" }, "anotherkey":{"url":"http//www.google.com", "type":"css"}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?Each asset definition should contain \*either\* a \[url\] or \[path\] element, not both" );
			} );

			it( "should throw useful error when asset definition has a url element that is not a string", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"js" }, "anotherkey":{"url":["http//www.google.com"], "type":"css"}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?Asset url is not a string" );
			} );

			it( "should throw useful error when asset definition has a path element that is not a string", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"js" }, "anotherkey":{"url":"http//www.google.com", "type":"css"},"abadkey":{"path":{}}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?Asset path is not a string" );
			} );

			it( "should throw useful error when asset definition has an empty url element", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"js" }, "anotherkey":{"url":"", "type":"css"}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?Asset url is empty" );
			} );

			it( "should throw useful error when asset definition has an empty path element", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"js" }, "anotherkey":{"path":"", "type":"css"}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?Asset path is empty" );
			} );
		});
	}
	
}
