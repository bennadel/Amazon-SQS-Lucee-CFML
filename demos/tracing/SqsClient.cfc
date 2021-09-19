component
	output = false
	hint = "I provide a simplified API over Amazon's Java SDK for Simple Queue Service (SQS)."
	{

	/**
	* I initialize an SQS client for the given queue and credentials.
	*/
	public void function init(
		required any classLoader,
		required string accessID,
		required string secretKey,
		required string region,
		required string queueName
		numeric defaultWaitTime = 0,
		numeric defaultVisibilityTimeout = 20
		) {

		variables.classLoader = arguments.classLoader;
		variables.queueName = arguments.queueName;
		// NOTE: Timeouts are provided in Seconds.
		variables.defaultWaitTime = arguments.defaultWaitTime;
		variables.defaultVisibilityTimeout = arguments.defaultVisibilityTimeout;

		var basicCredentials = classLoader
			.load( "com.amazonaws.auth.BasicAWSCredentials" )
			.init( accessID, secretKey )
		;
		var credentialsProvider = classLoader
			.load( "com.amazonaws.auth.AWSStaticCredentialsProvider" )
			.init( basicCredentials )
		;

		variables.sqsClient = classLoader
			.load( "com.amazonaws.services.sqs.AmazonSQSClientBuilder" )
			.standard()
			.withCredentials( credentialsProvider )
			.withRegion( region )
			.build()
		;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I delete the message with the given receipt handle from the queue.
	*/
	public void function deleteMessage( required string receiptHandle ) {

		sqsClient.deleteMessage( queueName, receiptHandle );

	}


	/**
	* I receive up to the max number of messages from the queue.
	*/
	public array function receiveMessages(
		numeric maxNumberOfMessages = 1,
		numeric waitTime = defaultWaitTime,
		numeric visibilityTimeout = defaultVisibilityTimeout
		) {

		var outboundMessageRequest = classLoader
			.load( "com.amazonaws.services.sqs.model.ReceiveMessageRequest" )
			.init( queueName )
			.withMaxNumberOfMessages( maxNumberOfMessages )
			// NOTE: Timeouts are provided in Seconds.
			.withWaitTimeSeconds( waitTime )
			.withVisibilityTimeout( visibilityTimeout )
			// For the time-being, we're going to assume that all attributes stored with
			// the message are necessary for the processing. As such, we'll always return
			// all attributes in our response.
			.withMessageAttributeNames([ "All" ])
		;

		var inboundMessageResponse = sqsClient.receiveMessage( outboundMessageRequest );

		var messages = inboundMessageResponse.getMessages().map(
			( inboundMessage ) => {

				return({
					receiptHandle: inboundMessage.getReceiptHandle(),
					attributes: decodeMessageAttributes( inboundMessage.getMessageAttributes() ),
					body: inboundMessage.getBody()
				});

			}
		);

		return( messages );

	}


	/**
	* I send the given message with the optional attributes. Attributes can be binary or
	* simple. All simple values are converted to strings. Returns the ID of the message.
	*/
	public string function sendMessage(
		required string message,
		struct messageAttributes = {}
		) {

		var outboundMessageRequest = classLoader
			.load( "com.amazonaws.services.sqs.model.SendMessageRequest" )
			.init( queueName, message )
			.withMessageAttributes( encodeMessageAttributes( messageAttributes ) )
		;

		var inboundMessageResponse = sqsClient.sendMessage( outboundMessageRequest );

		return( inboundMessageResponse.getMessageId() );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I decode the given inbound message attributes into a normal ColdFusion struct.
	*/
	private struct function decodeMessageAttributes( required struct inboundAttributes ) {

		var decodedAttributes = inboundAttributes.map(
			( key, value ) => {

				if ( value.getDataType() == "Binary" ) {

					return( value.getBinaryValue() );

				} else {

					return( value.getStringValue() );

				}

			}
		);

		return( decodedAttributes );

	}


	/**
	* I encode the given outbound message attributes for use in the Amazon SDK.
	*/
	private struct function encodeMessageAttributes( required struct outboundAttributes ) {

		var encodedAttributes = outboundAttributes.map(
			( key, value ) => {

				var encodedValue = classLoader
					.load( "com.amazonaws.services.sqs.model.MessageAttributeValue" )
					.init()
				;

				if ( isBinary( value ) ) {

					encodedValue.setDataType( "Binary" );
					encodedValue.setBinaryValue( value );

				} else {

					encodedValue.setDataType( "String" );
					encodedValue.setStringValue( javaCast( "string", value ) );

				}

				return( encodedValue );

			}
		);

		return( encodedAttributes );

	}

}
