<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
	xmlns="http://www.daisy.org/ns/z3998/authoring/"
	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="utf-8"/>
	
	<xsl:template match="z:frontmatter">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<toc>
				<h>Inhaltsverzeignis</h>
				<xsl:for-each select="//z:bodymatter//z:h">
					<entry><ref ref="{@xml:id}"/></entry>
				</xsl:for-each>
			</toc>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
