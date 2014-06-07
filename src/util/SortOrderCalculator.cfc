/**
 * I provide functionality to take an asset manifest and return an array of asset
 * keys in the correct order
 */ 

component output=false {

	/**
	 * I calculate the sort order of assets
	 * 
	 * @assets.hint Assets structure as parsed by the ManifestParser object
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
		var key1Befores = _getChain( arguments.key1, arguments.assets, "before" );
		var key1Afters  = _getChain( arguments.key1, arguments.assets, "after" );
		var key2Befores = _getChain( arguments.key2, arguments.assets, "before" );
		var key2Afters  = _getChain( arguments.key2, arguments.assets, "after" );
		
		if ( !key1Befores.findNoCase( arguments.key2 ) && !key1Afters.findNoCase( arguments.key2 ) && !key2Befores.findNoCase( arguments.key1 ) && !key2Afters.findNoCase( arguments.key1) ) {
			return; // return null - no positive evidence to suggest it is before - leave order as it is
		}

		return     ( key1Befores.findNoCase( arguments.key2 ) || key2Afters.findNoCase( arguments.key1 ) )
		       && !( key2Befores.findNoCase( arguments.key1 ) || key1Afters.findNoCase( arguments.key2 ) );
	}

	private array function _getChain( required string assetKey, required struct assets, required string type ) output=false {
		var unexpandedChain = arguments.assets[ arguments.assetKey ][ arguments.type ] ?: [];
		var chain = [];
		
		if ( IsSimpleValue( unexpandedChain ) ) {
			unexpandedChain = [ unexpandedChain ];
		}

		for( var key in unexpandedChain ){
			if ( chain.findNoCase( key ) || key == arguments.assetKey ) {
				continue;
			}

			if ( key contains "*" ) {
				var expanded = _expandWildcard( key, arguments.assets );
				for( var expandedKey in expanded ){
					if ( !chain.findNoCase( expandedKey ) && expandedKey != arguments.assetKey ) {
						chain.append( expandedKey );
					}
				}
			} else {
				chain.append( key );
			}
		}

		return chain;
	}

	private array function _expandWildcard( required string wildcard, required struct assets ) output=false {
		var wildcardRegex = Replace( arguments.wildcard, "*", ".*?", "all" );
		var expanded      = [];

		for( var key in arguments.assets.keyArray() ){
			if ( ReFindNoCase( wildcardRegex, key ) ) {
				expanded.append( key );
			}
		}

		return expanded;
	}
}