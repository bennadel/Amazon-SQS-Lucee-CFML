component
	output = false
	hint = "I generate color swatch images from 6-digit hexadecimal color values."
	{

	/**
	* I initialize the color swatch service.
	*/
	public void function init() {

		variables.swatchWidth = 200;
		variables.swatchHeight = 150;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I generate and return a color swatch image for the given hexadecimal value.
	*/
	public struct function generateSwatch( required string hexColor ) {

		var normalizedHex = ( "##" & hexColor.right( 6 ).ucase() );
		var annotationFont = {
			font: "monospace",
			size: 16
		};
		var labelWidth = 92;
		var labelHeight = 36;

		var swatch = imageNew( "", swatchWidth, swatchHeight, "rgb", normalizedHex )
			.setAntialiasing( true )
			.setDrawingColor( "ffffff" )
			.drawRect( 0, ( swatchHeight - labelHeight ), labelWidth, labelHeight, true )
			.setDrawingColor( "000000" )
			.drawText( normalizedHex, 10, ( swatchHeight - 11 ), annotationFont )
		;

		return( swatch );

	}


	/**
	* I generate a color swatch image for the given hexadecimal value and save it to the
	* given filename.
	*/
	public void function generateSwatchFile(
		required string hexColor,
		required string destination
		) {

		var quality = 1;
		var overwrite = true;
		var noMetaData = true;

		// NOTE: Instead of passing-in variables to the .write() method, I would normally
		// just used named-arguments. However, it seems that attempting to call the
		// .write() method with named arguments throws an error. Perhaps the documented
		// argument names are wrong.
		generateSwatch( hexColor )
			.write( destination, quality, overwrite, noMetaData )
		;

	}

}
