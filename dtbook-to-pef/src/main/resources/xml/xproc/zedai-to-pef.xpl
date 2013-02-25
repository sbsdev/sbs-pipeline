<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:sbs="http://www.sbs.ch/pipeline"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="px d sbs"
    type="sbs:zedai-to-pef" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">ZedAI to PEF (SBS)</h1>
        <p px:role="desc">Transforms a ZedAI (DAISY 4 XML) document into a PEF.</p>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Bert Frees</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.sbs.ch/">SBS</dd>
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
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/zedai-to-pef/xproc/zedai-to-pef.xpl"/>

    <p:variable name="stylesheet" select="'http://www.sbs.ch/pipeline/modules/braille/zedai.css'"/>
    <p:variable name="preprocessor" select="'http://www.sbs.ch/pipeline/modules/braille/zedai-preprocessor.xpl'"/>
    <p:variable name="translator" select="'http://www.sbs.ch/pipeline/modules/braille/zedai-translator.xsl'"/>

    <!-- ============ -->
    <!-- ZEDAI TO PEF -->
    <!-- ============ -->
    
    <px:zedai-to-pef>
        <p:with-option name="stylesheet" select="$stylesheet"/>
        <p:with-option name="preprocessor" select="$preprocessor"/>
        <p:with-option name="translator" select="$translator"/>
        <p:with-option name="preview" select="$preview"/>
        <p:with-option name="output-dir" select="$output-dir"/>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </px:zedai-to-pef>
    
</p:declare-step>
