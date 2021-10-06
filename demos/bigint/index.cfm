<cfscript>

	param name="url.create" type="boolean" default=false;

	if ( url.create ) {

		```
		<cfquery name="insert">
			INSERT INTO
				bigint_test
			SET
				value = <cfqueryparam value="Uniquely #createUniqueId()#" sqltype="varchar" />,
				version = <cfqueryparam value="1" sqltype="integer" />
		</cfquery>
		```

	}

	```
	<cfquery name="records">
		SELECT
			id
		FROM
			bigint_test
	</cfquery>
	```

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
			Testing BIGINT Usage In MySQL 5.7.32 And Lucee CFML 5.3.8.201
		</h1>

		<p>
			<a href="./index.cfm?create=true">Create a new record</a>
		</p>

		<ul>
			<cfloop query="records">
				<li>
					<a href="./view.cfm?id=#records.id#">
						View #records.id# &rarr;
					</a>
				</li>
			</cfloop>
		</ul>
	
	</body>
	</html>

</cfoutput>
