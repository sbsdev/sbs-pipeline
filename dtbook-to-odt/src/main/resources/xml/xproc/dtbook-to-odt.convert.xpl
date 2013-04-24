<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:sbs="http://www.sbs.ch/pipeline"
    xmlns:odt="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    exclude-inline-prefixes="#all"
    type="sbs:dtbook-to-odt.convert" name="convert" version="1.0">
    
    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true"/>
    
    <p:output port="fileset.out" primary="true">
        <p:pipe step="template" port="fileset.out"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe step="new-content" port="result"/>
        <p:pipe step="content" port="not-matched"/>
    </p:output>
    
    <p:option name="template" required="true"/>
    
    <!-- Empty temporary directory dedicated to this conversion -->
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/odt-utils/library.xpl"/>
    
    <!-- Destination -->
    <p:variable name="save-dir" select="resolve-uri('result.odt/', $temp-dir)"/>
    
    <!-- ============= -->
    <!-- LOAD TEMPLATE -->
    <!-- ============= -->
    
    <p:variable name="template-copy" select="resolve-uri(replace($template, '^.*/([^/]+)$','$1'), $temp-dir)"/>
    
    <px:copy-resource>
        <p:with-option name="href" select="$template"/>
        <p:with-option name="target" select="$template-copy"/>
    </px:copy-resource>
    
    <odt:load name="template">
        <p:with-option name="href" select="$template-copy"/>
        <p:with-option name="target" select="$save-dir"/>
    </odt:load>
    <p:sink/>
    
    <!-- ============== -->
    <!-- MODIFY CONTENT -->
    <!-- ============== -->
    
    <p:split-sequence test="ends-with(base-uri(/*), '/content.xml')" name="content">
        <p:input port="source">
            <p:pipe step="template" port="in-memory.out"/>
        </p:input>
    </p:split-sequence>
    
    <p:insert xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
              xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
              match="/office:document-content/office:body/office:text/text:sequence-decls"
              position="after" name="new-content">
        <p:input port="insertion">
            <p:inline>
                <text:h>Hello World !</text:h>
            </p:inline>
            <p:inline>
                <text:p>This is a test.</text:p>
            </p:inline>
        </p:input>
    </p:insert>
    
</p:declare-step>
