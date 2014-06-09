component extends="testbox.system.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		variables.mockManifestParser = getMockBox().createEmptyMock( "sticker.util.ManifestParser" );
		variables.manager            = new sticker.util.BundleManager(
			manifestParser = mockManifestParser
		);
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "calling addBundle() multiple times followed by getManifest()", function(){
			it( "should return a merged manifest based on the manifest file for each bundle", function(){
				var manifests = [ {test="1"}, {test="2"}, {test="3"}, {test="4"} ];
				var manifestParserResult = { some="structure" };


				mockManifestParser.$( "parseManifest" ).$args( filePath="/resources/bundles/bundle1/sticker-bundle.json", rootUrl="http://bundle1.com/assets" ).$results( manifests[1] );
				mockManifestParser.$( "parseManifest" ).$args( filePath="/resources/bundles/bundle3/sticker-bundle.json", rootUrl="/"                         ).$results( manifests[2] );
				mockManifestParser.$( "parseManifest" ).$args( filePath="/resources/bundles/bundle2/sticker-bundle.json", rootUrl="http://bundle2.com/assets" ).$results( manifests[3] );
				mockManifestParser.$( "parseManifest" ).$args( filePath="/resources/bundles/bundle4/sticker-bundle.json", rootUrl="/assets"                   ).$results( manifests[4] );
				mockManifestParser.$( "mergeManifests" ).$args( manifests ).$results( manifestParserResult );

				expect( manager.addBundle( rootDirectory="/resources/bundles/bundle1", rootUrl="http://bundle1.com/assets" )
				       .addBundle( rootDirectory="/resources/bundles/bundle3", rootUrl="/" )
				       .addBundle( rootDirectory="/resources/bundles/bundle2", rootUrl="http://bundle2.com/assets" )
				       .addBundle( rootDirectory="/resources/bundles/bundle4", rootUrl="/assets" )
				       .getManifest()
				).toBe( manifestParserResult );
			} );
		} );
	}

}
