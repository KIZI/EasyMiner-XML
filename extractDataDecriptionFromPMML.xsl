<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xd"
    version="2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:pmml="http://www.dmg.org/PMML-4_0" xmlns:data="http://keg.vse.cz/ns/datadescription0_1"   
    >
    <xsl:output indent="yes"/>
    <xsl:template match="/">
        <data:DataDescription xsi:schemaLocation="http://keg.vse.cz/ns/datadescription0_1 http://sewebar.vse.cz/schemas/DataDescription0_1.xsd">
            <Dictionary sourceSubType="TransformationDictionary" sourceType="PMML" default="true" sourceName="{pmml:PMML/pmml:Header/pmml:Extension[@name='dataset']/@value}">            
            <xsl:apply-templates select="pmml:PMML/pmml:TransformationDictionary"/>
            </Dictionary>
        </data:DataDescription>
    </xsl:template>
    <xsl:template match="pmml:TransformationDictionary">
        <xsl:apply-templates select="pmml:DerivedField/pmml:MapValues/pmml:InlineTable"/>
        <xsl:apply-templates select="pmml:DerivedField/pmml:Discretize"/>        
    </xsl:template>
    <xsl:template match="pmml:DerivedField/pmml:MapValues/pmml:InlineTable">        
        <Field name="{../@outputColumn}" dataType="string">
            <xsl:for-each-group  select="pmml:row" group-by="pmml:field">
                <Category><xsl:value-of select="current-grouping-key()"/></Category>
            </xsl:for-each-group>
        </Field>
    </xsl:template>
    <xsl:template match="pmml:Discretize">
        <Field name="{@field}">
            
            <xsl:for-each select="pmml:DiscretizeBin">
                <Category><xsl:value-of select="@binValue"/></Category>
            </xsl:for-each>
        
        </Field>            
    </xsl:template>
</xsl:stylesheet>