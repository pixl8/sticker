/**
 * I manage the collecting and parsing of any number of sticker bundles
 *
 */
component {

// CONSTRUCTOR

	/**
	 * I am the constructor
	 */
	public BundleManager function init() {
		_setBundles( [] );
		return this;
	}

// PUBLIC API METHODS

	/**
	 * I add a bundle (directory containing StickerBundle.cfc config file at the root)
	 * to the manager instance
	 *
	 * @rootDirectory.hint Root directory of the bundle, must contain a StickerBundle.cfc configuration file in its root
	 * @rootUrl.hint       URL that maps to the directory
	 */
	public BundleManager function addBundle( required string rootDirectory, required string rootUrl, string rootComponentPath, struct config={} ) {
		var bundles       = _getBundles();
		var bundle        = new Bundle( rootDirectory=arguments.rootDirectory, rootUrl=arguments.rootUrl );
		var configCfcPath = arguments.rootComponentPath ?: _convertDirectoryToComponentPath( arguments.rootDirectory );


		configCfcPath &= ".StickerBundle";

		if ( !FileExists( ListAppend( arguments.rootDirectory, "StickerBundle.cfc", "/" ) ) ) {
			throw( type="Sticker.missingStickerBundle", message="No StickerBundle.cfc file found at [#arguments.rootDirectory#]" );
		}

		CreateObject( configCfcPath ).configure( bundle, arguments.config );

		bundles.append( bundle );
		_setBundles( bundles );

		return this;
	}

	/**
	 * I return a merged asset set based on all the bundles
	 *
	 */
	public struct function getAssets() {
		var bundles = _getBundles();
		var assets  = {};

		for( var bundle in bundles ){
			assets.append( bundle.getAssets() );
		}

		_expandWildcards( assets );
		_mapDependencies( assets );

		return assets;
	}

// PRIVATE HELPERS
	private string function _convertDirectoryToComponentPath( required string directory ) {
		var trimmed = ReReplace( arguments.directory, "^\/?(.*?)\/?$", "\1" );

		return Replace( trimmed, "/", ".", "all" );
	}

	private void function _expandWildcards( required struct assets ) {
		var types = [ "before", "after", "dependsOn", "dependents" ];

		for( var assetKey in arguments.assets ){
			var asset = arguments.assets[ assetKey ];
			for( var type in types ){
				var raw      = _getBeforeAfterOrDependencies( type, asset );
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

				_setBeforeAfterOrDependencies( type, asset, expanded );
			}
		}
	}

	private void function _mapDependencies( required struct assets ) {
		for( var assetId in arguments.assets ){
			var asset = arguments.assets[ assetId ];
			for( var dependentAssetId in asset.getDependents() ){
				if ( arguments.assets.keyExists( dependentAssetId ) ) {
					var dependentAsset = arguments.assets[ dependentAssetId ];

					dependentAsset.dependsOn( assetId );
				}
			}
		}
	}

	private array function _expandWildcard( required string wildcard, required struct assets, required string belongingToKey, required string type ) {
		var wildcardRegex     = Replace( arguments.wildcard, "*", ".*?", "all" );
		var expanded          = [];
		var skippableKeys     = [ arguments.belongingToKey ];
		var otherType         = _getOppositeBeforeAfterOrDependencies( arguments.type );
		var belongsTo         = arguments.assets[ arguments.belongingToKey ];
		var possiblySkippable = _getBeforeAfterOrDependencies( otherType, belongsTo );

		for( var key in possiblySkippable ) {
			if ( !key contains "*" ) {
				skippableKeys.append( key );
			}
		}

		for( var key in arguments.assets.keyArray() ){
			var asset = arguments.assets[ key ];
			var beforeOrAfter = _getBeforeAfterOrDependencies( arguments.type, asset );

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


	private array function _getBeforeAfterOrDependencies( required string type, required Asset asset ) {
		switch( arguments.type ){
			case "before"     : return arguments.asset.getBefore();
			case "after"      : return arguments.asset.getAfter();
			case "dependsOn"  : return arguments.asset.getDependsOn();
			case "dependents" : return arguments.asset.getDependents();
		}
	}


	private void function _setBeforeAfterOrDependencies( required string type, required Asset asset, required array value ) {
		switch( arguments.type ){
			case "before"     : arguments.asset.setBefore( arguments.value ); break;
			case "after"      : arguments.asset.setAfter( arguments.value ); break;
			case "dependsOn"  : arguments.asset.setDependsOn( arguments.value ); break;
			case "dependents" : arguments.asset.setDependents( arguments.value ); break;
		}
	}

	private string function _getOppositeBeforeAfterOrDependencies( required string type ) {
		switch( arguments.type ){
			case "before"     : return "after";
			case "after"      : return "before";
			case "dependsOn"  : return "dependents";
			case "dependents" : return "dependsOn";
		}
	}

// GETTERS AND SETTERS
	private array function _getBundles() {
		return _bundles;
	}
	private void function _setBundles( required array Bundles ) outputbfalse {
		_Bundles = arguments.bundles;
	}
}