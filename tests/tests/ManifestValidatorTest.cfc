component extends="testbox.system.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		variables.validator = new sticker.util.ManifestValidator();
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

			it( "should throw useful error when asset definition does not have a type element", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"js" }, "anotherkey":{"url":"http//www.google.com"}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?Each asset definition must have a \[type\] element" );
			} );

			it( "should throw useful error when asset definition's type element is not a string", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:{} }, "anotherkey":{"url":"http//www.google.com", "type":"css"}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?Type must be equal to either 'css' or 'js'" );
			} );

			it( "should throw useful error when asset definition's type element is not equal to either 'js' or 'css'", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"whatever" }, "anotherkey":{"url":"http//www.google.com", "type":"css"}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?Type must be equal to either 'css' or 'js'" );
			} );

			it( "should throw useful error when asset definition's before element is neither an array or simple value", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"css","before":{}}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?\[before\] element must be either a string or array of strings" );
			} );

			it( "should throw useful error when asset definition's before element is an array that contains one or more non-simple elements", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"css","before":["test",{}]}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?\[before\] element must be either a string or array of strings" );
			} );

			it( "should throw useful error when asset definition's after element is neither an array or simple value", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"css","after":{}}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?\[after\] element must be either a string or array of strings" );
			} );

			it( "should throw useful error when asset definition's after element is an array that contains one or more non-simple elements", function(){
				expect( function(){
					validator.validate( '{ "somekey":{ "path":"/some/path",type:"css","after":["test",{}]}}' );
				}).toThrow( type="Sticker.badManifest", regex="invalid asset definition.*?\[after\] element must be either a string or array of strings" );
			} );
		});
	}

}
