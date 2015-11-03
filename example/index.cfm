<cfscript>

	// Grab the cached value and perform a function that we know has a variable leak.
	application.thing.leakForLoop();

	// Get the manifest of private variables that may be leaking.
	manifest = new lib.Snooper()
		// .includeFunctions()
		// .includeComponents()
		.excludeKeys( [ "password", "secretkey", "apiKey" ] )
		.snoop( application.thing )
	;

</cfscript>

<!--- ------------------------------------------------------------------------------ --->
<!--- ------------------------------------------------------------------------------ --->

<cfcontent type="text/html; charset=utf-8" />

<!doctype html>
<html>
<head>
	<meta charset="utf-8" />

	<title>
		Checking ColdFusion Variable Leaks With Snooper.cfc
	</title>
</head>
<body>

	<h1>
		Checking ColdFusion Variable Leaks With Snooper.cfc
	</h1>

	<cfdump
		label="(Potentially) Leaked Variables"
		var="#manifest#"
		format="html"
	/>

</body>
</html>
