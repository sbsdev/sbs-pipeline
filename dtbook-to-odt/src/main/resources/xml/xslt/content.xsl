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
		xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
		xmlns:d="http://www.daisy.org/ns/pipeline/data"
		exclude-result-prefixes="#all">
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
	
	<!-- ======== -->
	<!-- TEMPLATE -->
	<!-- ======== -->
	
	<xsl:template match="/">
		<xsl:apply-templates select="/*" mode="template"/>
	</xsl:template>
	
	<xsl:template match="@*|node()" mode="template">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="template"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="/office:document-content/office:body/office:text/text:sequence-decls" mode="template">
		<xsl:sequence select="."/>
		<xsl:apply-templates select="following-sibling::*" mode="template"/>
		<xsl:apply-templates select="collection()[2]/*" mode="office:text"/>
	</xsl:template>
	
	<!-- =================== -->
	<!-- STRUCTURAL ELEMENTS -->
	<!-- =================== -->
	
	<xsl:template match="dtb:dtbook" mode="office:text">
		<xsl:apply-templates mode="#current">
			<xsl:with-param name="paragraph_style" select="'Text_20_body'" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="dtb:book|dtb:frontmatter|dtb:bodymatter|
	                     dtb:level1|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6"
	              mode="office:text">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<!-- ======== -->
	<!-- HEADINGS -->
	<!-- ======== -->
	
	<xsl:template match="dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6" mode="office:text text:list-item text:section">
		<xsl:call-template name="text:h">
			<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
			<xsl:with-param name="text:outline-level" select="number(substring(local-name(.),2,1))"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ========== -->
	<!-- PARAGRAPHS -->
	<!-- ========== -->
	
	<xsl:template match="dtb:p" mode="office:text text:section text:list-item table:table-cell">
		<xsl:param name="paragraph_style" as="xs:string?" tunnel="yes"/>
		<xsl:call-template name="text:p">
			<xsl:with-param name="text:style-name" select="$paragraph_style"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ===== -->
	<!-- LISTS -->
	<!-- ===== -->
	
	<xsl:template match="dtb:list" mode="office:text text:section">
		<xsl:element name="text:list">
			<xsl:attribute name="text:style-name" select="dtb:style-name(.)"/>
			<xsl:apply-templates mode="text:list"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:list" mode="text:list-item">
		<xsl:element name="text:list">
			<xsl:apply-templates mode="text:list"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:li" mode="text:list">
		<xsl:element name="text:list-item">
			<xsl:choose>
				<xsl:when test="dtb:p">
					<xsl:apply-templates mode="text:list-item">
						<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="text:p">
						<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<!-- ====== -->
	<!-- TABLES -->
	<!-- ====== -->
	
	<xsl:template match="dtb:table" mode="office:text text:section">
		<xsl:apply-templates select="dtb:caption" mode="#current"/>
		<xsl:element name="table:table">
			<xsl:attribute name="table:name" select="concat('dtb:table#', count(preceding::dtb:table) + 1)"/>
			<xsl:element name="table:table-column">
				<xsl:attribute name="table:number-columns-repeated" select="max(.//dtb:tr/count(dtb:td|dtb:th))"/>
			</xsl:element>
			<xsl:apply-templates mode="table:table" select="dtb:thead"/>
			<xsl:apply-templates mode="table:table" select="*[not(self::dtb:thead or self::dtb:tfoot or self::dtb:caption)]|text()"/>
			<xsl:apply-templates mode="table:table" select="dtb:tfoot"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:thead" mode="table:table">
		<xsl:element name="table:table-header-rows">
			<xsl:apply-templates mode="table:table-header-rows"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:tbody|dtb:tfoot" mode="table:table">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<xsl:template match="dtb:tr" mode="table:table table:table-header-rows">
		<xsl:element name="table:table-row">
			<xsl:apply-templates mode="table:table-row"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:td|dtb:th" mode="table:table-row">
		<xsl:element name="table:table-cell">
			<xsl:attribute name="office:value-type" select="'string'"/>
			<xsl:choose>
				<xsl:when test="dtb:p">
					<xsl:apply-templates mode="table:table-cell">
						<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="text:p">
						<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:table/dtb:caption" mode="office:text text:section">
		<xsl:call-template name="text:p">
			<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ===== -->
	<!-- NOTES -->
	<!-- ===== -->
	
	<!-- ==================== -->
	<!-- OTHER BLOCK ELEMENTS -->
	<!-- ==================== -->
	
	<xsl:template match="dtb:sidebar" mode="office:text text:section">
		<xsl:call-template name="text:section">
			<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
			<xsl:with-param name="number" select="count(preceding::dtb:sidebar) + 1"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="dtb:blockquote" mode="office:text text:section">
		<xsl:apply-templates mode="#current">
			<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ====== -->
	<!-- IMAGES -->
	<!-- ====== -->
	
	<xsl:template match="dtb:imggroup" mode="office:text text:section">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<!-- FIXME: svg:width, svg:height ?? -->
	
	<xsl:template match="dtb:img" mode="office:text text:section">
		<xsl:variable name="src" select="resolve-uri(@src, base-uri(.))"/>
		<xsl:element name="text:p">
			<xsl:attribute name="text:style-name" select="dtb:style-name(.)"/>
			<xsl:element name="draw:frame">
				<xsl:attribute name="draw:name" select="concat('dtb:img#', count(preceding::dtb:img) + 1)"/>
				<xsl:attribute name="draw:style-name" select="dtb:style-name(.)"/>
				<xsl:attribute name="text:anchor-type" select="'as-char'"/>
				<xsl:attribute name="draw:z-index" select="'0'"/>
				<xsl:element name="draw:image">
					<xsl:attribute name="xlink:href"
					               select="pf:relativize-uri(
					                         collection()[3]//d:file[resolve-uri(@original-href,base-uri(.))=$src]/resolve-uri(@href,base-uri(.)),
					                         collection()[1]/*/base-uri(.))"/>
					<xsl:attribute name="xlink:type" select="'simple'"/>
					<xsl:attribute name="xlink:show" select="'embed'"/>
					<xsl:attribute name="xlink:actuate" select="'onLoad'"/>
					<xsl:attribute name="svg:width" select="'25%'"/>
					<xsl:attribute name="svg:height" select="'25%'"/>
					<xsl:attribute name="svg:y" select="'0in'"/>
				</xsl:element>
				<xsl:if test="@alt">
					<xsl:element name="svg:title">
						<xsl:sequence select="string(@alt)"/>
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:imggroup/dtb:caption" mode="office:text text:section">
		<xsl:call-template name="text:p">
			<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ==== -->
	<!-- MATH -->
	<!-- ==== -->
	
	<!-- ================= -->
	<!-- TABLE OF CONTENTS -->
	<!-- ================= -->
	
	<!-- ============== -->
	<!-- PAGE NUMBERING -->
	<!-- ============== -->
	
	<xsl:template match="dtb:pagenum" mode="#all">
	</xsl:template>
	
	<!-- ====================== -->
	<!-- INLINE ELEMENTS & TEXT -->
	<!-- ====================== -->
	
	<xsl:template match="dtb:span|dtb:sent|dtb:em|dtb:strong|dtb:abbr|dtb:a|dtb:acronym" mode="text:p text:h">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<xsl:template match="dtb:br" mode="text:p text:h">
		<text:line-break/>
	</xsl:template>
	
	<xsl:template match="text()" mode="text:p text:h">
		<xsl:sequence select="."/>
	</xsl:template>
	
	<xsl:template match="text()" mode="#all" priority="-1">
		<xsl:choose>
			<xsl:when test="normalize-space(.)=''">
				<xsl:sequence select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="TERMINATE"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ============= -->
	<!-- BRAILLE STUFF -->
	<!-- ============= -->
	
	<xsl:template match="brl:homograph|brl:place|brl:name|brl:v-form" mode="text:p text:h">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<xsl:template match="brl:running-line|brl:toc-line|brl:volume|brl:when-braille" mode="#all">
		<xsl:call-template name="skip"/>
	</xsl:template>
	
	<xsl:template match="brl:select|brl:otherwise" mode="#all">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<!-- =============== -->
	<!-- EVERYTHING ELSE -->
	<!-- =============== -->
	
	<xsl:template match="dtb:head" mode="#all">
		<xsl:call-template name="skip"/>
	</xsl:template>
	
	<xsl:template match="*" mode="office:text text:section text:list-item table:table-cell">
		<xsl:element name="text:p">
			<xsl:attribute name="text:style-name" select="'ERROR'"/>
			<xsl:call-template name="FIXME"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="*" mode="text:p">
		<xsl:element name="text:span">
			<xsl:attribute name="text:style-name" select="'ERROR'"/>
			<xsl:call-template name="FIXME"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="*" mode="#all" priority="-1">
		<xsl:call-template name="TERMINATE"/>
	</xsl:template>
	
	<xsl:template match="@*" mode="#all" priority="-1"/>
	
	<!-- ========= -->
	<!-- UTILITIES -->
	<!-- ========= -->
	
	<xsl:template name="text:p">
		<xsl:param name="text:style-name" as="xs:string?"/>
		<xsl:element name="text:p">
			<xsl:attribute name="text:style-name" select="($text:style-name, 'Standard')[1]"/>
			<xsl:apply-templates mode="text:p"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="text:h">
		<xsl:param name="text:style-name" as="xs:string?"/>
		<xsl:param name="text:outline-level" as="xs:double"/>
		<xsl:element name="text:h">
			<xsl:attribute name="text:outline-level" select="$text:outline-level"/>
			<xsl:attribute name="text:style-name" select="($text:style-name, concat('Heading_20_', $text:outline-level))[1]"/>
			<xsl:apply-templates mode="text:h"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="text:section">
		<xsl:param name="text:style-name" as="xs:string"/>
		<xsl:param name="number" as="xs:double"/>
		<xsl:element name="text:section">
			<xsl:attribute name="text:name" select="concat(style:display-name($text:style-name), '#', $number)"/>
			<xsl:attribute name="text:style-name" select="$text:style-name"/>
			<xsl:apply-templates mode="text:section"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="office:annotation">
		<xsl:param name="text" as="xs:string"/>
		<xsl:element name="office:annotation">
			<xsl:element name="dc:creator">
				<xsl:text>sbs:dtbook-to-odt</xsl:text>
			</xsl:element>
			<xsl:element name="dc:date">
				<xsl:sequence select="current-dateTime()"/>
			</xsl:element>
			<xsl:element name="text:p">
				<xsl:element name="text:span">
					<xsl:sequence select="$text"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- ====================================================== -->
	
	<xsl:template name="skip">
		<xsl:message>
			<xsl:text>Skipping node </xsl:text>
			<xsl:sequence select="dtb:node-trace(.)"/>
		</xsl:message>
	</xsl:template>
	
	<xsl:template name="FIXME">
		<xsl:message>
			<xsl:text>FIXME!! </xsl:text>
			<xsl:sequence select="dtb:node-trace(.)"/>
		</xsl:message>
		<xsl:call-template name="office:annotation">
			<xsl:with-param name="text" select="dtb:node-trace(.)"/>
		</xsl:call-template>
		<xsl:text>FIXME!!</xsl:text>
	</xsl:template>

	<xsl:template name="TERMINATE">
		<xsl:message terminate="yes">
			<xsl:text>FIXME!! </xsl:text>
			<xsl:sequence select="dtb:node-trace(.)"/>
		</xsl:message>
	</xsl:template>
	
	<!-- ====================================================== -->
	
	<xsl:function name="dtb:style-name">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="concat('dtb_3a_', local-name($element))"/>
	</xsl:function>
	
	<xsl:function name="style:display-name">
		<xsl:param name="style-name" as="xs:string"/>
		<xsl:sequence select="replace(replace(replace(replace($style-name, '_20_', ' '), '_3a_', ':'), '_5f_', '_'), '_23_', '#')"/>
	</xsl:function>
	
	<xsl:function name="dtb:node-trace">
		<xsl:param name="node" as="node()"/>
		<xsl:sequence select="string-join(('',
		                        $node/ancestor::*/name(),
		                        if ($node/self::element()) then name($node)
		                          else if ($node/self::attribute()) then concat('@', name($node))
		                          else if ($node/self::text()) then 'text()'
		                          else '?'
		                      ), '/')"/>
	</xsl:function>
	
</xsl:stylesheet>