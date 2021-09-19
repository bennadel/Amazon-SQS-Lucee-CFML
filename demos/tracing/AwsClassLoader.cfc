component
	output = false
	hint = "I provide class loading methods for the Amazon Web Services Java SDK."
	{

	public void function init() {

		// NOTE: One of the coolest features of Lucee CFML is the fact that it can create
		// Java objects on-the-fly from a given set of JAR files and directories. I mean,
		// how awesome is that?! These JAR files were downloaded from Maven:
		// --
		// https://mvnrepository.com/artifact/com.amazonaws/aws-java-sdk-sqs/1.12.60
		variables.jarPaths = [ expandPath( "/vendor" ) ];

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I load the given class out of the local AWS Java SDK JAR paths.
	*/
	public any function load( required string className ) {

		return( createObject( "java", className, jarPaths ) );

	}

}
