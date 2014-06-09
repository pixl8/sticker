<cfscript>
	testbox = new testbox.system.TestBox( options={}, directory={
		recurse = true,
		mapping = "tests",
		filter  = function( required path ){ return true; }
	} );

	WriteOutput( testbox.run() );
</cfscript>