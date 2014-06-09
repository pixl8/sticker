/**
* I provider a method for taking a number of manifest files
* and returning a combined manifest file for them all
*
*/
component output=false {

	/**
	 * I take an array of manifest file paths and return a merged
	 * structure of asset definitions
	 *
	 * @filePath.hint filepath of the json manifest file
	 */
	public struct function parseManifest( required string filePath, required string rootUrl ) output=false {
		if ( !FileExists( arguments.filePath ) ) {
			throw(
				  type    = "Sticker.missingManifest"
				, message = "Manifest file [#SerializeJson( arguments.filePath )#] does not exist or is not available"
			);
		}

		var fileContent = FileRead( arguments.filePath );
		new ManifestValidator().validate( fileContent );

		manifest = DeSerializeJson( fileContent );
		for( var assetId in manifest ) {
			if ( !manifest[ assetId ].keyExists( "url" ) ) {
				manifest[ assetId ].url = rootUrl & ( manifest[ assetId ].path ?: "/" )
			}
		}

		return manifest;
	}

	/**
	 * I take an array of manifest structures and merge them, expanding any wildcard before and after paths
	 *
	 * @manifests.hint array of manifest structures (i.e. as returned from parseManifest)
	 */
	public struct function mergeManifests( required array manifests ) output=false {
		var merged = {};
		for( var manifest in arguments.manifests ){
			if ( IsStruct( manifest ) ) {
				merged.append( manifest );
			}
		}

		_expandWildcards( merged );

		return merged;
	}

// private helpers
	private void function _expandWildcards( required struct assetsManifest ) output=false {
		var types = [ "before", "after" ];

		for( var assetKey in arguments.assetsManifest ){
			for( var type in types ){
				var raw = arguments.assetsManifest[ assetKey ][ type ] ?: [];
				var expanded = [];

				if ( IsSimpleValue( raw ) ) { raw = [ raw ]; }

				for( var rawKey in raw ) {
					if ( rawKey contains "*" ) {
						_expandWildcard( rawKey, arguments.assetsManifest, assetKey, type ).each( function( expandedKey ){
							if ( !expanded.findNoCase( expandedKey ) ) {
								expanded.append( expandedKey );
							}
						} );
					} else {
						if ( !expanded.findNoCase( rawKey ) ) {
							expanded.append( rawKey );
						}
					}
				}
				expanded.sort( "textnocase" );

				arguments.assetsManifest[ assetKey ][ type ] = expanded;
			}
		}
	}

	private array function _expandWildcard( required string wildcard, required struct assetsManifest, required string belongingToKey, required string type ) output=false {
		var wildcardRegex = Replace( arguments.wildcard, "*", ".*?", "all" );
		var expanded      = [];
		var skippableKeys = [ arguments.belongingToKey ];
		var otherType     = ( arguments.type == "before" ) ? "after" : "before";

		if ( IsSimpleValue( arguments.assetsManifest[ arguments.belongingToKey ][ otherType ] ) ) {
			arguments.assetsManifest[ arguments.belongingToKey ][ otherType ] = [ arguments.assetsManifest[ arguments.belongingToKey ][ otherType ] ];
		}
		for( var key in arguments.assetsManifest[ arguments.belongingToKey ][ otherType ] ) {
			if ( !key contains "*" ) {
				skippableKeys.append( key );
			}
		}

		for( var key in arguments.assetsManifest.keyArray() ){
			var beforeOrAfter = arguments.assetsManifest[ key ][ arguments.type ] ?: [];
			if ( IsSimpleValue( beforeOrAfter ) ) { beforeOrAfter = [ beforeOrAfter ]; }
			if ( beforeOrAfter.findNoCase( arguments.belongingToKey ) ) {
				skippableKeys.append( key );
			}
		}

		for( var key in arguments.assetsManifest.keyArray() ){
			if ( skippableKeys.findNoCase( key ) ) {
				continue;
			}

			if ( ReFindNoCase( wildcardRegex, key ) ) {
				expanded.append( key );
			}
		}

		return expanded;
	}

}