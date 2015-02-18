<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions"
    xmlns:pmml="http://www.dmg.org/PMML-4_0" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
version="1.0"
exclude-result-prefixes="xd exsl func xsi">

<xsl:output indent="yes"/>
<!--  simplifying assumptions -
    1] Rule can contain only one BBA derived from given DataField
    2] Values referenced from BBA must be contained in a field in TransformationDictionary
-->
    <!--xsl:template match="/">

        <xsl:apply-templates select="//AssociationRule[2]" mode="createQueryMain"/>
    </xsl:template-->

 <xsl:template match="AssociationRule" mode="createQueryMain">
     <xsl:processing-instruction name="oxygen">SCHSchema="http://sewebar.vse.cz/schemas/QueryByAssociationRule0_1.sch"</xsl:processing-instruction>
     <arb:ARBuilder  xmlns:arb="http://keg.vse.cz/ns/arbuilder0_1"
         xsi:schemaLocation="http://keg.vse.cz/ns/arbuilder0_1 http://sewebar.vse.cz/schemas/ARBuilder0_1.xsd"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         mode="AssociationRules">
         <!-- identifies bins used in the association rule and resolves them to values in the datadictionary
             from these values, an incomplete dictionary is cremated -->
         <xsl:variable name="mapping">
             <DictionaryMapping>
             <xsl:apply-templates select="." mode="mapping"/>
             </DictionaryMapping>
         </xsl:variable>
         <DataDescription>
         <xsl:apply-templates select="exsl:node-set($mapping)/DictionaryMapping" >
             <xsl:with-param name="dictionary">TransformationDictionary</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="exsl:node-set($mapping)/DictionaryMapping" >
             <xsl:with-param name="dictionary">DataDictionary</xsl:with-param>
         </xsl:apply-templates>
         <xsl:copy-of select="$mapping"/>
         </DataDescription>
         <QueryByAssociationRule xmlns=""
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://keg.vse.cz/ns/GUHA0.1rev1 http://sewebar.vse.cz/schemas/GUHA0.1rev1.xsd">
     <xsl:apply-templates select="." mode="query"></xsl:apply-templates>
         </QueryByAssociationRule>
         </arb:ARBuilder>
 </xsl:template>
    <xsl:template match="DictionaryMapping">
        <!-- this template creates a dictionary from a mapping -->
        <xsl:param name="dictionary"/>
        <Dictionary sourceSubType="{$dictionary}" sourceType="PMML">
            <!-- first extract field names ensuring they are unique -->
            <xsl:for-each select="ValueMapping/Field[@dictionary=$dictionary and not(@name=../preceding-sibling::ValueMapping/Field[@dictionary=$dictionary]/@name)]">
                <Field name="{@name}">
                    <!-- Create categories/intervals for each field, again observing they are unique -->
                <xsl:variable name="currentFieldName" select="@name"/>
                    <xsl:for-each select="/DictionaryMapping/ValueMapping/Field[@name=$currentFieldName and @dictionary=$dictionary]/Value[not(.=../../preceding-sibling::ValueMapping/Field[@dictionary=$dictionary]/Value)]">
                    <Category><xsl:value-of select="."/></Category>
                </xsl:for-each>
                    <xsl:for-each select="/DictionaryMapping/ValueMapping/Field[@name=$currentFieldName and @dictionary=$dictionary]/Interval[not(.=../../preceding-sibling::ValueMapping/Field[@dictionary=$dictionary]/Interval)]">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </Field>
            </xsl:for-each>
        </Dictionary>
    </xsl:template>

 <xsl:template match="AssociationRule" mode="query">
     <xsl:variable name="ante" select="@antecedent"/>
     <xsl:variable name="cons" select="@consequent | @succedent"/>
     <xsl:variable name="cond" select="@condition"/>

     <xsl:apply-templates select="../BBA[@id=$ante] | ../DBA[@id=$ante]" mode="query"/>
     <xsl:apply-templates select="../BBA[@id=$cons] | ../DBA[@id=$cons]" mode="query"/>
     <xsl:apply-templates select="../BBA[@id=$cond] | ../DBA[@id=$cond]" mode="query"/>

     <xsl:copy-of select="."/>
 </xsl:template>
    <xsl:template match="DBA" mode="query">
        <xsl:apply-templates select="BARef" mode="query"/>
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="BARef" mode="query">
        <xsl:variable name="ref" select="text()"/>
        <xsl:apply-templates select="../../BBA[@id=$ref] | ../../DBA[@id=$ref]" mode="query"/>
    </xsl:template>

    <xsl:template match="BBA" mode="query">
        <!-- makes TransformationDictionary explicit as  dictionary on FieldRef -->

        <BBA id="{@id}">
                <Text><xsl:value-of select="Text"/></Text>
        <xsl:variable name="dictionary">
            <xsl:choose>
                <xsl:when test="FieldRef/@dictionary"><xsl:value-of select="FieldRef/@dictionary"/></xsl:when>
                <xsl:otherwise>TransformationDictionary</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
            <FieldRef dictionary="{$dictionary}"><xsl:value-of select="FieldRef"/></FieldRef>
            <xsl:for-each select="CatRef">
            <CatRef><xsl:value-of select="."/></CatRef>
            </xsl:for-each>

        </BBA>
    </xsl:template>

    <xsl:template match="AssociationRule" mode="mapping">
        <xsl:variable name="ante" select="@antecedent"/>
        <xsl:variable name="cons" select="@consequent | @succedent"/>
        <xsl:variable name="cond" select="@condition"/>

        <xsl:apply-templates select="../BBA[@id=$ante] | ../DBA[@id=$ante]" mode="mapping"/>
        <xsl:apply-templates select="../BBA[@id=$cons] | ../DBA[@id=$cons]" mode="mapping"/>
        <xsl:apply-templates select="../BBA[@id=$cond] | ../DBA[@id=$cond]" mode="mapping"/>

    </xsl:template>
    <xsl:template match="DBA" mode="mapping">
        <xsl:apply-templates select="BARef" mode="mapping"/>
    </xsl:template>
    <xsl:template match="BARef" mode="mapping">
        <xsl:variable name="ref" select="text()"/>
        <xsl:apply-templates select="../../BBA[@id=$ref] | ../../DBA[@id=$ref]" mode="mapping"/>
    </xsl:template>

    <xsl:template match="BBA" mode="mapping">
        <xsl:variable name="fieldName" select="FieldRef"/>
        <xsl:variable name="dictionary" select="FieldRef/@dictionary"/>
    <xsl:choose>
        <xsl:when test="not($dictionary) or $dictionary='TransformationDictionary'">
                <xsl:apply-templates select="/pmml:PMML/pmml:TransformationDictionary/pmml:DerivedField[@name=$fieldName]" mode="mapping">
                    <xsl:with-param name="category" select="CatRef"/>
                </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
            <ValueMapping orphan="true">
                <Field name="{FieldRef}" dictionary="{$dictionary}">
                <xsl:for-each select="CatRef">
                    <Value><xsl:value-of select="."/></Value>
                </xsl:for-each>
                </Field>
            </ValueMapping>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:template>
    <xsl:template match="pmml:DerivedField" mode="mapping">
        <xsl:param name="category"></xsl:param>
<!--        <DerivedField xmlns="" name="{@name}" optype="{@optype}" dataType="{@dataType}">-->

            <xsl:apply-templates select="pmml:MapValues/pmml:InlineTable/pmml:row[pmml:field = $category]" mode="mapping"/>
            <xsl:apply-templates select="pmml:Discretize/pmml:DiscretizeBin[@binValue=$category]/pmml:Interval" mode="mapping"/>

    </xsl:template>

    <xsl:template match="pmml:MapValues/pmml:InlineTable/pmml:row" mode="mapping">
        <ValueMapping>
            <Field name="{../../pmml:FieldColumnPair/@field}" dictionary="TransformationDictionary"><Value><xsl:value-of select="pmml:field"/></Value></Field>
            <Field name="{../../pmml:FieldColumnPair/@column}" dictionary="DataDictionary"><Value><xsl:value-of select="pmml:column"/></Value></Field>
        </ValueMapping>
    </xsl:template>

    <xsl:template match="pmml:Interval" mode="mapping">
        <ValueMapping>
            <Field name="{../../../@name}" dictionary="TransformationDictionary"><Value><xsl:value-of select="../@binValue"/></Value></Field>
            <Field name="{../../@field}" dictionary="DataDictionary"><Interval xmlns="" closure="{@closure}" leftMargin="{@leftMargin}" rightMargin="{@rightMargin}"/></Field>
        </ValueMapping>
    </xsl:template>

</xsl:stylesheet>