component
	output = false
	hint = "I define the application settings and event handlers."
	{

	// Configure the application settings.
	this.name = "BigIntDemo";
	this.applicationTimeout = createTimeSpan( 0, 1, 0, 0 );
	this.sessionManagement = false;
	this.setClientCookies = false;

	this.datasources.testing = buildDatasource();
	this.datasource = "testing";

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I return the struct used to define the primary datasource.
	*/
	private struct function buildDatasource() {

		var connectionParams = [
			"useUnicode": "true",
			"characterEncoding": "UTF-8",
			"zeroDateTimeBehavior": "round",
			"serverTimezone": "Etc/UTC",
			"autoReconnect": "true",
			"allowMultiQueries": "true",
			"useLegacyDatetimeCode": "false",
			"tinyInt1isBit": "false",
			"useDynamicCharsetInfo": "false",
			// Maximum performance options:
			// https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-configuration-properties.html
			"cachePrepStmts": "true",
			"cacheCallableStmts": "true",
			"cacheServerConfiguration": "true",
			"useLocalSessionState": "true",
			"elideSetAutoCommits": "true",
			"alwaysSendSetIsolation": "false",
			"enableQueryTimeouts": "false"
		];

		var connectionStringParams = connectionParams
			.reduce(
				( reduction, key, value ) => {

					return( reduction.append( "#key#=#value#") );

				},
				[]
			)
			.toList( "&" )
		;

		return({
			class: "com.mysql.cj.jdbc.Driver",
			connectionString: 'jdbc:mysql://127.0.0.1:3306/outbox_demo?#connectionStringParams#',
			username: "sqsdemo",
			password: "password"
		});

	}

}
