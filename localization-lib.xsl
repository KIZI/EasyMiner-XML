<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  version="1.0"  
    xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz"
    extension-element-prefixes="func exsl"
    exclude-result-prefixes="keg">

    <!-- MASTER COPY OF THIS TEMPLATE IS LOCATED AT
        sewebar-cms/Specifications/XSLLibraries/
        -->

<!-- When including to other stylesheet,
    se the $LocalizationDictionary variable first
-->

    <!-- Funkce realizujici vkladani textovych retezcu z XSLT do aktualniho jazyka a  pro preklad retezcu z XML. Pokud funkce nenalezne preklad ve slovniku, vrati hodnotu parametru name-->    
    <func:function name="keg:translate">
        <!-- parametr name je volitelny. povinny je tehdy, pokud nezname id prekladaneho vyrazu, coz nastava pri prekladu z XML-->    
        <xsl:param name="name"/>
        <!-- parametr id je volitelny, jeho pouziti je pro preklad vkladani textovych retezcu z XSLT-->    
        <xsl:param name="id" select="-1"/>
        <!-- u parametru from ponechat vychozi hodnotu-->    
        <xsl:param name="from">en</xsl:param>        
        <xsl:variable name="translated" select="exsl:node-set($LocalizationDictionary)/Dictionary/Entry[str/@lang=$from and (@id=$id or str=$name)]/str[@lang=$reportLang]"></xsl:variable>
        <xsl:variable name="outputString">
            <xsl:choose>                
                <xsl:when test="$translated"><xsl:value-of select="concat($translated, ' ')"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="concat($name, ' ')"/></xsl:otherwise>
            </xsl:choose>                               
        </xsl:variable>
        <xsl:variable name="visualization" select="exsl:node-set($LocalizationDictionary)/Dictionary/Entry[str/@lang=$from and (@id=$id or str=$name)]/Visualization"></xsl:variable>
        <xsl:choose>                
            <xsl:when test="$visualization='box'">
                <func:result>
                    <div class="box">
                        <xsl:value-of select="$outputString"/>
                    </div>
                </func:result>
            </xsl:when>
            <xsl:otherwise><func:result select="$outputString"/></xsl:otherwise>
        </xsl:choose>                           
    </func:function>
    
    
</xsl:stylesheet>
