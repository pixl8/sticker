component output=false {
	this.name = "Sticker CI Test runner";

	this.mappings['/results']       = ExpandPath( "./results" );
	this.mappings['/sticker' ]      = ExpandPath( "../sticker" );
	this.mappings['/tests']         = ExpandPath( "../tests" );
	this.mappings['/resources']     = ExpandPath( "../tests/resources" );

	setting requesttimeout="600";
}