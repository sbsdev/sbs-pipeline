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
	
	<!-- ======= -->
	<!-- OPTIONS -->
	<!-- ======= -->
	
	<xsl:param name="image_dpi" select="300"/>
	
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
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<xsl:template match="dtb:book|dtb:frontmatter|dtb:bodymatter|dtb:rearmatter|
	                     dtb:level1|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6"
	              mode="office:text">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<!-- ======== -->
	<!-- HEADINGS -->
	<!-- ======== -->
	
	<xsl:template match="dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6" mode="office:text text:section" priority="1">
		<xsl:call-template name="insert-pagenum-after"/>
	</xsl:template>
	
	<xsl:template match="dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6" mode="office:text text:section text:list-item">
		<xsl:call-template name="text:h">
			<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
			<xsl:with-param name="text:outline-level" select="number(substring(local-name(.),2,1))"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ========== -->
	<!-- PARAGRAPHS -->
	<!-- ========== -->
	
	<xsl:template match="dtb:p[.//dtb:pagenum]" mode="office:text text:section" priority="1">
		<xsl:call-template name="insert-pagenum-after"/>
	</xsl:template>
		
	<xsl:template match="dtb:p" mode="office:text text:section text:list-item table:table-cell text:note-body">
		<xsl:param name="paragraph_style" as="xs:string?" tunnel="yes"/>
		<xsl:call-template name="text:p">
			<xsl:with-param name="paragraph_style" select="($paragraph_style, dtb:style-name(.))[1]" tunnel="yes"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ===== -->
	<!-- LISTS -->
	<!-- ===== -->
	
	<xsl:template match="dtb:list" mode="office:text text:section" priority="1">
		<xsl:call-template name="insert-pagenum-after"/>
	</xsl:template>
	
	<xsl:template match="dtb:list" mode="office:text text:section table:table-cell text:list-item">
		<xsl:element name="text:list">
			<xsl:attribute name="text:style-name" select="style:name(concat('dtb:list_', (@type, 'ul')[1]))"/>
			<xsl:apply-templates mode="text:list"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:li" mode="text:list">
		<xsl:element name="text:list-item">
			<xsl:apply-templates select="$group-inline-nodes" mode="text:list-item">
				<xsl:with-param name="select" select="*|text()"/>
				<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
			</xsl:apply-templates>
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
				<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
				<xsl:with-param name="apply-templates" select="($dt, $colon, *|text())"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:dt" mode="text:p">
		<xsl:call-template name="text:span">
			<xsl:with-param name="text_style" select="dtb:style-name(.)" tunnel="yes"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- ====== -->
	<!-- TABLES -->
	<!-- ====== -->
	
	<xsl:template match="dtb:table" mode="office:text text:section" priority="1">
		<xsl:call-template name="insert-pagenum-after"/>
	</xsl:template>
	
	<xsl:template match="dtb:table" mode="office:text text:section">
		<xsl:apply-templates select="dtb:caption" mode="#current"/>
		<xsl:variable name="dtb:tr" as="element()*">
			<xsl:call-template name="dtb:insert-covered-table-cells">
				<xsl:with-param name="table_cells" select="dtb:tr/(dtb:td|dtb:th)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:element name="table:table">
			<xsl:attribute name="table:name" select="concat('dtb:table#', count(preceding::dtb:table) + 1)"/>
			<xsl:element name="table:table-column">
				<xsl:attribute name="table:number-columns-repeated" select="max(.//dtb:tr/count(dtb:td|dtb:th))"/>
			</xsl:element>
			<xsl:apply-templates mode="table:table" select="(dtb:thead, $dtb:tr, dtb:tbody, dtb:tfoot)"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:thead" mode="table:table">
		<xsl:variable name="dtb:tr" as="element()*">
			<xsl:call-template name="dtb:insert-covered-table-cells">
				<xsl:with-param name="table_cells" select="dtb:tr/(dtb:td|dtb:th)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:element name="table:table-header-rows">
			<xsl:apply-templates mode="table:table-header-rows" select="$dtb:tr"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:tbody|dtb:tfoot" mode="table:table">
		<xsl:variable name="dtb:tr" as="element()*">
			<xsl:call-template name="dtb:insert-covered-table-cells">
				<xsl:with-param name="table_cells" select="dtb:tr/(dtb:td|dtb:th)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:apply-templates mode="#current" select="$dtb:tr"/>
	</xsl:template>
	
	<xsl:template match="dtb:tr" mode="table:table table:table-header-rows">
		<xsl:element name="table:table-row">
			<xsl:apply-templates mode="table:table-row"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:td|dtb:th" mode="table:table-row">
		<xsl:variable name="colspan" as="xs:integer" select="@colspan"/>
		<xsl:variable name="rowspan" as="xs:integer" select="@rowspan"/>
		<xsl:element name="table:table-cell">
			<xsl:attribute name="office:value-type" select="'string'"/>
			<xsl:if test="$colspan &gt; 1">
				<xsl:attribute name="table:number-columns-spanned" select="$colspan"/>
			</xsl:if>
			<xsl:if test="$rowspan &gt; 1">
				<xsl:attribute name="table:number-rows-spanned" select="$rowspan"/>
			</xsl:if>
			<xsl:apply-templates select="$group-inline-nodes" mode="table:table-cell">
				<xsl:with-param name="select" select="*|text()"/>
				<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:covered-table-cell" mode="table:table-row">
		<xsl:element name="table:covered-table-cell"/>
	</xsl:template>
	
	<xsl:template match="dtb:table/dtb:caption" mode="office:text text:section">
		<xsl:apply-templates select="$group-inline-nodes" mode="#current">
			<xsl:with-param name="select" select="*|text()"/>
			<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template name="dtb:insert-covered-table-cells" as="element()*">
		<xsl:param name="table_cells" as="element()*"/>
		<xsl:param name="covered_cells" as="element()*"/>
		<xsl:param name="current_row" as="element()*"/>
		<xsl:param name="row_count" as="xs:integer" select="0"/>
		<xsl:variable name="cell_count" select="count($current_row)"/>
		<xsl:choose>
			<xsl:when test="$covered_cells[@row=($row_count+1) and @col=($cell_count+1)]">
				<xsl:call-template name="dtb:insert-covered-table-cells">
					<xsl:with-param name="table_cells" select="$table_cells"/>
					<xsl:with-param name="current_row" select="($current_row, $covered_cells[@row=($row_count+1) and @col=($cell_count+1)])"/>
					<xsl:with-param name="row_count" select="$row_count"/>
					<xsl:with-param name="covered_cells" select="$covered_cells[not(@row=($row_count+1) and @col=($cell_count+1))]"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$table_cells[1][count(parent::*/preceding-sibling::dtb:tr)=$row_count]">
				<xsl:variable name="new_covered_cells" as="element()*">
					<xsl:variable name="colspan" as="xs:integer" select="$table_cells[1]/@colspan"/>
					<xsl:variable name="rowspan" as="xs:integer" select="$table_cells[1]/@rowspan"/>
					<xsl:if test="$colspan + $rowspan &gt; 2">
						<xsl:sequence select="for $i in 1 to $rowspan return
						                      for $j in 1 to $colspan return
						                        if (not($i=1 and $j=1)) then dtb:covered-table-cell($row_count + $i, $cell_count + $j) else ()"/>
					</xsl:if>
				</xsl:variable>
				<xsl:call-template name="dtb:insert-covered-table-cells">
					<xsl:with-param name="table_cells" select="$table_cells[position() &gt; 1]"/>
					<xsl:with-param name="current_row" select="($current_row, $table_cells[1])"/>
					<xsl:with-param name="row_count" select="$row_count"/>
					<xsl:with-param name="covered_cells" select="($covered_cells, $new_covered_cells)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="exists($current_row)">
					<xsl:element name="dtb:tr">
						<xsl:sequence select="$current_row"/>
					</xsl:element>
					<xsl:if test="exists($table_cells)">
						<xsl:call-template name="dtb:insert-covered-table-cells">
							<xsl:with-param name="table_cells" select="$table_cells"/>
							<xsl:with-param name="current_row" select="()"/>
							<xsl:with-param name="row_count" select="$row_count + 1"/>
							<xsl:with-param name="covered_cells" select="$covered_cells"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:function name="dtb:covered-table-cell">
		<xsl:param name="row"/>
		<xsl:param name="col"/>
		<dtb:covered-table-cell row="{$row}" col="{$col}"/>
	</xsl:function>
	
	<!-- ===== -->
	<!-- NOTES -->
	<!-- ===== -->
	
	<xsl:template match="dtb:noteref|dtb:annoref" mode="text:p text:h text:span">
		<xsl:variable name="id" select="translate(@idref,'#','')"/>
		<xsl:variable name="note" select="if (self::dtb:noteref) then dtb:find-note($id)
		                                  else dtb:find-annotation($id)"/>
		<xsl:if test="self::dtb:annoref">
			<xsl:apply-templates mode="#current"/>
		</xsl:if>
		<xsl:element name="text:note">
			<xsl:attribute name="text:note-class" select="($note/@class, 'footnote')[.=('footnote','endnote')][1]"/>
			<xsl:attribute name="text:id" select="$note/@id"/>
			<!-- LO takes care of updating this -->
			<xsl:element name="text:note-citation"></xsl:element>
			<xsl:element name="text:note-body">
				<xsl:apply-templates select="$note" mode="text:note-body">
					<xsl:with-param name="skip_notes" select="false()" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dtb:note|dtb:annotation" mode="text:note-body" priority="1">
		<xsl:param name="skip_notes" as="xs:boolean" select="true()" tunnel="yes"/>
		<xsl:choose>
			<xsl:when test="not($skip_notes)">
				<xsl:apply-templates select="$group-inline-nodes" mode="#current">
					<xsl:with-param name="select" select="*|text()"/>
					<xsl:with-param name="paragraph_style"
					                select="if (self::dtb:note)
					                        then style:name(concat('dtb:note_', (@class, 'footnote')[.=('footnote','endnote')][1]))
					                        else dtb:style-name(.)"
					                tunnel="yes"/>
					<xsl:with-param name="skip_notes" select="true()" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="dtb:note|dtb:annotation" mode="#all">
		<xsl:param name="skip_notes" as="xs:boolean" select="true()" tunnel="yes"/>
		<xsl:variable name="id" select="string(@id)"/>
		<xsl:variable name="refs" select="if (self::dtb:note)
		                                  then //dtb:noteref[@idref=concat('#',$id)]
		                                  else //dtb:annoref[@idref=concat('#',$id)]"/>
		<xsl:if test="not(exists($refs)) or not($skip_notes)">
			<xsl:message terminate="yes">
				<xsl:text>ERROR! </xsl:text>
				<xsl:sequence select="name(.)"/>
				<xsl:text> with id #</xsl:text>
				<xsl:sequence select="$id"/>
				<xsl:text> is never referenced.</xsl:text>
			</xsl:message>
		</xsl:if>
	</xsl:template>
	
	<xsl:variable name="dtb:notes" as="element()*" select="collection()[2]//dtb:note"/>
	
	<xsl:function name="dtb:find-note" as="element()">
		<xsl:param name="id" as="xs:string"/>
		<xsl:variable name="note" select="$dtb:notes[@id=$id]"/>
		<xsl:if test="not(exists($note))">
			<xsl:message terminate="yes">
				<xsl:text>ERROR! dtb:note with id #</xsl:text>
				<xsl:sequence select="$id"/>
				<xsl:text> could not be found.</xsl:text>
			</xsl:message>
		</xsl:if>
		<xsl:sequence select="$note"/>
	</xsl:function>
	
	<xsl:variable name="dtb:annotations" as="element()*" select="collection()[2]//dtb:annotation"/>
	
	<xsl:function name="dtb:find-annotation" as="element()">
		<xsl:param name="id" as="xs:string"/>
		<xsl:variable name="annotation" select="$dtb:annotations[@id=$id]"/>
		<xsl:if test="not(exists($annotation))">
			<xsl:message terminate="yes">
				<xsl:text>ERROR! dtb:annotation with id #</xsl:text>
				<xsl:sequence select="$id"/>
				<xsl:text> could not be found.</xsl:text>
			</xsl:message>
		</xsl:if>
		<xsl:sequence select="$annotation"/>
	</xsl:function>
	
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
	
	<xsl:template match="dtb:blockquote|dtb:epigraph|dtb:poem" mode="office:text text:section">
		<xsl:apply-templates mode="#current">
			<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="dtb:doctitle|dtb:docauthor|dtb:byline|dtb:bridgehead|dtb:hd|dtb:covertitle"
	              mode="office:text text:section">
		<xsl:call-template name="text:p">
			<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="dtb:linegroup" mode="office:text text:section">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<xsl:template match="dtb:line" mode="office:text text:section">
		<xsl:call-template name="text:p"/>
	</xsl:template>
	
	<!-- ====== -->
	<!-- IMAGES -->
	<!-- ====== -->
	
	<xsl:template match="dtb:imggroup" mode="office:text text:section table:table-cell text:list-item">
		<xsl:apply-templates select="dtb:caption" mode="#current"/>
		<xsl:apply-templates select="*[not(self::dtb:caption)]" mode="#current"/>
	</xsl:template>
	
	<xsl:template match="dtb:img" mode="office:text text:section table:table-cell text:list-item">
		<xsl:variable name="src" select="resolve-uri(@src, base-uri(collection()[2]/dtb:dtbook))"/>
		<xsl:variable name="image_dimensions" as="xs:integer*" select="pf:image-dimensions($src)"/>
		<xsl:call-template name="text:p">
			<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
			<xsl:with-param name="sequence">
				<xsl:element name="draw:frame">
					<xsl:attribute name="draw:name" select="concat('dtb:img#', count(preceding::dtb:img) + 1)"/>
					<xsl:attribute name="draw:style-name" select="dtb:style-name(.)"/>
					<xsl:attribute name="text:anchor-type" select="'as-char'"/>
					<xsl:attribute name="draw:z-index" select="'0'"/>
					<xsl:attribute name="svg:width" select="format-number($image_dimensions[1] div $image_dpi, '0.0000in')"/>
					<xsl:attribute name="svg:height" select="format-number($image_dimensions[2] div $image_dpi, '0.0000in')"/>
					<xsl:element name="draw:image">
						<xsl:attribute name="xlink:href" select="$src"/>
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
	
	<xsl:template match="dtb:imggroup/dtb:caption" mode="office:text text:section table:table-cell text:list-item">
		<xsl:param name="caption_prefix" as="node()*" tunnel="yes"/>
		<xsl:param name="caption_suffix" as="node()*" tunnel="yes"/>
		<xsl:apply-templates select="$group-inline-nodes" mode="#current">
			<xsl:with-param name="select" select="($caption_prefix, *|text(), $caption_suffix)"/>
			<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ==== -->
	<!-- MATH -->
	<!-- ==== -->
	
	<!-- ================= -->
	<!-- TABLE OF CONTENTS -->
	<!-- ================= -->
	<xsl:template match="math:math" mode="text:p text:h text:span">
		<xsl:variable name="asciimath" select="string(math:semantics/math:annotation[@encoding='ASCIIMath'])"/>
		<xsl:variable name="count" as="xs:integer" select="count(preceding::math:math) + 1"/>
		<xsl:element name="draw:frame">
			<xsl:attribute name="draw:name" select="concat('math:math#', $count)"/>
			<xsl:attribute name="draw:style-name" select="dtb:style-name(.)"/>
			<xsl:attribute name="text:anchor-type" select="'as-char'"/>
			<xsl:attribute name="draw:z-index" select="'0'"/>
			<xsl:element name="draw:object">
				<xsl:sequence select="."/>
			</xsl:element>
			<xsl:if test="$asciimath!=''">
				<xsl:element name="svg:title">
					<xsl:sequence select="$asciimath"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<!-- ============== -->
	<!-- PAGE NUMBERING -->
	<!-- ============== -->
	
	<xsl:template match="dtb:pagenum" mode="office:text text:section" priority="1">
		<xsl:param name="pagenum_done" as="xs:boolean" select="false()" tunnel="yes"/>
		<xsl:param name="pagenum_prefix" as="node()*" tunnel="yes"/>
		<xsl:if test="not($pagenum_done)">
			<xsl:call-template name="text:p">
				<xsl:with-param name="paragraph_style" select="dtb:style-name(.)" tunnel="yes"/>
				<xsl:with-param name="apply-templates" select="($pagenum_prefix, *|text())"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="dtb:pagenum" mode="#all">
		<xsl:param name="pagenum_done" as="xs:boolean" select="false()" tunnel="yes"/>
		<xsl:if test="not($pagenum_done)">
			<xsl:call-template name="TERMINATE"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="insert-pagenum-after">
		<xsl:param name="pagenum_done" as="xs:boolean" select="false()" tunnel="yes"/>
		<xsl:next-match>
			<xsl:with-param name="pagenum_done" select="true()" tunnel="yes"/>
		</xsl:next-match>
		<xsl:if test="not($pagenum_done)">
			<xsl:apply-templates mode="#current" select=".//dtb:pagenum"/>
		</xsl:if>
	</xsl:template>
	
	<!-- ====================== -->
	<!-- INLINE ELEMENTS & TEXT -->
	<!-- ====================== -->
	
	<xsl:template match="dtb:span|dtb:sent" mode="text:p text:h text:span">
		<xsl:call-template name="text:span"/>
	</xsl:template>
	
	<xsl:template match="dtb:em|dtb:strong|dtb:sub|dtb:sup|dtb:cite|dtb:q|dtb:author|dtb:title|
	                     dtb:acronym|dtb:abbr|dtb:kbd|dtb:code|dtb:samp|dtb:linenum"
	              mode="text:p text:h text:span">
		<xsl:call-template name="text:span">
			<xsl:with-param name="text_style" select="dtb:style-name(.)" tunnel="yes"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="dtb:code|dtb:samp" mode="office:text text:section text:list-item table:table-cell text:note-body">
		<xsl:call-template name="text:p">
			<xsl:with-param name="text_style" select="dtb:style-name(.)" tunnel="yes"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="dtb:a[@external='true']" mode="text:p text:h text:span">
		<xsl:call-template name="text:a">
			<xsl:with-param name="text_style" select="dtb:style-name(.)" tunnel="yes"/>
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
	
	<xsl:variable name="document_lang" select="string(/dtb:dtbook/@xml:lang)"/>
	
	<xsl:template match="dtb:*" mode="#all" priority="10">
		<xsl:next-match>
			<xsl:with-param name="lang" select="dtb:lang(.)" tunnel="yes"/>
		</xsl:next-match>
	</xsl:template>
	
	<!-- =============== -->
	<!-- EVERYTHING ELSE -->
	<!-- =============== -->
	
	<xsl:template match="dtb:head" mode="#all"/>
	
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
	
	<xsl:variable name="group-inline-nodes">
		<group-inline-nodes/>
	</xsl:variable>
	
	<xsl:template match="group-inline-nodes" mode="#all">
		<xsl:param name="select" as="node()*"/>
		<xsl:for-each-group select="$select" group-adjacent="boolean(descendant-or-self::*[dtb:is-block-element(.)])">
			<xsl:choose>
				<xsl:when test="current-grouping-key()">
					<xsl:apply-templates select="current-group()" mode="#current"/>
				</xsl:when>
				<xsl:when test="normalize-space(string-join(current-group()/string(.), ''))=''"/>
				<xsl:otherwise>
					<xsl:call-template name="text:p">
						<xsl:with-param name="apply-templates" select="current-group()"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:function name="dtb:is-block-element" as="xs:boolean">
		<xsl:param name="node" as="node()"/>
		<xsl:apply-templates select="$node" mode="is-block-element"/>
	</xsl:function>
	
	<xsl:template match="dtb:*|math:*" as="xs:boolean" mode="is-block-element" priority="11">
		<xsl:sequence select="false()"/>
	</xsl:template>
	
	<xsl:template match="dtb:p|dtb:list|dtb:imggroup|dtb:blockquote" as="xs:boolean" mode="is-block-element" priority="12">
		<xsl:sequence select="true()"/>
	</xsl:template>
	
	<!-- ====================================================== -->
	
	<xsl:template name="text:span">
		<xsl:param name="lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="paragraph_lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="text_lang" as="xs:string?" tunnel="yes"/>
		<xsl:param name="text_style" as="xs:string?" tunnel="yes"/>
		<xsl:param name="apply-templates" as="node()*" select="*|text()"/>
		<xsl:param name="sequence" as="node()*"/>
		<xsl:choose>
			<xsl:when test="$lang!=($text_lang,$paragraph_lang)[1] or $text_style">
				<xsl:element name="text:span">
					<xsl:if test="$lang!=($text_lang,$paragraph_lang)[1]">
						<xsl:attribute name="xml:lang" select="$lang"/>
					</xsl:if>
					<xsl:if test="$text_style">
						<xsl:attribute name="text:style-name" select="$text_style"/>
					</xsl:if>
					<xsl:sequence select="$sequence"/>
					<xsl:if test="not(exists($sequence))">
						<xsl:apply-templates select="$apply-templates" mode="text:span">
							<xsl:with-param name="text_lang" select="$lang" tunnel="yes"/>
							<xsl:with-param name="text_style" select="()" tunnel="yes"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$sequence"/>
				<xsl:if test="not(exists($sequence))">
					<xsl:apply-templates select="$apply-templates" mode="#current"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="text:a">
		<xsl:param name="lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="paragraph_lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="text_lang" as="xs:string?" tunnel="yes"/>
		<xsl:param name="text_style" as="xs:string?" tunnel="yes"/>
		<xsl:param name="xlink:href" as="xs:string"/>
		<xsl:element name="text:a">
			<xsl:if test="$lang!=($text_lang,$paragraph_lang)[1]">
				<xsl:attribute name="xml:lang" select="$lang"/>
			</xsl:if>
			<xsl:if test="$text_style">
				<xsl:attribute name="text:style-name" select="$text_style"/>
			</xsl:if>
			<xsl:attribute name="xlink:href" select="$xlink:href"/>
			<xsl:attribute name="xlink:type" select="'simple'"/>
			<xsl:apply-templates mode="text:a">
				<xsl:with-param name="text_lang" select="$lang" tunnel="yes"/>
				<xsl:with-param name="text_style" select="()" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="text:p">
		<xsl:param name="lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="text_style" as="xs:string?" tunnel="yes"/>
		<xsl:param name="paragraph_style" as="xs:string?" tunnel="yes"/>
		<xsl:param name="apply-templates" as="node()*" select="*|text()"/>
		<xsl:param name="sequence" as="node()*"/>
		<xsl:element name="text:p">
			<xsl:if test="$lang!=$document_lang">
				<xsl:attribute name="xml:lang" select="$lang"/>
			</xsl:if>
			<xsl:attribute name="text:style-name" select="($paragraph_style, 'Standard')[1]"/>
			<xsl:choose>
				<xsl:when test="$text_style">
					<xsl:call-template name="text:span">
						<xsl:with-param name="apply-templates" select="$apply-templates"/>
						<xsl:with-param name="sequence" select="$sequence"/>
						<xsl:with-param name="paragraph_lang" select="$lang" tunnel="yes"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="exists($sequence)">
					<xsl:sequence select="$sequence"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$apply-templates" mode="text:p">
						<xsl:with-param name="paragraph_lang" select="$lang" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="text:h">
		<xsl:param name="lang" as="xs:string" tunnel="yes"/>
		<xsl:param name="text_style" as="xs:string?" tunnel="yes"/>
		<xsl:param name="paragraph_style" as="xs:string?" tunnel="yes"/>
		<xsl:param name="text:outline-level" as="xs:double"/>
		<xsl:param name="apply-templates" as="node()*" select="*|text()"/>
		<xsl:param name="sequence" as="node()*"/>
		<xsl:element name="text:h">
			<xsl:if test="$lang!=$document_lang">
				<xsl:attribute name="xml:lang" select="$lang"/>
			</xsl:if>
			<xsl:attribute name="text:outline-level" select="$text:outline-level"/>
			<xsl:attribute name="text:style-name" select="($paragraph_style, style:name(concat('Heading ', $text:outline-level)))[1]"/>
			<xsl:choose>
				<xsl:when test="$text_style">
					<xsl:call-template name="text:span">
						<xsl:with-param name="apply-templates" select="$apply-templates"/>
						<xsl:with-param name="sequence" select="$sequence"/>
						<xsl:with-param name="paragraph_lang" select="$lang" tunnel="yes"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="exists($sequence)">
					<xsl:sequence select="$sequence"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$apply-templates" mode="text:h">
						<xsl:with-param name="paragraph_lang" select="$lang" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
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
