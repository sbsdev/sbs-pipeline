<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:sbs="http://www.sbs.ch/pipeline"
    xmlns:odt="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:math="http://www.w3.org/1998/Math/MathML"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:am="http://www.asciimathml.com"
    exclude-inline-prefixes="#all"
    type="sbs:dtbook-to-odt.convert" name="convert" version="1.0">
    
    <!-- WARNING! This converter doesn't produce valid OpenDocument Text as such.
       It relies on LibreOffice to do some fixing. Opening the ODT file in MS Word
       directly might fail. One way of dealing with this is to add an `odt:save-as`
       post-step, opening the ODT file in LibreOffice and saving it again as ODT.
    -->
    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="false"/>
    
    <p:output port="fileset.out" primary="true">
        <p:pipe step="fileset.with-mathml" port="result"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe step="content" port="result"/>
        <p:pipe step="styles" port="result"/>
        <p:pipe step="meta" port="result"/>
        <p:pipe step="template-everything-else" port="result"/>
        <p:pipe step="extract-mathml" port="extracted"/>
    </p:output>
    
    <p:option name="template" required="true"/>
    
    <!-- Empty temporary directory dedicated to this conversion -->
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/odt-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/asciimathml/library.xpl"/>
    
    <!-- ============= -->
    <!-- LOAD TEMPLATE -->
    <!-- ============= -->
    
    <p:variable name="save-dir" select="resolve-uri('result.odt/', $temp-dir)"/>
    <p:variable name="template-copy" select="resolve-uri(replace($template, '^.*/([^/]+)$','$1'), $temp-dir)"/>
    
    <px:copy-resource>
        <p:with-option name="href" select="$template"/>
        <p:with-option name="target" select="$template-copy"/>
    </px:copy-resource>
    
    <odt:load name="template">
        <p:with-option name="href" select="string(/c:result)"/>
        <p:with-option name="target" select="$save-dir"/>
    </odt:load>
    <p:sink/>
    
    <p:split-sequence test="ends-with(base-uri(/*), '/content.xml')" name="template-content">
        <p:input port="source">
            <p:pipe step="template" port="in-memory.out"/>
        </p:input>
    </p:split-sequence>
    <p:sink/>
    
    <p:split-sequence test="ends-with(base-uri(/*), '/styles.xml')" name="template-styles">
        <p:input port="source">
            <p:pipe step="template-content" port="not-matched"/>
        </p:input>
    </p:split-sequence>
    <p:sink/>
    
    <p:split-sequence test="ends-with(base-uri(/*), '/meta.xml')" name="template-meta">
        <p:input port="source">
            <p:pipe step="template-styles" port="not-matched"/>
        </p:input>
    </p:split-sequence>
    <p:sink/>
    
    <p:identity name="template-everything-else">
        <p:input port="source">
            <p:pipe step="template-meta" port="not-matched"/>
        </p:input>
    </p:identity>
    <p:sink/>
    
    <!-- =========== -->
    <!-- COPY IMAGES -->
    <!-- =========== -->
    
    <px:fileset-create name="images-base">
        <p:with-option name="base" select="resolve-uri('Pictures/', $save-dir)"/>
    </px:fileset-create>
    <p:sink/>
    
    <p:for-each>
        <p:iteration-source select="//dtb:img">
            <p:pipe step="convert" port="in-memory.in"/>
        </p:iteration-source>
        <p:variable name="original-href" select="/*/resolve-uri(@src, base-uri(.))"/>
        <px:fileset-add-entry>
            <p:input port="source">
                <p:pipe step="images-base" port="result"/>
            </p:input>
            <p:with-option name="href" select="concat('img_', p:iteration-position(), replace($original-href, '^.*(\.[^/\.]*)$', '$1'))"/>
            <p:with-option name="original-href" select="$original-href"/>
            <p:with-option name="media-type" select="//d:file[resolve-uri((@original-href,@href)[1], base-uri(.))=$original-href]/@media-type">
                <p:pipe step="convert" port="fileset.in"/>
            </p:with-option>
        </px:fileset-add-entry>
    </p:for-each>
    
    <px:fileset-join name="fileset.images"/>
    <p:sink/>
    
    <px:fileset-join name="fileset.with-images">
        <p:input port="source">
            <p:pipe step="template" port="fileset.out"/>
            <p:pipe step="fileset.images" port="result"/>
        </p:input>
    </px:fileset-join>
    <p:sink/>
    
    <!-- =================== -->
    <!-- ASCIIMATH TO MATHML -->
    <!-- =================== -->
    
    <p:viewport match="dtb:span[@class='asciimath']" name="asciimathml">
        <p:viewport-source>
            <p:pipe step="convert" port="in-memory.in"/>
        </p:viewport-source>
        <am:asciimathml>
            <p:with-option name="asciimath" select="string(.)"/>
        </am:asciimathml>
    </p:viewport>
    
    <!-- ============================= -->
    <!-- MODIFY CONTENT, STYLES & META -->
    <!-- ============================= -->
    
    <p:xslt name="content-1">
        <p:input port="source">
            <p:pipe step="template-content" port="matched"/>
            <p:pipe step="asciimathml" port="result"/>
            <p:pipe step="fileset.images" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/content-sbs.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="content-2">
        <p:input port="stylesheet">
            <p:document href="../xslt/automatic-styles.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <p:sink/>
    
    <p:xslt name="styles">
        <p:input port="source">
            <p:pipe step="template-styles" port="matched"/>
            <p:pipe step="content-1" port="result"/>
            <p:pipe step="convert" port="in-memory.in"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/styles.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <p:sink/>
    
    <p:xslt name="meta">
        <p:input port="source">
            <p:pipe step="template-meta" port="matched"/>
            <p:pipe step="convert" port="in-memory.in"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/meta.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <p:sink/>
    
    <!-- ============== -->
    <!-- EXTRACT MATHML -->
    <!-- ============== -->
    
    <!-- NOTE: We rely on LibreOffice to generate the settings.xml file that goes with the content.xml file. -->
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="content-2" port="result"/>
        </p:input>
    </p:identity>
    
    <p:group name="extract-mathml">
        <p:output port="result" primary="true"/>
        <p:output port="extracted" sequence="true">
            <p:pipe step="filter" port="result"/>
        </p:output>
        <p:label-elements match="draw:frame/math:math" attribute="xml:base" name="add-xml-base">
            <p:with-option name="label"
                           select="concat('concat(&quot;',resolve-uri('Math/mathml_', $save-dir),'&quot;, $p:index,&quot;/content.xml&quot;)')"/>
        </p:label-elements>
        <p:filter select="//draw:frame/math:math" name="filter"/>
        <p:viewport match="draw:frame/math:math">
            <p:viewport-source>
                <p:pipe step="add-xml-base" port="result"/>
            </p:viewport-source>
            <p:add-attribute match="/*" attribute-name="xlink:href">
                <p:input port="source">
                    <p:inline>
                        <draw:object xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad"/>
                    </p:inline>
                </p:input>
                <p:with-option name="attribute-value"
                               select="concat('./',substring-before(substring-after(base-uri(.), $save-dir), '/content.xml'))"/>
            </p:add-attribute>
        </p:viewport>
    </p:group>
    
    <p:identity name="content"/>
    <p:sink/>
    
    <px:fileset-create name="mathml-base">
        <p:with-option name="base" select="resolve-uri('Math/', $save-dir)"/>
    </px:fileset-create>
    
    <p:for-each>
        <p:iteration-source>
            <p:pipe step="extract-mathml" port="extracted"/>
        </p:iteration-source>
        <px:fileset-add-entry media-type="application/mathml+xml">
            <p:input port="source">
                <p:pipe step="mathml-base" port="result"/>
            </p:input>
            <p:with-option name="href" select="base-uri(/*)"/>
        </px:fileset-add-entry>
    </p:for-each>
    
    <px:fileset-join name="fileset.mathml"/>
    
    <px:fileset-join name="fileset.with-mathml">
        <p:input port="source">
            <p:pipe step="fileset.with-images" port="result"/>
            <p:pipe step="fileset.mathml" port="result"/>
        </p:input>
    </px:fileset-join>
    
</p:declare-step>
