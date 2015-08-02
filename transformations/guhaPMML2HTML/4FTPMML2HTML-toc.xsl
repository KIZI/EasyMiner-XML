<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:p="http://www.dmg.org/PMML-4_0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common"
                xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz"
                xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
                extension-element-prefixes="func exsl"
                exclude-result-prefixes="p xsi keg guha">
  <!-- ==============================
       Section 1+2 - Data description
       ============================== -->
  <xsl:template match="p:DataDictionary" mode="toc">
    <ol>
      <xsl:apply-templates select="p:DataField" mode="toc"/>
    </ol>
  </xsl:template>

  <xsl:template match="p:DataField" mode="toc">
    <li>
      <xsl:apply-templates select="." mode="odkaz"/>
    </li>
  </xsl:template>

  <xsl:template match="p:DataField" mode="odkaz">
    <a href="#sect2-{@name}">
      <xsl:value-of select="@name"/>
    </a>
  </xsl:template>
  <!-- ==============================
       Section 3 - Created Attributes
       ============================== -->
  <xsl:template match="p:TransformationDictionary" mode="toc">
    <ol>
      <xsl:apply-templates select="p:DerivedField" mode="toc"/>
    </ol>
  </xsl:template>

  <xsl:template match="p:DerivedField" mode="toc">
    <li>
      <xsl:apply-templates select="." mode="odkaz"/>
    </li>
  </xsl:template>
  <xsl:template match="p:DerivedField" mode="odkaz">
    <a href="#sect3-{@name}">
      <xsl:value-of select="@name"/>
    </a>
  </xsl:template>

  <!-- =========================
       Section 4 - Task settings
       ========================= -->
  <xsl:template match="TaskSetting" mode="toc">
    <!-- from 4FTPMML2HTML-sect4 -->
    <xsl:call-template name="TaskSettingRulePattern">
      <xsl:with-param name="arrowOnly" select="1"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ==========================
       Section 5 - Discovered ARs
       ========================== -->
  <xsl:template match="guha:AssociationModel" mode="toc">
    <xsl:variable name="numberOfRules" select="count(/p:PMML/guha:AssociationModel/AssociationRules/AssociationRule)"/>
    <xsl:choose>
      <xsl:when test="$numberOfRules>0">
        <ol>
          <xsl:apply-templates
              select="AssociationRules/AssociationRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]"
              mode="toc"/>
        </ol>
      </xsl:when>
      <xsl:when test="$numberOfRules=0">
        <p style="color: red">
          <xsl:copy-of select="keg:translate('No rules found',191)"/>
        </p>
      </xsl:when>
      <xsl:when test="$numberOfRules &gt; $maxRulesToList">
        <p style="color: red">
          <xsl:copy-of select="keg:translate('Exceeded',190)"/>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:copy-of select="keg:translate('first',200)"/>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:copy-of select="keg:translate('from the total number of',210)"/>
          <xsl:value-of select="count(AssociationRule)"/>
          <xsl:copy-of select="keg:translate('rules',220)"/>.
        </p>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="guha:SD4ftModel" mode="toc">
    <xsl:variable name="numberOfRules" select="count(/p:PMML/guha:SD4ftModel/SD4ftRules/SD4ftRule)"/>
    <xsl:choose>
      <xsl:when test="$numberOfRules>0">
        <ol>
          <xsl:apply-templates select="SD4ftRules/SD4ftRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]"
                               mode="toc"/>
        </ol>
      </xsl:when>
      <xsl:when test="$numberOfRules=0">
        <p style="color: red">
          <xsl:copy-of select="keg:translate('No rules found',191)"/>
        </p>
      </xsl:when>
      <xsl:when test="$numberOfRules &gt; $maxRulesToList">
        <p style="color: red">
          <xsl:copy-of select="keg:translate('Exceeded',190)"/>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:copy-of select="keg:translate('first',200)"/>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:copy-of select="keg:translate('from the total number of',210)"/>
          <xsl:value-of select="count(SD4ftRule)"/>
          <xsl:copy-of select="keg:translate('rules',220)"/>.
        </p>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="guha:Ac4ftModel" mode="toc">
    <xsl:variable name="numberOfRules" select="count(/p:PMML/guha:Ac4ftModel/Ac4ftRules/Ac4ftRule)"/>
    <xsl:choose>
      <xsl:when test="$numberOfRules>0">
        <ol>
          <xsl:apply-templates select="Ac4ftRules/Ac4ftRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]"
                               mode="toc"/>
        </ol>
      </xsl:when>
      <xsl:when test="$numberOfRules=0">
        <p style="color: red">
          <xsl:copy-of select="keg:translate('No rules found',191)"/>
        </p>
      </xsl:when>
      <xsl:when test="$numberOfRules &gt; $maxRulesToList">
        <p style="color: red">
          <xsl:copy-of select="keg:translate('Exceeded',190)"/>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:copy-of select="keg:translate('first',200)"/>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:copy-of select="keg:translate('from the total number of',210)"/>
          <xsl:value-of select="count(Ac4ftRule)"/>
          <xsl:copy-of select="keg:translate('rules',220)"/>.
        </p>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="guha:CFMinerModel" mode="toc">
    <xsl:variable name="numberOfRules" select="count(/p:PMML/guha:CFMinerModel/CFMinerRules/CFMinerRule)"/>
    <xsl:choose>
      <xsl:when test="$numberOfRules>0">
        <ol>
          <xsl:apply-templates
              select="CFMinerRules/CFMinerRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]" mode="toc"/>
        </ol>
      </xsl:when>
      <xsl:when test="$numberOfRules=0">
        <p style="color: red">
          <xsl:copy-of select="keg:translate('No rules found',191)"/>
        </p>
      </xsl:when>
      <xsl:when test="$numberOfRules &gt; $maxRulesToList">
        <p style="color: red">
          <xsl:copy-of select="keg:translate('Exceeded',190)"/>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:copy-of select="keg:translate('first',200)"/>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:copy-of select="keg:translate('from the total number of',210)"/>
          <xsl:value-of select="count(CFMinerRule)"/>
          <xsl:copy-of select="keg:translate('rules',220)"/>.
        </p>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="AssociationRule | SD4ftRule | Ac4ftRule | CFMinerRule" mode="toc">
    <li>
      <xsl:variable name="ruleClass">
        <xsl:if test="./Extension[@name='mark']/@value='interesting'">selectedRuleA</xsl:if>
      </xsl:variable>
      <a href="#sect5-rule{position()}" class="{$ruleClass}">
        <!-- from 4FTPMML2HTML-sect5 -->
        <xsl:apply-templates select="." mode="ruleBody">
          <xsl:with-param name="arrowOnly" select="1"/>
        </xsl:apply-templates>

      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>