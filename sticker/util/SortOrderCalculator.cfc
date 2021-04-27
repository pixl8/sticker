/**
 * I provide functionality to take an collection of assets and return an array of asset
 * keys in the correct order
 */

component {

	/**
	 * I calculate the sort order of assets
	 *
	 * @assets.hint Assets structure
	 */
	public array function calculateOrder( required struct assets, boolean allowFromCache=true ) {
		if ( arguments.allowFromCache ) {
			var cacheKey  = Hash( SerializeJson( arguments.assets ) );
			var fromCache = _getFromCache( cacheKey );

			if ( !IsNull( fromCache ) ) {
				return fromCache;
			}
		}

		var assetKeys  = StructKeyArray( arguments.assets );
		var keyCount   = ArrayLen( assetKeys );
		var comparisonCache = {};

		ArraySort( assetKeys, "textnocase" );

		// a bubble sort
		var orderChanged = false;
		do {
			orderChanged = false;
			for( var i = 1; i < keyCount; i++ ){
				for( var n=i+1; n <= keyCount; n++ ){
					var key1                   = assetKeys[ i ];
					var key2                   = assetKeys[ n ];
					var key1ShouldBeBeforeKey2 = _isBefore( key1, key2, arguments.assets, comparisonCache );

					if ( !IsNull( key1ShouldBeBeforeKey2 ) ) {
						if ( key1ShouldBeBeforeKey2 && i > n ) {
							orderChanged = true;
							ArrayDeleteAt( assetKeys, i );
							ArrayInsertAt( assetKeys, n, key1 );
						} else if ( !key1ShouldBeBeforeKey2 && n > i ) {
							orderChanged = true;
							ArrayDeleteAt( assetKeys, n );
							ArrayInsertAt( assetKeys, i, key2 );
						}
					}
				}
			}
		} while ( orderChanged );

		if ( arguments.allowFromCache ) {
			_putInCache( assetKeys, cacheKey )
		}

		return assetKeys;
	}

// private utility
	private any function _isBefore( required string key1, required string key2, required struct assets, required struct comparisonCache ) {
		var cacheKey = arguments.key1 & "..." & arguments.key2;
		var reverseCacheKey = arguments.key2 & "..." & arguments.key1;

		if ( StructKeyExists( arguments.comparisonCache, cacheKey ) ) {
			return arguments.comparisonCache[ cacheKey ] == "null" ? NullValue() : arguments.comparisonCache[ cacheKey ];
		}

		var key1Befores = arguments.assets[ arguments.key1 ].getBefore();
		var key1Afters  = arguments.assets[ arguments.key1 ].getAfter();
		var key2Befores = arguments.assets[ arguments.key2 ].getBefore();
		var key2Afters  = arguments.assets[ arguments.key2 ].getAfter();

		var isBeforeKey1 = ArrayFindNoCase( key1Befores, arguments.key2 );
		var isAfterKey1  = ArrayFindNoCase( key1Afters, arguments.key2 );
		var isBeforeKey2 = ArrayFindNoCase( key2Befores, arguments.key1 );
		var isAfterKey2  = ArrayFindNoCase( key2Afters, arguments.key1 );

		if ( !isBeforeKey1 && !isAfterKey1 && !isBeforeKey2 && !isAfterKey2 ) {
			arguments.comparisonCache[ cacheKey ] = arguments.comparisonCache[ reverseCacheKey ] = "null";
			return; // return null - no positive evidence to suggest it is before - leave order as it is
		}

		var isBefore = ( isBeforeKey1 || isAfterKey2 ) && !( isBeforeKey2 || isAfterKey1 );
		arguments.comparisonCache[ cacheKey ] = isBefore;
		arguments.comparisonCache[ reverseCacheKey ] = !isBefore;

		return isBefore;
	}

	private any function _getFromCache( required string cacheKey ) {
		var filePath = GetTempDirectory() & "/stickercache-#arguments.cacheKey#.json";

		if ( FileExists( filePath ) ) {
			var rawJson = FileRead( filePath );
			if ( isJson( rawJson ) ) {
				return DeserializeJson( rawJson );
			}
		}
	}
	private void function _putInCache( required array keys, required string cacheKey ) {
		var filePath = GetTempDirectory() & "/stickercache-#arguments.cacheKey#.json";

		FileWrite( filePath, SerializeJson( arguments.keys ) );
	}
}