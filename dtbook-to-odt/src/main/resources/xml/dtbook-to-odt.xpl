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
    
    <p:option name="asciimath" required="false" px:type="string" select="''">
        <p:documentation>
            <h2 px:role="name">asciimath</h2>
            <p px:role="desc">How to render ASCIIMath-encoded formulas? `ASCIIMATH', `MATHML' or `BOTH'. Default is `ASCIIMATH'.</p>
            <pre><code class="example">MATHML</code></pre>
        </p:documentation>
    </p:option>
    
    <p:option name="images" required="false" px:type="string" select="''">
        <p:documentation>
            <h2 px:role="name">images</h2>
            <p px:role="desc">How to render images? `EMBED', `LINK' or `DROP'. Default is `EMBED'.</p>
            <pre><code class="example">LINK</code></pre>
        </p:documentation>
    </p:option>
    
    <p:option name="phonetics" required="false" px:type="boolean" select="true()">
        <p:documentation>
            <h2 px:role="name">phonetics</h2>
            <p px:role="desc">Render phonetics or not.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="line-numbers" required="false" px:type="boolean" select="true()">
        <p:documentation>
            <h2 px:role="name">line-numbers</h2>
            <p px:role="desc">Show line numbers or not.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="page-numbers" required="false" px:type="boolean" select="true()">
        <p:documentation>
            <h2 px:role="name">page-numbers</h2>
            <p px:role="desc">Show page numbers or not.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="answer" required="false" px:type="string" select="''">
        <p:documentation>
            <h2 px:role="name">answer</h2>
            <p px:role="desc">How to indicate answer fields.</p>
            <pre><code class="example">_..</code></pre>
        </p:documentation>
    </p:option>
    
    <p:option name="image-dpi" required="false" px:type="string" select="''">
        <p:documentation>
            <h2 px:role="name">image-dpi</h2>
            <p px:role="desc">Resolution of images. Default is 600 DPI.</p>
            <pre><code class="example">600</code></pre>
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
            <p:with-option name="template" select="if ($template!='') then $template else resolve-uri('../templates/etext.ott')">
                <p:inline>
                    <irrelevant/>
                </p:inline>
            </p:with-option>
            <p:with-option name="asciimath" select="if ($asciimath=('MATHML','BOTH')) then $asciimath else 'ASCIIMATH'"/>
            <p:with-option name="images" select="if ($images=('LINK','DROP')) then $images else 'EMBED'"/>
            <p:with-option name="image-dpi" select="if ($image-dpi='') then '600' else $image-dpi"/>
            <p:with-option name="answer" select="if ($answer='') then '_..' else $answer"/>
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
