/**
 * I represent an asset bundle and provide methods
 * for configuring myself
 *
 */
component output=false {

// CONSTRUCTOR
	/**
	 * I am the constructor, pass me the root URL of this bundle
	 *
	 * @rootUrl.hint The root URL of the bundle, all generated URLs for each asset in the bundle will be relative to this
	 */
	public Bundle function init( required string rootDirectory, required string rootUrl ) output=false {
		_setRootDirectory( arguments.rootDirectory );
		_setRootUrl( arguments.rootUrl );
		_setAssetCollection( {} );
		return this;
	}

// PUBLIC API METHODS
	/**
	 * I return a structure of all the asset definitions stored in the bundle
	 */
	public struct function getAssets() output=false {
		return _getAssetCollection();
	}

	/**
	 * I add a single asset to the bundle
	 *
	 * @id.hint   ID to use for the asset - you will use this later in calls to sticker.include( idOfAsset )
	 * @url.hint  URL of the asset. Used only for externally hosted assets
	 * @path.hint Path to the file, relative to the root URL of this bundle
	 * @type.hint Type of the file, either "js" or "css". If not supplied, it will be inferred from the file extension
	 */
	public Bundle function addAsset(
		  required string id
	    ,          string url
	    ,          string path
	    ,          string type
	) output=false {
		var assetCollection = _getAssetCollection();
		var asset = {};

		if ( arguments.keyExists( "path" ) ) {
			asset.path = _resolvePath( arguments.path );
			asset.url = _getRootUrl() & asset.path;
		} else if ( arguments.keyExists( "url" ) ) {
			asset.url = arguments.url
		}

		asset.type = arguments.type ?: ListLast( asset.url, "." );
		asset.before = asset.after = [];

		assetCollection[ arguments.id ] = new Asset( argumentCollection=asset );

		return this;
	}

// PRIVATE HELPERS
	private string function _resolvePath( required string path ) output=false {
		var fullPath  = _getRootDirectory();
		var directory = "";
		var file      = "";
		var matches   = "";
		var resolved  = GetDirectoryFromPath( arguments.path );

		if ( Left( arguments.path, 1 ) != "/" ) {
			fullPath &= "/";
		}
		fullPath &= arguments.path;

		directory = GetDirectoryFromPath( fullPath );
		file      = ListLast( fullPath, "\/" );

		if ( !DirectoryExists( directory ) ) {
			throw( type="Sticker.missingAsset", message="The asset [#arguments.path#] could not be found in the bundle who's root directory is at [#_getRootDirectory()#]" );
		}

		matches = DirectoryList( directory, false, "name", file );
		if ( !matches.len() ) {
			throw( type="Sticker.missingAsset", message="The asset [#arguments.path#] could not be found in the bundle who's root directory is at [#_getRootDirectory()#]" );
		}
		if ( matches.len() > 1 ) {
			throw( type="Sticker.multipleAssets", message="The asset path [#arguments.path#] returned multiple assets. Wildcard asset paths must resolve to a single file." );
		}

		return resolved & matches[1];
	}

	/**
	 * I return an Asset object for the given asset id
	 *
	 * @id.hint ID of the asset to fetch
	 */
	public Asset function asset( required string id ) output=false {
		var assetCollection = _getAssetCollection();
		return assetCollection[ arguments.id ];
	}

// GETTERS AND SETTERS
	private string function _getRootDirectory() output=false {
		return _rootDirectory;
	}
	private void function _setRootDirectory( required string rootDirectory ) output=false {
		_rootDirectory = ReReplace( arguments.rootDirectory, "(.*?)/$", "\1" );
	}

	private string function _getRootUrl() output=false {
		return _rootUrl;
	}
	private void function _setRootUrl( required string rootUrl ) output=false {
		_rootUrl = ReReplace( arguments.rootUrl, "(.*?)/$", "\1" );
	}

	private struct function _getAssetCollection() output=false {
		return _assetCollection;
	}
	private void function _setAssetCollection( required struct assetCollection ) output=false {
		_assetCollection = arguments.assetCollection;
	}
}