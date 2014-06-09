/**
 * I manage the collecting and parsing of any number of sticker bundles
 *
 */
component output=false {

// Constructor

	/**
	 * I am the constructor, pass me a ManifestParser object please
	 *
	 * @ManifestParser.hint Manifest parser object, I'll use this to build a merged manifest for all of the bundles
	 */
	public BundleManager function init( required ManifestParser manifestParser ) output=false {
		_setManifestParser( arguments.manifestParser );
		_setBundles( [] );
		return this;
	}

// Public API methods

	/**
	 * I add a bundle (directory containing assets with a manifest file at the root)
	 * to the manager instance
	 *
	 * @rootDirectory.hint Root directory of the bundle, must contain a sticker-bundle.json manifest file
	 * @rootUrl.hint       URL that maps to the directory
	 */
	public BundleManager function addBundle( required string rootDirectory, required string rootUrl ) output=false {
		var bundles = _getBundles();
		var bundle  = Duplicate( arguments );

		bundle.manifest = _getManifestParser().parseManifest(
			  filePath = rootDirectory & "/sticker-bundle.json"
			, rootUrl  = arguments.rootUrl
		);

		bundles.append( bundle );
		_setBundles( bundles );

		return this;
	}

	/**
	 * I return a merged manifest object for all the registered bundles
	 *
	 */
	public struct function getManifest() output=false {
		var bundles   = _getBundles();
		var manifests = [];

		for( var bundle in bundles ){
			manifests.append( bundle.manifest );
		}
		return _getManifestParser().mergeManifests( manifests=manifests );
	}





// private getters and setters
	private ManifestParser function _getManifestParser() output=false {
		return _manifestParser;
	}
	private void function _setManifestParser( required ManifestParser manifestParser ) output=false {
		_manifestParser = arguments.manifestParser;
	}

	private array function _getBundles() output=false {
		return _bundles;
	}
	private void function _setBundles( required array Bundles ) outputbfalse {
		_Bundles = arguments.bundles;
	}
}