component extends="testbox.system.testing.BaseSpec"{
	
/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		variables.renderer = new sticker.util.IncludeRenderer();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "renderCssInclude", function(){

			it( "should return link tag with href matching the passed href", function(){
				expect( renderer.renderCssInclude( href="/path/to/css.min.css" ) ).toBe( '<link rel="stylesheet" type="text/css" href="/path/to/css.min.css">' );
			} );

			it( "should return link tag with trailing slash when 'includeTrailingSlash' is set to true", function(){
				expect( renderer.renderCssInclude( href="/some/file.css", includeTrailingSlash=true ) ).toBe( '<link rel="stylesheet" type="text/css" href="/some/file.css" />' );
			} );

			it( "should include media attribute when specified", function(){
				expect( renderer.renderCssInclude( href="/a/print.css", media="print" ) ).toBe( '<link rel="stylesheet" type="text/css" href="/a/print.css" media="print">' );
			} );
		} );
	}

}