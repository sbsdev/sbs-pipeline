<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:sbs="http://www.sbs.ch/pipeline"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:odt="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    exclude-inline-prefixes="#all"
    type="sbs:dtbook-to-odt" name="dtbook-to-odt" version="1.0">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DTBook to ODT</h1>
        <p px:role="desc">Transforms a DTBook (DAISY 3 XML) document into an ODT (Open Document Text).</p>
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
    
    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation>
            <h2 px:role="name">output-dir</h2>
            <p px:role="desc">Directory for storing result files.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="template" required="false" px:type="string" select="''">
        <p:documentation>
            <h2 px:role="name">template</h2>
            <p px:role="desc">OpenOffice template file (.ott) that contains the style definitions.</p>
            <pre><code class="example">default.ott</code></pre>
        </p:documentation>
    </p:option>
    
    <p:import href="dtbook-to-odt.convert.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/dtbook-load.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/odt-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    
    <!-- =============== -->
    <!-- CREATE TEMP DIR -->
    <!-- =============== -->
    
    <px:tempdir name="temp-dir">
        <p:with-option name="href" select="$output-dir"/>
    </px:tempdir>
    <p:group>
        
        <p:variable name="temp-dir" select="string(/c:result)">
            <p:pipe step="temp-dir" port="result"/>
        </p:variable>
        
        <!-- =========== -->
        <!-- LOAD DTBOOK -->
        <!-- =========== -->
        
        <px:dtbook-load name="dtbook">
            <p:input port="source">
                <p:pipe step="dtbook-to-odt" port="source"/>
            </p:input>
        </px:dtbook-load>
        
        <!-- ===================== -->
        <!-- CONVERT DTBOOK TO ODT -->
        <!-- ===================== -->
        
        <sbs:dtbook-to-odt.convert name="odt">
            <p:input port="fileset.in">
                <p:pipe step="dtbook" port="fileset.out"/>
            </p:input>
            <p:input port="in-memory.in">
                <p:pipe step="dtbook" port="in-memory.out"/>
            </p:input>
            <p:with-option name="temp-dir" select="$temp-dir">
                <p:pipe step="temp-dir" port="result"/>
            </p:with-option>
            <p:with-option name="template" select="if ($template!='') then $template else resolve-uri('../../templates/default.ott')">
                <p:inline>
                    <irrelevant/>
                </p:inline>
            </p:with-option>
        </sbs:dtbook-to-odt.convert>
        
        <!-- ========= -->
        <!-- STORE ODT -->
        <!-- ========= -->
        
        <odt:store name="store">
            <p:input port="fileset.in">
                <p:pipe step="odt" port="fileset.out"/>
            </p:input>
            <p:input port="in-memory.in">
                <p:pipe step="odt" port="in-memory.out"/>
            </p:input>
            <p:with-option name="href" select="concat($output-dir, '/', replace(p:base-uri(/),'^.*/([^/]*)\.[^/\.]*$','$1'), '.odt')">
                <p:pipe step="dtbook-to-odt" port="source"/>
            </p:with-option>
        </odt:store>
    </p:group>
    
</p:declare-step>
