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

		describe( "renderJsInclude", function(){

			it( "should return script tag with src matching the passed src", function(){
				expect( renderer.renderJsInclude( src="/path/to/some.js" ) ).toBe( '<script src="/path/to/some.js"></script>' );
			} );

		} );

		describe( "renderJsData", function(){

			it( "should return a script block with passed data rendered as a JavaScript object", function(){
				var testData = StructNew( "linked" );

				testData[ "thisIsAnArray"  ] = [ 1,2,3,4,"five"];
				testData[ "thisIsAnObject" ] = { "thisIsAKey"="and a value", "aontherKey"=[1,4,{},false]};
				testData[ "interesting"    ] = NullValue();

				var expectedResult = '<script>cfrequest={"thisIsAnArray":[1,2,3,4,"five"],"thisIsAnObject":{"thisIsAKey":"and a value","aontherKey":[1,4,{},false]},"interesting":null}</script>'

				expect( renderer.renderData( data=testData ) ).toBe( expectedResult );
			} );

			it( "should use custom variable name when passed, rather than the default 'cfrequest'", function(){
				var testData = StructNew( "linked" );

				testData[ "thisIsAnArray"  ] = [ 1,2,3,4,"five"];
				testData[ "thisIsAnObject" ] = { "thisIsAKey"="and a value", "aontherKey"=[1,4,{},false]};
				testData[ "interesting"    ] = NullValue();

				var expectedResult = '<script>customVariableName={"thisIsAnArray":[1,2,3,4,"five"],"thisIsAnObject":{"thisIsAKey":"and a value","aontherKey":[1,4,{},false]},"interesting":null}</script>'
				expect( renderer.renderData( data=testData, variableName="customVariableName" ) ).toBe( expectedResult );

			} );

		} );
	}

}