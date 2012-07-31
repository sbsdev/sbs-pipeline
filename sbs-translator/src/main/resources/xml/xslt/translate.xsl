<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:louis="http://liblouis.org/liblouis"
	exclude-result-prefixes="xs louis">
	
	<xsl:output method="xml" encoding="utf-8"/>

	<xsl:variable name="table" select="string-join(
		('sbs-de-core6.cti',
		 'sbs-de-accents.cti',
		 'sbs-special.cti',
		 'sbs-whitespace.mod',
		 'sbs-de-letsign.mod',
		 'sbs-numsign.mod',
		 'sbs-litdigit-upper.mod',
		 'sbs-de-core.mod',
		 'sbs-de-g2-core.mod',
		 'sbs-special.mod'), ',')"/>

	<xsl:template match="/*">
		<xsl:copy>
			<xsl:sequence select="louis:translate($table, string(/*))"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
