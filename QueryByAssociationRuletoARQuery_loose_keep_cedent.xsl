<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions"
    xmlns:pmml="http://www.dmg.org/PMML-4_0" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"    
    exclude-result-prefixes="xd exsl arb func pmml xsi" version="1.0" 
xmlns:arb="http://keg.vse.cz/ns/arbuilder0_1"
    >

<xsl:output indent="yes"/>
<!--
Warning! This query is not maintained

Input:   This stylesheet processes documents conforming to ARBuilder0_1.xsd QueryByAssociationRule model
Output:  An association rule complying to the query created by this stylesheet contains the same set of BBAs, placed in the same part of the rule as in the input AR.
    Logical connectives including negation are not considered.

  simplifying assumptions - 
    1] Rule can contain only one BBA derived from given DataField
    2] Values referenced from BBA must be contained in a field in TransformationDictionary 

    
-->    
    
    
    <xsl:template match="/arb:ARBuilder">
        <arb:ARBuilder  xsi:schemaLocation="http://keg.vse.cz/ns/arbuilder0_1 http://sewebar.vse.cz/schemas/ARBuilder0_1.xsd">
        <xsl:copy-of select="DataDescription"/>
        <xsl:apply-templates select="QueryByAssociationRule"/>
        </arb:ARBuilder>
    </xsl:template>
    
    
 
    
    <xsl:template match="QueryByAssociationRule">
        <xsl:variable name="ante" select="AssociationRule/@antecedent"/>
        <xsl:variable name="cons" select="AssociationRule/@consequent | AssociationRule/@succedent"/>
        <xsl:variable name="cond" select="AssociationRule/@condition"/>
                           
     <ARQuery>
         <BBASettings>
             <xsl:apply-templates select="BBA"/>
         </BBASettings>
         <DBASettings>
             <xsl:apply-templates select="DBA[@connective!='Literal']"/>
             <xsl:apply-templates select="DBA[@connective='Literal']"/>
         </DBASettings>          
         <xsl:if test="$ante" >
             <AntecedentSetting><xsl:value-of select="$ante"/></AntecedentSetting>
          </xsl:if>
         <ConsequentSetting><xsl:value-of select="$cons"/></ConsequentSetting>
         <xsl:if test="$cond">
         <ConditionSetting><xsl:value-of select="$cond"/></ConditionSetting>
         </xsl:if>
         <InterestMeasureSetting>
             <InterestMeasureThreshold id="1">
                 <InterestMeasure>Any Interest Measure</InterestMeasure>
             </InterestMeasureThreshold>
         </InterestMeasureSetting>         
     </ARQuery>
       
    </xsl:template>
    
    <xsl:template match="DBA[not(@literal='true')]">        
        <xsl:if test="BARef"></xsl:if>
        <DBASetting id="{@id}" type="Any" match="traverseOnly"> <!-- requireListed_exclusive, requireListed_notexclusive - complementWithUnlisted, traverseOnly (DBASetting only)- no match required but proceed to children, requirePresence (DBA Only)-->
            <xsl:for-each select="BARef">
                <BASettingRef><xsl:value-of select="."/></BASettingRef>
            </xsl:for-each>                        
        </DBASetting>    
    </xsl:template>
    
    <!-- DBA references negated BBA -->
    <xsl:template match="DBA[@literal='true']">        
        <DBASetting  id="{@id}" type="Literal">            
            <xsl:for-each select="BARef">
                <BASettingRef><xsl:value-of select="."/></BASettingRef>
            </xsl:for-each>        
            <LiteralSign>Both</LiteralSign>
        </DBASetting>                
    </xsl:template>
    
    <xsl:template match="BARef" mode="query" >
        <xsl:variable name="ref" select="text()"/>        
            <xsl:apply-templates select="../../BBA[@id=$ref] | ../../DBA[@id=$ref]" />
                    
    </xsl:template>
    
    <xsl:template match="BBA">
        <!-- makes TransformationDictionary explicit as  dictionary on FieldRef -->
        <xsl:choose>
            <xsl:when test="@literal='false'">
                
            </xsl:when>
            <xsl:otherwise>
                
            </xsl:otherwise>
        </xsl:choose>
        
        <BBASetting id="{@id}">
                <Text><xsl:value-of select="Text"/></Text>
            <xsl:variable name="dictionary">
                <xsl:choose>
                    <xsl:when test="FieldRef/@dictionary"><xsl:value-of select="FieldRef/@dictionary"/></xsl:when>
                    <xsl:when test="/arb:ARBuilder/DataDescription/Dictionary/@default='true'"><xsl:value-of select="/arb:ARBuilder/DataDescription/Dictionary[@default='true']/@sourceSubType"/></xsl:when>
                    <xsl:otherwise>TransformationDictionary</xsl:otherwise>
                </xsl:choose>            
            </xsl:variable>
            <FieldRef dictionary="{$dictionary}"><xsl:value-of select="FieldRef"/></FieldRef>
            
            <Coefficient>                          
                <Type>At least one from listed</Type>
                <xsl:for-each select="CatRef">
                    <Category><xsl:value-of select="."/></Category>
                </xsl:for-each>
            </Coefficient>                                 
        </BBASetting>
    </xsl:template>    
    

</xsl:stylesheet>