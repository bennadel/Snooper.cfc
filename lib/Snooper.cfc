component
	output = false
	hint = "I provide a means to examine ColdFusion components for variable leaks."
	{

	/**
	* I create a new Snooper that can inspect private variables.
	* 
	* @output false
	*/
	public any function init() {

		// By default, we're going to exclude Functions and Components in the private
		// variable reporting. More likely than not, these are not leaked variables.
		// Leaks tend to be caused by lower-level values like numbers, strings, arrays
		// and structs.
		isIncludingFunctions = false;
		isIncludingComponents = false;

		// By default, we won't exclude any arbitrary keys from the manifest.
		keysToExclude = [];

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I exclude ColdFusion components from the collection of reported private keys.
	* Returns [this].
	* 
	* @output false
	*/
	public any function excludeComponents() {

		isIncludingComponents = false;

		return( this );

	}


	/**
	* I exclude ColdFusion functions from the collection of reported private keys. 
	* This does NOT EXCLUDE closures as those are more likely be a source of leaks. 
	* Returns [this].
	* 
	* @output false
	*/
	public any function excludeFunctions() {

		isIncludingFunctions = false;

		return( this );

	}


	/**
	* I exclude the given keys from every manifest. Returns [this].
	* 
	* @newKeys I am an array of key values to always exclude.
	* @output false
	*/
	public any function excludeKeys( required array newKeys ) {

		// Reset the key exclusion collection.
		keysToExclude = [];

		for ( var newKey in newKeys ) {

			if ( isSimpleValue( newKey ) ) {

				arrayAppend( keysToExclude, lcase( newKey ) );

			}

		}

		return( this );

	}


	/**
	* I include ColdFusion components in the collection of reported private keys.
	* Returns [this].
	* 
	* @output false
	*/
	public any function includeComponents() {

		isIncludingComponents = true;

		return( this );

	}


	/**
	* I include ColdFusion functions in the collection of reported private keys.
	* Returns [this].
	* 
	* @output false
	*/
	public any function includeFunctions() {

		isIncludingFunctions = true;

		return( this );

	}


	/**
	* I inspect the private variables of the given target. By default, all keys will
	* be examined; however, you can include an optional filter that can exclude reported
	* keys (to both reduce noise and reduce security issues).
	* 
	* I return a struct manifest of the private keys being reported.
	* 
	* @target I am the ColdFusion component being snooped.
	* @filter I am the optional filter for key inclusion (return True to include).
	* @output false 
	*/
	public struct function snoop( 
		required any target,
		function filter = noopTrue 
		) {

		testTarget( target );

		// Echo the name of the target component for a more flexible consumption in the
		// calling context.
		var manifest = {
			target: getMetaData( target ).name,
			keys: {},
			keyCount: 0
		};

		// In order to gain access to the private variables of the target, we have to 
		// inject a Function that will circumvent the private security. However, after
		// we access the private variables we have to clean up after ourselves - we 
		// don't want to leave the target in a dirty state.
		try {

			target.snoop___getVariables = snoop___getVariables;

			var privateVariables = target.snoop___getVariables();

		} finally {
	
			structDelete( target, "snoop___getVariables" );

		}

		// Now that we have our extracted private variables, let's iterate over the keys
		// and determine which ones should be reported.
		for ( var privateKey in privateVariables ) {

			// Normalize the key for consistent consumption.
			privateKey = lcase( privateKey );

			var privateValue = privateVariables[ privateKey ];

			// Exclude private components if necessary.
			if ( isObject( privateValue ) && ! isIncludingComponents ) {

				continue;

			}

			// Excluded private functions if necessary.
			if ( isCustomFunction( privateValue ) && ! isIncludingFunctions ) {

				continue;

			}

			// Exclude blacklisted keys if necessary.
			if ( arrayContains( keysToExclude, privateKey ) ) {

				continue;

			}

			// Exclude private key based on user-provided filter.
			if ( ! filter( privateKey, privateValue ) ) {

				continue;

			}

			// If we made it this far, the user wants to see this private variable
			// reported in the snooped manifest.
			manifest.keys[ privateKey ] = privateValue;
			manifest.keyCount++;

		}

		return( manifest );

	}


	/**
	* I am the INJECTED method that exposes the private Variables scope of the target.
	* After being injected, it is called in the context of the target, hence the just-in
	* time variables binding.
	* 
	* @output false
	*/
	public struct function snoop___getVariables() {

		return( variables );

	}


	/**
	* I test the given target to see if it can be snooped. If the target is valid, I 
	* return quietly; otherwise, I throw an error.
	* 
	* @newTarget I am the target being validated.
	* @output false
	*/
	public void function testTarget( required any newTarget ) {

		if ( ! isObject( newTarget ) ) {

			throw(
				type = "Snooper.InvalidTarget",
				message = "Target must be a ColdFusion component."
			);

		}

	}


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* I always return true.
	* 
	* @output false
	*/
	private boolean function noopTrue() {

		return( true );

	}

}
