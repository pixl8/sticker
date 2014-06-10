component extends="testbox.system.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){}

	// executes after all suites+specs in the run() method
	function afterAll(){}

/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "getAssets()", function(){

			it( "should return an empty struct when no assets have been added", function(){
				bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/" );

				expect( bundle.getAssets() ).toBe( {} );
			} );

			it( "should return a structure of simple asset definitions defined with the addAsset() method", function(){
				bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				bundle.addAsset( id="jquery", url="http://www.jquery.com/jquery.js" );
				bundle.addAsset( id="somejs", path="/js/javascript.js" );

				expect( bundle.getAssets() ).toBe( {
					  somejs = { type="js", path="/js/javascript.js", url="/assets/js/javascript.js", before=[], after=[] }
					, jquery = { type="js", url="http://www.jquery.com/jquery.js", before=[], after=[] }
				} );
			} );
		} );

		describe( "addAsset()", function(){
			it( "should resolve any paths containing wildcards", function(){
				bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				bundle.addAsset( id="somejs", path="/js/subfolder/*-myfile.min.js" );

				expect( bundle.getAssets() ).toBe( {
					  somejs = { type="js", path="/js/subfolder/fa56e8c-myfile.min.js", url="/assets/js/subfolder/fa56e8c-myfile.min.js", before=[], after=[] }
				} );
			} );

			it( "should throw informative error, when passed path does not exist", function(){
				bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				expect( function(){
					bundle.addAsset( id="somejs", path="/js/subfolder/*-idonotexist.min.js" );
				} ).toThrow( type="Sticker.missingAsset" );
			} );

			it( "should throw informative error, when passed wildcard path matches more than one file", function(){
				bundle = new sticker.util.Bundle( rootDirectory="/resources/bundles/bundle1", rootUrl="/assets/" );

				expect( function(){
					bundle.addAsset( id="somejs", path="/js/subfolder/*.js" );
				} ).toThrow( type="Sticker.multipleAssets" );
			} );

		} );

	}
}