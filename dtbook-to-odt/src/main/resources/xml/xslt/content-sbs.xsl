<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
		xmlns:xforms="http://www.w3.org/2002/xforms"
		xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
		xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
		xmlns:dom="http://www.w3.org/2001/xml-events"
		xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
		xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
		xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
		xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
		xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
		xmlns:math="http://www.w3.org/1998/Math/MathML"
		xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
		xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
		xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
		xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
		xmlns:brl="http://www.daisy.org/z3986/2009/braille/"
		exclude-result-prefixes="#all">
	
	<xsl:import href="content.xsl"/>
	
	<!-- ======= -->
	<!-- SIDEBAR -->
	<!-- ======= -->
	
	<xsl:template match="dtb:sidebar" mode="office:text text:section">
		<xsl:next-match>
			<xsl:with-param name="sidebar_announcement" tunnel="yes">
				<dtb:p class="announcement" xml:lang="en">[Begin of sidebar]</dtb:p>
			</xsl:with-param>
			<xsl:with-param name="sidebar_deannouncement" tunnel="yes">
				<dtb:p class="deannouncement" xml:lang="en">[End of sidebar]</dtb:p>
			</xsl:with-param>
		</xsl:next-match>
	</xsl:template>
	
	<!-- ============= -->
	<!-- BRAILLE STUFF -->
	<!-- ============= -->
	
	<xsl:template match="brl:homograph|brl:place|brl:name|brl:v-form" mode="text:p text:h">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<xsl:template match="brl:running-line|brl:toc-line|brl:volume|brl:when-braille" mode="#all"/>
	
	<xsl:template match="brl:select|brl:otherwise" mode="#all">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
</xsl:stylesheet>
