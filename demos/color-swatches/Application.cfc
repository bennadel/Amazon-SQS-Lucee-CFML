component
	output = false
	hint = "I define the application settings and event handlers."
	{

	// Configure the application settings.
	this.name = "ColorSwatchesQueueDemo";
	this.applicationTimeout = createTimeSpan( 0, 1, 0, 0 );
	this.sessionManagement = false;
	this.setClientCookies = false;

	this.mappings = {
		"/swatches": "./swatches",
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

		// This service generates color swatches and KNOWS NOTHING about Amazon SQS.
		application.colorSwatchService = new ColorSwatchService();

		// This service interacts specifically with the "color-swatch-queue" but KNOWS
		// NOTHING about color watches, how they are used within this application, or how
		// the queue will be monitored on an ongoing basis.
		application.sqsClient = new SqsClient(
			classLoader = new AwsClassLoader(),
			accessID = config.aws.accessID,
			secretKey = config.aws.secretKey,
			region = config.aws.region,
			queueName = config.aws.queue, // This instance if QUEUE SPECIFIC.
			defaultWaitTime = 20,
			defaultVisibilityTimeout = 60
		);

		// This service is the TRANSLATION GLUE between the Amazon SQS client and the
		// application's business logic. However, it KNOWS NOTHING about how the queue
		// will be monitored on an ongoing basis.
		application.colorSwatchQueueService = new ColorSwatchQueueService(
			sqsClient = application.sqsClient,
			colorSwatchService = application.colorSwatchService
		);

		// For this demo, this scheduled task will be the only thing in the application
		// that manages the monitoring of the queue over the long-term. However, it
		// doesn't actually know anything about the queue, the color swatches, or how
		// they are used within the application - the scheduled task ONLY KNOWS about the
		// ColorSwatchQueueService component (and its ".processNewMessages()" method).
		schedule
			action = "update"
			task = "ColorSwatchQueueManager"
			operation = "HTTPRequest"
			url = "http://#cgi.server_name#:#cgi.server_port#/demos/color-swatches/color-swatch-queue-manager.cfm"
			startDate = "2021-09-10"
			startTime = "00:00 AM"
			interval = 10 // Every 10 seconds (smallest increment allowed in Lucee CFML).
		;

	}


	/**
	* I get called once when the request is being initialized.
	*/
	public void function onRequestStart() {

		// If the INIT flag is defined, restart the application in order to refresh the
		// in-memory cache of components.
		if ( url.keyExists( "init" ) ) {

			applicationStop();
			location( url = cgi.script_name, addToken = false );

		}

	}

}
