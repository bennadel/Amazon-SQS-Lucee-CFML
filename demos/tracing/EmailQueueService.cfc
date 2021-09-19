component
	output = false
	hint = "I provide methods for interacting with the email-queue - I GLUE the concept of the queue to larger application context."
	{

	/**
	* I initialize the email queue service with the given SQS client. Note that the SQS
	* client is assumed to be created specifically for the email-queue in Amazon SQS.
	*/
	public void function init(
		required any sqsClient,
		required any requestMetadata,
		required any emailService
		) {

		variables.sqsClient = arguments.sqsClient;
		variables.requestMetadata = arguments.requestMetadata;
		variables.emailService = arguments.emailService;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I create and persist a new message for processing the given transactional email.
	*/
	public void function addMessage(
		required string emailType,
		required struct emailData
		) {

		systemOutput( "Queuing transactional email", true );
		systemOutput( "> Request ID: [#application.requestMetadata.getRequestId()#]", true );

		// The QUEUE is DECOUPLING the incoming request from the subsequent processing.
		// However, the overall workflow is still inherently linked. In order to make
		// debugging this workflow easier, we're going to propagate the request tracing
		// ID as an ATTRIBUTE on the SQS queue message. This way, we can tie the message
		// processing to the message generation.
		sqsClient.sendMessage(
			serializeJson({
				emailType: emailType,
				emailData: emailData
			}),
			// Sending as an ATTRIBUTE, not as part of the core message. This is not a
			// critical distinction - I probably just wanted a reason to use the
			// attributes collection :D
			{
				requestId: requestMetadata.getRequestId()
			}
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
	* rest of the application logic. In this case, we're sending transactional emails.
	*/
	public void function processMessage( required struct message ) {

		var body = deserializeJson( message.body );
		var emailType = body.emailType;
		var emailData = body.emailData;

		// This service only knows how to GLUE the message queue to the rest of the
		// application, it doesn't know what goes on under the hood. As such, for each
		// message, we want to override the current request ID context so that lower-
		// level processing can carry on (and consume request metadata) as if it were
		// part of the original request. This will make the overall workflow easier to
		// debug in the future.
		systemOutput( "Overriding Request ID context: [#message.attributes.requestId#]", true );
		requestMetadata.setRequestId( message.attributes.requestId );

		switch ( emailType ) {
			case "invitation":
				emailService.sendInvitation( emailData.toEmail );
			break;
			default:
				systemOutput( "Unknown email type: [#emailType#]", true, true );
			break;
		}

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

				systemOutput( "An email-queue message failed to process.", true, true );
				systemOutput( "> Request ID: [#requestMetadata.getRequestId()#]", true, true );
				systemOutput( message, true, true );
				systemOutput( error, true, true );

			}

			deleteMessage( message );

		}

	}

}
