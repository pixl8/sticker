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
				var testAssets = {
					  asset01 = new sticker.util.Asset( beforeAssert=[ "asset02", "asset04", "asset05", "asset06", "asset07", "asset08" ], afterAssert=[ "asset03" ] )
					, asset02 = new sticker.util.Asset( beforeAssert=[], afterAssert=[ "asset03", "asset01" ] )
					, asset03 = new sticker.util.Asset( beforeAssert=[], afterAssert=[] )
					, asset04 = new sticker.util.Asset( beforeAssert=[ "asset02" ], afterAssert=[] )
					, asset05 = new sticker.util.Asset( beforeAssert=[ "asset02" ], afterAssert=[] )
					, asset06 = new sticker.util.Asset( beforeAssert=[ "asset02", "asset04" ], afterAssert=["asset05"] )
					, asset07 = new sticker.util.Asset( beforeAssert=[], afterAssert=[ "asset01", "asset02", "asset03", "asset04", "asset05", "asset06", "asset08" ] )
					, asset08 = new sticker.util.Asset( beforeAssert=[], afterAssert=[] )
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

				expect( calculator.calculateOrder( testAssets ) ).toBe( expectedOrder );
			} );

			it( "should NOT *explode* when there is an infinite loop in the ordering logic (i.e. two assets declare that they should be before each other)", function(){
				var testAssets = {
					  asset01 = new sticker.util.Asset( beforeAssert=[ "asset02" ], afterAssert=[ "asset03" ] )
					, asset02 = new sticker.util.Asset( beforeAssert=[ "asset01" ], afterAssert=[] )
					, asset03 = new sticker.util.Asset( beforeAssert=[], afterAssert=[ "asset01" ] )
					, asset04 = new sticker.util.Asset( beforeAssert=[ "asset01" ], afterAssert=[ "asset01" ] )
				};
				var expectedOrder = [
					  "asset02"
					, "asset03"
					, "asset04"
					, "asset01"
				];

				expect( calculator.calculateOrder( testAssets ) ).toBe( expectedOrder );
			} );

		} );
	}

}
