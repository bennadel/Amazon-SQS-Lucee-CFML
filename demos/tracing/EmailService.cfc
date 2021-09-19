component
	output = false
	hint = "I provide methods for sending transactional emails."
	{

	/**
	* I initialize the email service.
	*/
	public void function init( required any requestMetadata ) {

		variables.requestMetadata = arguments.requestMetadata;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I send out a new user invitation email.
	*/
	public void function sendInvitation( required string toEmail ) {

		// In this demo, we don't actually have an email API configured. As such, we'll
		// just log to the console as a simulation.
		systemOutput( "Sending invitation to [#toEmail#].", true );
		// As part of the outgoing email simulation, let's include a custom SMTP header
		// for our tracing ID. Since I use PostMark as my transactional email SaaS
		// provider, I'm going to lean on their custom metadata headers. We'll be able to
		// propagate this value through any PostMark webhooks.
		systemOutput( "> X-PM-Metadata-Request-ID: [#requestMetadata.getRequestId()#]", true );

	}

}
