<cfscript>

	// This template is being invoked as a ColdFusion Scheduled Task that fires every
	// 10-seconds (the smallest scheduled task increment in Lucee CFML). This means that
	// any given request will almost always be overlapping with the previous, still-
	// executing request. As such, let's use a no-error lock to synchronize our
	// monitoring of the color swatch queue.
	lock
		name = "color-swatch-queue-manager"
		type = "exclusive"
		timeout = 1
		throwOnTimeout = false
		{

		systemOutput( "Start polling color-swatch-queue for new messages.", true );

		// When we ask the queue service to process new messages, it only processes one
		// batch of new messages at a time. This way, we can separate the concern of
		// processing new messages from the concern of polling the queue over a long
		// period of time. Due to the constraints of the web server, requests timeout if
		// they run for too long. As such, we have to explicitly increase the timeout of
		// this page so that it doesn't get terminated forcefully by the server.
		// --
		// NOTE: For the demo, I'm using a relatively low-number so that as I edit this
		// template and I don't have to restart the server to kill this thread. But, in a
		// production setting, I would use a rather large number.
		maxRuntimeInSeconds = 100;
		maxTickCount = ( getTickCount() + ( maxRuntimeInSeconds * 1000 ) );

		// Increase the execution timeout for this web-server request.
		setting
			requestTimeout = maxRuntimeInSeconds
		;

		// Since each call to the queue service will only process a single batch of new
		// messages, we have to continually loop in order to keep polling the queue.
		while ( getTickCount() <= maxTickCount ) {

			systemOutput( "LOOP: Checking color-swatch-queue for new messages.", true );

			application.colorSwatchQueueService.processNewMessages();

		}

		systemOutput( "LOOP: Exiting long-polling while-loop.", true );

	}

	// If a previous instance of the scheduled task was still polling the message queue,
	// the lock will have failed to be obtained.
	if ( ! cflock.succeeded ) {

		systemOutput( "Lock failure, color-swatch-queue monitoring already in place.", true, true );

	}

</cfscript>
