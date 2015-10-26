/**
 * I am the Sticker API and am all you need to interact with in order
 * to work with Sticker.
 *
 */
component {

// CONSTRUCTOR

	/**
	 * I am the Sticker constructor
	 *
	 */
	public Sticker function init() {
		_setBundleManager( new util.BundleManager( )         );
		_setAssets       ( {}                                );
		_setSortOrder    ( []                                );
		_setReady        ( false                             );
		_setRequestKey   ( "stickerIncludes_" & CreateUUId() );

		return this;
	}

// PUBLIC API

	/**
	 * I add a bundle to this instance of sticker, returning an instance of the Sticker object
	 * so that you can chain me
	 *
	 * @rootDirectory.hint Root directory of the bundle, must contain a StickerBundle.cfc configuration file
	 * @rootUrl.hint       URL that maps to the directory
	 */
	public Sticker function addBundle( required string rootDirectory, required string rootUrl ) {
		_getBundleManager().addBundle( argumentCollection = arguments );
		_setReady( false );

		return this;
	}

	/**
	 * I prepare the API to be ready for use by parsing all the bundles
	 * and doing any other leg work such as ensuring the correct order
	 * of assets
	 */
	public Sticker function load() {
		var assets = _getBundleManager().getAssets();

		new util.IncludeRenderer().addRenderedIncludesToAssets( assets );

		_setAssets( assets );
		_setSortOrder( new util.SortOrderCalculator().calculateOrder( assets ) );
		_setReady( true );

		return this;
	}

	/**
	 * I return whether or not the API is ready for use (i.e.
	 * has load() been called since the last addBundle() call)
	 */
	public boolean function ready() {
		return _getReady();
	}

	/**
	 * I return the URL of the given asset
	 *
	 * @assetId.hint ID of the asset as defined in any of the sticker bundle's configuration files
	 */
	public string function getAssetUrl( required string assetId ) {
		_checkReady();

		var assets = _getAssets();

		if ( assets.keyExists( arguments.assetId ) ) {
			return assets[ arguments.assetId ].getUrl();
		}

		throw( type="Sticker.missingAsset", message="asset [#arguments.assetid#] not found" );

	}

	/**
	 * I include an asset in the request, ready for rendering
	 *
	 * @assetId.hint ID of the asset as defined in any of the sticker bundles' config file
	 * @throwOnMissing.hint Whether or not to throw an error when the asset does not exist, default=true
	 */
	public Sticker function include( required string assetId, boolean throwOnMissing=true, string group="default" ) {
		_checkReady();

		var assets = _getAssets();

		if ( assets.keyExists( arguments.assetId ) ) {
			var requestedIncludes = _getRequestStorage();

			if ( !requestedIncludes.keyExists( arguments.group ) ){
				requestedIncludes[ arguments.group ] = StructNew( "linked" );
			}

			requestedIncludes[ arguments.group ][ arguments.assetId ] = "";

			return this;
		}

		if ( arguments.throwOnMissing ) {
			throw( type="Sticker.missingAsset", message="asset [#arguments.assetid#] not found" );
		}

		return this;
	}

	/**
	 * I include a data to be made available to the requested javascript
	 *
	 * @data.hint CFML Structure
	 */
	public Sticker function includeData( required struct data, string group="default" ) {
		_checkReady();

		var requestStorage = _getRequestStorage( "data" );
		if ( !requestStorage.keyExists( arguments.group ) ){
			requestStorage[ arguments.group ] = StructNew( "linked" );
		}

		requestStorage[ arguments.group ].append( arguments.data );

		return this;
	}

	/**
	 * I render the collected request includes as HTML includes
	 * I ensure all includes are rendered in the correct order
	 *
	 */
	public string function renderIncludes( string type, string group="default" ) {
		var includes      = _getRequestStorage();
		var fullSortOrder = _getSortOrder();
		var ordered       = [];
		var assets        = _getAssets();
		var rendered      = "";

		includes = ( includes[ arguments.group ] ?: {} );

		_addIncludeDependencies( includes );

		for( var assetid in fullSortOrder ){
			if ( includes.keyExists( assetId ) ) {
				ordered.append( assetId );
			}
		}

		for( var t in [ "css", "js" ] ){
			if ( t == ( arguments.type ?: t ) ) {
				if ( t == "js" ) {
					var data = _getRequestStorage( "data" );
					if ( data.keyExists( arguments.group ) ) {
						rendered &= new util.IncludeRenderer().renderData( data[ arguments.group ] ) & Chr(13) & Chr(10);
					}
				}
				for( var asset in ordered ){
					if ( assets[ asset ].getType() == t ){
						rendered &= assets[ asset ].getRenderedInclude() & Chr(13) & Chr(10);
					}
				}
			}
		}

		return rendered;
	}

// PRIVATE UTILITY
	private void function _checkReady() {
		if ( !ready() ) {
			throw( type="Sticker.notReady", message="The sticker API instance has not yet been loaded. Please use the load() method before calling any of the per-request inclusion methods" );
		}
	}

	private struct function _getRequestStorage( string key="includes" ) {
		var key = _getRequestKey();
		if ( !request.keyExists( key ) ) {
			request[ key ] = {
				  includes = {}
				, data     = StructNew( "linked" )
			};
		}

		return request[ key ][ arguments.key ];
	}

	private void function _addIncludeDependencies( required struct includes ) {
		for( var assetId in arguments.includes ){
			for( var dependencyAssetId in _getDependencies( assetId=assetId, ignore=arguments.includes.keyArray() ) ){
				arguments.includes[ dependencyAssetId ] = "";
			}
		}
	}

	private array function _getDependencies( required string assetId, required array ignore, array dependencies=[] ) {
		var assets = _getAssets();

		for( var dependencyAssetId in assets[ arguments.assetId ].getDependsOn() ) {
			if ( !ignore.find( dependencyAssetId ) && !arguments.dependencies.find( dependencyAssetId ) ) {
				arguments.dependencies.append( dependencyAssetId );
				arguments.dependencies = _getDependencies( dependencyAssetId, arguments.ignore, arguments.dependencies );
			}
		}

		return arguments.dependencies;
	}

// GETTERS and SETTERS
	private BundleManager function _getBundleManager() {
		return _bundleManager;
	}
	private void function _setBundleManager( required BundleManager bundleManager ) {
		_bundleManager = arguments.bundleManager;
	}

	private struct function _getAssets() {
		return _assets;
	}
	private void function _setAssets( required struct assets ) {
		_assets = arguments.assets;
	}

	private array function _getSortOrder() {
		return _sortOrder;
	}
	private void function _setSortOrder( required array sortOrder ) {
		_sortOrder = arguments.sortOrder;
	}

	private boolean function _getReady() {
		return _ready;
	}
	private void function _setReady( required boolean ready ) {
		_ready = arguments.ready;
	}

	private string function _getRequestKey() {
		return _requestKey;
	}
	private void function _setRequestKey( required string requestKey ) {
		_requestKey = arguments.requestKey;
	}
}