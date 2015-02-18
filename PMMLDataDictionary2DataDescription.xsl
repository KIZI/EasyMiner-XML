<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xd"
    version="1.0" xmlns:pmml = "http://www.dmg.org/PMML-4_0"
    xmlns:dd =  "http://keg.vse.cz/ns/datadescription0_1"   >
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 17, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> tomas</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates select="pmml:PMML/pmml:DataDictionary"></xsl:apply-templates>
    </xsl:template>
    <xsl:template match="pmml:DataDictionary">
        <dd:DataDescription xsi:schemaLocation="http://keg.vse.cz/ns/datadescription0_1 http://sewebar.vse.cz/schemas/DataDescription0_1.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Dictionary numberOfFields="{@numberOfFields}" sourceType="PMML" sourceName="/pmml:PMML/pmml:Header/pmml:Extension[@name='metabase']/@value">
                <xsl:apply-templates select="pmml:DataField"></xsl:apply-templates>
            </Dictionary>
        </dd:DataDescription>
    </xsl:template>
    <xsl:template match="pmml:DataField">
        <Field name="{@name}" optype="{@optype}" dataType="{@dataType}">
            <xsl:apply-templates></xsl:apply-templates>
        </Field>
    </xsl:template>
    <xsl:template match="pmml:Interval">
        <Interval closure="{@closure}" leftMargin="{@leftMargin}" rightMargin="{@rightMargin}"/>
    </xsl:template>
    <xsl:template match="pmml:Value">
        <Category><xsl:value-of select="@value"/></Category>
    </xsl:template>
</xsl:stylesheet>