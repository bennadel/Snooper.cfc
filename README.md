
# Snooper.cfc - A ColdFusion Component For Finding Live Variable Leaks

by [Ben Nadel][1] (on [Google+][2])

This is a small ColdFusion component that I use, as a sanity check, to inspect other
ColdFusion components that are cached in a production system. Snooper.cfc works by 
injecting a public method that can access the target component's private variables scope.
Snooper.cfc then inspects the private variables and looks for potential variable leaks.

To inspect a component, instantiate the Snooper.cfc and call .snoop() on the target:

```cfc
// Get the manifest of private variables that may be leaking.
manifest = new lib.Snooper()
	// .includeFunctions()
	// .includeComponents()
	.excludeKeys( [ "password", "secretkey", "apiKey" ] )
	.snoop( application.thing )
;

writeDump( label = "Possible Leaks", manifest );
```

By default, private functions and private component references are excluded from the 
manifest of private variables. However, you can include them if you want to be calling:

* .includeFunctions() 
* .includeComponents()

You can also exclude arbitrary keys by passing an array of strings to:

* .excludeKeys( arrayOfKeys )

The .snoop() method also takes an optional filter function that will exclude keys:

* .snoop( target [, filterClosure] )

----

*CAUTION*: Never run this in "public" - always hide this behind some sort of 
authentication or administrative tooling. This could expose very sensitive information
to anyone who can access it.


[1]: http://www.bennadel.com
[2]: https://plus.google.com/108976367067760160494?rel=author
