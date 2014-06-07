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
	 * @filePaths.hint An array of filepaths. each filepath should point at a valid Sticker manifest json file
	 */
	public struct function parseFiles( required array filePaths ) output=false {
		var manifest  = {};
		var validator = new ManifestValidator();

		for( var filePath in filePaths ){
			if ( !IsSimpleValue( filePath ) || !FileExists( filePath ) ) {
				throw(
					  type    = "Sticker.missingManifest"
					, message = "Manifest file [#SerializeJson( filePath )#] does not exist or is not available"
				);
			}

			var fileContent = FileRead( filePath );
			
			validator.validate( fileContent );

			manifest.append( DeSerializeJson( fileContent ) );
		}

		_expandWildcards( manifest );

		return manifest;
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