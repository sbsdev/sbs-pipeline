<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:sbs="http://www.sbs.ch/pipeline"
    exclude-inline-prefixes="px sbs"
    type="sbs:zedai-preprocessor" version="1.0">
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/utilities/xproc/mark-transitions.xpl"/>
    
    <p:variable name="contraction" select="2"/>
    
    <!-- =============== -->
    <!-- Handle emphasis -->
    <!-- =============== -->
    
    <px:mark-transitions>
        <p:with-option name="predicate" select="'ancestor::z:emph'">
            <p:empty/>
        </p:with-option>
        <p:with-option name="announcement" select="'╠'">
            <p:empty/>
        </p:with-option>
        
        <p:with-option name="deannouncement" select="'╣'">
            <p:empty/>
        </p:with-option>
    </px:mark-transitions>
    
    <!-- ================== -->
    <!-- Handle downgrading -->
    <!-- ================== -->
    
    <px:mark-transitions>
        <p:with-option name="predicate" select="'not(lang(&quot;de&quot;))'">
            <p:empty/>
        </p:with-option>
        <p:with-option name="announcement" select="'╚'">
            <p:empty/>
        </p:with-option>
        <p:with-option name="deannouncement" select="'╝'">
            <p:empty/>
        </p:with-option>
    </px:mark-transitions>
    
</p:pipeline>
