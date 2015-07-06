<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:p="http://www.dmg.org/PMML-4_0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common"
                xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz"
                xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
                extension-element-prefixes="func exsl"
                exclude-result-prefixes="p xsi keg guha">
  <!-- Obsahuje slovnik mer zajimavosti - nazvy pouzite v ruznych systemech Ferda, LISp-Miner a mapuje je na jeden spolecny nazev pomoci obsazene funkce -->
  <!-- TODO??? Z duvodu vyuziti funkce keg:translateInterestMeasure i v jinem stylu je tato funkce umistena v  InterestMeasureDictionary.xsl a ne zde-->
  <xsl:variable name="InterestMeasureDictionary"
                select="document('../dict/GUHAQuantifier-InterestMeasureDictionary.xml')"/>

  <xsl:param name="roundTo" select="1000"/>
  <xsl:variable name="basePresent" select="
       count(/p:PMML/guha:AssociationModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/InterestMeasure[text() = 'Support' or text() = 'BASE'])
     + count(/p:PMML/guha:SD4ftModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/Extension[@name='ShortName' and (text() = 'Support' or text() = 'BASE')])
     + count(/p:PMML/guha:Ac4ftModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/Extension[@name='ShortName' and (text() = 'Support' or text() = 'BASE')])
  "/>
  <xsl:variable name="numberOfQuantifiers"
                select="
       count(/p:PMML/guha:AssociationModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/InterestMeasure[not(text() = '')])
     + count(/p:PMML/guha:AssociationModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/Formula[not(@name = '')])
     + count(/p:PMML/guha:SD4ftModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/InterestMeasure[not(text() = '')])
     + count(/p:PMML/guha:SD4ftModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/Formula[not(@name = '')])
     + count(/p:PMML/guha:Ac4ftModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/InterestMeasure[not(text() = '')])
     + count(/p:PMML/guha:Ac4ftModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/Formula[not(@name = '')])
   "/>
  <xsl:variable name="encloseQuantifiersInBrackets"
                select="($numberOfQuantifiers > 1 and $basePresent = 0) or ($numberOfQuantifiers > 2)"></xsl:variable>
  <xsl:variable name="contentsQuantifier">
    <xsl:variable name="quantifiers">
      <xsl:for-each select="
         /p:PMML/guha:AssociationModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/InterestMeasure
       | /p:PMML/guha:AssociationModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/Formula
       | /p:PMML/guha:SD4ftModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/InterestMeasure
       | /p:PMML/guha:SD4ftModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/Formula
       | /p:PMML/guha:Ac4ftModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/InterestMeasure
       | /p:PMML/guha:Ac4ftModel/TaskSetting/InterestMeasureSetting/InterestMeasureThreshold/Formula
      ">
        <xsl:if test="
          ($numberOfQuantifiers>1 and text()!='BASE' and text()!='Support')
          or ($numberOfQuantifiers>1 and @name!='BASE' and @name!='Support')
          or $numberOfQuantifiers=1">
          <span title="{text() | @name}">
            <xsl:copy-of select="keg:selectQuantifier(text() | @name,'1')"/>
          </span>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$encloseQuantifiersInBrackets='true'">
        &#9001;
        <xsl:copy-of select="$quantifiers"/>
        &#9002;
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$quantifiers"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <func:function name="keg:translateInterestMeasure">
    <!-- parametr name je volitelny. povinny je tehdy, pokud nezname id prekladaneho vyrazu, coz nastava pri prekladu z XML-->
    <xsl:param name="name"/>
    <xsl:param name="type"/>
    <!-- InterestMeasure nebo TestCriterion -->
    <xsl:param name="fromLang"/>
    <xsl:param name="toLang"/>
    <xsl:variable name="translated">
      <xsl:choose>
        <xsl:when test="$type='InterestMeasure'">
          <xsl:value-of
              select="exsl:node-set($InterestMeasureDictionary)/InterestMeasures/InterestMeasure[str/@lang='pmml' and str=$name]/str[@lang=$toLang]"/>
        </xsl:when>
        <xsl:when test="$type='TestCriterion'">
          <xsl:value-of
              select="exsl:node-set($InterestMeasureDictionary)/InterestMeasures/InterestMeasure/TestCriteria/TestCriterion[str/@lang=$fromLang and str=$name]/str[@lang=$toLang]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'keg:translateInterestMeasure - unable to translate'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$translated and not($translated='')">
        <func:result select="concat($translated, ' ')"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="concat($name, ' ')"/>
      </xsl:otherwise>
    </xsl:choose>
  </func:function>

  <func:function name="keg:selectQuantifier">
    <xsl:param name="quantifierName"/>
    <xsl:param name="arrowOnly"/>
    <!--
    <xsl:variable name="quantifierTreshold" select="round($qTreshold * $roundTo) div $roundTo" />
    <xsl:variable name="quantifierSigLev"  select="round($qSigLev * $roundTo) div $roundTo" />
    <xsl:variable name="baseVal" select="round($bVal * $roundTo) div $roundTo" />
    -->
    <xsl:variable name="Symbol"
                  select="exsl:node-set($InterestMeasureDictionary)//InterestMeasure[str[@lang='MasterName']=$quantifierName]/Symbol/node()"/>
    <xsl:variable name="vrat">
      <xsl:choose>
        <xsl:when test="$numberOfQuantifiers>1 and $quantifierName='Support'">
          <!-- if there is support and also some other quantifier, skip support as it is part of the other quantifier -->
        </xsl:when>
        <xsl:otherwise>
          <span title="{$quantifierName}">
            <xsl:text> </xsl:text>
            <!--<xsl:copy-of select="' '"/>-->
            <xsl:copy-of select="$Symbol"/>
            <xsl:text> </xsl:text>
            <!--<xsl:copy-of select="' '"/>-->
            <xsl:if test="not($Symbol)">?</xsl:if>
          </span>
          <xsl:if test="last() > position() and ($numberOfQuantifiers - $basePresent) > 1">
            <xsl:text> ,  </xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <func:result select="$vrat"/>
  </func:function>
</xsl:stylesheet>
