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
		xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
		xmlns:d="http://www.daisy.org/ns/pipeline/data"
		exclude-result-prefixes="#all">
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
	<xsl:include href="utilities.xsl"/>
	
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
	
	<xsl:template match="dtb:book|dtb:frontmatter|dtb:bodymatter|dtb:rearmatter|
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
	
	<xsl:template match="dtb:p" mode="office:text text:section text:list-item table:table-cell text:note-body">
		<xsl:param name="paragraph_style" as="xs:string?" tunnel="yes"/>
		<xsl:call-template name="text:p">
			<xsl:with-param name="text:style-name" select="$paragraph_style"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ===== -->
	<!-- LISTS -->
	<!-- ===== -->
	
	<xsl:template match="dtb:list" mode="office:text text:section table:table-cell text:list-item">
		<xsl:element name="text:list">
			<xsl:attribute name="text:style-name" select="style:name(concat('dtb:list_', (@type, 'ul')[1]))"/>
			<xsl:apply-templates mode="text:list"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:li" mode="text:list">
		<xsl:variable name="style_name" select="dtb:style-name(.)"/>
		<xsl:element name="text:list-item">
			<xsl:for-each-group select="*|text()" group-by="boolean(self::dtb:p or self::dtb:list)">
				<xsl:choose>
					<xsl:when test="current-grouping-key()">
						<xsl:apply-templates select="current-group()" mode="text:list-item">
							<xsl:with-param name="paragraph_style" select="$style_name" tunnel="yes"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="normalize-space(string-join(current-group()/string(.), ''))=''"/>
					<xsl:otherwise>
						<xsl:call-template name="text:p">
							<xsl:with-param name="text:style-name" select="$style_name"/>
							<xsl:with-param name="apply-templates" select="current-group()"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each-group>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:lic" mode="text:p">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<xsl:template match="dtb:dl" mode="office:text text:section">
		<xsl:element name="text:list">
			<xsl:attribute name="text:style-name" select="dtb:style-name(.)"/>
			<xsl:apply-templates mode="text:list"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:dt[following-sibling::*[1]/self::dtb:dd]" mode="text:list"/>
	
	<xsl:template match="dtb:dd[preceding-sibling::*[1]/self::dtb:dt]" mode="text:list">
		<xsl:variable name="dt" select="preceding-sibling::*[1]"/>
		<xsl:variable name="colon">
			<xsl:text>: </xsl:text>
		</xsl:variable>
		<xsl:element name="text:list-item">
			<xsl:call-template name="text:p">
				<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
				<xsl:with-param name="apply-templates" select="($dt, $colon, *|text())"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:dt" mode="text:p">
		<xsl:call-template name="text:span">
			<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
		</xsl:call-template>
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
				<xsl:when test="dtb:p|dtb:imggroup|dtb:list">
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
		<xsl:choose>
			<xsl:when test="dtb:p">
				<xsl:apply-templates mode="#current">
					<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="text:p">
					<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ===== -->
	<!-- NOTES -->
	<!-- ===== -->
	
	<xsl:template match="dtb:noteref" mode="text:p text:h text:span">
		<xsl:variable name="id" select="translate(@idref,'#','')"/>
		<xsl:variable name="note" select="//dtb:note[@id=$id]"/>
		<xsl:choose>
			<xsl:when test="exists($note)">
				<xsl:element name="text:note">
					<xsl:attribute name="text:note-class" select="($note/@class, 'footnote')[.=('footnote','endnote')][1]"/>
					<xsl:attribute name="text:id" select="$note/@id"/>
					<!-- LO takes care of updating this -->
					<xsl:element name="text:note-citation">1</xsl:element>
					<xsl:element name="text:note-body">
						<xsl:apply-templates select="$note" mode="text:note-body"/>
					</xsl:element>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>WARNING! dtb:note with id #</xsl:text>
					<xsl:sequence select="$id"/>
					<xsl:text> not found.</xsl:text>
				</xsl:message>
				<xsl:call-template name="skip"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="dtb:note" mode="text:note-body" priority="1">
		<xsl:variable name="note_class" select="(@class, 'footnote')[.=('footnote','endnote')][1]"/>
		<xsl:variable name="style_name" select="style:name(concat('dtb:note_', $note_class))"/>
		<xsl:choose>
			<xsl:when test="dtb:p">
				<xsl:apply-templates mode="#current">
					<xsl:with-param name="paragraph_style" select="$style_name" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="text:p">
					<xsl:with-param name="text:style-name" select="$style_name"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="dtb:note" mode="#all">
		<xsl:variable name="id" select="string(@id)"/>
		<xsl:variable name="noterefs" select="//dtb:noteref[@idref=concat('#',$id)]"/>
		<xsl:if test="not(exists($noterefs))">
			<xsl:message>
				<xsl:text>WARNING! dtb:note with id #</xsl:text>
				<xsl:sequence select="$id"/>
				<xsl:text> is never referenced.</xsl:text>
			</xsl:message>
		</xsl:if>
	</xsl:template>
	
	<!-- ==================== -->
	<!-- OTHER BLOCK ELEMENTS -->
	<!-- ==================== -->
	
	<xsl:template match="dtb:sidebar" mode="office:text text:section">
		<xsl:param name="sidebar_announcement" as="node()*" tunnel="yes"/>
		<xsl:param name="sidebar_deannouncement" as="node()*" tunnel="yes"/>
		<xsl:call-template name="text:section">
			<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
			<xsl:with-param name="number" select="count(preceding::dtb:sidebar) + count(ancestor::dtb:sidebar) + 1"/>
			<xsl:with-param name="apply-templates" select="($sidebar_announcement, *|text(), $sidebar_deannouncement)"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="dtb:blockquote" mode="office:text text:section">
		<xsl:apply-templates mode="#current">
			<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="dtb:doctitle|dtb:docauthor" mode="office:text text:section">
		<xsl:call-template name="text:p">
			<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ====== -->
	<!-- IMAGES -->
	<!-- ====== -->
	
	<xsl:template match="dtb:imggroup" mode="office:text text:section table:table-cell">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<xsl:template match="dtb:img" mode="office:text text:section table:table-cell">
		<xsl:variable name="src" select="resolve-uri(@src, base-uri(.))"/>
		<xsl:variable name="image_dimensions" as="xs:integer*" select="pf:image-dimensions($src)"/>
		<xsl:variable name="image_resolution" select="300"/>
		<xsl:call-template name="text:p">
			<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
			<xsl:with-param name="sequence">
				<xsl:element name="draw:frame">
					<xsl:attribute name="draw:name" select="concat('dtb:img#', count(preceding::dtb:img) + 1)"/>
					<xsl:attribute name="draw:style-name" select="dtb:style-name(.)"/>
					<xsl:attribute name="text:anchor-type" select="'as-char'"/>
					<xsl:attribute name="draw:z-index" select="'0'"/>
					<xsl:attribute name="svg:width" select="format-number($image_dimensions[1] div $image_resolution, '0.0000in')"/>
					<xsl:attribute name="svg:height" select="format-number($image_dimensions[2] div $image_resolution, '0.0000in')"/>
					<xsl:attribute name="svg:y" select="'0in'"/>
					<xsl:element name="draw:image">
						<xsl:attribute name="xlink:href"
						               select="pf:relativize-uri(
						                       collection()[3]//d:file[resolve-uri(@original-href,base-uri(.))=$src]/resolve-uri(@href,base-uri(.)),
						                       collection()[1]/*/base-uri(.))"/>
						<xsl:attribute name="xlink:type" select="'simple'"/>
						<xsl:attribute name="xlink:show" select="'embed'"/>
						<xsl:attribute name="xlink:actuate" select="'onLoad'"/>
					</xsl:element>
					<xsl:if test="@alt">
						<xsl:element name="svg:title">
							<xsl:sequence select="string(@alt)"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="dtb:imggroup/dtb:caption" mode="office:text text:section table:table-cell">
		<xsl:choose>
			<xsl:when test="dtb:p">
				<xsl:apply-templates mode="#current">
					<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="text:p">
					<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
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
	
	<xsl:template match="dtb:span|dtb:sent|dtb:abbr|dtb:acronym|dtb:cite|dtb:author|dtb:title"
	              mode="text:p text:h text:span">
		<xsl:param name="lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="paragraph-lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="span-lang" as="xs:string?" tunnel="yes"/>
		<xsl:choose>
			<xsl:when test="$lang!=($span-lang,$paragraph-lang)[1]">
				<xsl:call-template name="text:span"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="#current"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="dtb:em|dtb:strong|dtb:sub|dtb:sup" mode="text:p text:h text:span">
		<xsl:call-template name="text:span">
			<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="dtb:a[@external='true']" mode="text:p text:h text:span">
		<xsl:call-template name="text:a">
			<xsl:with-param name="text:style-name" select="dtb:style-name(.)"/>
			<xsl:with-param name="xlink:href" select="@href"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="dtb:br" mode="text:p text:h text:span text:a">
		<text:line-break/>
	</xsl:template>
	
	<xsl:template match="text()" mode="text:p text:h text:span text:a">
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
	
	
	<!-- ======== -->
	<!-- LANGUAGE -->
	<!-- ======== -->
	
	<xsl:template match="*" mode="#all" priority="10">
		<xsl:next-match>
			<xsl:with-param name="lang" select="string(ancestor-or-self::*[@xml:lang][1]/@xml:lang)" tunnel="yes"/>
		</xsl:next-match>
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
	
	<xsl:template match="*" mode="text:p text:h text:span text:a">
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
	
	<xsl:template name="text:span">
		<xsl:param name="lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="paragraph-lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="span-lang" as="xs:string?" tunnel="yes"/>
		<xsl:param name="text:style-name" as="xs:string?"/>
		<xsl:element name="text:span">
			<xsl:if test="$lang!=($span-lang,$paragraph-lang)[1]">
				<xsl:attribute name="xml:lang" select="$lang"/>
			</xsl:if>
			<xsl:if test="$text:style-name">
				<xsl:attribute name="text:style-name" select="$text:style-name"/>
			</xsl:if>
			<xsl:apply-templates mode="text:span">
				<xsl:with-param name="span-lang" tunnel="yes" select="$lang"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="text:a">
		<xsl:param name="lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="paragraph-lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="span-lang" as="xs:string?" tunnel="yes"/>
		<xsl:param name="text:style-name" as="xs:string?"/>
		<xsl:param name="xlink:href" as="xs:string"/>
		<xsl:element name="text:a">
			<xsl:if test="$lang!=($span-lang,$paragraph-lang)[1]">
				<xsl:attribute name="xml:lang" select="$lang"/>
			</xsl:if>
			<xsl:if test="$text:style-name">
				<xsl:attribute name="text:style-name" select="$text:style-name"/>
			</xsl:if>
			<xsl:attribute name="xlink:href" select="$xlink:href"/>
			<xsl:attribute name="xlink:type" select="'simple'"/>
			<xsl:apply-templates mode="text:a">
				<xsl:with-param name="span-lang" tunnel="yes" select="$lang"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="text:p">
		<xsl:param name="lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="text:style-name" as="xs:string?"/>
		<xsl:param name="apply-templates" as="node()*" select="*|text()"/>
		<xsl:param name="sequence" as="node()*"/>
		<xsl:element name="text:p">
			<xsl:if test="$lang!=string(/dtb:dtbook/@xml:lang)">
				<xsl:attribute name="xml:lang" select="$lang"/>
			</xsl:if>
			<xsl:attribute name="text:style-name" select="($text:style-name, 'Standard')[1]"/>
			<xsl:choose>
				<xsl:when test="exists($sequence)">
					<xsl:sequence select="$sequence"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$apply-templates" mode="text:p">
						<xsl:with-param name="paragraph-lang" tunnel="yes" select="$lang"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="text:h">
		<xsl:param name="lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="text:style-name" as="xs:string?"/>
		<xsl:param name="text:outline-level" as="xs:double"/>
		<xsl:element name="text:h">
			<xsl:if test="$lang!=string(/dtb:dtbook/@xml:lang)">
				<xsl:attribute name="xml:lang" select="$lang"/>
			</xsl:if>
			<xsl:attribute name="text:outline-level" select="$text:outline-level"/>
			<xsl:attribute name="text:style-name" select="($text:style-name, concat('Heading_20_', $text:outline-level))[1]"/>
			<xsl:apply-templates mode="text:h">
				<xsl:with-param name="paragraph-lang" tunnel="yes" select="$lang"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="text:section">
		<xsl:param name="text:style-name" as="xs:string"/>
		<xsl:param name="number" as="xs:double"/>
		<xsl:param name="apply-templates" as="node()*" select="*|text()"/>
		<xsl:param name="sequence" as="node()*"/>
		<xsl:element name="text:section">
			<xsl:attribute name="text:name" select="concat(style:display-name($text:style-name), '#', $number)"/>
			<xsl:attribute name="text:style-name" select="$text:style-name"/>
			<xsl:choose>
				<xsl:when test="exists($sequence)">
					<xsl:sequence select="$sequence"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$apply-templates" mode="text:section"/>
				</xsl:otherwise>
			</xsl:choose>
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
			<xsl:text>Skipping </xsl:text>
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
	
</xsl:stylesheet>
