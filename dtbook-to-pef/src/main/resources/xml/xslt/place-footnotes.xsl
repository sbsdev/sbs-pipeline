<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
	xmlns:rend="http://www.daisy.org/ns/z3998/authoring/features/rend/"
	xmlns="http://www.daisy.org/ns/z3998/authoring/"
	exclude-result-prefixes="#all">
	
	<xsl:param name="note-placement" select="'end'"/>
	
	<xsl:output method="xml" encoding="utf-8"/>
	
	<xsl:template match="/*">
		<xsl:copy>
			<xsl:copy-of select="document('')/*/namespace::*[name()='rend']"/>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="z:note">
		<xsl:param name="render" select="$note-placement = 'standard'"/>
		<xsl:if test="$render">
			<xsl:variable name="id" select="string(@xml:id)"/>
			<xsl:variable name="noteref" select="//z:noteref[@ref=$id]"/>
			<xsl:copy>
				<xsl:attribute name="rend:prefix"
					select="if ($noteref/@value) then string($noteref/@value) else string($noteref)"/>
				<xsl:sequence select="@*|node()"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="note-section">
		<xsl:param name="noterefs"/>
		<section role="notes">
			<h>Fussnoten</h>
			<xsl:for-each select="$noterefs">
				<xsl:variable name="ref" select="string(@ref)"/>
				<xsl:variable name="note" select="//z:note[@xml:id=$ref]"/>
				<xsl:apply-templates select="$note">
					<xsl:with-param name="render" select="true()"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</section>
	</xsl:template>
	
	<xsl:template match="z:section[not(ancestor::z:section)]">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:if test="$note-placement = 'section' and .//z:noteref">
				<xsl:call-template name="note-section">
					<xsl:with-param name="noterefs" select=".//z:noteref"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="z:bodymatter">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:if test="$note-placement = 'end' and .//z:noteref">
				<xsl:call-template name="note-section">
					<xsl:with-param name="noterefs" select=".//z:noteref"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
