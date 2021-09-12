<cfscript>

	param name="form.hexColor" type="string" default="";

	// If we have a new hex color to process, put it on the message queue - a background
	// thread will monitor the queue for new messages and generate the color swatch image
	// asynchronously.
	if ( form.hexColor.len() ) {

		application.colorSwatchQueueService.addMessage( form.hexColor );

	}

	// Query for the existing color swatches. Since we don't have a database, we'll just
	// read the images right off of the file-system.
	swatches = directoryList(
		path = expandPath( "/swatches" ),
		listInfo = "name",
		type = "file",
		filter = "*.png"
	);
	swatches.sort( "textnocase", "desc" );

</cfscript>
<cfoutput>

	<!doctype html>
	<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>
			Separation Of Concerns When Consuming Amazon SQS Queues In Lucee CFML 5.3.8.201
		</title>
		<link rel="stylesheet" type="text/css" href="./index.css" />
		<!---
			If we just submitted a hexColor, let's automatically refresh the page in a
			few seconds. For this particular demo, a few seconds is all it takes for the
			ColdFusion application to poll the queue, get the new messages, and generate
			the associated color swatch image. Refreshing the page will, therefore, read
			the new image off the file-system.
		--->
		<cfif form.hexColor.len()>
			<meta http-equiv="refresh" content="2" />
		</cfif>
	</head>
	<body>

		<h1>
			Separation Of Concerns When Consuming Amazon SQS Queues In Lucee CFML 5.3.8.201
		</h1>

		<form method="post" action="./index.cfm">
			<input
				type="text"
				name="hexColor"
				placeholder="Enter hex color..."
				size="20"
				maxlength="6"
				autofocus
			/>
			<button type="submit">
				Generate swatch
			</button>
		</form>

		<hr />

		<h2>
			Existing Swatches
		</h2>

		<ul>
			<cfloop value="filename" array="#swatches#">
				<li>
					<img src="./swatches/#filename#" />
				</li>
			</cfloop>
		</ul>

	</body>
	</html>

</cfoutput>
