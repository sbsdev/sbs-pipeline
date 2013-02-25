<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
	xmlns="http://www.daisy.org/ns/z3998/authoring/"
	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="utf-8"/>
	
	<xsl:template match="z:h">
		<xsl:copy>
			<xsl:if test="not(@xml:id)">
				<xsl:attribute name="xml:id" select="generate-id()"/>
			</xsl:if>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
