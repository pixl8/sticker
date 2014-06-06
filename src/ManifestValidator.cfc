/**
 * I provide a method for validating a JSON manifest string, throwing suitable errors when the
 * input is invalid
 */
component output=false {
	
	/**
	 * I accept a string manifest input and throw an error when it is invalid
	 * I return nothing
	 * 
	 * @manifest.hint a hopefully valid Sticker manifest string
	 */
	public void function validate( required string manifest ) output=false {
		var parsedJson = "";

		try{
			parsedJson = DeSerializeJson( arguments.manifest );
			
		} catch ( any e ) {
			throw( 
				  type    = "Sticker.badManifest"
				, message = "Invalid manifest. Your manifest file contained invalid JSON"
				, detail  = "Passed manifest: [#arguments.manifest#]. Error message: [#e.message#]. Error detail: [#e.detail#]"
			);
		}

		if ( !IsStruct( parsedJson ) ) {
			throw( 
				  type    = "Sticker.badManifest"
				, message = "Invalid manifest. The supplied manifest was in an incorrect format"
				, detail  = "Passed manifest: [#arguments.manifest#]" 
			);
		}

		for( var key in parsedJson ){
			_validateAssetDefinition( key, parsedJson[ key ] );
		}
	}

// private helpers
	private void function _validateAssetDefinition( required string key, required any definition ) output=false {
		if ( !IsStruct( arguments.definition ) ) {
			throw( 
				  type    = "Sticker.badManifest"
				, message = "Invalid asset definition in manifest. Asset definitions must be a JSON object"
				, detail  = "Asset definition: [""#arguments.key#"":#SerializeJson( arguments.definition )#]" 
			);	
		}
	}
}