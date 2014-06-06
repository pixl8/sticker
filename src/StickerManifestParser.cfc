/**
 * I provide methods for taking sticker manifest file input and converting it to
 * various structures that the API can then use to provide fast per-request inclusion logic
 */
component output=false {
	
	/**
	 * I accept an array of manifest JSON strings and 
	 * turn them into a useable form for the API
	 * 
	 * @manifests.hint an array of JSON strings, each of which should be a valid Sticker manifest
	 */
	public struct function parseManifests( required array manifests ) output=false {
		var combinedManifests = _combineManifests( arguments.manifests );
		
		return {};
	}

// private helpers
	private struct function _combineManifests( required array manifests ) output=false {
		var combined = {};

		arguments.manifests.each( function( manifest ){
			try{
				var parsedJson = DeSerializeJson( arguments.manifest );
				combined.append( parsedJson );
			} catch ( any e ) {
				throw( 
					  type="Sticker.badManifest"
					, message="Invalid manifest. Your manifest file contained invalid JSON"
					, detail="Passed manifest: [#arguments.manifest#]" 
				);
			}
		} );

		return combined;
	}

}