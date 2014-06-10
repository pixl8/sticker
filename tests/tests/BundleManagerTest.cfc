component extends="testbox.system.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		variables.manager = new sticker.util.BundleManager();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "calling addBundle() multiple times followed by getAssets()", function(){
			it( "should return a merged set of assets based on the configuration of each bundle", function(){
				var assets = manager.addBundle( rootDirectory="/resources/bundles/bundle1", rootUrl="http://bundle1.com/assets" )
				                    .addBundle( rootDirectory="/resources/bundles/bundle2", rootUrl="http://bundle2.com/assets" )
				                    .getAssets();


				expect( _assetsToStruct( assets ) ).toBe( {
					"js-someplugin"={
						  before          = ["jquery"]
						, after           = []
						, path            = "/js/someplugin.min.js"
						, url             = "http://bundle2.com/assets/js/someplugin.min.js"
						, type            = "js"
						, ie              = ""
						, media           = ""
						, renderedInclude = ""
					},
					"css-subfolder-another"={
						  before          = []
						, after           = []
						, path            = "/css/subfolder/another.min.css"
						, url             = "http://bundle2.com/assets/css/subfolder/another.min.css"
						, type            = "css"
						, ie              = ""
						, media           = ""
						, renderedInclude = ""
					},
					"js-subfolder-myfile"={
						  before          = ["jquery", "js-someplugin"]
						, after           = []
						, path            = "/js/subfolder/fa56e8c-myfile.min.js"
						, url             = "http://bundle1.com/assets/js/subfolder/fa56e8c-myfile.min.js"
						, type            = "js"
						, ie              = ""
						, media           = ""
						, renderedInclude = ""
					},
					"css-subfolder-more"={
						  before          = ["subfolder-another"]
						, after           = []
						, path            = "/css/subfolder/more.min.css"
						, url             = "http://bundle2.com/assets/css/subfolder/more.min.css"
						, type            = "css"
						, ie              = ""
						, media           = ""
						, renderedInclude = ""
					},
					"jquery"={
						  before          = []
						, after           = []
						, path            = ""
						, url             = "http://jquery.com/jquery.js"
						, type            = "js"
						, ie              = ""
						, media           = ""
						, renderedInclude = ""
					},
					"jquery-ui-css"={
						  before          = ["css-some", "css-subfolder-another", "css-subfolder-more"]
						, after           = []
						, path            = ""
						, url             = "http://jquery.com/jqueryui.min.css"
						, type            = "css"
						, ie              = ""
						, media           = ""
						, renderedInclude = ""
					},
					"css-some"={
						  before          = ["css-subfolder-another", "css-subfolder-more"]
						, after           = ["jquery-ui-css"]
						, path            = "/css/some.min.css"
						, url             = "http://bundle2.com/assets/css/some.min.css"
						, type            = "css"
						, ie              = ""
						, media           = ""
						, renderedInclude = ""
					}
				} );
			} );
		} );
	}

/************************************ PRIVATE HELPERS ***************************************/

	private struct function _assetsToStruct( required struct assets ) output=false {
		var a = {};

		for( var asset in arguments.assets ){
			a[ asset ] = arguments.assets[ asset ].getMemento();
		}

		return a;
	}

}
