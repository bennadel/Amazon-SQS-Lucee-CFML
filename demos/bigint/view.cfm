<cfscript>

	param name="url.id" type="numeric" default=0;

	// Since all URL values are string values, let's convert the string URL parameter
	// into a true numeric data-type.
	url.id = val( url.id );

	```
	<cfquery name="record">
		SELECT
			id, /* BIGINT */
			value,
			version /* INTEGER */
		FROM
			bigint_test
		WHERE
			id = <cfqueryparam value="#url.id#" sqltype="bigint" />
	</cfquery>
	```

	if ( ! record.recordCount ) {

		location( url = "./index.cfm", addToken = false );

	}

</cfscript>
<cfoutput>

	<!doctype html>
	<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>
			Testing BIGINT Usage In MySQL 5.7.32 And Lucee CFML 5.3.8.201
		</title>
	</head>
	<body>

		<h1>
			Record Detail
		</h1>

		<p>
			&larr; <a href="./index.cfm">Back to Home</a>
		</p>

		<ul>
			<li>
				<strong>ID:</strong> #record.id#
			</li>
			<li>
				<strong>Value:</strong> #record.value#
			</li>
		</ul>

		<h2>
			<code>URL.id</code>
		</h2>

		<cfdump var="#isNumeric( url.id )#" />
		<cfdump var="#numberFormat( url.id )#" />
		<cfdump var="#getMetadata( url.id ).name#" />
		<cfdump var="#( url.id + 1 )#" />

		<h2>
			<code>RECORD.id</code> (BIGINT)
		</h2>

		<cfdump var="#isNumeric( record.id )#" />
		<cfdump var="#numberFormat( record.id )#" />
		<cfdump var="#getMetadata( record.id ).name#" />
		<cfdump var="#( record.id + 1 )#" />

		<h2>
			<code>RECORD.version</code> (INTEGER)
		</h2>

		<cfdump var="#getMetadata( record.version ).name#" />

	</body>
	</html>

</cfoutput>
