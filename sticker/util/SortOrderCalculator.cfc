/**
 * I provide functionality to take an collection of assets and return an array of asset
 * keys in the correct order
 */

component output=false {

	/**
	 * I calculate the sort order of assets
	 *
	 * @assets.hint Assets structure
	 */
	public array function calculateOrder( required struct assets ) output=false {
		var assetKeys  = arguments.assets.keyArray();
		var keyCount   = assetKeys.len();
		var newOrder   = "";

		assetKeys.sort( "textnocase" );
		newOrder = Duplicate( assetKeys );

		for( var i = 1; i < keyCount; i++ ){
			for( var n=i+1; n <= keyCount; n++ ){
				var key1                   = assetKeys[i];
				var key2                   = assetKeys[n];
				var pos1                   = newOrder.findNoCase( key1 );
				var pos2                   = newOrder.findNoCase( key2 );
				var key1ShouldBeBeforeKey2 = _isBefore( key1, key2, arguments.assets );

				if ( !IsNull( key1ShouldBeBeforeKey2 ) ) {
					if ( key1ShouldBeBeforeKey2 && pos1 > pos2 ) {
						newOrder.deleteAt( pos1 );
						newOrder.insertAt( pos2, key1 );
					} elseif ( !key1ShouldBeBeforeKey2 && pos2 > pos1 ) {
						newOrder.deleteAt( pos2 );
						newOrder.insertAt( pos1, key2 );
					}
				}
			}
		}

		return newOrder;
	}

// private utility
	private any function _isBefore( required string key1, required string key2, required struct assets ) output=false {
		var key1Befores = arguments.assets[ arguments.key1 ].getBefore();
		var key1Afters  = arguments.assets[ arguments.key1 ].getAfter();
		var key2Befores = arguments.assets[ arguments.key2 ].getBefore();
		var key2Afters  = arguments.assets[ arguments.key2 ].getAfter();

		if ( !key1Befores.findNoCase( arguments.key2 ) && !key1Afters.findNoCase( arguments.key2 ) && !key2Befores.findNoCase( arguments.key1 ) && !key2Afters.findNoCase( arguments.key1) ) {
			return; // return null - no positive evidence to suggest it is before - leave order as it is
		}

		return     ( key1Befores.findNoCase( arguments.key2 ) || key2Afters.findNoCase( arguments.key1 ) )
		       && !( key2Befores.findNoCase( arguments.key1 ) || key1Afters.findNoCase( arguments.key2 ) );
	}
}