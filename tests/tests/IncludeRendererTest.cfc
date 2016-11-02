component extends="testbox.system.BaseSpec"{

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

		describe( "renderCssInclude()", function(){

			it( "should return link tag with href matching the passed href", function(){
				expect( renderer.renderCssInclude( href="/path/to/css.min.css" ) ).toBe( '<link rel="stylesheet" type="text/css" href="/path/to/css.min.css">' );
			} );

			it( "should return link tag with trailing slash when 'includeTrailingSlash' is set to true", function(){
				expect( renderer.renderCssInclude( href="/some/file.css", includeTrailingSlash=true ) ).toBe( '<link rel="stylesheet" type="text/css" href="/some/file.css" />' );
			} );

			it( "should include media attribute when specified", function(){
				expect( renderer.renderCssInclude( href="/a/print.css", media="print" ) ).toBe( '<link rel="stylesheet" type="text/css" href="/a/print.css" media="print">' );
			} );

			it( "should add any passed arbitrary attributes to the tag", function(){
				expect( renderer.renderCssInclude( href="/a/print.css", media="print", extraAttributes={ test="this", thing="good" } ) ).toBe( '<link rel="stylesheet" type="text/css" href="/a/print.css" media="print" test="this" thing="good">' );
			} );
		} );

		describe( "renderJsInclude()", function(){

			it( "should return script tag with src matching the passed src", function(){
				expect( renderer.renderJsInclude( src="/path/to/some.js" ) ).toBe( '<script src="/path/to/some.js"></script>' );
			} );

			it( "should add any passed arbitrary attributes to the tag", function(){
				expect( renderer.renderJsInclude( src="/path/to/some.js", extraAttributes={ test="this", thing="good" } ) ).toBe( '<script src="/path/to/some.js" test="this" thing="good"></script>' );
			} );

		} );

		describe( "renderJsData()", function(){

			it( "should return a script block with passed data rendered as a JavaScript object", function(){
				var testData = createObject("java", "java.util.LinkedHashMap").init();

				testData[ "thisIsAnArray"  ] = [ 1,2,3,4,"five"];
				testData[ "thisIsAnObject" ] = { "thisIsAKey"="and a value", "aontherKey"=[1,4,{},false]};
				testData[ "interesting"    ] = javaCast( "null", "" );

				var expectedResult = '<script>cfrequest={"thisIsAnArray":[1,2,3,4,"five"],"thisIsAnObject":{"thisIsAKey":"and a value","aontherKey":[1,4,{},false]},"interesting":null}</script>';

				expect( renderer.renderData( data=testData ) ).toBe( expectedResult );
			} );

			it( "should use custom variable name when passed, rather than the default 'cfrequest'", function(){
				var testData = createObject("java", "java.util.LinkedHashMap").init();

				testData[ "thisIsAnArray"  ] = [ 1,2,3,4,"five"];
				testData[ "thisIsAnObject" ] = { "thisIsAKey"="and a value", "aontherKey"=[1,4,{},false]};
				testData[ "interesting"    ] = javaCast( "null", "" );

				var expectedResult = '<script>customVariableName={"thisIsAnArray":[1,2,3,4,"five"],"thisIsAnObject":{"thisIsAKey":"and a value","aontherKey":[1,4,{},false]},"interesting":null}</script>';
				expect( renderer.renderData( data=testData, variableName="customVariableName" ) ).toBe( expectedResult );

			} );

		} );

		describe( "wrapWithIeConditional()", function(){

			it( "should return passed content wrapped in passed condition", function(){
				expect( renderer.wrapWithIeConditional( "somecontent", "IE LT 7" ) ).toBe(
					"<!--[if IE LT 7]>somecontent<![endif]-->"
				);
 			} );

 			it( "should return passed content wrapped in a special 'NOT IE' conditional, when condition=""!IE""", function(){
 				expect( renderer.wrapWithIeConditional( "<script src=""/some/path/to.js""></script>", "!IE" ) ).toBe(
					"<!--[if !IE]>--><script src=""/some/path/to.js""></script><!-- <![endif]-->"
				);
 			} );
		} );

		describe( "addRenderedIncludesToAssets()", function(){

			it( "should render an include for each asset in the passed assets structure", function(){
				var assets = {
					  key1 = new sticker.util.Asset( beforeAssert=[], afterAssert=[], url="/some/url/to.js"           , type="js"                , extraAttributes={}, dependsOnAssert=[], dependentsAssert=[] )
					, key2 = new sticker.util.Asset( beforeAssert=[], afterAssert=[], url="/some/url/toanother.js"    , type="js"                , extraAttributes={ test="true" }, dependsOnAssert=[], dependentsAssert=[] )
					, key3 = new sticker.util.Asset( beforeAssert=[], afterAssert=[], url="/some/url/toyetanother.js" , type="js", ie="!IE"      , extraAttributes={}, dependsOnAssert=[], dependentsAssert=[] )
					, key4 = new sticker.util.Asset( beforeAssert=[], afterAssert=[], url="/some/url/to.css"          , type="css"               , extraAttributes={ nice="try" }, dependsOnAssert=[], dependentsAssert=[] )
					, key5 = new sticker.util.Asset( beforeAssert=[], afterAssert=[], url="/some/url/toanother.css"   , type="css", media="print", extraAttributes={}, dependsOnAssert=[], dependentsAssert=[] )
					, key6 = new sticker.util.Asset( beforeAssert=[], afterAssert=[], url="/some/url/toyetanother.css", type="css", ie="IE 8"    , extraAttributes={}, dependsOnAssert=[], dependentsAssert=[] )
				};
				var actual   = _assetsToStruct( renderer.addRenderedIncludesToAssets( assets=assets ) );
				var expected = duplicate( _assetsToStruct( assets ) );

				expected.key1.renderedInclude = '<script src="/some/url/to.js"></script>';
				expected.key2.renderedInclude = '<script src="/some/url/toanother.js" test="true"></script>';
				expected.key3.renderedInclude = '<!--[if !IE]>--><script src="/some/url/toyetanother.js"></script><!-- <![endif]-->';
				expected.key4.renderedInclude = '<link rel="stylesheet" type="text/css" href="/some/url/to.css" nice="try">';
				expected.key5.renderedInclude = '<link rel="stylesheet" type="text/css" href="/some/url/toanother.css" media="print">';
				expected.key6.renderedInclude = '<!--[if IE 8]><link rel="stylesheet" type="text/css" href="/some/url/toyetanother.css"><![endif]-->';

				expect( actual ).toBe( expected );
			} );

		} );
	}

/************************************ PRIVATE HELPERS ***************************************/

	private struct function _assetsToStruct( required struct assets ) {
		var a = {};

		for( var asset in arguments.assets ){
			a[ asset ] = arguments.assets[ asset ].getMemento();
		}

		return a;
	}
}