<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
	xmlns:louis="http://liblouis.org/liblouis"
	xmlns:my="http://www.sbs.ch/pipeline"
	xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
	exclude-result-prefixes="xs louis my z css">
	
	<xsl:output method="xml" encoding="utf-8"/>
	
	<xsl:param name="contraction" as="xs:integer" select="2"/>
	<xsl:param name="enable-capitalization" as="xs:boolean" select="false()"/>
	<xsl:param name="detailed-accents" as="xs:string" select="'all'"/>
	
	<xsl:variable name="LETTER" select="'\p{L}+'"/>
	<xsl:variable name="UPPERCASE" select="'\p{Lu}+'"/>
	
	<xsl:template match="/css:block">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<!-- ==================== -->
	<!-- LIBLOUIS TRANSLATION -->
	<!-- ==================== -->
	
	<xsl:function name="my:translate" as="xs:string">
		<xsl:param name="table" as="xs:string"/>
		<xsl:param name="string" as="xs:string"/>
		<xsl:sequence select="translate(louis:translate($table, $string), '−┎', '⠤&#xAD;')"/>
	</xsl:function>
	
	<!-- ======================== -->
	<!-- LIBLOUIS TABLE SELECTION -->
	<!-- ======================== -->
	
	<xsl:function name="my:get-table" as="xs:string">
		<xsl:param name="this" as="node()"/>
		<xsl:variable name="actual-contraction"
			select="if ($this/lang('de')) then $contraction else 0"/>
		<xsl:variable name="is-abbr-without-periods"
			select="boolean($this/self::z:abbr and not(my:contains-period(string($this))))"/>
		<xsl:variable name="table-list" as="xs:string*">
			<xsl:sequence select="'sbs-de-core6.cti'"/>
			<xsl:sequence select="'sbs-de-core6.cti'"/>
			<xsl:sequence select="'sbs-de-accents.cti'"/>
			<xsl:sequence select="'sbs-special.cti'"/>
			<xsl:sequence select="'sbs-whitespace.mod'"/>
			<xsl:if test="$actual-contraction &lt; 2 and $enable-capitalization">
				<xsl:sequence select="'sbs-de-capsign.mod'"/>
			</xsl:if>
			<xsl:if test="$actual-contraction = 2 and not($is-abbr-without-periods)">
				<xsl:sequence select="'sbs-de-letsign.mod'"/>
			</xsl:if>
			<xsl:if test="not($this/self::z:ref)">
				<xsl:sequence select="'sbs-numsign.mod'"/>
				<xsl:sequence select="'sbs-litdigit-upper.mod'"/>
				<xsl:sequence select="'sbs-de-core.mod'"/>
			</xsl:if>
			<xsl:if test="$actual-contraction &lt; 2 or $is-abbr-without-periods">
				<xsl:sequence select="'sbs-de-g0-core.mod'"/>
			</xsl:if>
			<xsl:if test="not($is-abbr-without-periods) and not($this/self::z:ref)">
				<xsl:if test="$actual-contraction = 1">
					<xsl:sequence select="'sbs-de-g1-white.mod'"/>
					<xsl:sequence select="'sbs-de-g1-core.mod'"/>
				</xsl:if>
				<xsl:if test="$actual-contraction = 2">
					<xsl:sequence select="'sbs-de-g2-white.mod'"/>
					<xsl:sequence select="'sbs-de-g2-core.mod'"/>
				</xsl:if>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$detailed-accents = 'swiss'">
					<xsl:sequence select="'sbs-de-accents-ch.mod'"/>
				</xsl:when>
				<xsl:when test="$detailed-accents = 'none'">
					<xsl:sequence select="'sbs-de-accents-reduced.mod'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="'sbs-de-accents.mod'"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence select="'sbs-special.mod'"/>
		</xsl:variable>
		<xsl:sequence select="concat(
			'http://www.sbs.ch/pipeline/modules/braille/tables/',
			'unicode.dis,', string-join($table-list, ','))"/>
	</xsl:function>
	
	<!-- ============ -->
	<!-- PAGE NUMBERS -->
	<!-- ============ -->
	
	
	
	<!-- ======== -->
	<!-- EMPHASIS -->
	<!-- ======== -->
	
	<xsl:template match="z:emph">
		<xsl:variable name="braille"
			select="my:translate(my:get-table(.), translate(string(.), '╠╣', ''))"/>
		<xsl:choose>
			<xsl:when test="matches(string(.), '^╠.*╣$')">
				<xsl:choose>
					<xsl:when test="count(tokenize(string(.), '(\s|/|-)+')[not(empty(.))]) > 1">
						<!-- Multiple words -->
						<xsl:sequence select="concat('⠸⠸', $braille, '⠠⠄')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="my:ends-with-non-word(preceding-sibling::text()[1])
								and my:starts-with-word(following-sibling::text()[1])">
								<!-- At the beginning of a word -->
								<xsl:sequence select="concat('⠸', $braille, '⠠⠄')"/>
							</xsl:when>
							<xsl:when test="my:ends-with-word(preceding-sibling::text()[1])
								and my:starts-with-non-word(following-sibling::text()[1])">
								<!-- At the end of a word -->
								<xsl:sequence select="concat('⠠⠸', $braille)"/>
							</xsl:when>
							<xsl:when test="my:ends-with-word(preceding-sibling::text()[1])
								and my:starts-with-word(following-sibling::text()[1])">
								<!-- Within a word -->
								<xsl:sequence select="concat('⠠⠸', $braille, '⠠⠄')"/>
							</xsl:when>
							<xsl:otherwise>
								<!-- Single word -->
								<xsl:sequence select="concat('⠸', $braille)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="matches(string(.), '^╠')">
				<!-- Begin of continuation -->
				<xsl:sequence select="concat('⠸⠸', $braille)"/>
			</xsl:when>
			<xsl:when test="matches(string(.), '╣$')">
				<!-- End of continuation -->
				<xsl:sequence select="concat($braille, '⠠⠄')"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Middle of continuation -->
				<xsl:sequence select="$braille"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ============= -->
	<!-- ABBREVIATIONS -->
	<!-- ============= -->
	
	<xsl:template match="z:abbr">
		<xsl:variable name="text" as="xs:string*">
			<xsl:choose>
				<xsl:when test="my:contains-period(string(.))">
					<xsl:for-each select="tokenize(string(.), '\s+')">
						<xsl:value-of select="."/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:analyze-string select="normalize-space(string(.))" regex="{$LETTER}">
						<xsl:matching-substring>
							<xsl:analyze-string select="." regex="{$UPPERCASE}">
								<xsl:matching-substring>
									<xsl:sequence select="if (string-length(.) &gt; 1) then '╦'
										else (if (position()=last()) then '╦' else '╤')"/>
									<xsl:sequence select="."/>
									<xsl:if test="(string-length(.) &gt; 1) and (position() &lt; last())">
										<xsl:sequence select="'╩'"/>
									</xsl:if>
								</xsl:matching-substring>
								<xsl:non-matching-substring>
									<xsl:if test="position()=1">
										<xsl:sequence select="'╩'"/>
									</xsl:if>
									<xsl:sequence select="."/>
								</xsl:non-matching-substring>
							</xsl:analyze-string>
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<xsl:sequence select="."/>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="matches(string(.), '.*\p{Lu}$') and 
				following-sibling::node()[1][self::text()] and
				matches(string(following-sibling::node()[1]), '^\p{Ll}.*')">
				<xsl:value-of select="'╩'"/>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select="my:translate(my:get-table(.), string-join($text, ''))"/>
	</xsl:template>
	
	<!-- ======================= -->
	<!-- OTHER (INLINE) ELEMENTS -->
	<!-- ======================= -->
	
	<xsl:template match="*">
		<xsl:sequence select="my:translate(my:get-table(.), string(.))"/>
	</xsl:template>
	
	<!-- ========== -->
	<!-- TEXT NODES -->
	<!-- ========== -->
	
	<xsl:template match="text()">
		<xsl:sequence select="my:translate(my:get-table(.), string(.))"/>
	</xsl:template>
	
	<!-- ================ -->
	<!-- HELPER FUNCTIONS -->
	<!-- ================ -->
	
	<xsl:function name="my:contains-period" as="xs:boolean">
		<xsl:param name="string"/>
		<xsl:value-of select="contains($string, '.')"/>
	</xsl:function>
	
	<xsl:function name="my:is-letter" as="xs:boolean">
		<xsl:param name="char"/>
		<xsl:value-of select=" matches($char, '\p{L}')"/>
	</xsl:function>
	
	<xsl:function name="my:is-upper" as="xs:boolean">
		<xsl:param name="char"/>
		<xsl:value-of select="$char=upper-case($char)"/>
	</xsl:function>
	
	<xsl:function name="my:ends-with-word" as="xs:boolean">
		<xsl:param name="string"/>
		<xsl:value-of select="not(empty($string)) and matches($string, '\w$')"/>
	</xsl:function>
	
	<xsl:function name="my:starts-with-word" as="xs:boolean">
		<xsl:param name="string"/>
		<xsl:value-of select="not(empty($string)) and matches($string, '^\w')"/>
	</xsl:function>
	
	<xsl:function name="my:ends-with-non-word" as="xs:boolean">
		<xsl:param name="string"/>
		<xsl:value-of select="empty($string) or matches($string, '\W$')"/>
	</xsl:function>
	
	<xsl:function name="my:starts-with-non-word" as="xs:boolean">
		<xsl:param name="string"/>
		<xsl:value-of select="empty($string) or matches($string, '^\W')"/>
	</xsl:function>
	
</xsl:stylesheet>
