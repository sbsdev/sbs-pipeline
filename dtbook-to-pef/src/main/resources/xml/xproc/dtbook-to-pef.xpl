<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:sbs="http://www.sbs.ch/pipeline"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="#all"
    type="sbs:dtbook-to-pef" name="dtbook-to-pef" version="1.0">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DTBook to PEF (SBS)</h1>
        <p px:role="desc">Transforms a DTBook (DAISY 3 XML) document into a PEF.</p>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Bert Frees</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.sbs-online.ch/">SBS</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:bertfrees@gmail.com">bert.frees@sbs.ch</a></dd>
        </dl>
    </p:documentation>
    
    <p:input port="source" primary="true" px:name="source" px:media-type="application/x-dtbook+xml">
        <p:documentation>
            <h2 px:role="name">source</h2>
            <p px:role="desc">Input DTBook.</p>
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
            <p px:role="desc">Whether or not to include a preview in HTML (true or false).</p>
        </p:documentation>
    </p:option>
    
    <p:option name="brf" required="false" px:type="boolean" select="'false'">
        <p:documentation>
            <h2 px:role="name">brf</h2>
            <p px:role="desc">Whether or not to include a BRF too (true or false).</p>
        </p:documentation>
    </p:option>
    
    <p:import href="zedai-to-pef.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/dtbook-load.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-to-zedai/dtbook-to-zedai.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-to-zedai/dtbook-to-zedai.store.xpl"/>
    
    <!-- =============== -->
    <!-- DTBOOK TO ZEDAI -->
    <!-- =============== -->
    
    <px:dtbook-load name="load"/>
    <px:dtbook-to-zedai-convert name="zedai">
        <p:input port="in-memory.in">
            <p:pipe step="load" port="in-memory.out"/>
        </p:input>
        <p:with-option name="opt-output-dir" select="$temp-dir"/>
    </px:dtbook-to-zedai-convert>
    <p:sink/>
    <px:dtbook-to-zedai-store>
        <p:input port="fileset.in">
            <p:pipe step="zedai" port="fileset.out"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe step="zedai" port="in-memory.out"/>
        </p:input>
    </px:dtbook-to-zedai-store>
    
    <!-- ============ -->
    <!-- ZEDAI TO PEF -->
    <!-- ============ -->
    
    <p:split-sequence>
        <p:input port="source">
            <p:pipe step="zedai" port="in-memory.out"/>
        </p:input>
        <p:with-option name="test"
            select="concat('/*/@xml:base=&quot;',
                            //d:file[@media-type='application/z3998-auth+xml'][1]/resolve-uri(@href, base-uri()),
                            '&quot;')">
            <p:pipe step="zedai" port="fileset.out"/>
        </p:with-option>
    </p:split-sequence>
    
    <sbs:zedai-to-pef>
        <p:with-option name="temp-dir" select="$temp-dir"/>
        <p:with-option name="output-dir" select="$output-dir"/>
        <p:with-option name="preview" select="$preview"/>
        <p:with-option name="brf" select="$brf"/>
    </sbs:zedai-to-pef>
    
</p:declare-step>
