component
	output = false
	hint = "I define the application settings and event handlers."
	{

	// Configure the application settings.
	this.name = "EmailQueueDemo";
	this.applicationTimeout = createTimeSpan( 0, 1, 0, 0 );
	this.sessionManagement = false;
	this.setClientCookies = false;

	this.mappings = {
		"/vendor": "../../vendor"
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I get called once when the application is being initialized.
	*/
	public void function onApplicationStart() {

		var config = deserializeJson( fileRead( "./config.json" ) );

		// This service interfaces with globally-available scopes (request, cgi, server,
		// etc.) such that the strong coupling to those scopes feels bit less "magical".
		application.requestMetadata = new RequestMetadata();

		// This services sends transactional emails.
		application.emailService = new EmailService(
			requestMetadata = application.requestMetadata
		);

		// This service interacts specifically with the "email-queue".
		application.sqsClient = new SqsClient(
			classLoader = new AwsClassLoader(),
			accessID = config.aws.accessID,
			secretKey = config.aws.secretKey,
			region = config.aws.region,
			queueName = config.aws.queue, // This component instance if QUEUE SPECIFIC.
			defaultWaitTime = 20,
			defaultVisibilityTimeout = 60
		);

		// This service is the TRANSLATION GLUE between the Amazon SQS client and the
		// application's business logic. However, it KNOWS NOTHING about how the queue
		// will be monitored on an ongoing basis.
		application.emailQueueService = new EmailQueueService(
			sqsClient = application.sqsClient,
			requestMetadata = application.requestMetadata,
			emailService = application.emailService
		);

		// For this demo, this scheduled task will be the only thing in the application
		// that manages the monitoring of the queue over the long-term. However, it
		// doesn't actually know anything about the queue, the emails, or how they are
		// integrated within the application - the scheduled task ONLY KNOWS about the
		// EmailQueueService component (and its ".processNewMessages()" method).
		schedule
			action = "update"
			task = "EmailQueueManager"
			operation = "HTTPRequest"
			url = "http://#cgi.server_name#:#cgi.server_port#/demos/tracing/email-queue-manager.cfm"
			startDate = "2021-09-10"
			startTime = "00:00 AM"
			interval = 10 // Every 10 seconds (smallest increment allowed in Lucee CFML).
		;

	}


	/**
	* I get called once when the request is being initialized.
	*/
	public void function onRequestStart() {

		// Setup the tracing ID for the rest of the request.
		application.requestMetadata.ensureRequestId();

		// If the INIT flag is defined, restart the application in order to refresh the
		// in-memory cache of components.
		if ( url.keyExists( "init" ) ) {

			applicationStop();
			location( url = cgi.script_name, addToken = false );

		}

	}

}
