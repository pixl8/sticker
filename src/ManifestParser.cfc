component output=false {

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

		return manifest;
	}

}