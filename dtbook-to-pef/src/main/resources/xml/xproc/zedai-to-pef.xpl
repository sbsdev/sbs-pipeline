<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:sbs="http://www.sbs.ch/pipeline"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="#all"
    type="sbs:zedai-to-pef" name="zedai-to-pef" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">ZedAI to PEF (SBS)</h1>
        <p px:role="desc">Transforms a ZedAI (DAISY 4 XML) document into a PEF.</p>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Bert Frees</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.sbs.ch/">SBS</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:bertfrees@gmail.com">bert.frees@sbs.ch</a></dd>
        </dl>
    </p:documentation>

    <p:input port="source" primary="true" px:name="source" px:media-type="application/z3998-auth+xml">
        <p:documentation>
            <h2 px:role="name">source</h2>
            <p px:role="desc">Input ZedAI.</p>
        </p:documentation>
    </p:input>
    
    <p:option name="output-dir" required="true" px:output="result" px:sequence="false" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Path to output directory for the PEF.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="temp-dir" required="true" px:output="temp" px:sequence="false" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">temp-dir</h2>
            <p px:role="desc">Path to directory for storing temporary files.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="preview" required="false" px:type="boolean" select="'false'">
        <p:documentation>
            <h2 px:role="name">preview</h2>
            <p px:role="desc">Whether or not to include a preview of the PEF in HTML (true or false).</p>
        </p:documentation>
    </p:option>
    
    <p:option name="brf" required="false" px:type="boolean" select="'false'">
        <p:documentation>
            <h2 px:role="name">brf</h2>
            <p px:role="desc">Whether or not to include a BRF too (true or false).</p>
        </p:documentation>
    </p:option>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/zedai-to-pef/xproc/zedai-to-pef.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/xproc/xml-to-pef.load-preprocessor.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/xproc/xml-to-pef.load-translator.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/xml-to-pef/xproc/xml-to-pef.store.xpl"/>
    
    <p:variable name="stylesheet" select="'http://www.sbs.ch/pipeline/modules/braille/zedai.css'"/>
    <p:variable name="preprocessor" select="'http://www.sbs.ch/pipeline/modules/braille/zedai-preprocessor.xpl'"/>
    <p:variable name="hyphenator" select="'http://www.daisy.org/pipeline/modules/braille/utilities/xslt/generic-libhyphen-hyphenate.xsl'"/>
    <p:variable name="translator" select="'http://www.sbs.ch/pipeline/modules/braille/zedai-translator.xsl'"/>
    <p:variable name="brf-table" select="'ch.sbs.pef.SBSTableProvider.TableType.DE_CH_SBS'"/>
    
    <!-- =============== -->
    <!-- LOAD COMPONENTS -->
    <!-- =============== -->
    
    <px:xml-to-pef.load-preprocessor name="preprocessor">
        <p:with-option name="preprocessor" select="$preprocessor"/>
    </px:xml-to-pef.load-preprocessor>
    <p:sink/>
    <px:xml-to-pef.load-translator name="hyphenator">
        <p:with-option name="translator" select="$hyphenator"/>
    </px:xml-to-pef.load-translator>
    <p:sink/>
    <px:xml-to-pef.load-translator name="translator">
        <p:with-option name="translator" select="$translator"/>
    </px:xml-to-pef.load-translator>
    <p:sink/>
    
    <!-- ================ -->
    <!-- BOILERPLATE TEXT -->
    <!-- ================ -->
    
    <p:xslt>
        <p:input port="source">
            <p:pipe step="zedai-to-pef" port="source"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/add-boilerplate.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- ============== -->
    <!-- TOC GENERATION -->
    <!-- ============== -->
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/generate-ids.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/generate-toc.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- ================== -->
    <!-- FOOTNOTE PLACEMENT -->
    <!-- ================== -->
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/place-footnotes.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- ============ -->
    <!-- ZEDAI TO PEF -->
    <!-- ============ -->
    
    <px:zedai-to-pef.convert>
        <p:input port="source">
            <p:pipe step="zedai-to-pef" port="source"/>
        </p:input>
        <p:input port="preprocessors">
            <p:pipe step="preprocessor" port="result"/>
        </p:input>
        <p:input port="translators">
            <p:pipe step="hyphenator" port="result"/>
            <p:pipe step="translator" port="result"/>
        </p:input>
        <p:with-option name="stylesheet" select="$stylesheet"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:zedai-to-pef.convert>
    
    <!-- ========= -->
    <!-- STORE PEF -->
    <!-- ========= -->
    
    <px:xml-to-pef.store>
        <p:with-option name="output-dir" select="$output-dir"/>
        <p:with-option name="name" select="replace(p:base-uri(/),'^.*/([^/]*)\.[^/\.]*$','$1')">
            <p:pipe step="zedai-to-pef" port="source"/>
        </p:with-option>
        <p:with-option name="preview" select="$preview"/>
        <p:with-option name="brf" select="$brf"/>
        <p:with-option name="brf-table" select="$brf-table"/>
    </px:xml-to-pef.store>
    
</p:declare-step>
