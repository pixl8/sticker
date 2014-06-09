component extends="testbox.system.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		variables.calculator = new sticker.util.SortOrderCalculator();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "calculateOrder()", function(){

			it( "should calculate the order or assets based on their before and after properties, using their name as a tie breaker", function(){
				var testManifest = {
					  asset01 = { before=[ "asset02", "asset04", "asset05", "asset06", "asset07", "asset08" ], after=[ "asset03" ] }
					, asset02 = { before=[], after=[ "asset03", "asset01" ] }
					, asset03 = { before=[], after=[] }
					, asset04 = { before=[ "asset02" ], after=[] }
					, asset05 = { before=[ "asset02" ], after=[] }
					, asset06 = { before=[ "asset02", "asset04" ], after=["asset05"] }
					, asset07 = { before=[], after=[ "asset01", "asset02", "asset03", "asset04", "asset05", "asset06", "asset08" ] }
					, asset08 = { before=[], after=[] }
				};
				var expectedOrder = [
					  "asset03"
					, "asset01"
					, "asset05"
					, "asset06"
					, "asset04"
					, "asset02"
					, "asset08"
					, "asset07"
				];

				expect( calculator.calculateOrder( testManifest ) ).toBe( expectedOrder );
			} );

			it( "should NOT *explode* when there is an infinite loop in the ordering logic (i.e. two assets declare that they should be before each other)", function(){
				var testManifest = {
					  asset01 = { before=[ "asset02" ], after=[ "asset03" ] }
					, asset02 = { before=[ "asset01" ], after=[] }
					, asset03 = { before=[], after=[ "asset01" ] }
					, asset04 = { before=[ "asset01" ], after=[ "asset01" ] }
				};
				var expectedOrder = [
					  "asset02"
					, "asset03"
					, "asset04"
					, "asset01"
				];

				expect( calculator.calculateOrder( testManifest ) ).toBe( expectedOrder );
			} );

		} );
	}

}
