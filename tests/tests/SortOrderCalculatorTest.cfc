component extends="testbox.system.testing.BaseSpec"{
	
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
					  asset01 = { before="*", after="asset03" }
					, asset02 = { after=[ "asset03", "asset01" ] }
					, asset03 = {}
					, asset04 = { before=[ "asset02" ] }
					, asset05 = { before=[ "asset02" ] }
					, asset06 = { before=[ "asset02", "asset04" ], after="asset05" }
					, asset07 = { after="*" }
					, asset08 = {}
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

		} );
	}
	
}
