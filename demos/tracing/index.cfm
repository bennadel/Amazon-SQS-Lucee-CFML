<cfscript>

	param name="form.toEmail" type="string" default="";

	// If we have a new user email to process, put it on the message queue - a background
	// thread will monitor the queue for new messages and then send out an invite email.
	if ( form.toEmail.len() ) {

		application.emailQueueService.addMessage(
			"invitation",
			{
				toEmail: form.toEmail
			}
		);

	}

</cfscript>
<cfoutput>

	<!doctype html>
	<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>
			Request Tracing Propagation When Consuming Amazon SQS Queues In Lucee CFML 5.3.8.201
		</title>
		<link rel="stylesheet" type="text/css" href="./index.css" />
	</head>
	<body>

		<h1>
			Request Tracing Propagation When Consuming Amazon SQS Queues In Lucee CFML 5.3.8.201
		</h1>

		<form method="post" action="./index.cfm">
			<input
				type="text"
				name="toEmail"
				placeholder="New user email..."
				size="40"
				maxlength="75"
				autofocus
				autocomplete="off"
			/>
			<button type="submit">
				Send invitation
			</button>
		</form>

		<p>
			<a href="./?init=1">Restart application</a>
		</p>

	</body>
	</html>

</cfoutput>
