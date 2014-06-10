/**
 * I manage the collecting and parsing of any number of sticker bundles
 *
 */
component output=false {

// CONSTRUCTOR

	/**
	 * I am the constructor
	 */
	public BundleManager function init() output=false {
		_setBundles( [] );
		return this;
	}

// PUBLIC API METHODS

	/**
	 * I add a bundle (directory containing assets with a manifest file at the root)
	 * to the manager instance
	 *
	 * @rootDirectory.hint Root directory of the bundle, must contain a sticker-bundle.json manifest file
	 * @rootUrl.hint       URL that maps to the directory
	 */
	public BundleManager function addBundle( required string rootDirectory, required string rootUrl, string rootComponentPath ) output=false {
		var bundles       = _getBundles();
		var bundle        = new Bundle( rootDirectory=arguments.rootDirectory, rootUrl=arguments.rootUrl );
		var configCfcPath = arguments.rootComponentPath ?: _convertDirectoryToComponentPath( arguments.rootDirectory );

		configCfcPath &= ".StickerBundle";

		CreateObject( configCfcPath ).configure( bundle );

		bundles.append( bundle );
		_setBundles( bundles );

		return this;
	}

	/**
	 * I return a merged asset set based on all the bundles
	 *
	 */
	public struct function getAssets() output=false {
		var bundles = _getBundles();
		var assets  = {};

		for( var bundle in bundles ){
			assets.append( bundle.getAssets() );
		}

		_expandWildcards( assets );

		return assets;
	}

// PRIVATE HELPERS
	private string function _convertDirectoryToComponentPath( required string directory ) output=false {
		var trimmed = ReReplace( arguments.directory, "^\/?(.*?)\/?$", "\1" );

		return Replace( trimmed, "/", ".", "all" );
	}

	private void function _expandWildcards( required struct assets ) output=false {
		var types = [ "before", "after" ];

		for( var assetKey in arguments.assets ){
			var asset = arguments.assets[ assetKey ];
			for( var type in types ){
				var raw      = ( type == "before" ? asset.getBefore() : asset.getAfter() );
				var expanded = [];

				for( var rawKey in raw ) {
					if ( rawKey contains "*" ) {
						_expandWildcard( rawKey, arguments.assets, assetKey, type ).each( function( expandedKey ){
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

				type == "before" ? asset.setBefore( expanded ) : asset.setAfter( expanded );
			}
		}
	}

	private array function _expandWildcard( required string wildcard, required struct assets, required string belongingToKey, required string type ) output=false {
		var wildcardRegex     = Replace( arguments.wildcard, "*", ".*?", "all" );
		var expanded          = [];
		var skippableKeys     = [ arguments.belongingToKey ];
		var otherType         = ( arguments.type == "before" ) ? "after" : "before";
		var belongsTo         = arguments.assets[ arguments.belongingToKey ];
		var possiblySkippable = ( otherType == "after" ? belongsTo.getAfter() : belongsTo.getBefore() )

		for( var key in possiblySkippable ) {
			if ( !key contains "*" ) {
				skippableKeys.append( key );
			}
		}

		for( var key in arguments.assets.keyArray() ){
			var asset = arguments.assets[ key ];
			var beforeOrAfter = arguments.type == "before" ? asset.getBefore() : asset.getAfter();

			if ( beforeOrAfter.findNoCase( arguments.belongingToKey ) ) {
				skippableKeys.append( key );
			}
		}

		for( var key in arguments.assets.keyArray() ){
			if ( skippableKeys.findNoCase( key ) || arguments.assets[ key ].getType() != belongsTo.getType() ) {
				continue;
			}

			if ( ReFindNoCase( wildcardRegex, key ) ) {
				expanded.append( key );
			}
		}

		return expanded;
	}

// GETTERS AND SETTERS
	private array function _getBundles() output=false {
		return _bundles;
	}
	private void function _setBundles( required array Bundles ) outputbfalse {
		_Bundles = arguments.bundles;
	}
}