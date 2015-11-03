component
	output = false
	hint = "I am a ColdFusion component that contains a memory leak."
	{

	public any function init() {

		// NOTE: This will be excluded based on the key-filtering.
		secretKey = "h@x0r";

		// NOTE: This will be excluded based on the component filtering.
		anotherThing = new AnotherThing();

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	public any function leakForLoop() {

		// "i" is not var'd correctly.
		for ( i = 0 ; i <= 10 ; i++ ) {

			var j = i;

		}

		return( this );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	// NOTE: This will be excluded based on the function filtering.
	private void function doSomethingPrivate() {

		// ...

	}

}