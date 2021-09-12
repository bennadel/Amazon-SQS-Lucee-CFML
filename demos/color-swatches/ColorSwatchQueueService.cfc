component
	output = false
	hint = "I provide methods for interacting with the color-swatch-queue - I GLUE the concept of the queue to larger application context."
	{

	/**
	* I initialize the color swatch queue service with the given SQS client. Note that
	* the SQS client is assumed to be created specifically for the color-swatch-queue
	* in Amazon SQS.
	*/
	public void function init(
		required any sqsClient,
		required any colorSwatchService
		) {

		variables.sqsClient = arguments.sqsClient;
		variables.colorSwatchService = arguments.colorSwatchService;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create and persist a new message for processing the given HEX color.
	*/
	public void function addMessage( required string hexColor ) {

		sqsClient.sendMessage(
			serializeJson({
				hexColor: hexColor
			})
		);

	}


	/**
	* I delete the given message from the queue.
	*/
	public void function deleteMessage( required struct message ) {

		sqsClient.deleteMessage( message.receiptHandle );

	}


	/**
	* I process the given message, translating the message into an interaction with the
	* rest of the application logic. In this case, we're generating a color swatch image
	* for the hexColor contained within the SQS message.
	*/
	public void function processMessage( required struct message ) {

		var body = deserializeJson( message.body );
		var hexColor = body.hexColor;
		var filename = getFilenameForHex( hexColor );
		var destination = expandPath( "/swatches/#filename#" );

		systemOutput( "Generating color swatch for ###hexColor.ucase()#", true );

		colorSwatchService.generateSwatchFile( hexColor, destination );

	}


	/**
	* I look for new messages on the queue.
	* 
	* CAUTION: While this request will block-and-wait for new messages to arrive (if
	* waitTime argument is non-zero), it will do so only once. We are not putting the
	* onus of continual polling inside this component. Instead, we are placing that
	* responsibility in another area of the app (in this demo, a scheduled task).
	*/
	public void function processNewMessages(
		numeric maxNumberOfMessages = 3,
		numeric waitTime = 20,
		numeric visibilityTimeout = 10
		) {

		var messages = sqsClient.receiveMessages( argumentCollection = arguments );

		for ( var message in messages ) {

			// Since we are gathering more than one message at a time in this demo (in
			// order to reduce the dollars-and-cents cost of making API calls to Amazon
			// SQS), we want to wrap each message processing in a try-catch so that one
			// "poison pill" doesn't prevent the other messages from being processed.
			try {

				processMessage( message );

			} catch ( any error ) {

				systemOutput( "A color-swatch-queue message failed to process.", true, true );
				systemOutput( message, true, true );
				systemOutput( error, true, true );

			}

			deleteMessage( message );

		}

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I generate a natural-sort-friendly filename for the given hexColor.
	*/
	private string function getFilenameForHex( required string hexColor ) {

		// For this demo, we know that the files are going to be read directly off of the
		// local file-system. As such, if we prefix each color swatch with a date/time
		// stamp, we know that we can list the newest swatches first using an alpha-
		// numeric sort on the file names.
		return( now().dateTimeFormat( "yyyy-mm-dd HH-nn-ss" ) & "-" & hexColor.right( 6 ) & ".png" );

	}

}
