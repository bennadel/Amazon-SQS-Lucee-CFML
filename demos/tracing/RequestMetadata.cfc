component
	output = false
	hint = "I provide methods for access metadata and tracing information relating to the current request processing."
	{

	/**
	* I ensure that the "request.requestId" value exists. If it does not exist, it is
	* generated and assigned to the request scope. In either case, the final requestId
	* value is returned.
	* 
	* NOTE: This method should be called as the very first line of processing in an
	* inbound HTTP request so that all subsequent processing within the request is more
	* likely to have access to the same value.
	*/
	public string function ensureRequestId() {

		return( request.requestId ?: setRequestId( generateRequestId() ) );

	}


	/**
	* I generate a new requestId value.
	*/
	public string function generateRequestId() {

		return( "request-#createUuid().lcase()#" );

	}


	/**
	* I get the requestId for the current request context. If no requestId has been set
	* yet, this action generates and assigns a requestId.
	*/
	public string function getRequestId() {

		return( ensureRequestId() );

	}


	/**
	* I apply the given requestId to the current request context.
	*/
	public string function setRequestId( required string newRequestId ) {

		return( request.requestId = newRequestId );

	}

}
