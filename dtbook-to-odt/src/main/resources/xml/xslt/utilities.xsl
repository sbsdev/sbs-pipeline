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
		xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
		exclude-result-prefixes="#all">
	
	<xsl:function name="style:name">
		<xsl:param name="style-name" as="xs:string"/>
		<xsl:sequence select="replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
		                      $style-name, '_', '_5f_'),
		                                   ' ', '_20_'),
		                                   '#', '_23_'),
		                                   '/', '_2f_'),
		                                   ':', '_3a_'),
		                                   '=', '_3d_'),
		                                   '>', '_3e_'),
		                                   '\[', '_5b_'),
		                                   '\]', '_5d_'),
		                                   '\|', '_7c_')"/>
	</xsl:function>
		
	<xsl:function name="style:display-name">
		<xsl:param name="style-name" as="xs:string"/>
		<xsl:sequence select="replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
		                      $style-name, '_20_', ' '),
		                                   '_23_', '#'),
		                                   '_2f_', '/'),
		                                   '_3a_', ':'),
		                                   '_3d_', '='),
		                                   '_3e_', '>'),
		                                   '_5b_', '['),
		                                   '_5d_', ']'),
		                                   '_5f_', '_'),
		                                   '_7c_', '|')"/>
	</xsl:function>
	
	<xsl:function name="style:family">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="if ($element[self::text:p or self::text:h]) then 'paragraph' else
		                      if ($element[self::text:span or self::text:a]) then 'text' else ''"/>
	</xsl:function>
	
	<xsl:function name="fo:language">
		<xsl:param name="lang" as="xs:string"/>
		<xsl:sequence select="lower-case(replace($lang, '^([^-_]+).*', '$1'))"/>
	</xsl:function>
	
	<xsl:function name="fo:country">
		<xsl:param name="lang" as="xs:string"/>
		<xsl:variable name="country" select="upper-case(substring-after(translate($lang, '-', '_'), '_'))"/>
		<xsl:sequence select="if ($country!='') then $country else 'none'"/>
	</xsl:function>
	
	<xsl:function name="dtb:style-name">
		<xsl:param name="element" as="element()"/>
		<xsl:sequence select="style:name(concat('dtb:', local-name($element)))"/>
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
