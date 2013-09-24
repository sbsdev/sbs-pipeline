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
		xmlns:f="functions"
		exclude-result-prefixes="#all">
	
	<xsl:import href="content.xsl"/>
	
	<!-- ======= -->
	<!-- SIDEBAR -->
	<!-- ======= -->
	<xsl:param name="image_dpi" select="600"/>
	
	
	<!-- ======== -->
	<!-- HEADINGS -->
	<!-- ======== -->
	
	<xsl:template match="dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6" mode="office:text text:list-item text:section">
		<xsl:call-template name="text:empty-p"/>
		<xsl:next-match/>
		<xsl:call-template name="text:empty-p"/>
	</xsl:template>
	
	
	<!-- ===== -->
	<!-- LISTS -->
	<!-- ===== -->
	
	<xsl:template match="dtb:list" mode="office:text text:section table:table-cell">
		<xsl:call-template name="text:empty-p"/>
		<xsl:next-match/>
		<xsl:call-template name="text:empty-p"/>
	</xsl:template>
	
	<!-- ===== -->
	<!-- NOTES -->
	<!-- ===== -->
	
	<xsl:template match="dtb:noteref" mode="text:p text:h text:span">
		<xsl:variable name="id" select="translate(@idref,'#','')"/>
		<xsl:variable name="asterisk" as="text()?">
			<xsl:if test="not(starts-with(normalize-space(string(.)), '*'))">
				<xsl:text>*</xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:call-template name="text:span">
			<xsl:with-param name="lang" select="f:lang(.)" tunnel="yes"/>
			<xsl:with-param name="text_style" as="xs:string?" tunnel="yes">
				<xsl:apply-templates select="." mode="text-style"/>
			</xsl:with-param>
			<xsl:with-param name="apply-templates" select="($asterisk, *|text())"/>
		</xsl:call-template>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="dtb:find-note($id)" mode="#current">
			<xsl:with-param name="skip_notes" select="false()" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="dtb:annoref" mode="text:p text:h text:span">
		<xsl:variable name="id" select="translate(@idref,'#','')"/>
		<xsl:variable name="asterisk" as="text()">
			<xsl:text>*</xsl:text>
		</xsl:variable>
		<xsl:call-template name="text:span">
			<xsl:with-param name="lang" select="f:lang(.)" tunnel="yes"/>
			<xsl:with-param name="text_style" as="xs:string?" tunnel="yes">
				<xsl:apply-templates select="." mode="text-style"/>
			</xsl:with-param>
			<xsl:with-param name="apply-templates" select="(*|text(), $asterisk)"/>
		</xsl:call-template>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="dtb:find-annotation($id)" mode="#current">
			<xsl:with-param name="skip_notes" select="false()" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="dtb:note|dtb:annotation" mode="text:p text:h text:span">
		<xsl:param name="skip_notes" as="xs:boolean" select="true()" tunnel="yes"/>
		<xsl:choose>
			<xsl:when test="not($skip_notes)">
				<xsl:variable name="open_bracket" as="text()">
					<xsl:text>(</xsl:text>
				</xsl:variable>
				<xsl:variable name="asterisk" as="text()?">
					<xsl:if test="not(starts-with(normalize-space(string(.)), '*'))">
						<xsl:text>*</xsl:text>
					</xsl:if>
				</xsl:variable>
				<xsl:variable name="close_bracket" as="text()">
					<xsl:text>)</xsl:text>
				</xsl:variable>
				<xsl:call-template name="text:span">
					<xsl:with-param name="lang" select="f:lang(.)" tunnel="yes"/>
					<xsl:with-param name="text_style" as="xs:string?" tunnel="yes">
						<xsl:apply-templates select="." mode="text-style"/>
					</xsl:with-param>
					<xsl:with-param name="skip_notes" select="true()" tunnel="yes"/>
					<xsl:with-param name="apply-templates" select="($open_bracket, $asterisk, *|text(), $close_bracket)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="dtb:annotation/dtb:p" as="xs:boolean" mode="is-block-element">
		<xsl:sequence select="false()"/>
	</xsl:template>
	
	<xsl:template match="dtb:annotation/dtb:p" mode="text:p text:h text:span">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	
	<!-- ====== -->
	<!-- IMAGES -->
	<!-- ====== -->
	
	<xsl:template match="dtb:imggroup/dtb:caption" mode="office:text text:section table:table-cell">
		<xsl:call-template name="text:empty-p"/>
		<xsl:next-match>
			<xsl:with-param name="caption_suffix" tunnel="yes">
				<xsl:text>:</xsl:text>
			</xsl:with-param>
		</xsl:next-match>
	</xsl:template>
	
	<!-- ======== -->
	<!-- PRODNOTE -->
	<!-- ======== -->
	
	<xsl:template match="dtb:prodnote" mode="office:text text:section">
		<xsl:next-match>
			<xsl:with-param name="prodnote_announcement" tunnel="yes">
				<dtb:p class="announcement" xml:lang="de">[Anmerkung e-text]</dtb:p>
			</xsl:with-param>
		</xsl:next-match>
	</xsl:template>
	
	<!-- ========= -->
	<!-- EXERCISES -->
	<!-- ========= -->
	
	<xsl:template match="dtb:span[@class=('answer','answer-1','box')]" mode="text:p text:span">
		<xsl:call-template name="text:span">
			<xsl:with-param name="lang" select="'none'" tunnel="yes"/>
			<xsl:with-param name="sequence">
				<xsl:text>_..</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ==== -->
	<!-- MATH -->
	<!-- ==== -->
	
	<xsl:template match="math:math" mode="text:p text:h text:span">
		<xsl:next-match/>
		<xsl:call-template name="text:span">
			<xsl:with-param name="text_style" select="style:name('dtb:span_asciimath')" tunnel="yes"/>
			<xsl:with-param name="sequence" select="math:semantics/math:annotation[@encoding='ASCIIMath']/text()"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ============== -->
	<!-- PAGE NUMBERING -->
	<!-- ============== -->
	
	<xsl:template match="dtb:pagenum" mode="office:text text:section">
		<xsl:next-match>
			<xsl:with-param name="pagenum_prefix" tunnel="yes">
				<dtb:span xml:lang="de">\\Seite </dtb:span>
			</xsl:with-param>
		</xsl:next-match>
	</xsl:template>
	
	<!-- ==================== -->
	<!-- OTHER BLOCK ELEMENTS -->
	<!-- ==================== -->
	
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
	
	<xsl:template match="dtb:blockquote|dtb:epigraph|dtb:poem" mode="office:text text:section">
		<xsl:call-template name="text:empty-p"/>
		<xsl:next-match/>
		<xsl:call-template name="text:empty-p"/>
	</xsl:template>
	
	<!-- ====================== -->
	<!-- INLINE ELEMENTS & TEXT -->
	<!-- ====================== -->
	
	<xsl:template match="dtb:linenum" mode="text:p text:h text:span">
		<xsl:variable name="prefix" as="text()">
			<xsl:text>Z</xsl:text>
		</xsl:variable>
		<xsl:call-template name="text:span">
			<xsl:with-param name="lang" select="f:lang(.)" tunnel="yes"/>
			<xsl:with-param name="text_style" as="xs:string?" tunnel="yes">
				<xsl:apply-templates select="." mode="text-style"/>
			</xsl:with-param>
			<xsl:with-param name="apply-templates" select="($prefix, *|text())"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ============= -->
	<!-- BRAILLE STUFF -->
	<!-- ============= -->
	
	<xsl:template match="brl:homograph|brl:place|brl:name|brl:v-form|brl:num|brl:emph" mode="text:p text:h">
		<xsl:apply-templates mode="#current">
			<xsl:with-param name="lang" select="f:lang(.)" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="brl:running-line|brl:toc-line|brl:volume|brl:when-braille|brl:separator"
	              mode="#all"/>
	
	<xsl:template match="brl:select|brl:otherwise" mode="#all">
		<xsl:apply-templates mode="#current">
			<xsl:with-param name="lang" select="f:lang(.)" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ===== -->
	<!-- STYLE -->
	<!-- ===== -->
	
	<xsl:template match="dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6" mode="paragraph-style">
		<xsl:sequence select="concat('Überschrift_20_', substring(local-name(.),2,1))"/>
	</xsl:template>
	
	<xsl:template match="dtb:list|dtb:dl" mode="list-style">
		<xsl:sequence select="'LFO3'"/>
	</xsl:template>
	
	<xsl:template match="dtb:list|dtb:dl" mode="paragraph-style">
		<xsl:sequence select="'Liste1'"/>
	</xsl:template>
	
	<xsl:template match="dtb:a[@href]" mode="text-style">
		<xsl:sequence select="'Hyperlink'"/>
	</xsl:template>
	
	<xsl:template match="dtb:span[@class=('exercisenumber','exercisepart')]" mode="text-style">
		<xsl:sequence select="style:name(concat('dtb:span_', @class))"/>
	</xsl:template>
	
	<xsl:template match="dtb:prodnote|dtb:th|dtb:caption|dtb:pagenum" mode="paragraph-style">
		<xsl:sequence select="dtb:style-name(.)"/>
	</xsl:template>
	
	<xsl:template match="dtb:sub|dtb:sup|dtb:strong|dtb:em|dtb:dt|dtb:note|dtb:annotation|
	                     dtb:cite|dtb:q|dtb:author|dtb:title|dtb:acronym|dtb:abbr|dtb:kbd|
	                     dtb:code|dtb:samp|dtb:linenum"
	              mode="text-style">
		<xsl:sequence select="dtb:style-name(.)"/>
	</xsl:template>
	
	<xsl:template match="dtb:*" as="xs:string?" mode="text-style" priority="-1.1">
		<xsl:call-template name="inherit-text-style"/>
	</xsl:template>
	
	<xsl:template match="dtb:*" as="xs:string?" mode="paragraph-style" priority="-1.1">
		<xsl:call-template name="inherit-paragraph-style"/>
	</xsl:template>
	
	<xsl:template match="dtb:*" as="xs:string?" mode="list-style" priority="-1.1">
		<xsl:call-template name="inherit-list-style"/>
	</xsl:template>
	
	<!-- ========= -->
	<!-- UTILITIES -->
	<!-- ========= -->
	
	<xsl:template name="text:empty-p">
		<xsl:call-template name="text:p">
			<xsl:with-param name="sequence">
				<xsl:text/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>
