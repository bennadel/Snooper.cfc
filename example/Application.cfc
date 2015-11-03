component 
	output = "false"
	hint = "I define the applications settings and event handlers."
	{

	// Define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 0, 0, 30 );

	// Get the current directory and the root directory.
	this.appDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
	this.projectDirectory = ( this.appDirectory & "../" );

	// Map the lib directory so we can create our components.
	this.mappings[ "/lib" ] = ( this.projectDirectory & "lib" );


	/**
	* I initialize the application.
	* 
	* @output false 
	*/
	public boolean function onApplicationStart() {

		// Cache a component that has variable leaking problems.
		application.thing = new Thing();

		return( true );

	}

}