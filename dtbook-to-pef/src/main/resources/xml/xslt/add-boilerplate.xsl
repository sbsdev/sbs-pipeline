<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
	xmlns="http://www.daisy.org/ns/z3998/authoring/"
	exclude-result-prefixes="#all">
	
	<xsl:output method="xml" encoding="utf-8"/>
	
	<!-- FIXME prod:series  and prod:seriesNumber not copied to zedai -->
	<xsl:variable name="book-type">
		<xsl:choose>
			<xsl:when test="//z:head/z:meta[@property='prod:series']/@content='PPP'">rucksack</xsl:when>
			<xsl:when test="//z:head/z:meta[@property='prod:series']/@content='SJW'">sjw</xsl:when>
			<xsl:otherwise>standard</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template match="z:frontmatter/z:section[@class='titlepage']">
		<xsl:variable name="series-number" select="string(//z:meta[@property='prod:seriesNumber']/@content)"/>
		<xsl:variable name="source" select="string(//z:meta[@property='prod:source']/@content)"/>
		<xsl:variable name="date" select="string(//z:meta[@property='dc:date']/@content)"/>
		<section class="boilerplate">
			<xsl:choose>
				<xsl:when test="$book-type = 'sjw'">
					<p>
						<abbr>SJW</abbr>-Heft Nr.<xsl:sequence select="$series-number"/>
					</p>
				</xsl:when>
				<xsl:when test="$book-type = 'rucksack'">
					<p>
						Rucksackbuch Nr.<xsl:sequence select="$series-number"/>
					</p>
				</xsl:when>
			</xsl:choose>
			<p>
				<abbr>SBS</abbr> Schweizerische Bibliothek für Blinde, Seh- und Lesebehinderte
			</p>
			<xsl:choose>
				<xsl:when test="$book-type = 'sjw'">
					<p>
						Brailleausgabe mit freundlicher Genehmigung des <abbr>SJW</abbr> Schweizerischen Jugendschriftenwerks, Zürich.
						Wir danken dem <abbr>SJW</abbr>-Verlag für die Bereitstellung der Daten.
					</p>
				</xsl:when>
				<xsl:otherwise>
					<p>
						Dieses Braillebuch ist die ausschließlich für die Nutzung durch Seh- und Lesebehinderte Menschen
						bestimmte zugängliche Version eines urheberrechtlich geschützten Werks. Sie können es im Rahmen des
						Urheberrechts persönlich nutzen, dürfen es aber nicht weiter verbreiten oder öffentlich zugänglich machen.
					</p>
					<xsl:if test="$source = 'electronicData'">
						<p>
							Wir danken dem Verlag für die freundliche Bereitstellung der elektronischen Textdaten.
						</p>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="$book-type = 'rucksack'">
				<z:p>
					Rucksackbuch Nr.<xsl:sequence select="$series-number"/>
				</z:p>
			</xsl:if>
			<p>
				Verlag, Satz und Druck
			</p>
			<p>
				<abbr>SBS</abbr> Schweizerische Bibliothek für Blinde, Seh- und Lesebehinderte, Zürich <ref xml:lang="de">www.sbs.ch</ref>
			</p>
			<p>
				<abbr>SBS</abbr> <xsl:sequence select="substring-before($date,'-')"/>
			</p>
		</section>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
