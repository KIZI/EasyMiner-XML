<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="1.0" xmlns:x="http://www.topicmaps.org/xtm/1.0/" 
     
    >
    <xsl:output method="xml" indent="yes" />
    <xsl:param name="ontologyName" select="'Barbora'"></xsl:param>
    
    <xsl:template match="/result">
        <Dictionary xmlns="http://keg.vse.cz/ns/datadescription0_1"  xmlns:d="http://keg.vse.cz/ns/datadescription0_1"  
            sourceName="{$ontologyName}" sourceType="BKEF" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://keg.vse.cz/ns/datadescription0_1 http://sewebar.vse.cz/schemas/DataDescription0_1.xsd">
            <xsl:apply-templates select="row[not(value[1] = preceding-sibling::node()/value[1])]" />
        </Dictionary>
    </xsl:template>
<xsl:template match="row">    
            <Field name="{value[1]}" optype="categorical" dataType="string"  xmlns="http://keg.vse.cz/ns/datadescription0_1" derived="true">
                <AuxilliaryIdentifier display="true">
                    <Name>Preprocessing Hint</Name>
                    <Value><xsl:value-of select="value[2]"/></Value>
                </AuxilliaryIdentifier>
                <AuxilliaryIdentifier display="false">
                    <Name>Bin Type</Name>
                    <Value><xsl:value-of select="value[4]"/></Value>
                </AuxilliaryIdentifier>
                <xsl:for-each select=".|following-sibling::node()[value[1]=current()/value[1]]">
                    <Category><xsl:value-of select="value[3]"/></Category>                                                 
                </xsl:for-each>
            </Field>             
</xsl:template>
</xsl:stylesheet>
