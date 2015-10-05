<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:p="http://www.dmg.org/PMML-4_0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
                exclude-result-prefixes="p xsi guha">

  <!-- Parametr maxValuesToList omezuje pocet kategorii (hodnot sloupce), ktere mohou byt v 2. oddilu vypsany. Pokud pocet kategorii prekroci hodnotu parametru je vypsano varovani. -->
  <xsl:param name="maxValuesToList" select="100"/>
  <!-- Maximalni pocet vypisovanych kategorii do tabulek popisujicich transformace vstupnich sloupcu na atributy -->
  <xsl:param name="maxCategoriesToList" select="100"/>
  <!-- Parametr maxRulesToList omezuje pocet pravidel, ktere mohou byt v vypsany. Pokud pocet pravidel prekroci hodnotu parametru je vypsano varovani. -->
  <xsl:param name="maxRulesToList" select="1000"/>
  <!-- maximal number of items to show in graph -->
  <xsl:param name="maxCategoriesToListInGraphs" select="100"/>

  <xsl:output method="xml" encoding="utf-8"/>

  <!-- Parametr contentOnly slouzi k potlaceni generovani hlavicky HTML a elementu html, head a body. V pripade, ze je atribut nastaven, vygeneruje se jen obsah elementu body pro pouziti ve slozitejsich dokumentech. Pravidla jsou vypisovana na zaklade jejich poradi v PMML souboru. -->
  <xsl:param name="contentOnly" select="false()"/>
  <xsl:param name="loadJQuery" select="true()"/>
  <!-- Parametry pro nastaveni znaku nebo retezce znaku reprezentujiciho logicke operatory -->
  <xsl:param name="NullName" select="'Null'"/>
  <xsl:param name="notOperator" select="' &#x00AC;'"/>
  <xsl:param name="andOperator" select="' &amp; '"/>
  <xsl:param name="orOperator" select="' &#x02228; '"/>
  <xsl:param name="implyOperator" select="' &#8594; '"/>
  <xsl:param name="notAvailable" select="'NA'"/>
  <xsl:param name="reportLang" select="'cs'"/>
  <xsl:param name="contentsQuantifier" select="' &#x21D2; '"/>
  <!-- Polozky Support a Confidence jsou systemove, pouzivaji se pro preklad nazvu povinnych PMML atributu -->

  <!-- Obsahuje slovnik pojmu generovanych xslt transformaci v ruznych jazycich-->
  <xsl:variable name="LocalizationDictionary" select="document('pmml/dict/PMMLDictionary.xml')"/>

  <!-- Obsahuje lokalizaci znacek vkladanych pro gInclude (nadpisy pro fragmenty dokumentu)-->
  <xsl:variable name="ContentTagsDictionary" select="document('pmml/dict/PMMLContentTagsDictionary.xml')"/>

  <!-- region Transformation root - everyting begins here -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$contentOnly">
        <xsl:call-template name="resources"/>
        <xsl:apply-templates select="/p:PMML" mode="body"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"&gt;</xsl:text>
        <html>
          <head>
            <xsl:call-template name="resources"/>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <title>
              <xsl:value-of
                  select="/p:PMML/guha:AssociationModel/@modelName | /p:PMML/guha:SD4ftModel/@modelName | /p:PMML/guha:Ac4ftModel/@modelName | /p:PMML/guha:CFMinerModel/@modelName"/>
              -
              <xsl:text>Description of Data Mining Task</xsl:text>
            </title>
          </head>
          <body>
            <xsl:apply-templates select="/p:PMML" mode="body"/>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--endregion-->

  <!-- region TOC
      Section 1+2 - Data description
      -->
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
          <xsl:text>No rules found</xsl:text>
        </p>
      </xsl:when>
      <xsl:when test="$numberOfRules &gt; $maxRulesToList">
        <p style="color: red">
          <xsl:text>Exceeded </xsl:text>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:text> first </xsl:text>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:text> from the total number of </xsl:text>
          <xsl:value-of select="count(AssociationRule)"/>
          <xsl:text> rules</xsl:text>
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
          <xsl:text>No rules found</xsl:text>
        </p>
      </xsl:when>
      <xsl:when test="$numberOfRules &gt; $maxRulesToList">
        <p style="color: red">
          <xsl:text>Exceeded </xsl:text>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:text> first </xsl:text>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:text> from the total number of </xsl:text>
          <xsl:value-of select="count(SD4ftRule)"/>
          <xsl:text> rules.</xsl:text>
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
          <xsl:text>No rules found</xsl:text>
        </p>
      </xsl:when>
      <xsl:when test="$numberOfRules &gt; $maxRulesToList">
        <p style="color: red">
          <xsl:text>Exceeded </xsl:text>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:text> first </xsl:text>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:text> from the total number of </xsl:text>
          <xsl:value-of select="count(Ac4ftRule)"/>
          <xsl:text> rules.</xsl:text>.
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
          <xsl:text>No rules found</xsl:text>
        </p>
      </xsl:when>
      <xsl:when test="$numberOfRules &gt; $maxRulesToList">
        <p style="color: red">
          <xsl:text>Exceeded </xsl:text>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:text> first </xsl:text>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:text> from the total number of </xsl:text>
          <xsl:value-of select="count(CFMinerRule)"/>
          <xsl:text> rules.</xsl:text>
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

  <!--endregion-->

  <!--region main template-->
  <xsl:template name="resources">
    <xsl:param name="loadJquery" select="true()"/>
    <style type="text/css">
      <xsl:text disable-output-escaping="yes">
        <!--main styles-->
        <![CDATA[
          td.bg0p{background:transparent !important;background:rgba(180,232,215,0) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 0%,transparent 0%,transparent 100%) !important}td.bg1p{background:transparent !important;background:rgba(180,232,215,0.01) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 1%,transparent 1%,transparent 100%) !important}td.bg2p{background:transparent !important;background:rgba(180,232,215,0.02) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 2%,transparent 2%,transparent 100%) !important}td.bg3p{background:transparent !important;background:rgba(180,232,215,0.03) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 3%,transparent 3%,transparent 100%) !important}td.bg4p{background:transparent !important;background:rgba(180,232,215,0.04) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 4%,transparent 4%,transparent 100%) !important}td.bg5p{background:transparent !important;background:rgba(180,232,215,0.05) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 5%,transparent 5%,transparent 100%) !important}td.bg6p{background:transparent !important;background:rgba(180,232,215,0.06) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 6%,transparent 6%,transparent 100%) !important}td.bg7p{background:transparent !important;background:rgba(180,232,215,0.07) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 7%,transparent 7%,transparent 100%) !important}td.bg8p{background:transparent !important;background:rgba(180,232,215,0.08) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 8%,transparent 8%,transparent 100%) !important}td.bg9p{background:transparent !important;background:rgba(180,232,215,0.09) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 9%,transparent 9%,transparent 100%) !important}td.bg10p{background:transparent !important;background:rgba(180,232,215,0.1) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 10%,transparent 10%,transparent 100%) !important}td.bg11p{background:transparent !important;background:rgba(180,232,215,0.11) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 11%,transparent 11%,transparent 100%) !important}td.bg12p{background:transparent !important;background:rgba(180,232,215,0.12) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 12%,transparent 12%,transparent 100%) !important}td.bg13p{background:transparent !important;background:rgba(180,232,215,0.13) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 13%,transparent 13%,transparent 100%) !important}td.bg14p{background:transparent !important;background:rgba(180,232,215,0.14) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 14%,transparent 14%,transparent 100%) !important}td.bg15p{background:transparent !important;background:rgba(180,232,215,0.15) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 15%,transparent 15%,transparent 100%) !important}td.bg16p{background:transparent !important;background:rgba(180,232,215,0.16) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 16%,transparent 16%,transparent 100%) !important}td.bg17p{background:transparent !important;background:rgba(180,232,215,0.17) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 17%,transparent 17%,transparent 100%) !important}td.bg18p{background:transparent !important;background:rgba(180,232,215,0.18) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 18%,transparent 18%,transparent 100%) !important}td.bg19p{background:transparent !important;background:rgba(180,232,215,0.19) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 19%,transparent 19%,transparent 100%) !important}td.bg20p{background:transparent !important;background:rgba(180,232,215,0.2) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 20%,transparent 20%,transparent 100%) !important}td.bg21p{background:transparent !important;background:rgba(180,232,215,0.21) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 21%,transparent 21%,transparent 100%) !important}td.bg22p{background:transparent !important;background:rgba(180,232,215,0.22) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 22%,transparent 22%,transparent 100%) !important}td.bg23p{background:transparent !important;background:rgba(180,232,215,0.23) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 23%,transparent 23%,transparent 100%) !important}td.bg24p{background:transparent !important;background:rgba(180,232,215,0.24) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 24%,transparent 24%,transparent 100%) !important}td.bg25p{background:transparent !important;background:rgba(180,232,215,0.25) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 25%,transparent 25%,transparent 100%) !important}td.bg26p{background:transparent !important;background:rgba(180,232,215,0.26) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 26%,transparent 26%,transparent 100%) !important}td.bg27p{background:transparent !important;background:rgba(180,232,215,0.27) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 27%,transparent 27%,transparent 100%) !important}td.bg28p{background:transparent !important;background:rgba(180,232,215,0.28) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 28%,transparent 28%,transparent 100%) !important}td.bg29p{background:transparent !important;background:rgba(180,232,215,0.29) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 29%,transparent 29%,transparent 100%) !important}td.bg30p{background:transparent !important;background:rgba(180,232,215,0.3) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 30%,transparent 30%,transparent 100%) !important}td.bg31p{background:transparent !important;background:rgba(180,232,215,0.31) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 31%,transparent 31%,transparent 100%) !important}td.bg32p{background:transparent !important;background:rgba(180,232,215,0.32) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 32%,transparent 32%,transparent 100%) !important}td.bg33p{background:transparent !important;background:rgba(180,232,215,0.33) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 33%,transparent 33%,transparent 100%) !important}td.bg34p{background:transparent !important;background:rgba(180,232,215,0.34) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 34%,transparent 34%,transparent 100%) !important}td.bg35p{background:transparent !important;background:rgba(180,232,215,0.35) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 35%,transparent 35%,transparent 100%) !important}td.bg36p{background:transparent !important;background:rgba(180,232,215,0.36) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 36%,transparent 36%,transparent 100%) !important}td.bg37p{background:transparent !important;background:rgba(180,232,215,0.37) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 37%,transparent 37%,transparent 100%) !important}td.bg38p{background:transparent !important;background:rgba(180,232,215,0.38) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 38%,transparent 38%,transparent 100%) !important}td.bg39p{background:transparent !important;background:rgba(180,232,215,0.39) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 39%,transparent 39%,transparent 100%) !important}td.bg40p{background:transparent !important;background:rgba(180,232,215,0.4) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 40%,transparent 40%,transparent 100%) !important}td.bg41p{background:transparent !important;background:rgba(180,232,215,0.41) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 41%,transparent 41%,transparent 100%) !important}td.bg42p{background:transparent !important;background:rgba(180,232,215,0.42) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 42%,transparent 42%,transparent 100%) !important}td.bg43p{background:transparent !important;background:rgba(180,232,215,0.43) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 43%,transparent 43%,transparent 100%) !important}td.bg44p{background:transparent !important;background:rgba(180,232,215,0.44) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 44%,transparent 44%,transparent 100%) !important}td.bg45p{background:transparent !important;background:rgba(180,232,215,0.45) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 45%,transparent 45%,transparent 100%) !important}td.bg46p{background:transparent !important;background:rgba(180,232,215,0.46) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 46%,transparent 46%,transparent 100%) !important}td.bg47p{background:transparent !important;background:rgba(180,232,215,0.47) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 47%,transparent 47%,transparent 100%) !important}td.bg48p{background:transparent !important;background:rgba(180,232,215,0.48) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 48%,transparent 48%,transparent 100%) !important}td.bg49p{background:transparent !important;background:rgba(180,232,215,0.49) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 49%,transparent 49%,transparent 100%) !important}td.bg50p{background:transparent !important;background:rgba(180,232,215,0.5) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 50%,transparent 50%,transparent 100%) !important}td.bg51p{background:transparent !important;background:rgba(180,232,215,0.51) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 51%,transparent 51%,transparent 100%) !important}td.bg52p{background:transparent !important;background:rgba(180,232,215,0.52) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 52%,transparent 52%,transparent 100%) !important}td.bg53p{background:transparent !important;background:rgba(180,232,215,0.53) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 53%,transparent 53%,transparent 100%) !important}td.bg54p{background:transparent !important;background:rgba(180,232,215,0.54) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 54%,transparent 54%,transparent 100%) !important}td.bg55p{background:transparent !important;background:rgba(180,232,215,0.55) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 55%,transparent 55%,transparent 100%) !important}td.bg56p{background:transparent !important;background:rgba(180,232,215,0.56) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 56%,transparent 56%,transparent 100%) !important}td.bg57p{background:transparent !important;background:rgba(180,232,215,0.57) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 57%,transparent 57%,transparent 100%) !important}td.bg58p{background:transparent !important;background:rgba(180,232,215,0.58) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 58%,transparent 58%,transparent 100%) !important}td.bg59p{background:transparent !important;background:rgba(180,232,215,0.59) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 59%,transparent 59%,transparent 100%) !important}td.bg60p{background:transparent !important;background:rgba(180,232,215,0.6) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 60%,transparent 60%,transparent 100%) !important}td.bg61p{background:transparent !important;background:rgba(180,232,215,0.61) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 61%,transparent 61%,transparent 100%) !important}td.bg62p{background:transparent !important;background:rgba(180,232,215,0.62) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 62%,transparent 62%,transparent 100%) !important}td.bg63p{background:transparent !important;background:rgba(180,232,215,0.63) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 63%,transparent 63%,transparent 100%) !important}td.bg64p{background:transparent !important;background:rgba(180,232,215,0.64) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 64%,transparent 64%,transparent 100%) !important}td.bg65p{background:transparent !important;background:rgba(180,232,215,0.65) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 65%,transparent 65%,transparent 100%) !important}td.bg66p{background:transparent !important;background:rgba(180,232,215,0.66) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 66%,transparent 66%,transparent 100%) !important}td.bg67p{background:transparent !important;background:rgba(180,232,215,0.67) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 67%,transparent 67%,transparent 100%) !important}td.bg68p{background:transparent !important;background:rgba(180,232,215,0.68) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 68%,transparent 68%,transparent 100%) !important}td.bg69p{background:transparent !important;background:rgba(180,232,215,0.69) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 69%,transparent 69%,transparent 100%) !important}td.bg70p{background:transparent !important;background:rgba(180,232,215,0.7) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 70%,transparent 70%,transparent 100%) !important}td.bg71p{background:transparent !important;background:rgba(180,232,215,0.71) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 71%,transparent 71%,transparent 100%) !important}td.bg72p{background:transparent !important;background:rgba(180,232,215,0.72) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 72%,transparent 72%,transparent 100%) !important}td.bg73p{background:transparent !important;background:rgba(180,232,215,0.73) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 73%,transparent 73%,transparent 100%) !important}td.bg74p{background:transparent !important;background:rgba(180,232,215,0.74) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 74%,transparent 74%,transparent 100%) !important}td.bg75p{background:transparent !important;background:rgba(180,232,215,0.75) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 75%,transparent 75%,transparent 100%) !important}td.bg76p{background:transparent !important;background:rgba(180,232,215,0.76) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 76%,transparent 76%,transparent 100%) !important}td.bg77p{background:transparent !important;background:rgba(180,232,215,0.77) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 77%,transparent 77%,transparent 100%) !important}td.bg78p{background:transparent !important;background:rgba(180,232,215,0.78) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 78%,transparent 78%,transparent 100%) !important}td.bg79p{background:transparent !important;background:rgba(180,232,215,0.79) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 79%,transparent 79%,transparent 100%) !important}td.bg80p{background:transparent !important;background:rgba(180,232,215,0.8) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 80%,transparent 80%,transparent 100%) !important}td.bg81p{background:transparent !important;background:rgba(180,232,215,0.81) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 81%,transparent 81%,transparent 100%) !important}td.bg82p{background:transparent !important;background:rgba(180,232,215,0.82) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 82%,transparent 82%,transparent 100%) !important}td.bg83p{background:transparent !important;background:rgba(180,232,215,0.83) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 83%,transparent 83%,transparent 100%) !important}td.bg84p{background:transparent !important;background:rgba(180,232,215,0.84) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 84%,transparent 84%,transparent 100%) !important}td.bg85p{background:transparent !important;background:rgba(180,232,215,0.85) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 85%,transparent 85%,transparent 100%) !important}td.bg86p{background:transparent !important;background:rgba(180,232,215,0.86) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 86%,transparent 86%,transparent 100%) !important}td.bg87p{background:transparent !important;background:rgba(180,232,215,0.87) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 87%,transparent 87%,transparent 100%) !important}td.bg88p{background:transparent !important;background:rgba(180,232,215,0.88) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 88%,transparent 88%,transparent 100%) !important}td.bg89p{background:transparent !important;background:rgba(180,232,215,0.89) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 89%,transparent 89%,transparent 100%) !important}td.bg90p{background:transparent !important;background:rgba(180,232,215,0.9) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 90%,transparent 90%,transparent 100%) !important}td.bg91p{background:transparent !important;background:rgba(180,232,215,0.91) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 91%,transparent 91%,transparent 100%) !important}td.bg92p{background:transparent !important;background:rgba(180,232,215,0.92) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 92%,transparent 92%,transparent 100%) !important}td.bg93p{background:transparent !important;background:rgba(180,232,215,0.93) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 93%,transparent 93%,transparent 100%) !important}td.bg94p{background:transparent !important;background:rgba(180,232,215,0.94) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 94%,transparent 94%,transparent 100%) !important}td.bg95p{background:transparent !important;background:rgba(180,232,215,0.95) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 95%,transparent 95%,transparent 100%) !important}td.bg96p{background:transparent !important;background:rgba(180,232,215,0.96) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 96%,transparent 96%,transparent 100%) !important}td.bg97p{background:transparent !important;background:rgba(180,232,215,0.97) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 97%,transparent 97%,transparent 100%) !important}td.bg98p{background:transparent !important;background:rgba(180,232,215,0.98) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 98%,transparent 98%,transparent 100%) !important}td.bg99p{background:transparent !important;background:rgba(180,232,215,0.99) !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 99%,transparent 99%,transparent 100%) !important}td.bg100p{background:transparent !important;background:#b4e8d7 !important;background:linear-gradient(to right,#dad5fd 0%,#b4e8d7 100%,transparent 100%,transparent 100%) !important}p.error{color:#f00}div.header table.metadata{background:#fff;border-spacing:0;margin:20px 0;}div.header table.metadata th,div.header table.metadata td{padding:5px 8px;background:#fff;color:#434343;text-align:left;border:none;font-weight:normal}div.header table.metadata td{font-weight:bold}div#sect2 .attributesCount,div#sect3 .attributesCount{font-weight:bold}div#sect2 .multiCollapsers,div#sect3 .multiCollapsers{margin:5px;margin-bottom:15px;padding:0;font-size:80%;}div#sect2 .multiCollapsers a,div#sect3 .multiCollapsers a{color:#808080;display:inline-block;padding:0 5px;border-left:1px solid #808080;text-decoration:none;}div#sect2 .multiCollapsers a:first-child,div#sect3 .multiCollapsers a:first-child{border-left:none}div#sect2 .multiCollapsers a:hover,div#sect3 .multiCollapsers a:hover{text-decoration:underline}div#sect2 div.list,div#sect3 div.list{display:none;}div#sect2 div.list table,div#sect3 div.list table{background:#fff;color:#434343;border-spacing:0;margin:20px 0;}div#sect2 div.list table tr:first-child th,div#sect3 div.list table tr:first-child th{border-top:1px solid #075783}div#sect2 div.list table th,div#sect3 div.list table th{padding:5px 8px;background:#075783;color:#fff;text-align:left;border:1px solid #075783;border-left:none;border-top:none;}div#sect2 div.list table th:first-child,div#sect3 div.list table th:first-child{border:1px solid #075783}div#sect2 div.list table th.empty,div#sect3 div.list table th.empty{background:#fff;}div#sect2 div.list table th.empty:first-child,div#sect3 div.list table th.empty:first-child{border-left:none;border-top:none}div#sect2 div.list table td,div#sect3 div.list table td{padding:5px 8px;text-align:left;border-bottom:1px solid #ebebeb;border-right:1px solid #ebebeb;border-top:none;}div#sect2 div.list table td:first-child,div#sect3 div.list table td:first-child{border-left:1px solid #ebebeb}div#sect2 div.list table tr:nth-child(even),div#sect3 div.list table tr:nth-child(even){background:#fcfbff}div#sect2 div.dataField,div#sect3 div.attribute{padding:20px 20px 10px 40px;margin:2px 5px;border:1px solid #f0f0f0;position:relative;}div#sect2 div.dataField h3,div#sect3 div.attribute h3{margin:0;margin-left:-25px;padding:0 0 0 25px;background:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB4klEQVQ4jc2TTUgUYRzGHzxF5wg6xF46uCRhh0UTlj2Uhz6hU1AEsRBIICv2QRFGp5JOfUBYaLGHwkQicw230jwYZhuRZu06us42aas5uzM77+zMzs77zr+bFK3boUM954ff4fmowV+q5v8ABCOd0X3nuung2R460N5Ne1vvUnNLFzW3dNGhtnt0+EyUjlzspfCVAWq98ZI67r+hx2Nzl9cAM/GR/q2+bRRs3IOGQAj19Y3wb9+JWn8dAoEdaGqoQ3CXH6GmWuwO+eHzbUZ0WJLWAFrqxeBQX/SOauiw7RLKrgvOOTjnII9ARAABRIDjcPT0vX8w0Ln/4S8Z5OY/to+9in1mpgnLsuE4DuxSGUJwCCHgkQeA8CSeSi8tJE/9FqK99M6WEhNH019mHWYWUbRsMGbCdR0IweEJgeSc6iamlWPK8w6jYgt6MjY1PTl+QddVMKMAkxkwWRFuuQxmljD8Wrk0339ysmqNWmbqelqaiRt6HszQkc9pcF0Ho2+zoyvS+LWKNf6s4mKCVhflE5qe+17Q8shmV5CSmZqRlePLE7e9PwIAQP3Qu1xgpbBlWbSgrNInmYXl2OlvlbzrLvHryNUh2rDpJjZuuTX7KDy4nq/qlDPPzrfJTyORap5/f6Yfov0LMDmKRNsAAAAASUVORK5CYII=") left 3px no-repeat;}div#sect2 div.dataField h3.clickable,div#sect3 div.attribute h3.clickable{cursor:pointer}div#sect2 div.dataField h3 span.counter,div#sect3 div.attribute h3 span.counter{float:right;color:#808080;font-style:italic;font-weight:normal}div#sect2 div.dataField .simpleDetails,div#sect3 div.attribute .simpleDetails{color:#808080;padding:5px 10px;display:none;}div#sect2 div.dataField .simpleDetails a,div#sect3 div.attribute .simpleDetails a{color:#808080;text-decoration:none;}div#sect2 div.dataField .simpleDetails a:hover,div#sect3 div.attribute .simpleDetails a:hover{text-decoration:underline}div#sect2 div.dataField.collapsed,div#sect3 div.attribute.collapsed{border:1px solid #fff;padding-top:5px;padding-bottom:0;}div#sect2 div.dataField.collapsed:hover,div#sect3 div.attribute.collapsed:hover{border:1px solid #f0f0f0}div#sect2 div.dataField.collapsed h3,div#sect3 div.attribute.collapsed h3{background:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB30lEQVR42mNkoBAwInPWHbjdsHDHrVsbO7yXkWVA7fwT/+XlxRjmrjq39Om961mPdtV+IsmA3Il7/jvbazL8/PmHYcPOG3dPX3oUfWdN6kmiDUhq2/jf3kqD4f9/EO8/w/Xbb37vOPqo7uWtI10vjk/7R9CA8OoV/20tNUF6Gf79/8fw7+9fhs9ffjDsO/V834P7j2Lvbyl+hteAwJKF/63MdYAu+M/wF6j5798/DL9//WL4/fsnw437n99cvf856ebKpM04DfArmPff1FSP4f+//xDNQI1fPn9lePf2PcPz5y8Z7j16/Z+BS3Ly/U35+VgNcM2Y8V9DU4fhz58/DN9//GL4/PkL0IBPDJ8/fWD4+P4dw7dv3/7/5xCZ9GBbRQFOAzS1DcEG/Pz5k+Hrt+9AzR8ZPn14x/D+w9tXHz//SHq8t30rTi945s76b2BgwfDr92+gbUDNX74yfPjwhuHurSs7Xz+5n/DmwooXeAPRp2jOf3NTe4bv338ANX9huPvw5s9LJ49Uvn9wccLXJ6f/E4xG39K5/20tXBjeAP18YP+Wa7dOH4/6cH3LRaITklfZnP+y8ir/t65aOPPtnctF35+e+c5AAKAYYJvfsfDKzr1r3t/YvZmQRqwGkAMAJ5ELIPTev5gAAAAASUVORK5CYII=") left 3px no-repeat}div#sect2 div.dataField.collapsed .details,div#sect3 div.attribute.collapsed .details{display:none}div#sect2 div.dataField.collapsed .simpleDetails,div#sect3 div.attribute.collapsed .simpleDetails{display:block}div#sect2 div.dataField.collapsed table.fieldBasicInfo,div#sect3 div.attribute.collapsed table.fieldBasicInfo{display:none}div#sect2 div.dataField table.fieldBasicInfo,div#sect3 div.attribute table.fieldBasicInfo{background:#fff;border-spacing:0;margin:20px 0;}div#sect2 div.dataField table.fieldBasicInfo th,div#sect3 div.attribute table.fieldBasicInfo th,div#sect2 div.dataField table.fieldBasicInfo td,div#sect3 div.attribute table.fieldBasicInfo td{padding:5px 8px;background:#fff;color:#434343;text-align:left;border:none;font-weight:normal}div#sect2 div.dataField table.fieldBasicInfo td,div#sect3 div.attribute table.fieldBasicInfo td{font-weight:bold}div#sect2 div.dataField .details table.graphTable,div#sect3 div.attribute .details table.graphTable{background:#fff;color:#434343;border-spacing:0;margin:20px 0;min-width:40%}div#sect2 div.dataField .details table.graphTable tr:first-child th,div#sect3 div.attribute .details table.graphTable tr:first-child th{border-top:1px solid #075783}div#sect2 div.dataField .details table.graphTable th,div#sect3 div.attribute .details table.graphTable th{padding:5px 8px;background:#075783;color:#fff;text-align:left;border:1px solid #075783;border-left:none;border-top:none;}div#sect2 div.dataField .details table.graphTable th:first-child,div#sect3 div.attribute .details table.graphTable th:first-child{border:1px solid #075783}div#sect2 div.dataField .details table.graphTable th.empty,div#sect3 div.attribute .details table.graphTable th.empty{background:#fff;}div#sect2 div.dataField .details table.graphTable th.empty:first-child,div#sect3 div.attribute .details table.graphTable th.empty:first-child{border-left:none;border-top:none}div#sect2 div.dataField .details table.graphTable td,div#sect3 div.attribute .details table.graphTable td{padding:5px 8px;text-align:left;border-bottom:1px solid #ebebeb;border-right:1px solid #ebebeb;border-top:none;}div#sect2 div.dataField .details table.graphTable td:first-child,div#sect3 div.attribute .details table.graphTable td:first-child{border-left:1px solid #ebebeb}div#sect2 div.dataField .details table.graphTable tr:nth-child(even),div#sect3 div.attribute .details table.graphTable tr:nth-child(even){background:#fcfbff}div#sect2 div.dataField .details table.graphTable td.name,div#sect3 div.attribute .details table.graphTable td.name{font-weight:bold}div#sect2 div.dataField .details table.graphTable td.frequency,div#sect3 div.attribute .details table.graphTable td.frequency{text-align:right}div#sect4 #sect4-imValues{padding:20px 20px 10px 40px;margin:2px 5px;border:1px solid #f0f0f0;position:relative;}div#sect4 #sect4-imValues h3{margin:0;margin-left:-25px;padding:0 0 0 25px;background:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB4klEQVQ4jc2TTUgUYRzGHzxF5wg6xF46uCRhh0UTlj2Uhz6hU1AEsRBIICv2QRFGp5JOfUBYaLGHwkQicw230jwYZhuRZu06us42aas5uzM77+zMzs77zr+bFK3boUM954ff4fmowV+q5v8ABCOd0X3nuung2R460N5Ne1vvUnNLFzW3dNGhtnt0+EyUjlzspfCVAWq98ZI67r+hx2Nzl9cAM/GR/q2+bRRs3IOGQAj19Y3wb9+JWn8dAoEdaGqoQ3CXH6GmWuwO+eHzbUZ0WJLWAFrqxeBQX/SOauiw7RLKrgvOOTjnII9ARAABRIDjcPT0vX8w0Ln/4S8Z5OY/to+9in1mpgnLsuE4DuxSGUJwCCHgkQeA8CSeSi8tJE/9FqK99M6WEhNH019mHWYWUbRsMGbCdR0IweEJgeSc6iamlWPK8w6jYgt6MjY1PTl+QddVMKMAkxkwWRFuuQxmljD8Wrk0339ysmqNWmbqelqaiRt6HszQkc9pcF0Ho2+zoyvS+LWKNf6s4mKCVhflE5qe+17Q8shmV5CSmZqRlePLE7e9PwIAQP3Qu1xgpbBlWbSgrNInmYXl2OlvlbzrLvHryNUh2rDpJjZuuTX7KDy4nq/qlDPPzrfJTyORap5/f6Yfov0LMDmKRNsAAAAASUVORK5CYII=") left 3px no-repeat;}div#sect4 #sect4-imValues h3.clickable{cursor:pointer}div#sect4 #sect4-imValues h3 span.counter{float:right;color:#808080;font-style:italic;font-weight:normal}div#sect4 #sect4-imValues .simpleDetails{color:#808080;padding:5px 10px;display:none;}div#sect4 #sect4-imValues .simpleDetails a{color:#808080;text-decoration:none;}div#sect4 #sect4-imValues .simpleDetails a:hover{text-decoration:underline}div#sect4 #sect4-imValues.collapsed{border:1px solid #fff;padding-top:5px;padding-bottom:0;}div#sect4 #sect4-imValues.collapsed:hover{border:1px solid #f0f0f0}div#sect4 #sect4-imValues.collapsed h3{background:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB30lEQVR42mNkoBAwInPWHbjdsHDHrVsbO7yXkWVA7fwT/+XlxRjmrjq39Om961mPdtV+IsmA3Il7/jvbazL8/PmHYcPOG3dPX3oUfWdN6kmiDUhq2/jf3kqD4f9/EO8/w/Xbb37vOPqo7uWtI10vjk/7R9CA8OoV/20tNUF6Gf79/8fw7+9fhs9ffjDsO/V834P7j2Lvbyl+hteAwJKF/63MdYAu+M/wF6j5798/DL9//WL4/fsnw437n99cvf856ebKpM04DfArmPff1FSP4f+//xDNQI1fPn9lePf2PcPz5y8Z7j16/Z+BS3Ly/U35+VgNcM2Y8V9DU4fhz58/DN9//GL4/PkL0IBPDJ8/fWD4+P4dw7dv3/7/5xCZ9GBbRQFOAzS1DcEG/Pz5k+Hrt+9AzR8ZPn14x/D+w9tXHz//SHq8t30rTi945s76b2BgwfDr92+gbUDNX74yfPjwhuHurSs7Xz+5n/DmwooXeAPRp2jOf3NTe4bv338ANX9huPvw5s9LJ49Uvn9wccLXJ6f/E4xG39K5/20tXBjeAP18YP+Wa7dOH4/6cH3LRaITklfZnP+y8ir/t65aOPPtnctF35+e+c5AAKAYYJvfsfDKzr1r3t/YvZmQRqwGkAMAJ5ELIPTev5gAAAAASUVORK5CYII=") left 3px no-repeat}div#sect4 #sect4-imValues.collapsed .details{display:none}div#sect4 #sect4-imValues.collapsed .simpleDetails{display:block}div#sect4 #sect4-imValues table{background:#fff;color:#434343;border-spacing:0;margin:20px 0;width:100%;}div#sect4 #sect4-imValues table tr:first-child th{border-top:1px solid #075783}div#sect4 #sect4-imValues table th{padding:5px 8px;background:#075783;color:#fff;text-align:left;border:1px solid #075783;border-left:none;border-top:none;}div#sect4 #sect4-imValues table th:first-child{border:1px solid #075783}div#sect4 #sect4-imValues table th.empty{background:#fff;}div#sect4 #sect4-imValues table th.empty:first-child{border-left:none;border-top:none}div#sect4 #sect4-imValues table td{padding:5px 8px;text-align:left;border-bottom:1px solid #ebebeb;border-right:1px solid #ebebeb;border-top:none;}div#sect4 #sect4-imValues table td:first-child{border-left:1px solid #ebebeb}div#sect4 #sect4-imValues table tr:nth-child(even){background:#fcfbff}div#sect4 #sect4-imValues table td.name{font-weight:bold}div#sect4 #sect4-imValues.collapsed{padding:20px 20px 10px 40px;border:1px solid #f0f0f0;}div#sect4 #sect4-imValues.collapsed table,div#sect4 #sect4-imValues.collapsed p{display:none}div#sect4 #sect4-cedents{padding:20px 20px 10px 40px;margin:2px 5px;border:1px solid #f0f0f0;position:relative;}div#sect4 #sect4-cedents h3{margin:0;margin-left:-25px;padding:0 0 0 25px;background:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB4klEQVQ4jc2TTUgUYRzGHzxF5wg6xF46uCRhh0UTlj2Uhz6hU1AEsRBIICv2QRFGp5JOfUBYaLGHwkQicw230jwYZhuRZu06us42aas5uzM77+zMzs77zr+bFK3boUM954ff4fmowV+q5v8ABCOd0X3nuung2R460N5Ne1vvUnNLFzW3dNGhtnt0+EyUjlzspfCVAWq98ZI67r+hx2Nzl9cAM/GR/q2+bRRs3IOGQAj19Y3wb9+JWn8dAoEdaGqoQ3CXH6GmWuwO+eHzbUZ0WJLWAFrqxeBQX/SOauiw7RLKrgvOOTjnII9ARAABRIDjcPT0vX8w0Ln/4S8Z5OY/to+9in1mpgnLsuE4DuxSGUJwCCHgkQeA8CSeSi8tJE/9FqK99M6WEhNH019mHWYWUbRsMGbCdR0IweEJgeSc6iamlWPK8w6jYgt6MjY1PTl+QddVMKMAkxkwWRFuuQxmljD8Wrk0339ysmqNWmbqelqaiRt6HszQkc9pcF0Ho2+zoyvS+LWKNf6s4mKCVhflE5qe+17Q8shmV5CSmZqRlePLE7e9PwIAQP3Qu1xgpbBlWbSgrNInmYXl2OlvlbzrLvHryNUh2rDpJjZuuTX7KDy4nq/qlDPPzrfJTyORap5/f6Yfov0LMDmKRNsAAAAASUVORK5CYII=") left 3px no-repeat;}div#sect4 #sect4-cedents h3.clickable{cursor:pointer}div#sect4 #sect4-cedents h3 span.counter{float:right;color:#808080;font-style:italic;font-weight:normal}div#sect4 #sect4-cedents .simpleDetails{color:#808080;padding:5px 10px;display:none;}div#sect4 #sect4-cedents .simpleDetails a{color:#808080;text-decoration:none;}div#sect4 #sect4-cedents .simpleDetails a:hover{text-decoration:underline}div#sect4 #sect4-cedents.collapsed{border:1px solid #fff;padding-top:5px;padding-bottom:0;}div#sect4 #sect4-cedents.collapsed:hover{border:1px solid #f0f0f0}div#sect4 #sect4-cedents.collapsed h3{background:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB30lEQVR42mNkoBAwInPWHbjdsHDHrVsbO7yXkWVA7fwT/+XlxRjmrjq39Om961mPdtV+IsmA3Il7/jvbazL8/PmHYcPOG3dPX3oUfWdN6kmiDUhq2/jf3kqD4f9/EO8/w/Xbb37vOPqo7uWtI10vjk/7R9CA8OoV/20tNUF6Gf79/8fw7+9fhs9ffjDsO/V834P7j2Lvbyl+hteAwJKF/63MdYAu+M/wF6j5798/DL9//WL4/fsnw437n99cvf856ebKpM04DfArmPff1FSP4f+//xDNQI1fPn9lePf2PcPz5y8Z7j16/Z+BS3Ly/U35+VgNcM2Y8V9DU4fhz58/DN9//GL4/PkL0IBPDJ8/fWD4+P4dw7dv3/7/5xCZ9GBbRQFOAzS1DcEG/Pz5k+Hrt+9AzR8ZPn14x/D+w9tXHz//SHq8t30rTi945s76b2BgwfDr92+gbUDNX74yfPjwhuHurSs7Xz+5n/DmwooXeAPRp2jOf3NTe4bv338ANX9huPvw5s9LJ49Uvn9wccLXJ6f/E4xG39K5/20tXBjeAP18YP+Wa7dOH4/6cH3LRaITklfZnP+y8ir/t65aOPPtnctF35+e+c5AAKAYYJvfsfDKzr1r3t/YvZmQRqwGkAMAJ5ELIPTev5gAAAAASUVORK5CYII=") left 3px no-repeat}div#sect4 #sect4-cedents.collapsed .details{display:none}div#sect4 #sect4-cedents.collapsed .simpleDetails{display:block}div#sect4 #sect4-cedents #sect4-rulesPattern{font-weight:bold}div#sect4 #sect4-cedents div.cedentsDetails table{background:#fff;color:#434343;border-spacing:0;margin:20px 0;width:100%;}div#sect4 #sect4-cedents div.cedentsDetails table tr:first-child th{border-top:1px solid #075783}div#sect4 #sect4-cedents div.cedentsDetails table th{padding:5px 8px;background:#075783;color:#fff;text-align:left;border:1px solid #075783;border-left:none;border-top:none;}div#sect4 #sect4-cedents div.cedentsDetails table th:first-child{border:1px solid #075783}div#sect4 #sect4-cedents div.cedentsDetails table th.empty{background:#fff;}div#sect4 #sect4-cedents div.cedentsDetails table th.empty:first-child{border-left:none;border-top:none}div#sect4 #sect4-cedents div.cedentsDetails table td{padding:5px 8px;text-align:left;border-bottom:1px solid #ebebeb;border-right:1px solid #ebebeb;border-top:none;}div#sect4 #sect4-cedents div.cedentsDetails table td:first-child{border-left:1px solid #ebebeb}div#sect4 #sect4-cedents div.cedentsDetails table tr:nth-child(even){background:#fcfbff}div#sect4 #sect4-cedents div.cedentsDetails table .id{display:none;}div#sect4 #sect4-cedents div.cedentsDetails table .id:first-child + th{border-left:1px solid #075783}div#sect4 #sect4-cedents div.cedentsDetails table .id:first-child + td{border-left:1px solid #ebebeb}div#sect4 #sect4-cedents.collapsed{padding:20px 20px 10px 40px;border:1px solid #f0f0f0;}div#sect4 #sect4-cedents.collapsed div.cedentsDetails,div#sect4 #sect4-cedents.collapsed p{display:none}div#sect4 #sect4-cedents.collapsed p#sect4-rulesPattern{display:block}div#sect5 .foundRulesCount{font-weight:bold}div#sect5 .multiCollapsers{margin:5px;margin-bottom:15px;padding:0;font-size:80%;}div#sect5 .multiCollapsers a{color:#808080;display:inline-block;padding:0 5px;border-left:1px solid #808080;text-decoration:none;}div#sect5 .multiCollapsers a:first-child{border-left:none}div#sect5 .multiCollapsers a:hover{text-decoration:underline}div#sect5 div.foundRule{padding:20px 20px 10px 40px;margin:2px 5px;border:1px solid #f0f0f0;position:relative;}div#sect5 div.foundRule h3{margin:0;margin-left:-25px;padding:0 0 0 25px;background:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB4klEQVQ4jc2TTUgUYRzGHzxF5wg6xF46uCRhh0UTlj2Uhz6hU1AEsRBIICv2QRFGp5JOfUBYaLGHwkQicw230jwYZhuRZu06us42aas5uzM77+zMzs77zr+bFK3boUM954ff4fmowV+q5v8ABCOd0X3nuung2R460N5Ne1vvUnNLFzW3dNGhtnt0+EyUjlzspfCVAWq98ZI67r+hx2Nzl9cAM/GR/q2+bRRs3IOGQAj19Y3wb9+JWn8dAoEdaGqoQ3CXH6GmWuwO+eHzbUZ0WJLWAFrqxeBQX/SOauiw7RLKrgvOOTjnII9ARAABRIDjcPT0vX8w0Ln/4S8Z5OY/to+9in1mpgnLsuE4DuxSGUJwCCHgkQeA8CSeSi8tJE/9FqK99M6WEhNH019mHWYWUbRsMGbCdR0IweEJgeSc6iamlWPK8w6jYgt6MjY1PTl+QddVMKMAkxkwWRFuuQxmljD8Wrk0339ysmqNWmbqelqaiRt6HszQkc9pcF0Ho2+zoyvS+LWKNf6s4mKCVhflE5qe+17Q8shmV5CSmZqRlePLE7e9PwIAQP3Qu1xgpbBlWbSgrNInmYXl2OlvlbzrLvHryNUh2rDpJjZuuTX7KDy4nq/qlDPPzrfJTyORap5/f6Yfov0LMDmKRNsAAAAASUVORK5CYII=") left 3px no-repeat;}div#sect5 div.foundRule h3.clickable{cursor:pointer}div#sect5 div.foundRule h3 span.counter{float:right;color:#808080;font-style:italic;font-weight:normal}div#sect5 div.foundRule .simpleDetails{color:#808080;padding:5px 10px;display:none;}div#sect5 div.foundRule .simpleDetails a{color:#808080;text-decoration:none;}div#sect5 div.foundRule .simpleDetails a:hover{text-decoration:underline}div#sect5 div.foundRule.collapsed{border:1px solid #fff;padding-top:5px;padding-bottom:0;}div#sect5 div.foundRule.collapsed:hover{border:1px solid #f0f0f0}div#sect5 div.foundRule.collapsed h3{background:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB30lEQVR42mNkoBAwInPWHbjdsHDHrVsbO7yXkWVA7fwT/+XlxRjmrjq39Om961mPdtV+IsmA3Il7/jvbazL8/PmHYcPOG3dPX3oUfWdN6kmiDUhq2/jf3kqD4f9/EO8/w/Xbb37vOPqo7uWtI10vjk/7R9CA8OoV/20tNUF6Gf79/8fw7+9fhs9ffjDsO/V834P7j2Lvbyl+hteAwJKF/63MdYAu+M/wF6j5798/DL9//WL4/fsnw437n99cvf856ebKpM04DfArmPff1FSP4f+//xDNQI1fPn9lePf2PcPz5y8Z7j16/Z+BS3Ly/U35+VgNcM2Y8V9DU4fhz58/DN9//GL4/PkL0IBPDJ8/fWD4+P4dw7dv3/7/5xCZ9GBbRQFOAzS1DcEG/Pz5k+Hrt+9AzR8ZPn14x/D+w9tXHz//SHq8t30rTi945s76b2BgwfDr92+gbUDNX74yfPjwhuHurSs7Xz+5n/DmwooXeAPRp2jOf3NTe4bv338ANX9huPvw5s9LJ49Uvn9wccLXJ6f/E4xG39K5/20tXBjeAP18YP+Wa7dOH4/6cH3LRaITklfZnP+y8ir/t65aOPPtnctF35+e+c5AAKAYYJvfsfDKzr1r3t/YvZmQRqwGkAMAJ5ELIPTev5gAAAAASUVORK5CYII=") left 3px no-repeat}div#sect5 div.foundRule.collapsed .details{display:none}div#sect5 div.foundRule.collapsed .simpleDetails{display:block}div#sect5 div.foundRule .details{overflow:auto;}div#sect5 div.foundRule .details div.imValues,div#sect5 div.foundRule .details div.fourFtTable{min-width:300px;padding:20px 20px 20px 0;float:left}div#sect5 div.foundRule .details div.imValues h4,div#sect5 div.foundRule .details div.fourFtTable h4{margin:0;padding:0}div#sect5 div.foundRule .details table.fourFtTable{background:#fff;color:#434343;border-spacing:0;margin:20px 0;}div#sect5 div.foundRule .details table.fourFtTable tr:first-child th{border-top:1px solid #075783}div#sect5 div.foundRule .details table.fourFtTable th{padding:5px 8px;background:#075783;color:#fff;text-align:left;border:1px solid #075783;border-left:none;border-top:none;}div#sect5 div.foundRule .details table.fourFtTable th:first-child{border:1px solid #075783}div#sect5 div.foundRule .details table.fourFtTable th.empty{background:#fff;}div#sect5 div.foundRule .details table.fourFtTable th.empty:first-child{border-left:none;border-top:none}div#sect5 div.foundRule .details table.fourFtTable td{padding:5px 8px;text-align:left;border-bottom:1px solid #ebebeb;border-right:1px solid #ebebeb;border-top:none;}div#sect5 div.foundRule .details table.fourFtTable td:first-child{border-left:1px solid #ebebeb}div#sect5 div.foundRule .details table.fourFtTable th,div#sect5 div.foundRule .details table.fourFtTable td{text-align:right}div#sect5 div.foundRule .details table.imValuesTable{background:#fff;color:#434343;border-spacing:0;margin:20px 0;}div#sect5 div.foundRule .details table.imValuesTable tr:first-child th{border-top:1px solid #075783}div#sect5 div.foundRule .details table.imValuesTable th{padding:5px 8px;background:#075783;color:#fff;text-align:left;border:1px solid #075783;border-left:none;border-top:none;}div#sect5 div.foundRule .details table.imValuesTable th:first-child{border:1px solid #075783}div#sect5 div.foundRule .details table.imValuesTable th.empty{background:#fff;}div#sect5 div.foundRule .details table.imValuesTable th.empty:first-child{border-left:none;border-top:none}div#sect5 div.foundRule .details table.imValuesTable td{padding:5px 8px;text-align:left;border-bottom:1px solid #ebebeb;border-right:1px solid #ebebeb;border-top:none;}div#sect5 div.foundRule .details table.imValuesTable td:first-child{border-left:1px solid #ebebeb}div#sect5 div.foundRule .details table.imValuesTable tr:nth-child(even){background:#fcfbff}div#sect5 div.foundRule .details table.imValuesTable td.value{text-align:right}
        ]]>
      </xsl:text>
      <xsl:if test="not($contentOnly)">
        <xsl:text disable-output-escaping="yes">
        <!--standalone page styles-->
        <![CDATA[
          *{font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;font-size:14px;color:#434343}html{background:#2d83be}body{width:80%;padding:20px;margin:20px auto;background:#fff;box-shadow:0 0 10px 0 rgba(0,0,0,0.4);}body > div.section{margin:10px 0;padding:10px 0 20px 0;border-bottom:1px solid #2d83be;}body > div.section:last-of-type{border-bottom:none}a{text-decoration:none;color:#6d87ba;}a:hover{text-decoration:underline;color:#6d87ba}h1{font-size:36px;font-weight:normal;color:#925213}h2{font-size:28px;font-weight:normal;color:#314e64;padding:0;margin:0 0 23px 0}h3{font-size:18px;font-weight:normal;color:#314e64;padding:0;margin:0;}h3.clickable{cursor:pointer;}h3.clickable:hover{text-decoration:underline;color:#6d87ba}div#navigation{position:relative;top:0;right:0;}div#navigation ol li{padding-bottom:3px}div#navigation.onTop{position:fixed;top:5px;right:5px;margin:0;padding:15px;border:1px solid #2d83be;background:#fff;box-shadow:0 0 10px 0 rgba(0,0,0,0.4);z-index:100;}div#navigation.onTop h2{font-size:16px;margin:0;padding:0}div#navigation.onTop ol{margin:5px;padding:5px 0 0 15px;}div#navigation.onTop ol li{padding-bottom:3px}
        ]]>
        </xsl:text>
      </xsl:if>
    </style>
    <!--načtení knihovny jQuery-->
    <xsl:if test="$loadJquery">
      <xsl:text disable-output-escaping="yes">&lt;script type="text/javascript"&gt;/*&lt;![CDATA[*/</xsl:text>
      <xsl:text disable-output-escaping="yes">
        <![CDATA[
          /*! jQuery v1.11.3 | (c) 2005, 2015 jQuery Foundation, Inc. | jquery.org/license */
          !function(a,b){"object"==typeof module&&"object"==typeof module.exports?module.exports=a.document?b(a,!0):function(a){if(!a.document)throw new Error("jQuery requires a window with a document");return b(a)}:b(a)}("undefined"!=typeof window?window:this,function(a,b){var c=[],d=c.slice,e=c.concat,f=c.push,g=c.indexOf,h={},i=h.toString,j=h.hasOwnProperty,k={},l="1.11.3",m=function(a,b){return new m.fn.init(a,b)},n=/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g,o=/^-ms-/,p=/-([\da-z])/gi,q=function(a,b){return b.toUpperCase()};m.fn=m.prototype={jquery:l,constructor:m,selector:"",length:0,toArray:function(){return d.call(this)},get:function(a){return null!=a?0>a?this[a+this.length]:this[a]:d.call(this)},pushStack:function(a){var b=m.merge(this.constructor(),a);return b.prevObject=this,b.context=this.context,b},each:function(a,b){return m.each(this,a,b)},map:function(a){return this.pushStack(m.map(this,function(b,c){return a.call(b,c,b)}))},slice:function(){return this.pushStack(d.apply(this,arguments))},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},eq:function(a){var b=this.length,c=+a+(0>a?b:0);return this.pushStack(c>=0&&b>c?[this[c]]:[])},end:function(){return this.prevObject||this.constructor(null)},push:f,sort:c.sort,splice:c.splice},m.extend=m.fn.extend=function(){var a,b,c,d,e,f,g=arguments[0]||{},h=1,i=arguments.length,j=!1;for("boolean"==typeof g&&(j=g,g=arguments[h]||{},h++),"object"==typeof g||m.isFunction(g)||(g={}),h===i&&(g=this,h--);i>h;h++)if(null!=(e=arguments[h]))for(d in e)a=g[d],c=e[d],g!==c&&(j&&c&&(m.isPlainObject(c)||(b=m.isArray(c)))?(b?(b=!1,f=a&&m.isArray(a)?a:[]):f=a&&m.isPlainObject(a)?a:{},g[d]=m.extend(j,f,c)):void 0!==c&&(g[d]=c));return g},m.extend({expando:"jQuery"+(l+Math.random()).replace(/\D/g,""),isReady:!0,error:function(a){throw new Error(a)},noop:function(){},isFunction:function(a){return"function"===m.type(a)},isArray:Array.isArray||function(a){return"array"===m.type(a)},isWindow:function(a){return null!=a&&a==a.window},isNumeric:function(a){return!m.isArray(a)&&a-parseFloat(a)+1>=0},isEmptyObject:function(a){var b;for(b in a)return!1;return!0},isPlainObject:function(a){var b;if(!a||"object"!==m.type(a)||a.nodeType||m.isWindow(a))return!1;try{if(a.constructor&&!j.call(a,"constructor")&&!j.call(a.constructor.prototype,"isPrototypeOf"))return!1}catch(c){return!1}if(k.ownLast)for(b in a)return j.call(a,b);for(b in a);return void 0===b||j.call(a,b)},type:function(a){return null==a?a+"":"object"==typeof a||"function"==typeof a?h[i.call(a)]||"object":typeof a},globalEval:function(b){b&&m.trim(b)&&(a.execScript||function(b){a.eval.call(a,b)})(b)},camelCase:function(a){return a.replace(o,"ms-").replace(p,q)},nodeName:function(a,b){return a.nodeName&&a.nodeName.toLowerCase()===b.toLowerCase()},each:function(a,b,c){var d,e=0,f=a.length,g=r(a);if(c){if(g){for(;f>e;e++)if(d=b.apply(a[e],c),d===!1)break}else for(e in a)if(d=b.apply(a[e],c),d===!1)break}else if(g){for(;f>e;e++)if(d=b.call(a[e],e,a[e]),d===!1)break}else for(e in a)if(d=b.call(a[e],e,a[e]),d===!1)break;return a},trim:function(a){return null==a?"":(a+"").replace(n,"")},makeArray:function(a,b){var c=b||[];return null!=a&&(r(Object(a))?m.merge(c,"string"==typeof a?[a]:a):f.call(c,a)),c},inArray:function(a,b,c){var d;if(b){if(g)return g.call(b,a,c);for(d=b.length,c=c?0>c?Math.max(0,d+c):c:0;d>c;c++)if(c in b&&b[c]===a)return c}return-1},merge:function(a,b){var c=+b.length,d=0,e=a.length;while(c>d)a[e++]=b[d++];if(c!==c)while(void 0!==b[d])a[e++]=b[d++];return a.length=e,a},grep:function(a,b,c){for(var d,e=[],f=0,g=a.length,h=!c;g>f;f++)d=!b(a[f],f),d!==h&&e.push(a[f]);return e},map:function(a,b,c){var d,f=0,g=a.length,h=r(a),i=[];if(h)for(;g>f;f++)d=b(a[f],f,c),null!=d&&i.push(d);else for(f in a)d=b(a[f],f,c),null!=d&&i.push(d);return e.apply([],i)},guid:1,proxy:function(a,b){var c,e,f;return"string"==typeof b&&(f=a[b],b=a,a=f),m.isFunction(a)?(c=d.call(arguments,2),e=function(){return a.apply(b||this,c.concat(d.call(arguments)))},e.guid=a.guid=a.guid||m.guid++,e):void 0},now:function(){return+new Date},support:k}),m.each("Boolean Number String Function Array Date RegExp Object Error".split(" "),function(a,b){h["[object "+b+"]"]=b.toLowerCase()});function r(a){var b="length"in a&&a.length,c=m.type(a);return"function"===c||m.isWindow(a)?!1:1===a.nodeType&&b?!0:"array"===c||0===b||"number"==typeof b&&b>0&&b-1 in a}var s=function(a){var b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u="sizzle"+1*new Date,v=a.document,w=0,x=0,y=ha(),z=ha(),A=ha(),B=function(a,b){return a===b&&(l=!0),0},C=1<<31,D={}.hasOwnProperty,E=[],F=E.pop,G=E.push,H=E.push,I=E.slice,J=function(a,b){for(var c=0,d=a.length;d>c;c++)if(a[c]===b)return c;return-1},K="checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|ismap|loop|multiple|open|readonly|required|scoped",L="[\\x20\\t\\r\\n\\f]",M="(?:\\\\.|[\\w-]|[^\\x00-\\xa0])+",N=M.replace("w","w#"),O="\\["+L+"*("+M+")(?:"+L+"*([*^$|!~]?=)"+L+"*(?:'((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\"|("+N+"))|)"+L+"*\\]",P=":("+M+")(?:\\((('((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\")|((?:\\\\.|[^\\\\()[\\]]|"+O+")*)|.*)\\)|)",Q=new RegExp(L+"+","g"),R=new RegExp("^"+L+"+|((?:^|[^\\\\])(?:\\\\.)*)"+L+"+$","g"),S=new RegExp("^"+L+"*,"+L+"*"),T=new RegExp("^"+L+"*([>+~]|"+L+")"+L+"*"),U=new RegExp("="+L+"*([^\\]'\"]*?)"+L+"*\\]","g"),V=new RegExp(P),W=new RegExp("^"+N+"$"),X={ID:new RegExp("^#("+M+")"),CLASS:new RegExp("^\\.("+M+")"),TAG:new RegExp("^("+M.replace("w","w*")+")"),ATTR:new RegExp("^"+O),PSEUDO:new RegExp("^"+P),CHILD:new RegExp("^:(only|first|last|nth|nth-last)-(child|of-type)(?:\\("+L+"*(even|odd|(([+-]|)(\\d*)n|)"+L+"*(?:([+-]|)"+L+"*(\\d+)|))"+L+"*\\)|)","i"),bool:new RegExp("^(?:"+K+")$","i"),needsContext:new RegExp("^"+L+"*[>+~]|:(even|odd|eq|gt|lt|nth|first|last)(?:\\("+L+"*((?:-\\d)?\\d*)"+L+"*\\)|)(?=[^-]|$)","i")},Y=/^(?:input|select|textarea|button)$/i,Z=/^h\d$/i,$=/^[^{]+\{\s*\[native \w/,_=/^(?:#([\w-]+)|(\w+)|\.([\w-]+))$/,aa=/[+~]/,ba=/'|\\/g,ca=new RegExp("\\\\([\\da-f]{1,6}"+L+"?|("+L+")|.)","ig"),da=function(a,b,c){var d="0x"+b-65536;return d!==d||c?b:0>d?String.fromCharCode(d+65536):String.fromCharCode(d>>10|55296,1023&d|56320)},ea=function(){m()};try{H.apply(E=I.call(v.childNodes),v.childNodes),E[v.childNodes.length].nodeType}catch(fa){H={apply:E.length?function(a,b){G.apply(a,I.call(b))}:function(a,b){var c=a.length,d=0;while(a[c++]=b[d++]);a.length=c-1}}}function ga(a,b,d,e){var f,h,j,k,l,o,r,s,w,x;if((b?b.ownerDocument||b:v)!==n&&m(b),b=b||n,d=d||[],k=b.nodeType,"string"!=typeof a||!a||1!==k&&9!==k&&11!==k)return d;if(!e&&p){if(11!==k&&(f=_.exec(a)))if(j=f[1]){if(9===k){if(h=b.getElementById(j),!h||!h.parentNode)return d;if(h.id===j)return d.push(h),d}else if(b.ownerDocument&&(h=b.ownerDocument.getElementById(j))&&t(b,h)&&h.id===j)return d.push(h),d}else{if(f[2])return H.apply(d,b.getElementsByTagName(a)),d;if((j=f[3])&&c.getElementsByClassName)return H.apply(d,b.getElementsByClassName(j)),d}if(c.qsa&&(!q||!q.test(a))){if(s=r=u,w=b,x=1!==k&&a,1===k&&"object"!==b.nodeName.toLowerCase()){o=g(a),(r=b.getAttribute("id"))?s=r.replace(ba,"\\$&"):b.setAttribute("id",s),s="[id='"+s+"'] ",l=o.length;while(l--)o[l]=s+ra(o[l]);w=aa.test(a)&&pa(b.parentNode)||b,x=o.join(",")}if(x)try{return H.apply(d,w.querySelectorAll(x)),d}catch(y){}finally{r||b.removeAttribute("id")}}}return i(a.replace(R,"$1"),b,d,e)}function ha(){var a=[];function b(c,e){return a.push(c+" ")>d.cacheLength&&delete b[a.shift()],b[c+" "]=e}return b}function ia(a){return a[u]=!0,a}function ja(a){var b=n.createElement("div");try{return!!a(b)}catch(c){return!1}finally{b.parentNode&&b.parentNode.removeChild(b),b=null}}function ka(a,b){var c=a.split("|"),e=a.length;while(e--)d.attrHandle[c[e]]=b}function la(a,b){var c=b&&a,d=c&&1===a.nodeType&&1===b.nodeType&&(~b.sourceIndex||C)-(~a.sourceIndex||C);if(d)return d;if(c)while(c=c.nextSibling)if(c===b)return-1;return a?1:-1}function ma(a){return function(b){var c=b.nodeName.toLowerCase();return"input"===c&&b.type===a}}function na(a){return function(b){var c=b.nodeName.toLowerCase();return("input"===c||"button"===c)&&b.type===a}}function oa(a){return ia(function(b){return b=+b,ia(function(c,d){var e,f=a([],c.length,b),g=f.length;while(g--)c[e=f[g]]&&(c[e]=!(d[e]=c[e]))})})}function pa(a){return a&&"undefined"!=typeof a.getElementsByTagName&&a}c=ga.support={},f=ga.isXML=function(a){var b=a&&(a.ownerDocument||a).documentElement;return b?"HTML"!==b.nodeName:!1},m=ga.setDocument=function(a){var b,e,g=a?a.ownerDocument||a:v;return g!==n&&9===g.nodeType&&g.documentElement?(n=g,o=g.documentElement,e=g.defaultView,e&&e!==e.top&&(e.addEventListener?e.addEventListener("unload",ea,!1):e.attachEvent&&e.attachEvent("onunload",ea)),p=!f(g),c.attributes=ja(function(a){return a.className="i",!a.getAttribute("className")}),c.getElementsByTagName=ja(function(a){return a.appendChild(g.createComment("")),!a.getElementsByTagName("*").length}),c.getElementsByClassName=$.test(g.getElementsByClassName),c.getById=ja(function(a){return o.appendChild(a).id=u,!g.getElementsByName||!g.getElementsByName(u).length}),c.getById?(d.find.ID=function(a,b){if("undefined"!=typeof b.getElementById&&p){var c=b.getElementById(a);return c&&c.parentNode?[c]:[]}},d.filter.ID=function(a){var b=a.replace(ca,da);return function(a){return a.getAttribute("id")===b}}):(delete d.find.ID,d.filter.ID=function(a){var b=a.replace(ca,da);return function(a){var c="undefined"!=typeof a.getAttributeNode&&a.getAttributeNode("id");return c&&c.value===b}}),d.find.TAG=c.getElementsByTagName?function(a,b){return"undefined"!=typeof b.getElementsByTagName?b.getElementsByTagName(a):c.qsa?b.querySelectorAll(a):void 0}:function(a,b){var c,d=[],e=0,f=b.getElementsByTagName(a);if("*"===a){while(c=f[e++])1===c.nodeType&&d.push(c);return d}return f},d.find.CLASS=c.getElementsByClassName&&function(a,b){return p?b.getElementsByClassName(a):void 0},r=[],q=[],(c.qsa=$.test(g.querySelectorAll))&&(ja(function(a){o.appendChild(a).innerHTML="<a id='"+u+"'></a><select id='"+u+"-\f]' msallowcapture=''><option selected=''></option></select>",a.querySelectorAll("[msallowcapture^='']").length&&q.push("[*^$]="+L+"*(?:''|\"\")"),a.querySelectorAll("[selected]").length||q.push("\\["+L+"*(?:value|"+K+")"),a.querySelectorAll("[id~="+u+"-]").length||q.push("~="),a.querySelectorAll(":checked").length||q.push(":checked"),a.querySelectorAll("a#"+u+"+*").length||q.push(".#.+[+~]")}),ja(function(a){var b=g.createElement("input");b.setAttribute("type","hidden"),a.appendChild(b).setAttribute("name","D"),a.querySelectorAll("[name=d]").length&&q.push("name"+L+"*[*^$|!~]?="),a.querySelectorAll(":enabled").length||q.push(":enabled",":disabled"),a.querySelectorAll("*,:x"),q.push(",.*:")})),(c.matchesSelector=$.test(s=o.matches||o.webkitMatchesSelector||o.mozMatchesSelector||o.oMatchesSelector||o.msMatchesSelector))&&ja(function(a){c.disconnectedMatch=s.call(a,"div"),s.call(a,"[s!='']:x"),r.push("!=",P)}),q=q.length&&new RegExp(q.join("|")),r=r.length&&new RegExp(r.join("|")),b=$.test(o.compareDocumentPosition),t=b||$.test(o.contains)?function(a,b){var c=9===a.nodeType?a.documentElement:a,d=b&&b.parentNode;return a===d||!(!d||1!==d.nodeType||!(c.contains?c.contains(d):a.compareDocumentPosition&&16&a.compareDocumentPosition(d)))}:function(a,b){if(b)while(b=b.parentNode)if(b===a)return!0;return!1},B=b?function(a,b){if(a===b)return l=!0,0;var d=!a.compareDocumentPosition-!b.compareDocumentPosition;return d?d:(d=(a.ownerDocument||a)===(b.ownerDocument||b)?a.compareDocumentPosition(b):1,1&d||!c.sortDetached&&b.compareDocumentPosition(a)===d?a===g||a.ownerDocument===v&&t(v,a)?-1:b===g||b.ownerDocument===v&&t(v,b)?1:k?J(k,a)-J(k,b):0:4&d?-1:1)}:function(a,b){if(a===b)return l=!0,0;var c,d=0,e=a.parentNode,f=b.parentNode,h=[a],i=[b];if(!e||!f)return a===g?-1:b===g?1:e?-1:f?1:k?J(k,a)-J(k,b):0;if(e===f)return la(a,b);c=a;while(c=c.parentNode)h.unshift(c);c=b;while(c=c.parentNode)i.unshift(c);while(h[d]===i[d])d++;return d?la(h[d],i[d]):h[d]===v?-1:i[d]===v?1:0},g):n},ga.matches=function(a,b){return ga(a,null,null,b)},ga.matchesSelector=function(a,b){if((a.ownerDocument||a)!==n&&m(a),b=b.replace(U,"='$1']"),!(!c.matchesSelector||!p||r&&r.test(b)||q&&q.test(b)))try{var d=s.call(a,b);if(d||c.disconnectedMatch||a.document&&11!==a.document.nodeType)return d}catch(e){}return ga(b,n,null,[a]).length>0},ga.contains=function(a,b){return(a.ownerDocument||a)!==n&&m(a),t(a,b)},ga.attr=function(a,b){(a.ownerDocument||a)!==n&&m(a);var e=d.attrHandle[b.toLowerCase()],f=e&&D.call(d.attrHandle,b.toLowerCase())?e(a,b,!p):void 0;return void 0!==f?f:c.attributes||!p?a.getAttribute(b):(f=a.getAttributeNode(b))&&f.specified?f.value:null},ga.error=function(a){throw new Error("Syntax error, unrecognized expression: "+a)},ga.uniqueSort=function(a){var b,d=[],e=0,f=0;if(l=!c.detectDuplicates,k=!c.sortStable&&a.slice(0),a.sort(B),l){while(b=a[f++])b===a[f]&&(e=d.push(f));while(e--)a.splice(d[e],1)}return k=null,a},e=ga.getText=function(a){var b,c="",d=0,f=a.nodeType;if(f){if(1===f||9===f||11===f){if("string"==typeof a.textContent)return a.textContent;for(a=a.firstChild;a;a=a.nextSibling)c+=e(a)}else if(3===f||4===f)return a.nodeValue}else while(b=a[d++])c+=e(b);return c},d=ga.selectors={cacheLength:50,createPseudo:ia,match:X,attrHandle:{},find:{},relative:{">":{dir:"parentNode",first:!0}," ":{dir:"parentNode"},"+":{dir:"previousSibling",first:!0},"~":{dir:"previousSibling"}},preFilter:{ATTR:function(a){return a[1]=a[1].replace(ca,da),a[3]=(a[3]||a[4]||a[5]||"").replace(ca,da),"~="===a[2]&&(a[3]=" "+a[3]+" "),a.slice(0,4)},CHILD:function(a){return a[1]=a[1].toLowerCase(),"nth"===a[1].slice(0,3)?(a[3]||ga.error(a[0]),a[4]=+(a[4]?a[5]+(a[6]||1):2*("even"===a[3]||"odd"===a[3])),a[5]=+(a[7]+a[8]||"odd"===a[3])):a[3]&&ga.error(a[0]),a},PSEUDO:function(a){var b,c=!a[6]&&a[2];return X.CHILD.test(a[0])?null:(a[3]?a[2]=a[4]||a[5]||"":c&&V.test(c)&&(b=g(c,!0))&&(b=c.indexOf(")",c.length-b)-c.length)&&(a[0]=a[0].slice(0,b),a[2]=c.slice(0,b)),a.slice(0,3))}},filter:{TAG:function(a){var b=a.replace(ca,da).toLowerCase();return"*"===a?function(){return!0}:function(a){return a.nodeName&&a.nodeName.toLowerCase()===b}},CLASS:function(a){var b=y[a+" "];return b||(b=new RegExp("(^|"+L+")"+a+"("+L+"|$)"))&&y(a,function(a){return b.test("string"==typeof a.className&&a.className||"undefined"!=typeof a.getAttribute&&a.getAttribute("class")||"")})},ATTR:function(a,b,c){return function(d){var e=ga.attr(d,a);return null==e?"!="===b:b?(e+="","="===b?e===c:"!="===b?e!==c:"^="===b?c&&0===e.indexOf(c):"*="===b?c&&e.indexOf(c)>-1:"$="===b?c&&e.slice(-c.length)===c:"~="===b?(" "+e.replace(Q," ")+" ").indexOf(c)>-1:"|="===b?e===c||e.slice(0,c.length+1)===c+"-":!1):!0}},CHILD:function(a,b,c,d,e){var f="nth"!==a.slice(0,3),g="last"!==a.slice(-4),h="of-type"===b;return 1===d&&0===e?function(a){return!!a.parentNode}:function(b,c,i){var j,k,l,m,n,o,p=f!==g?"nextSibling":"previousSibling",q=b.parentNode,r=h&&b.nodeName.toLowerCase(),s=!i&&!h;if(q){if(f){while(p){l=b;while(l=l[p])if(h?l.nodeName.toLowerCase()===r:1===l.nodeType)return!1;o=p="only"===a&&!o&&"nextSibling"}return!0}if(o=[g?q.firstChild:q.lastChild],g&&s){k=q[u]||(q[u]={}),j=k[a]||[],n=j[0]===w&&j[1],m=j[0]===w&&j[2],l=n&&q.childNodes[n];while(l=++n&&l&&l[p]||(m=n=0)||o.pop())if(1===l.nodeType&&++m&&l===b){k[a]=[w,n,m];break}}else if(s&&(j=(b[u]||(b[u]={}))[a])&&j[0]===w)m=j[1];else while(l=++n&&l&&l[p]||(m=n=0)||o.pop())if((h?l.nodeName.toLowerCase()===r:1===l.nodeType)&&++m&&(s&&((l[u]||(l[u]={}))[a]=[w,m]),l===b))break;return m-=e,m===d||m%d===0&&m/d>=0}}},PSEUDO:function(a,b){var c,e=d.pseudos[a]||d.setFilters[a.toLowerCase()]||ga.error("unsupported pseudo: "+a);return e[u]?e(b):e.length>1?(c=[a,a,"",b],d.setFilters.hasOwnProperty(a.toLowerCase())?ia(function(a,c){var d,f=e(a,b),g=f.length;while(g--)d=J(a,f[g]),a[d]=!(c[d]=f[g])}):function(a){return e(a,0,c)}):e}},pseudos:{not:ia(function(a){var b=[],c=[],d=h(a.replace(R,"$1"));return d[u]?ia(function(a,b,c,e){var f,g=d(a,null,e,[]),h=a.length;while(h--)(f=g[h])&&(a[h]=!(b[h]=f))}):function(a,e,f){return b[0]=a,d(b,null,f,c),b[0]=null,!c.pop()}}),has:ia(function(a){return function(b){return ga(a,b).length>0}}),contains:ia(function(a){return a=a.replace(ca,da),function(b){return(b.textContent||b.innerText||e(b)).indexOf(a)>-1}}),lang:ia(function(a){return W.test(a||"")||ga.error("unsupported lang: "+a),a=a.replace(ca,da).toLowerCase(),function(b){var c;do if(c=p?b.lang:b.getAttribute("xml:lang")||b.getAttribute("lang"))return c=c.toLowerCase(),c===a||0===c.indexOf(a+"-");while((b=b.parentNode)&&1===b.nodeType);return!1}}),target:function(b){var c=a.location&&a.location.hash;return c&&c.slice(1)===b.id},root:function(a){return a===o},focus:function(a){return a===n.activeElement&&(!n.hasFocus||n.hasFocus())&&!!(a.type||a.href||~a.tabIndex)},enabled:function(a){return a.disabled===!1},disabled:function(a){return a.disabled===!0},checked:function(a){var b=a.nodeName.toLowerCase();return"input"===b&&!!a.checked||"option"===b&&!!a.selected},selected:function(a){return a.parentNode&&a.parentNode.selectedIndex,a.selected===!0},empty:function(a){for(a=a.firstChild;a;a=a.nextSibling)if(a.nodeType<6)return!1;return!0},parent:function(a){return!d.pseudos.empty(a)},header:function(a){return Z.test(a.nodeName)},input:function(a){return Y.test(a.nodeName)},button:function(a){var b=a.nodeName.toLowerCase();return"input"===b&&"button"===a.type||"button"===b},text:function(a){var b;return"input"===a.nodeName.toLowerCase()&&"text"===a.type&&(null==(b=a.getAttribute("type"))||"text"===b.toLowerCase())},first:oa(function(){return[0]}),last:oa(function(a,b){return[b-1]}),eq:oa(function(a,b,c){return[0>c?c+b:c]}),even:oa(function(a,b){for(var c=0;b>c;c+=2)a.push(c);return a}),odd:oa(function(a,b){for(var c=1;b>c;c+=2)a.push(c);return a}),lt:oa(function(a,b,c){for(var d=0>c?c+b:c;--d>=0;)a.push(d);return a}),gt:oa(function(a,b,c){for(var d=0>c?c+b:c;++d<b;)a.push(d);return a})}},d.pseudos.nth=d.pseudos.eq;for(b in{radio:!0,checkbox:!0,file:!0,password:!0,image:!0})d.pseudos[b]=ma(b);for(b in{submit:!0,reset:!0})d.pseudos[b]=na(b);function qa(){}qa.prototype=d.filters=d.pseudos,d.setFilters=new qa,g=ga.tokenize=function(a,b){var c,e,f,g,h,i,j,k=z[a+" "];if(k)return b?0:k.slice(0);h=a,i=[],j=d.preFilter;while(h){(!c||(e=S.exec(h)))&&(e&&(h=h.slice(e[0].length)||h),i.push(f=[])),c=!1,(e=T.exec(h))&&(c=e.shift(),f.push({value:c,type:e[0].replace(R," ")}),h=h.slice(c.length));for(g in d.filter)!(e=X[g].exec(h))||j[g]&&!(e=j[g](e))||(c=e.shift(),f.push({value:c,type:g,matches:e}),h=h.slice(c.length));if(!c)break}return b?h.length:h?ga.error(a):z(a,i).slice(0)};function ra(a){for(var b=0,c=a.length,d="";c>b;b++)d+=a[b].value;return d}function sa(a,b,c){var d=b.dir,e=c&&"parentNode"===d,f=x++;return b.first?function(b,c,f){while(b=b[d])if(1===b.nodeType||e)return a(b,c,f)}:function(b,c,g){var h,i,j=[w,f];if(g){while(b=b[d])if((1===b.nodeType||e)&&a(b,c,g))return!0}else while(b=b[d])if(1===b.nodeType||e){if(i=b[u]||(b[u]={}),(h=i[d])&&h[0]===w&&h[1]===f)return j[2]=h[2];if(i[d]=j,j[2]=a(b,c,g))return!0}}}function ta(a){return a.length>1?function(b,c,d){var e=a.length;while(e--)if(!a[e](b,c,d))return!1;return!0}:a[0]}function ua(a,b,c){for(var d=0,e=b.length;e>d;d++)ga(a,b[d],c);return c}function va(a,b,c,d,e){for(var f,g=[],h=0,i=a.length,j=null!=b;i>h;h++)(f=a[h])&&(!c||c(f,d,e))&&(g.push(f),j&&b.push(h));return g}function wa(a,b,c,d,e,f){return d&&!d[u]&&(d=wa(d)),e&&!e[u]&&(e=wa(e,f)),ia(function(f,g,h,i){var j,k,l,m=[],n=[],o=g.length,p=f||ua(b||"*",h.nodeType?[h]:h,[]),q=!a||!f&&b?p:va(p,m,a,h,i),r=c?e||(f?a:o||d)?[]:g:q;if(c&&c(q,r,h,i),d){j=va(r,n),d(j,[],h,i),k=j.length;while(k--)(l=j[k])&&(r[n[k]]=!(q[n[k]]=l))}if(f){if(e||a){if(e){j=[],k=r.length;while(k--)(l=r[k])&&j.push(q[k]=l);e(null,r=[],j,i)}k=r.length;while(k--)(l=r[k])&&(j=e?J(f,l):m[k])>-1&&(f[j]=!(g[j]=l))}}else r=va(r===g?r.splice(o,r.length):r),e?e(null,g,r,i):H.apply(g,r)})}function xa(a){for(var b,c,e,f=a.length,g=d.relative[a[0].type],h=g||d.relative[" "],i=g?1:0,k=sa(function(a){return a===b},h,!0),l=sa(function(a){return J(b,a)>-1},h,!0),m=[function(a,c,d){var e=!g&&(d||c!==j)||((b=c).nodeType?k(a,c,d):l(a,c,d));return b=null,e}];f>i;i++)if(c=d.relative[a[i].type])m=[sa(ta(m),c)];else{if(c=d.filter[a[i].type].apply(null,a[i].matches),c[u]){for(e=++i;f>e;e++)if(d.relative[a[e].type])break;return wa(i>1&&ta(m),i>1&&ra(a.slice(0,i-1).concat({value:" "===a[i-2].type?"*":""})).replace(R,"$1"),c,e>i&&xa(a.slice(i,e)),f>e&&xa(a=a.slice(e)),f>e&&ra(a))}m.push(c)}return ta(m)}function ya(a,b){var c=b.length>0,e=a.length>0,f=function(f,g,h,i,k){var l,m,o,p=0,q="0",r=f&&[],s=[],t=j,u=f||e&&d.find.TAG("*",k),v=w+=null==t?1:Math.random()||.1,x=u.length;for(k&&(j=g!==n&&g);q!==x&&null!=(l=u[q]);q++){if(e&&l){m=0;while(o=a[m++])if(o(l,g,h)){i.push(l);break}k&&(w=v)}c&&((l=!o&&l)&&p--,f&&r.push(l))}if(p+=q,c&&q!==p){m=0;while(o=b[m++])o(r,s,g,h);if(f){if(p>0)while(q--)r[q]||s[q]||(s[q]=F.call(i));s=va(s)}H.apply(i,s),k&&!f&&s.length>0&&p+b.length>1&&ga.uniqueSort(i)}return k&&(w=v,j=t),r};return c?ia(f):f}return h=ga.compile=function(a,b){var c,d=[],e=[],f=A[a+" "];if(!f){b||(b=g(a)),c=b.length;while(c--)f=xa(b[c]),f[u]?d.push(f):e.push(f);f=A(a,ya(e,d)),f.selector=a}return f},i=ga.select=function(a,b,e,f){var i,j,k,l,m,n="function"==typeof a&&a,o=!f&&g(a=n.selector||a);if(e=e||[],1===o.length){if(j=o[0]=o[0].slice(0),j.length>2&&"ID"===(k=j[0]).type&&c.getById&&9===b.nodeType&&p&&d.relative[j[1].type]){if(b=(d.find.ID(k.matches[0].replace(ca,da),b)||[])[0],!b)return e;n&&(b=b.parentNode),a=a.slice(j.shift().value.length)}i=X.needsContext.test(a)?0:j.length;while(i--){if(k=j[i],d.relative[l=k.type])break;if((m=d.find[l])&&(f=m(k.matches[0].replace(ca,da),aa.test(j[0].type)&&pa(b.parentNode)||b))){if(j.splice(i,1),a=f.length&&ra(j),!a)return H.apply(e,f),e;break}}}return(n||h(a,o))(f,b,!p,e,aa.test(a)&&pa(b.parentNode)||b),e},c.sortStable=u.split("").sort(B).join("")===u,c.detectDuplicates=!!l,m(),c.sortDetached=ja(function(a){return 1&a.compareDocumentPosition(n.createElement("div"))}),ja(function(a){return a.innerHTML="<a href='#'></a>","#"===a.firstChild.getAttribute("href")})||ka("type|href|height|width",function(a,b,c){return c?void 0:a.getAttribute(b,"type"===b.toLowerCase()?1:2)}),c.attributes&&ja(function(a){return a.innerHTML="<input/>",a.firstChild.setAttribute("value",""),""===a.firstChild.getAttribute("value")})||ka("value",function(a,b,c){return c||"input"!==a.nodeName.toLowerCase()?void 0:a.defaultValue}),ja(function(a){return null==a.getAttribute("disabled")})||ka(K,function(a,b,c){var d;return c?void 0:a[b]===!0?b.toLowerCase():(d=a.getAttributeNode(b))&&d.specified?d.value:null}),ga}(a);m.find=s,m.expr=s.selectors,m.expr[":"]=m.expr.pseudos,m.unique=s.uniqueSort,m.text=s.getText,m.isXMLDoc=s.isXML,m.contains=s.contains;var t=m.expr.match.needsContext,u=/^<(\w+)\s*\/?>(?:<\/\1>|)$/,v=/^.[^:#\[\.,]*$/;function w(a,b,c){if(m.isFunction(b))return m.grep(a,function(a,d){return!!b.call(a,d,a)!==c});if(b.nodeType)return m.grep(a,function(a){return a===b!==c});if("string"==typeof b){if(v.test(b))return m.filter(b,a,c);b=m.filter(b,a)}return m.grep(a,function(a){return m.inArray(a,b)>=0!==c})}m.filter=function(a,b,c){var d=b[0];return c&&(a=":not("+a+")"),1===b.length&&1===d.nodeType?m.find.matchesSelector(d,a)?[d]:[]:m.find.matches(a,m.grep(b,function(a){return 1===a.nodeType}))},m.fn.extend({find:function(a){var b,c=[],d=this,e=d.length;if("string"!=typeof a)return this.pushStack(m(a).filter(function(){for(b=0;e>b;b++)if(m.contains(d[b],this))return!0}));for(b=0;e>b;b++)m.find(a,d[b],c);return c=this.pushStack(e>1?m.unique(c):c),c.selector=this.selector?this.selector+" "+a:a,c},filter:function(a){return this.pushStack(w(this,a||[],!1))},not:function(a){return this.pushStack(w(this,a||[],!0))},is:function(a){return!!w(this,"string"==typeof a&&t.test(a)?m(a):a||[],!1).length}});var x,y=a.document,z=/^(?:\s*(<[\w\W]+>)[^>]*|#([\w-]*))$/,A=m.fn.init=function(a,b){var c,d;if(!a)return this;if("string"==typeof a){if(c="<"===a.charAt(0)&&">"===a.charAt(a.length-1)&&a.length>=3?[null,a,null]:z.exec(a),!c||!c[1]&&b)return!b||b.jquery?(b||x).find(a):this.constructor(b).find(a);if(c[1]){if(b=b instanceof m?b[0]:b,m.merge(this,m.parseHTML(c[1],b&&b.nodeType?b.ownerDocument||b:y,!0)),u.test(c[1])&&m.isPlainObject(b))for(c in b)m.isFunction(this[c])?this[c](b[c]):this.attr(c,b[c]);return this}if(d=y.getElementById(c[2]),d&&d.parentNode){if(d.id!==c[2])return x.find(a);this.length=1,this[0]=d}return this.context=y,this.selector=a,this}return a.nodeType?(this.context=this[0]=a,this.length=1,this):m.isFunction(a)?"undefined"!=typeof x.ready?x.ready(a):a(m):(void 0!==a.selector&&(this.selector=a.selector,this.context=a.context),m.makeArray(a,this))};A.prototype=m.fn,x=m(y);var B=/^(?:parents|prev(?:Until|All))/,C={children:!0,contents:!0,next:!0,prev:!0};m.extend({dir:function(a,b,c){var d=[],e=a[b];while(e&&9!==e.nodeType&&(void 0===c||1!==e.nodeType||!m(e).is(c)))1===e.nodeType&&d.push(e),e=e[b];return d},sibling:function(a,b){for(var c=[];a;a=a.nextSibling)1===a.nodeType&&a!==b&&c.push(a);return c}}),m.fn.extend({has:function(a){var b,c=m(a,this),d=c.length;return this.filter(function(){for(b=0;d>b;b++)if(m.contains(this,c[b]))return!0})},closest:function(a,b){for(var c,d=0,e=this.length,f=[],g=t.test(a)||"string"!=typeof a?m(a,b||this.context):0;e>d;d++)for(c=this[d];c&&c!==b;c=c.parentNode)if(c.nodeType<11&&(g?g.index(c)>-1:1===c.nodeType&&m.find.matchesSelector(c,a))){f.push(c);break}return this.pushStack(f.length>1?m.unique(f):f)},index:function(a){return a?"string"==typeof a?m.inArray(this[0],m(a)):m.inArray(a.jquery?a[0]:a,this):this[0]&&this[0].parentNode?this.first().prevAll().length:-1},add:function(a,b){return this.pushStack(m.unique(m.merge(this.get(),m(a,b))))},addBack:function(a){return this.add(null==a?this.prevObject:this.prevObject.filter(a))}});function D(a,b){do a=a[b];while(a&&1!==a.nodeType);return a}m.each({parent:function(a){var b=a.parentNode;return b&&11!==b.nodeType?b:null},parents:function(a){return m.dir(a,"parentNode")},parentsUntil:function(a,b,c){return m.dir(a,"parentNode",c)},next:function(a){return D(a,"nextSibling")},prev:function(a){return D(a,"previousSibling")},nextAll:function(a){return m.dir(a,"nextSibling")},prevAll:function(a){return m.dir(a,"previousSibling")},nextUntil:function(a,b,c){return m.dir(a,"nextSibling",c)},prevUntil:function(a,b,c){return m.dir(a,"previousSibling",c)},siblings:function(a){return m.sibling((a.parentNode||{}).firstChild,a)},children:function(a){return m.sibling(a.firstChild)},contents:function(a){return m.nodeName(a,"iframe")?a.contentDocument||a.contentWindow.document:m.merge([],a.childNodes)}},function(a,b){m.fn[a]=function(c,d){var e=m.map(this,b,c);return"Until"!==a.slice(-5)&&(d=c),d&&"string"==typeof d&&(e=m.filter(d,e)),this.length>1&&(C[a]||(e=m.unique(e)),B.test(a)&&(e=e.reverse())),this.pushStack(e)}});var E=/\S+/g,F={};function G(a){var b=F[a]={};return m.each(a.match(E)||[],function(a,c){b[c]=!0}),b}m.Callbacks=function(a){a="string"==typeof a?F[a]||G(a):m.extend({},a);var b,c,d,e,f,g,h=[],i=!a.once&&[],j=function(l){for(c=a.memory&&l,d=!0,f=g||0,g=0,e=h.length,b=!0;h&&e>f;f++)if(h[f].apply(l[0],l[1])===!1&&a.stopOnFalse){c=!1;break}b=!1,h&&(i?i.length&&j(i.shift()):c?h=[]:k.disable())},k={add:function(){if(h){var d=h.length;!function f(b){m.each(b,function(b,c){var d=m.type(c);"function"===d?a.unique&&k.has(c)||h.push(c):c&&c.length&&"string"!==d&&f(c)})}(arguments),b?e=h.length:c&&(g=d,j(c))}return this},remove:function(){return h&&m.each(arguments,function(a,c){var d;while((d=m.inArray(c,h,d))>-1)h.splice(d,1),b&&(e>=d&&e--,f>=d&&f--)}),this},has:function(a){return a?m.inArray(a,h)>-1:!(!h||!h.length)},empty:function(){return h=[],e=0,this},disable:function(){return h=i=c=void 0,this},disabled:function(){return!h},lock:function(){return i=void 0,c||k.disable(),this},locked:function(){return!i},fireWith:function(a,c){return!h||d&&!i||(c=c||[],c=[a,c.slice?c.slice():c],b?i.push(c):j(c)),this},fire:function(){return k.fireWith(this,arguments),this},fired:function(){return!!d}};return k},m.extend({Deferred:function(a){var b=[["resolve","done",m.Callbacks("once memory"),"resolved"],["reject","fail",m.Callbacks("once memory"),"rejected"],["notify","progress",m.Callbacks("memory")]],c="pending",d={state:function(){return c},always:function(){return e.done(arguments).fail(arguments),this},then:function(){var a=arguments;return m.Deferred(function(c){m.each(b,function(b,f){var g=m.isFunction(a[b])&&a[b];e[f[1]](function(){var a=g&&g.apply(this,arguments);a&&m.isFunction(a.promise)?a.promise().done(c.resolve).fail(c.reject).progress(c.notify):c[f[0]+"With"](this===d?c.promise():this,g?[a]:arguments)})}),a=null}).promise()},promise:function(a){return null!=a?m.extend(a,d):d}},e={};return d.pipe=d.then,m.each(b,function(a,f){var g=f[2],h=f[3];d[f[1]]=g.add,h&&g.add(function(){c=h},b[1^a][2].disable,b[2][2].lock),e[f[0]]=function(){return e[f[0]+"With"](this===e?d:this,arguments),this},e[f[0]+"With"]=g.fireWith}),d.promise(e),a&&a.call(e,e),e},when:function(a){var b=0,c=d.call(arguments),e=c.length,f=1!==e||a&&m.isFunction(a.promise)?e:0,g=1===f?a:m.Deferred(),h=function(a,b,c){return function(e){b[a]=this,c[a]=arguments.length>1?d.call(arguments):e,c===i?g.notifyWith(b,c):--f||g.resolveWith(b,c)}},i,j,k;if(e>1)for(i=new Array(e),j=new Array(e),k=new Array(e);e>b;b++)c[b]&&m.isFunction(c[b].promise)?c[b].promise().done(h(b,k,c)).fail(g.reject).progress(h(b,j,i)):--f;return f||g.resolveWith(k,c),g.promise()}});var H;m.fn.ready=function(a){return m.ready.promise().done(a),this},m.extend({isReady:!1,readyWait:1,holdReady:function(a){a?m.readyWait++:m.ready(!0)},ready:function(a){if(a===!0?!--m.readyWait:!m.isReady){if(!y.body)return setTimeout(m.ready);m.isReady=!0,a!==!0&&--m.readyWait>0||(H.resolveWith(y,[m]),m.fn.triggerHandler&&(m(y).triggerHandler("ready"),m(y).off("ready")))}}});function I(){y.addEventListener?(y.removeEventListener("DOMContentLoaded",J,!1),a.removeEventListener("load",J,!1)):(y.detachEvent("onreadystatechange",J),a.detachEvent("onload",J))}function J(){(y.addEventListener||"load"===event.type||"complete"===y.readyState)&&(I(),m.ready())}m.ready.promise=function(b){if(!H)if(H=m.Deferred(),"complete"===y.readyState)setTimeout(m.ready);else if(y.addEventListener)y.addEventListener("DOMContentLoaded",J,!1),a.addEventListener("load",J,!1);else{y.attachEvent("onreadystatechange",J),a.attachEvent("onload",J);var c=!1;try{c=null==a.frameElement&&y.documentElement}catch(d){}c&&c.doScroll&&!function e(){if(!m.isReady){try{c.doScroll("left")}catch(a){return setTimeout(e,50)}I(),m.ready()}}()}return H.promise(b)};var K="undefined",L;for(L in m(k))break;k.ownLast="0"!==L,k.inlineBlockNeedsLayout=!1,m(function(){var a,b,c,d;c=y.getElementsByTagName("body")[0],c&&c.style&&(b=y.createElement("div"),d=y.createElement("div"),d.style.cssText="position:absolute;border:0;width:0;height:0;top:0;left:-9999px",c.appendChild(d).appendChild(b),typeof b.style.zoom!==K&&(b.style.cssText="display:inline;margin:0;border:0;padding:1px;width:1px;zoom:1",k.inlineBlockNeedsLayout=a=3===b.offsetWidth,a&&(c.style.zoom=1)),c.removeChild(d))}),function(){var a=y.createElement("div");if(null==k.deleteExpando){k.deleteExpando=!0;try{delete a.test}catch(b){k.deleteExpando=!1}}a=null}(),m.acceptData=function(a){var b=m.noData[(a.nodeName+" ").toLowerCase()],c=+a.nodeType||1;return 1!==c&&9!==c?!1:!b||b!==!0&&a.getAttribute("classid")===b};var M=/^(?:\{[\w\W]*\}|\[[\w\W]*\])$/,N=/([A-Z])/g;function O(a,b,c){if(void 0===c&&1===a.nodeType){var d="data-"+b.replace(N,"-$1").toLowerCase();if(c=a.getAttribute(d),"string"==typeof c){try{c="true"===c?!0:"false"===c?!1:"null"===c?null:+c+""===c?+c:M.test(c)?m.parseJSON(c):c}catch(e){}m.data(a,b,c)}else c=void 0}return c}function P(a){var b;for(b in a)if(("data"!==b||!m.isEmptyObject(a[b]))&&"toJSON"!==b)return!1;

          return!0}function Q(a,b,d,e){if(m.acceptData(a)){var f,g,h=m.expando,i=a.nodeType,j=i?m.cache:a,k=i?a[h]:a[h]&&h;if(k&&j[k]&&(e||j[k].data)||void 0!==d||"string"!=typeof b)return k||(k=i?a[h]=c.pop()||m.guid++:h),j[k]||(j[k]=i?{}:{toJSON:m.noop}),("object"==typeof b||"function"==typeof b)&&(e?j[k]=m.extend(j[k],b):j[k].data=m.extend(j[k].data,b)),g=j[k],e||(g.data||(g.data={}),g=g.data),void 0!==d&&(g[m.camelCase(b)]=d),"string"==typeof b?(f=g[b],null==f&&(f=g[m.camelCase(b)])):f=g,f}}function R(a,b,c){if(m.acceptData(a)){var d,e,f=a.nodeType,g=f?m.cache:a,h=f?a[m.expando]:m.expando;if(g[h]){if(b&&(d=c?g[h]:g[h].data)){m.isArray(b)?b=b.concat(m.map(b,m.camelCase)):b in d?b=[b]:(b=m.camelCase(b),b=b in d?[b]:b.split(" ")),e=b.length;while(e--)delete d[b[e]];if(c?!P(d):!m.isEmptyObject(d))return}(c||(delete g[h].data,P(g[h])))&&(f?m.cleanData([a],!0):k.deleteExpando||g!=g.window?delete g[h]:g[h]=null)}}}m.extend({cache:{},noData:{"applet ":!0,"embed ":!0,"object ":"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"},hasData:function(a){return a=a.nodeType?m.cache[a[m.expando]]:a[m.expando],!!a&&!P(a)},data:function(a,b,c){return Q(a,b,c)},removeData:function(a,b){return R(a,b)},_data:function(a,b,c){return Q(a,b,c,!0)},_removeData:function(a,b){return R(a,b,!0)}}),m.fn.extend({data:function(a,b){var c,d,e,f=this[0],g=f&&f.attributes;if(void 0===a){if(this.length&&(e=m.data(f),1===f.nodeType&&!m._data(f,"parsedAttrs"))){c=g.length;while(c--)g[c]&&(d=g[c].name,0===d.indexOf("data-")&&(d=m.camelCase(d.slice(5)),O(f,d,e[d])));m._data(f,"parsedAttrs",!0)}return e}return"object"==typeof a?this.each(function(){m.data(this,a)}):arguments.length>1?this.each(function(){m.data(this,a,b)}):f?O(f,a,m.data(f,a)):void 0},removeData:function(a){return this.each(function(){m.removeData(this,a)})}}),m.extend({queue:function(a,b,c){var d;return a?(b=(b||"fx")+"queue",d=m._data(a,b),c&&(!d||m.isArray(c)?d=m._data(a,b,m.makeArray(c)):d.push(c)),d||[]):void 0},dequeue:function(a,b){b=b||"fx";var c=m.queue(a,b),d=c.length,e=c.shift(),f=m._queueHooks(a,b),g=function(){m.dequeue(a,b)};"inprogress"===e&&(e=c.shift(),d--),e&&("fx"===b&&c.unshift("inprogress"),delete f.stop,e.call(a,g,f)),!d&&f&&f.empty.fire()},_queueHooks:function(a,b){var c=b+"queueHooks";return m._data(a,c)||m._data(a,c,{empty:m.Callbacks("once memory").add(function(){m._removeData(a,b+"queue"),m._removeData(a,c)})})}}),m.fn.extend({queue:function(a,b){var c=2;return"string"!=typeof a&&(b=a,a="fx",c--),arguments.length<c?m.queue(this[0],a):void 0===b?this:this.each(function(){var c=m.queue(this,a,b);m._queueHooks(this,a),"fx"===a&&"inprogress"!==c[0]&&m.dequeue(this,a)})},dequeue:function(a){return this.each(function(){m.dequeue(this,a)})},clearQueue:function(a){return this.queue(a||"fx",[])},promise:function(a,b){var c,d=1,e=m.Deferred(),f=this,g=this.length,h=function(){--d||e.resolveWith(f,[f])};"string"!=typeof a&&(b=a,a=void 0),a=a||"fx";while(g--)c=m._data(f[g],a+"queueHooks"),c&&c.empty&&(d++,c.empty.add(h));return h(),e.promise(b)}});var S=/[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source,T=["Top","Right","Bottom","Left"],U=function(a,b){return a=b||a,"none"===m.css(a,"display")||!m.contains(a.ownerDocument,a)},V=m.access=function(a,b,c,d,e,f,g){var h=0,i=a.length,j=null==c;if("object"===m.type(c)){e=!0;for(h in c)m.access(a,b,h,c[h],!0,f,g)}else if(void 0!==d&&(e=!0,m.isFunction(d)||(g=!0),j&&(g?(b.call(a,d),b=null):(j=b,b=function(a,b,c){return j.call(m(a),c)})),b))for(;i>h;h++)b(a[h],c,g?d:d.call(a[h],h,b(a[h],c)));return e?a:j?b.call(a):i?b(a[0],c):f},W=/^(?:checkbox|radio)$/i;!function(){var a=y.createElement("input"),b=y.createElement("div"),c=y.createDocumentFragment();if(b.innerHTML="  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>",k.leadingWhitespace=3===b.firstChild.nodeType,k.tbody=!b.getElementsByTagName("tbody").length,k.htmlSerialize=!!b.getElementsByTagName("link").length,k.html5Clone="<:nav></:nav>"!==y.createElement("nav").cloneNode(!0).outerHTML,a.type="checkbox",a.checked=!0,c.appendChild(a),k.appendChecked=a.checked,b.innerHTML="<textarea>x</textarea>",k.noCloneChecked=!!b.cloneNode(!0).lastChild.defaultValue,c.appendChild(b),b.innerHTML="<input type='radio' checked='checked' name='t'/>",k.checkClone=b.cloneNode(!0).cloneNode(!0).lastChild.checked,k.noCloneEvent=!0,b.attachEvent&&(b.attachEvent("onclick",function(){k.noCloneEvent=!1}),b.cloneNode(!0).click()),null==k.deleteExpando){k.deleteExpando=!0;try{delete b.test}catch(d){k.deleteExpando=!1}}}(),function(){var b,c,d=y.createElement("div");for(b in{submit:!0,change:!0,focusin:!0})c="on"+b,(k[b+"Bubbles"]=c in a)||(d.setAttribute(c,"t"),k[b+"Bubbles"]=d.attributes[c].expando===!1);d=null}();var X=/^(?:input|select|textarea)$/i,Y=/^key/,Z=/^(?:mouse|pointer|contextmenu)|click/,$=/^(?:focusinfocus|focusoutblur)$/,_=/^([^.]*)(?:\.(.+)|)$/;function aa(){return!0}function ba(){return!1}function ca(){try{return y.activeElement}catch(a){}}m.event={global:{},add:function(a,b,c,d,e){var f,g,h,i,j,k,l,n,o,p,q,r=m._data(a);if(r){c.handler&&(i=c,c=i.handler,e=i.selector),c.guid||(c.guid=m.guid++),(g=r.events)||(g=r.events={}),(k=r.handle)||(k=r.handle=function(a){return typeof m===K||a&&m.event.triggered===a.type?void 0:m.event.dispatch.apply(k.elem,arguments)},k.elem=a),b=(b||"").match(E)||[""],h=b.length;while(h--)f=_.exec(b[h])||[],o=q=f[1],p=(f[2]||"").split(".").sort(),o&&(j=m.event.special[o]||{},o=(e?j.delegateType:j.bindType)||o,j=m.event.special[o]||{},l=m.extend({type:o,origType:q,data:d,handler:c,guid:c.guid,selector:e,needsContext:e&&m.expr.match.needsContext.test(e),namespace:p.join(".")},i),(n=g[o])||(n=g[o]=[],n.delegateCount=0,j.setup&&j.setup.call(a,d,p,k)!==!1||(a.addEventListener?a.addEventListener(o,k,!1):a.attachEvent&&a.attachEvent("on"+o,k))),j.add&&(j.add.call(a,l),l.handler.guid||(l.handler.guid=c.guid)),e?n.splice(n.delegateCount++,0,l):n.push(l),m.event.global[o]=!0);a=null}},remove:function(a,b,c,d,e){var f,g,h,i,j,k,l,n,o,p,q,r=m.hasData(a)&&m._data(a);if(r&&(k=r.events)){b=(b||"").match(E)||[""],j=b.length;while(j--)if(h=_.exec(b[j])||[],o=q=h[1],p=(h[2]||"").split(".").sort(),o){l=m.event.special[o]||{},o=(d?l.delegateType:l.bindType)||o,n=k[o]||[],h=h[2]&&new RegExp("(^|\\.)"+p.join("\\.(?:.*\\.|)")+"(\\.|$)"),i=f=n.length;while(f--)g=n[f],!e&&q!==g.origType||c&&c.guid!==g.guid||h&&!h.test(g.namespace)||d&&d!==g.selector&&("**"!==d||!g.selector)||(n.splice(f,1),g.selector&&n.delegateCount--,l.remove&&l.remove.call(a,g));i&&!n.length&&(l.teardown&&l.teardown.call(a,p,r.handle)!==!1||m.removeEvent(a,o,r.handle),delete k[o])}else for(o in k)m.event.remove(a,o+b[j],c,d,!0);m.isEmptyObject(k)&&(delete r.handle,m._removeData(a,"events"))}},trigger:function(b,c,d,e){var f,g,h,i,k,l,n,o=[d||y],p=j.call(b,"type")?b.type:b,q=j.call(b,"namespace")?b.namespace.split("."):[];if(h=l=d=d||y,3!==d.nodeType&&8!==d.nodeType&&!$.test(p+m.event.triggered)&&(p.indexOf(".")>=0&&(q=p.split("."),p=q.shift(),q.sort()),g=p.indexOf(":")<0&&"on"+p,b=b[m.expando]?b:new m.Event(p,"object"==typeof b&&b),b.isTrigger=e?2:3,b.namespace=q.join("."),b.namespace_re=b.namespace?new RegExp("(^|\\.)"+q.join("\\.(?:.*\\.|)")+"(\\.|$)"):null,b.result=void 0,b.target||(b.target=d),c=null==c?[b]:m.makeArray(c,[b]),k=m.event.special[p]||{},e||!k.trigger||k.trigger.apply(d,c)!==!1)){if(!e&&!k.noBubble&&!m.isWindow(d)){for(i=k.delegateType||p,$.test(i+p)||(h=h.parentNode);h;h=h.parentNode)o.push(h),l=h;l===(d.ownerDocument||y)&&o.push(l.defaultView||l.parentWindow||a)}n=0;while((h=o[n++])&&!b.isPropagationStopped())b.type=n>1?i:k.bindType||p,f=(m._data(h,"events")||{})[b.type]&&m._data(h,"handle"),f&&f.apply(h,c),f=g&&h[g],f&&f.apply&&m.acceptData(h)&&(b.result=f.apply(h,c),b.result===!1&&b.preventDefault());if(b.type=p,!e&&!b.isDefaultPrevented()&&(!k._default||k._default.apply(o.pop(),c)===!1)&&m.acceptData(d)&&g&&d[p]&&!m.isWindow(d)){l=d[g],l&&(d[g]=null),m.event.triggered=p;try{d[p]()}catch(r){}m.event.triggered=void 0,l&&(d[g]=l)}return b.result}},dispatch:function(a){a=m.event.fix(a);var b,c,e,f,g,h=[],i=d.call(arguments),j=(m._data(this,"events")||{})[a.type]||[],k=m.event.special[a.type]||{};if(i[0]=a,a.delegateTarget=this,!k.preDispatch||k.preDispatch.call(this,a)!==!1){h=m.event.handlers.call(this,a,j),b=0;while((f=h[b++])&&!a.isPropagationStopped()){a.currentTarget=f.elem,g=0;while((e=f.handlers[g++])&&!a.isImmediatePropagationStopped())(!a.namespace_re||a.namespace_re.test(e.namespace))&&(a.handleObj=e,a.data=e.data,c=((m.event.special[e.origType]||{}).handle||e.handler).apply(f.elem,i),void 0!==c&&(a.result=c)===!1&&(a.preventDefault(),a.stopPropagation()))}return k.postDispatch&&k.postDispatch.call(this,a),a.result}},handlers:function(a,b){var c,d,e,f,g=[],h=b.delegateCount,i=a.target;if(h&&i.nodeType&&(!a.button||"click"!==a.type))for(;i!=this;i=i.parentNode||this)if(1===i.nodeType&&(i.disabled!==!0||"click"!==a.type)){for(e=[],f=0;h>f;f++)d=b[f],c=d.selector+" ",void 0===e[c]&&(e[c]=d.needsContext?m(c,this).index(i)>=0:m.find(c,this,null,[i]).length),e[c]&&e.push(d);e.length&&g.push({elem:i,handlers:e})}return h<b.length&&g.push({elem:this,handlers:b.slice(h)}),g},fix:function(a){if(a[m.expando])return a;var b,c,d,e=a.type,f=a,g=this.fixHooks[e];g||(this.fixHooks[e]=g=Z.test(e)?this.mouseHooks:Y.test(e)?this.keyHooks:{}),d=g.props?this.props.concat(g.props):this.props,a=new m.Event(f),b=d.length;while(b--)c=d[b],a[c]=f[c];return a.target||(a.target=f.srcElement||y),3===a.target.nodeType&&(a.target=a.target.parentNode),a.metaKey=!!a.metaKey,g.filter?g.filter(a,f):a},props:"altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" "),fixHooks:{},keyHooks:{props:"char charCode key keyCode".split(" "),filter:function(a,b){return null==a.which&&(a.which=null!=b.charCode?b.charCode:b.keyCode),a}},mouseHooks:{props:"button buttons clientX clientY fromElement offsetX offsetY pageX pageY screenX screenY toElement".split(" "),filter:function(a,b){var c,d,e,f=b.button,g=b.fromElement;return null==a.pageX&&null!=b.clientX&&(d=a.target.ownerDocument||y,e=d.documentElement,c=d.body,a.pageX=b.clientX+(e&&e.scrollLeft||c&&c.scrollLeft||0)-(e&&e.clientLeft||c&&c.clientLeft||0),a.pageY=b.clientY+(e&&e.scrollTop||c&&c.scrollTop||0)-(e&&e.clientTop||c&&c.clientTop||0)),!a.relatedTarget&&g&&(a.relatedTarget=g===a.target?b.toElement:g),a.which||void 0===f||(a.which=1&f?1:2&f?3:4&f?2:0),a}},special:{load:{noBubble:!0},focus:{trigger:function(){if(this!==ca()&&this.focus)try{return this.focus(),!1}catch(a){}},delegateType:"focusin"},blur:{trigger:function(){return this===ca()&&this.blur?(this.blur(),!1):void 0},delegateType:"focusout"},click:{trigger:function(){return m.nodeName(this,"input")&&"checkbox"===this.type&&this.click?(this.click(),!1):void 0},_default:function(a){return m.nodeName(a.target,"a")}},beforeunload:{postDispatch:function(a){void 0!==a.result&&a.originalEvent&&(a.originalEvent.returnValue=a.result)}}},simulate:function(a,b,c,d){var e=m.extend(new m.Event,c,{type:a,isSimulated:!0,originalEvent:{}});d?m.event.trigger(e,null,b):m.event.dispatch.call(b,e),e.isDefaultPrevented()&&c.preventDefault()}},m.removeEvent=y.removeEventListener?function(a,b,c){a.removeEventListener&&a.removeEventListener(b,c,!1)}:function(a,b,c){var d="on"+b;a.detachEvent&&(typeof a[d]===K&&(a[d]=null),a.detachEvent(d,c))},m.Event=function(a,b){return this instanceof m.Event?(a&&a.type?(this.originalEvent=a,this.type=a.type,this.isDefaultPrevented=a.defaultPrevented||void 0===a.defaultPrevented&&a.returnValue===!1?aa:ba):this.type=a,b&&m.extend(this,b),this.timeStamp=a&&a.timeStamp||m.now(),void(this[m.expando]=!0)):new m.Event(a,b)},m.Event.prototype={isDefaultPrevented:ba,isPropagationStopped:ba,isImmediatePropagationStopped:ba,preventDefault:function(){var a=this.originalEvent;this.isDefaultPrevented=aa,a&&(a.preventDefault?a.preventDefault():a.returnValue=!1)},stopPropagation:function(){var a=this.originalEvent;this.isPropagationStopped=aa,a&&(a.stopPropagation&&a.stopPropagation(),a.cancelBubble=!0)},stopImmediatePropagation:function(){var a=this.originalEvent;this.isImmediatePropagationStopped=aa,a&&a.stopImmediatePropagation&&a.stopImmediatePropagation(),this.stopPropagation()}},m.each({mouseenter:"mouseover",mouseleave:"mouseout",pointerenter:"pointerover",pointerleave:"pointerout"},function(a,b){m.event.special[a]={delegateType:b,bindType:b,handle:function(a){var c,d=this,e=a.relatedTarget,f=a.handleObj;return(!e||e!==d&&!m.contains(d,e))&&(a.type=f.origType,c=f.handler.apply(this,arguments),a.type=b),c}}}),k.submitBubbles||(m.event.special.submit={setup:function(){return m.nodeName(this,"form")?!1:void m.event.add(this,"click._submit keypress._submit",function(a){var b=a.target,c=m.nodeName(b,"input")||m.nodeName(b,"button")?b.form:void 0;c&&!m._data(c,"submitBubbles")&&(m.event.add(c,"submit._submit",function(a){a._submit_bubble=!0}),m._data(c,"submitBubbles",!0))})},postDispatch:function(a){a._submit_bubble&&(delete a._submit_bubble,this.parentNode&&!a.isTrigger&&m.event.simulate("submit",this.parentNode,a,!0))},teardown:function(){return m.nodeName(this,"form")?!1:void m.event.remove(this,"._submit")}}),k.changeBubbles||(m.event.special.change={setup:function(){return X.test(this.nodeName)?(("checkbox"===this.type||"radio"===this.type)&&(m.event.add(this,"propertychange._change",function(a){"checked"===a.originalEvent.propertyName&&(this._just_changed=!0)}),m.event.add(this,"click._change",function(a){this._just_changed&&!a.isTrigger&&(this._just_changed=!1),m.event.simulate("change",this,a,!0)})),!1):void m.event.add(this,"beforeactivate._change",function(a){var b=a.target;X.test(b.nodeName)&&!m._data(b,"changeBubbles")&&(m.event.add(b,"change._change",function(a){!this.parentNode||a.isSimulated||a.isTrigger||m.event.simulate("change",this.parentNode,a,!0)}),m._data(b,"changeBubbles",!0))})},handle:function(a){var b=a.target;return this!==b||a.isSimulated||a.isTrigger||"radio"!==b.type&&"checkbox"!==b.type?a.handleObj.handler.apply(this,arguments):void 0},teardown:function(){return m.event.remove(this,"._change"),!X.test(this.nodeName)}}),k.focusinBubbles||m.each({focus:"focusin",blur:"focusout"},function(a,b){var c=function(a){m.event.simulate(b,a.target,m.event.fix(a),!0)};m.event.special[b]={setup:function(){var d=this.ownerDocument||this,e=m._data(d,b);e||d.addEventListener(a,c,!0),m._data(d,b,(e||0)+1)},teardown:function(){var d=this.ownerDocument||this,e=m._data(d,b)-1;e?m._data(d,b,e):(d.removeEventListener(a,c,!0),m._removeData(d,b))}}}),m.fn.extend({on:function(a,b,c,d,e){var f,g;if("object"==typeof a){"string"!=typeof b&&(c=c||b,b=void 0);for(f in a)this.on(f,b,c,a[f],e);return this}if(null==c&&null==d?(d=b,c=b=void 0):null==d&&("string"==typeof b?(d=c,c=void 0):(d=c,c=b,b=void 0)),d===!1)d=ba;else if(!d)return this;return 1===e&&(g=d,d=function(a){return m().off(a),g.apply(this,arguments)},d.guid=g.guid||(g.guid=m.guid++)),this.each(function(){m.event.add(this,a,d,c,b)})},one:function(a,b,c,d){return this.on(a,b,c,d,1)},off:function(a,b,c){var d,e;if(a&&a.preventDefault&&a.handleObj)return d=a.handleObj,m(a.delegateTarget).off(d.namespace?d.origType+"."+d.namespace:d.origType,d.selector,d.handler),this;if("object"==typeof a){for(e in a)this.off(e,b,a[e]);return this}return(b===!1||"function"==typeof b)&&(c=b,b=void 0),c===!1&&(c=ba),this.each(function(){m.event.remove(this,a,c,b)})},trigger:function(a,b){return this.each(function(){m.event.trigger(a,b,this)})},triggerHandler:function(a,b){var c=this[0];return c?m.event.trigger(a,b,c,!0):void 0}});function da(a){var b=ea.split("|"),c=a.createDocumentFragment();if(c.createElement)while(b.length)c.createElement(b.pop());return c}var ea="abbr|article|aside|audio|bdi|canvas|data|datalist|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video",fa=/ jQuery\d+="(?:null|\d+)"/g,ga=new RegExp("<(?:"+ea+")[\\s/>]","i"),ha=/^\s+/,ia=/<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/gi,ja=/<([\w:]+)/,ka=/<tbody/i,la=/<|&#?\w+;/,ma=/<(?:script|style|link)/i,na=/checked\s*(?:[^=]|=\s*.checked.)/i,oa=/^$|\/(?:java|ecma)script/i,pa=/^true\/(.*)/,qa=/^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g,ra={option:[1,"<select multiple='multiple'>","</select>"],legend:[1,"<fieldset>","</fieldset>"],area:[1,"<map>","</map>"],param:[1,"<object>","</object>"],thead:[1,"<table>","</table>"],tr:[2,"<table><tbody>","</tbody></table>"],col:[2,"<table><tbody></tbody><colgroup>","</colgroup></table>"],td:[3,"<table><tbody><tr>","</tr></tbody></table>"],_default:k.htmlSerialize?[0,"",""]:[1,"X<div>","</div>"]},sa=da(y),ta=sa.appendChild(y.createElement("div"));ra.optgroup=ra.option,ra.tbody=ra.tfoot=ra.colgroup=ra.caption=ra.thead,ra.th=ra.td;function ua(a,b){var c,d,e=0,f=typeof a.getElementsByTagName!==K?a.getElementsByTagName(b||"*"):typeof a.querySelectorAll!==K?a.querySelectorAll(b||"*"):void 0;if(!f)for(f=[],c=a.childNodes||a;null!=(d=c[e]);e++)!b||m.nodeName(d,b)?f.push(d):m.merge(f,ua(d,b));return void 0===b||b&&m.nodeName(a,b)?m.merge([a],f):f}function va(a){W.test(a.type)&&(a.defaultChecked=a.checked)}function wa(a,b){return m.nodeName(a,"table")&&m.nodeName(11!==b.nodeType?b:b.firstChild,"tr")?a.getElementsByTagName("tbody")[0]||a.appendChild(a.ownerDocument.createElement("tbody")):a}function xa(a){return a.type=(null!==m.find.attr(a,"type"))+"/"+a.type,a}function ya(a){var b=pa.exec(a.type);return b?a.type=b[1]:a.removeAttribute("type"),a}function za(a,b){for(var c,d=0;null!=(c=a[d]);d++)m._data(c,"globalEval",!b||m._data(b[d],"globalEval"))}function Aa(a,b){if(1===b.nodeType&&m.hasData(a)){var c,d,e,f=m._data(a),g=m._data(b,f),h=f.events;if(h){delete g.handle,g.events={};for(c in h)for(d=0,e=h[c].length;e>d;d++)m.event.add(b,c,h[c][d])}g.data&&(g.data=m.extend({},g.data))}}function Ba(a,b){var c,d,e;if(1===b.nodeType){if(c=b.nodeName.toLowerCase(),!k.noCloneEvent&&b[m.expando]){e=m._data(b);for(d in e.events)m.removeEvent(b,d,e.handle);b.removeAttribute(m.expando)}"script"===c&&b.text!==a.text?(xa(b).text=a.text,ya(b)):"object"===c?(b.parentNode&&(b.outerHTML=a.outerHTML),k.html5Clone&&a.innerHTML&&!m.trim(b.innerHTML)&&(b.innerHTML=a.innerHTML)):"input"===c&&W.test(a.type)?(b.defaultChecked=b.checked=a.checked,b.value!==a.value&&(b.value=a.value)):"option"===c?b.defaultSelected=b.selected=a.defaultSelected:("input"===c||"textarea"===c)&&(b.defaultValue=a.defaultValue)}}m.extend({clone:function(a,b,c){var d,e,f,g,h,i=m.contains(a.ownerDocument,a);if(k.html5Clone||m.isXMLDoc(a)||!ga.test("<"+a.nodeName+">")?f=a.cloneNode(!0):(ta.innerHTML=a.outerHTML,ta.removeChild(f=ta.firstChild)),!(k.noCloneEvent&&k.noCloneChecked||1!==a.nodeType&&11!==a.nodeType||m.isXMLDoc(a)))for(d=ua(f),h=ua(a),g=0;null!=(e=h[g]);++g)d[g]&&Ba(e,d[g]);if(b)if(c)for(h=h||ua(a),d=d||ua(f),g=0;null!=(e=h[g]);g++)Aa(e,d[g]);else Aa(a,f);return d=ua(f,"script"),d.length>0&&za(d,!i&&ua(a,"script")),d=h=e=null,f},buildFragment:function(a,b,c,d){for(var e,f,g,h,i,j,l,n=a.length,o=da(b),p=[],q=0;n>q;q++)if(f=a[q],f||0===f)if("object"===m.type(f))m.merge(p,f.nodeType?[f]:f);else if(la.test(f)){h=h||o.appendChild(b.createElement("div")),i=(ja.exec(f)||["",""])[1].toLowerCase(),l=ra[i]||ra._default,h.innerHTML=l[1]+f.replace(ia,"<$1></$2>")+l[2],e=l[0];while(e--)h=h.lastChild;if(!k.leadingWhitespace&&ha.test(f)&&p.push(b.createTextNode(ha.exec(f)[0])),!k.tbody){f="table"!==i||ka.test(f)?"<table>"!==l[1]||ka.test(f)?0:h:h.firstChild,e=f&&f.childNodes.length;while(e--)m.nodeName(j=f.childNodes[e],"tbody")&&!j.childNodes.length&&f.removeChild(j)}m.merge(p,h.childNodes),h.textContent="";while(h.firstChild)h.removeChild(h.firstChild);h=o.lastChild}else p.push(b.createTextNode(f));h&&o.removeChild(h),k.appendChecked||m.grep(ua(p,"input"),va),q=0;while(f=p[q++])if((!d||-1===m.inArray(f,d))&&(g=m.contains(f.ownerDocument,f),h=ua(o.appendChild(f),"script"),g&&za(h),c)){e=0;while(f=h[e++])oa.test(f.type||"")&&c.push(f)}return h=null,o},cleanData:function(a,b){for(var d,e,f,g,h=0,i=m.expando,j=m.cache,l=k.deleteExpando,n=m.event.special;null!=(d=a[h]);h++)if((b||m.acceptData(d))&&(f=d[i],g=f&&j[f])){if(g.events)for(e in g.events)n[e]?m.event.remove(d,e):m.removeEvent(d,e,g.handle);j[f]&&(delete j[f],l?delete d[i]:typeof d.removeAttribute!==K?d.removeAttribute(i):d[i]=null,c.push(f))}}}),m.fn.extend({text:function(a){return V(this,function(a){return void 0===a?m.text(this):this.empty().append((this[0]&&this[0].ownerDocument||y).createTextNode(a))},null,a,arguments.length)},append:function(){return this.domManip(arguments,function(a){if(1===this.nodeType||11===this.nodeType||9===this.nodeType){var b=wa(this,a);b.appendChild(a)}})},prepend:function(){return this.domManip(arguments,function(a){if(1===this.nodeType||11===this.nodeType||9===this.nodeType){var b=wa(this,a);b.insertBefore(a,b.firstChild)}})},before:function(){return this.domManip(arguments,function(a){this.parentNode&&this.parentNode.insertBefore(a,this)})},after:function(){return this.domManip(arguments,function(a){this.parentNode&&this.parentNode.insertBefore(a,this.nextSibling)})},remove:function(a,b){for(var c,d=a?m.filter(a,this):this,e=0;null!=(c=d[e]);e++)b||1!==c.nodeType||m.cleanData(ua(c)),c.parentNode&&(b&&m.contains(c.ownerDocument,c)&&za(ua(c,"script")),c.parentNode.removeChild(c));return this},empty:function(){for(var a,b=0;null!=(a=this[b]);b++){1===a.nodeType&&m.cleanData(ua(a,!1));while(a.firstChild)a.removeChild(a.firstChild);a.options&&m.nodeName(a,"select")&&(a.options.length=0)}return this},clone:function(a,b){return a=null==a?!1:a,b=null==b?a:b,this.map(function(){return m.clone(this,a,b)})},html:function(a){return V(this,function(a){var b=this[0]||{},c=0,d=this.length;if(void 0===a)return 1===b.nodeType?b.innerHTML.replace(fa,""):void 0;if(!("string"!=typeof a||ma.test(a)||!k.htmlSerialize&&ga.test(a)||!k.leadingWhitespace&&ha.test(a)||ra[(ja.exec(a)||["",""])[1].toLowerCase()])){a=a.replace(ia,"<$1></$2>");try{for(;d>c;c++)b=this[c]||{},1===b.nodeType&&(m.cleanData(ua(b,!1)),b.innerHTML=a);b=0}catch(e){}}b&&this.empty().append(a)},null,a,arguments.length)},replaceWith:function(){var a=arguments[0];return this.domManip(arguments,function(b){a=this.parentNode,m.cleanData(ua(this)),a&&a.replaceChild(b,this)}),a&&(a.length||a.nodeType)?this:this.remove()},detach:function(a){return this.remove(a,!0)},domManip:function(a,b){a=e.apply([],a);var c,d,f,g,h,i,j=0,l=this.length,n=this,o=l-1,p=a[0],q=m.isFunction(p);if(q||l>1&&"string"==typeof p&&!k.checkClone&&na.test(p))return this.each(function(c){var d=n.eq(c);q&&(a[0]=p.call(this,c,d.html())),d.domManip(a,b)});if(l&&(i=m.buildFragment(a,this[0].ownerDocument,!1,this),c=i.firstChild,1===i.childNodes.length&&(i=c),c)){for(g=m.map(ua(i,"script"),xa),f=g.length;l>j;j++)d=i,j!==o&&(d=m.clone(d,!0,!0),f&&m.merge(g,ua(d,"script"))),b.call(this[j],d,j);if(f)for(h=g[g.length-1].ownerDocument,m.map(g,ya),j=0;f>j;j++)d=g[j],oa.test(d.type||"")&&!m._data(d,"globalEval")&&m.contains(h,d)&&(d.src?m._evalUrl&&m._evalUrl(d.src):m.globalEval((d.text||d.textContent||d.innerHTML||"").replace(qa,"")));i=c=null}return this}}),m.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(a,b){m.fn[a]=function(a){for(var c,d=0,e=[],g=m(a),h=g.length-1;h>=d;d++)c=d===h?this:this.clone(!0),m(g[d])[b](c),f.apply(e,c.get());return this.pushStack(e)}});var Ca,Da={};function Ea(b,c){var d,e=m(c.createElement(b)).appendTo(c.body),f=a.getDefaultComputedStyle&&(d=a.getDefaultComputedStyle(e[0]))?d.display:m.css(e[0],"display");return e.detach(),f}function Fa(a){var b=y,c=Da[a];return c||(c=Ea(a,b),"none"!==c&&c||(Ca=(Ca||m("<iframe frameborder='0' width='0' height='0'/>")).appendTo(b.documentElement),b=(Ca[0].contentWindow||Ca[0].contentDocument).document,b.write(),b.close(),c=Ea(a,b),Ca.detach()),Da[a]=c),c}!function(){var a;k.shrinkWrapBlocks=function(){if(null!=a)return a;a=!1;var b,c,d;return c=y.getElementsByTagName("body")[0],c&&c.style?(b=y.createElement("div"),d=y.createElement("div"),d.style.cssText="position:absolute;border:0;width:0;height:0;top:0;left:-9999px",c.appendChild(d).appendChild(b),typeof b.style.zoom!==K&&(b.style.cssText="-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;display:block;margin:0;border:0;padding:1px;width:1px;zoom:1",b.appendChild(y.createElement("div")).style.width="5px",a=3!==b.offsetWidth),c.removeChild(d),a):void 0}}();var Ga=/^margin/,Ha=new RegExp("^("+S+")(?!px)[a-z%]+$","i"),Ia,Ja,Ka=/^(top|right|bottom|left)$/;a.getComputedStyle?(Ia=function(b){return b.ownerDocument.defaultView.opener?b.ownerDocument.defaultView.getComputedStyle(b,null):a.getComputedStyle(b,null)},Ja=function(a,b,c){var d,e,f,g,h=a.style;return c=c||Ia(a),g=c?c.getPropertyValue(b)||c[b]:void 0,c&&(""!==g||m.contains(a.ownerDocument,a)||(g=m.style(a,b)),Ha.test(g)&&Ga.test(b)&&(d=h.width,e=h.minWidth,f=h.maxWidth,h.minWidth=h.maxWidth=h.width=g,g=c.width,h.width=d,h.minWidth=e,h.maxWidth=f)),void 0===g?g:g+""}):y.documentElement.currentStyle&&(Ia=function(a){return a.currentStyle},Ja=function(a,b,c){var d,e,f,g,h=a.style;return c=c||Ia(a),g=c?c[b]:void 0,null==g&&h&&h[b]&&(g=h[b]),Ha.test(g)&&!Ka.test(b)&&(d=h.left,e=a.runtimeStyle,f=e&&e.left,f&&(e.left=a.currentStyle.left),h.left="fontSize"===b?"1em":g,g=h.pixelLeft+"px",h.left=d,f&&(e.left=f)),void 0===g?g:g+""||"auto"});function La(a,b){return{get:function(){var c=a();if(null!=c)return c?void delete this.get:(this.get=b).apply(this,arguments)}}}!function(){var b,c,d,e,f,g,h;if(b=y.createElement("div"),b.innerHTML="  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>",d=b.getElementsByTagName("a")[0],c=d&&d.style){c.cssText="float:left;opacity:.5",k.opacity="0.5"===c.opacity,k.cssFloat=!!c.cssFloat,b.style.backgroundClip="content-box",b.cloneNode(!0).style.backgroundClip="",k.clearCloneStyle="content-box"===b.style.backgroundClip,k.boxSizing=""===c.boxSizing||""===c.MozBoxSizing||""===c.WebkitBoxSizing,m.extend(k,{reliableHiddenOffsets:function(){return null==g&&i(),g},boxSizingReliable:function(){return null==f&&i(),f},pixelPosition:function(){return null==e&&i(),e},reliableMarginRight:function(){return null==h&&i(),h}});function i(){var b,c,d,i;c=y.getElementsByTagName("body")[0],c&&c.style&&(b=y.createElement("div"),d=y.createElement("div"),d.style.cssText="position:absolute;border:0;width:0;height:0;top:0;left:-9999px",c.appendChild(d).appendChild(b),b.style.cssText="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;display:block;margin-top:1%;top:1%;border:1px;padding:1px;width:4px;position:absolute",e=f=!1,h=!0,a.getComputedStyle&&(e="1%"!==(a.getComputedStyle(b,null)||{}).top,f="4px"===(a.getComputedStyle(b,null)||{width:"4px"}).width,i=b.appendChild(y.createElement("div")),i.style.cssText=b.style.cssText="-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;display:block;margin:0;border:0;padding:0",i.style.marginRight=i.style.width="0",b.style.width="1px",h=!parseFloat((a.getComputedStyle(i,null)||{}).marginRight),b.removeChild(i)),b.innerHTML="<table><tr><td></td><td>t</td></tr></table>",i=b.getElementsByTagName("td"),i[0].style.cssText="margin:0;border:0;padding:0;display:none",g=0===i[0].offsetHeight,g&&(i[0].style.display="",i[1].style.display="none",g=0===i[0].offsetHeight),c.removeChild(d))}}}(),m.swap=function(a,b,c,d){var e,f,g={};for(f in b)g[f]=a.style[f],a.style[f]=b[f];e=c.apply(a,d||[]);for(f in b)a.style[f]=g[f];return e};var Ma=/alpha\([^)]*\)/i,Na=/opacity\s*=\s*([^)]*)/,Oa=/^(none|table(?!-c[ea]).+)/,Pa=new RegExp("^("+S+")(.*)$","i"),Qa=new RegExp("^([+-])=("+S+")","i"),Ra={position:"absolute",visibility:"hidden",display:"block"},Sa={letterSpacing:"0",fontWeight:"400"},Ta=["Webkit","O","Moz","ms"];function Ua(a,b){if(b in a)return b;var c=b.charAt(0).toUpperCase()+b.slice(1),d=b,e=Ta.length;while(e--)if(b=Ta[e]+c,b in a)return b;return d}function Va(a,b){for(var c,d,e,f=[],g=0,h=a.length;h>g;g++)d=a[g],d.style&&(f[g]=m._data(d,"olddisplay"),c=d.style.display,b?(f[g]||"none"!==c||(d.style.display=""),""===d.style.display&&U(d)&&(f[g]=m._data(d,"olddisplay",Fa(d.nodeName)))):(e=U(d),(c&&"none"!==c||!e)&&m._data(d,"olddisplay",e?c:m.css(d,"display"))));for(g=0;h>g;g++)d=a[g],d.style&&(b&&"none"!==d.style.display&&""!==d.style.display||(d.style.display=b?f[g]||"":"none"));return a}function Wa(a,b,c){var d=Pa.exec(b);return d?Math.max(0,d[1]-(c||0))+(d[2]||"px"):b}function Xa(a,b,c,d,e){for(var f=c===(d?"border":"content")?4:"width"===b?1:0,g=0;4>f;f+=2)"margin"===c&&(g+=m.css(a,c+T[f],!0,e)),d?("content"===c&&(g-=m.css(a,"padding"+T[f],!0,e)),"margin"!==c&&(g-=m.css(a,"border"+T[f]+"Width",!0,e))):(g+=m.css(a,"padding"+T[f],!0,e),"padding"!==c&&(g+=m.css(a,"border"+T[f]+"Width",!0,e)));return g}function Ya(a,b,c){var d=!0,e="width"===b?a.offsetWidth:a.offsetHeight,f=Ia(a),g=k.boxSizing&&"border-box"===m.css(a,"boxSizing",!1,f);if(0>=e||null==e){if(e=Ja(a,b,f),(0>e||null==e)&&(e=a.style[b]),Ha.test(e))return e;d=g&&(k.boxSizingReliable()||e===a.style[b]),e=parseFloat(e)||0}return e+Xa(a,b,c||(g?"border":"content"),d,f)+"px"}m.extend({cssHooks:{opacity:{get:function(a,b){if(b){var c=Ja(a,"opacity");return""===c?"1":c}}}},cssNumber:{columnCount:!0,fillOpacity:!0,flexGrow:!0,flexShrink:!0,fontWeight:!0,lineHeight:!0,opacity:!0,order:!0,orphans:!0,widows:!0,zIndex:!0,zoom:!0},cssProps:{"float":k.cssFloat?"cssFloat":"styleFloat"},style:function(a,b,c,d){if(a&&3!==a.nodeType&&8!==a.nodeType&&a.style){var e,f,g,h=m.camelCase(b),i=a.style;if(b=m.cssProps[h]||(m.cssProps[h]=Ua(i,h)),g=m.cssHooks[b]||m.cssHooks[h],void 0===c)return g&&"get"in g&&void 0!==(e=g.get(a,!1,d))?e:i[b];if(f=typeof c,"string"===f&&(e=Qa.exec(c))&&(c=(e[1]+1)*e[2]+parseFloat(m.css(a,b)),f="number"),null!=c&&c===c&&("number"!==f||m.cssNumber[h]||(c+="px"),k.clearCloneStyle||""!==c||0!==b.indexOf("background")||(i[b]="inherit"),!(g&&"set"in g&&void 0===(c=g.set(a,c,d)))))try{i[b]=c}catch(j){}}},css:function(a,b,c,d){var e,f,g,h=m.camelCase(b);return b=m.cssProps[h]||(m.cssProps[h]=Ua(a.style,h)),g=m.cssHooks[b]||m.cssHooks[h],g&&"get"in g&&(f=g.get(a,!0,c)),void 0===f&&(f=Ja(a,b,d)),"normal"===f&&b in Sa&&(f=Sa[b]),""===c||c?(e=parseFloat(f),c===!0||m.isNumeric(e)?e||0:f):f}}),m.each(["height","width"],function(a,b){m.cssHooks[b]={get:function(a,c,d){return c?Oa.test(m.css(a,"display"))&&0===a.offsetWidth?m.swap(a,Ra,function(){return Ya(a,b,d)}):Ya(a,b,d):void 0},set:function(a,c,d){var e=d&&Ia(a);return Wa(a,c,d?Xa(a,b,d,k.boxSizing&&"border-box"===m.css(a,"boxSizing",!1,e),e):0)}}}),k.opacity||(m.cssHooks.opacity={get:function(a,b){return Na.test((b&&a.currentStyle?a.currentStyle.filter:a.style.filter)||"")?.01*parseFloat(RegExp.$1)+"":b?"1":""},set:function(a,b){var c=a.style,d=a.currentStyle,e=m.isNumeric(b)?"alpha(opacity="+100*b+")":"",f=d&&d.filter||c.filter||"";c.zoom=1,(b>=1||""===b)&&""===m.trim(f.replace(Ma,""))&&c.removeAttribute&&(c.removeAttribute("filter"),""===b||d&&!d.filter)||(c.filter=Ma.test(f)?f.replace(Ma,e):f+" "+e)}}),m.cssHooks.marginRight=La(k.reliableMarginRight,function(a,b){return b?m.swap(a,{display:"inline-block"},Ja,[a,"marginRight"]):void 0}),m.each({margin:"",padding:"",border:"Width"},function(a,b){m.cssHooks[a+b]={expand:function(c){for(var d=0,e={},f="string"==typeof c?c.split(" "):[c];4>d;d++)e[a+T[d]+b]=f[d]||f[d-2]||f[0];return e}},Ga.test(a)||(m.cssHooks[a+b].set=Wa)}),m.fn.extend({css:function(a,b){return V(this,function(a,b,c){var d,e,f={},g=0;if(m.isArray(b)){for(d=Ia(a),e=b.length;e>g;g++)f[b[g]]=m.css(a,b[g],!1,d);return f}return void 0!==c?m.style(a,b,c):m.css(a,b)},a,b,arguments.length>1)},show:function(){return Va(this,!0)},hide:function(){return Va(this)},toggle:function(a){return"boolean"==typeof a?a?this.show():this.hide():this.each(function(){U(this)?m(this).show():m(this).hide()})}});function Za(a,b,c,d,e){
          return new Za.prototype.init(a,b,c,d,e)}m.Tween=Za,Za.prototype={constructor:Za,init:function(a,b,c,d,e,f){this.elem=a,this.prop=c,this.easing=e||"swing",this.options=b,this.start=this.now=this.cur(),this.end=d,this.unit=f||(m.cssNumber[c]?"":"px")},cur:function(){var a=Za.propHooks[this.prop];return a&&a.get?a.get(this):Za.propHooks._default.get(this)},run:function(a){var b,c=Za.propHooks[this.prop];return this.options.duration?this.pos=b=m.easing[this.easing](a,this.options.duration*a,0,1,this.options.duration):this.pos=b=a,this.now=(this.end-this.start)*b+this.start,this.options.step&&this.options.step.call(this.elem,this.now,this),c&&c.set?c.set(this):Za.propHooks._default.set(this),this}},Za.prototype.init.prototype=Za.prototype,Za.propHooks={_default:{get:function(a){var b;return null==a.elem[a.prop]||a.elem.style&&null!=a.elem.style[a.prop]?(b=m.css(a.elem,a.prop,""),b&&"auto"!==b?b:0):a.elem[a.prop]},set:function(a){m.fx.step[a.prop]?m.fx.step[a.prop](a):a.elem.style&&(null!=a.elem.style[m.cssProps[a.prop]]||m.cssHooks[a.prop])?m.style(a.elem,a.prop,a.now+a.unit):a.elem[a.prop]=a.now}}},Za.propHooks.scrollTop=Za.propHooks.scrollLeft={set:function(a){a.elem.nodeType&&a.elem.parentNode&&(a.elem[a.prop]=a.now)}},m.easing={linear:function(a){return a},swing:function(a){return.5-Math.cos(a*Math.PI)/2}},m.fx=Za.prototype.init,m.fx.step={};var $a,_a,ab=/^(?:toggle|show|hide)$/,bb=new RegExp("^(?:([+-])=|)("+S+")([a-z%]*)$","i"),cb=/queueHooks$/,db=[ib],eb={"*":[function(a,b){var c=this.createTween(a,b),d=c.cur(),e=bb.exec(b),f=e&&e[3]||(m.cssNumber[a]?"":"px"),g=(m.cssNumber[a]||"px"!==f&&+d)&&bb.exec(m.css(c.elem,a)),h=1,i=20;if(g&&g[3]!==f){f=f||g[3],e=e||[],g=+d||1;do h=h||".5",g/=h,m.style(c.elem,a,g+f);while(h!==(h=c.cur()/d)&&1!==h&&--i)}return e&&(g=c.start=+g||+d||0,c.unit=f,c.end=e[1]?g+(e[1]+1)*e[2]:+e[2]),c}]};function fb(){return setTimeout(function(){$a=void 0}),$a=m.now()}function gb(a,b){var c,d={height:a},e=0;for(b=b?1:0;4>e;e+=2-b)c=T[e],d["margin"+c]=d["padding"+c]=a;return b&&(d.opacity=d.width=a),d}function hb(a,b,c){for(var d,e=(eb[b]||[]).concat(eb["*"]),f=0,g=e.length;g>f;f++)if(d=e[f].call(c,b,a))return d}function ib(a,b,c){var d,e,f,g,h,i,j,l,n=this,o={},p=a.style,q=a.nodeType&&U(a),r=m._data(a,"fxshow");c.queue||(h=m._queueHooks(a,"fx"),null==h.unqueued&&(h.unqueued=0,i=h.empty.fire,h.empty.fire=function(){h.unqueued||i()}),h.unqueued++,n.always(function(){n.always(function(){h.unqueued--,m.queue(a,"fx").length||h.empty.fire()})})),1===a.nodeType&&("height"in b||"width"in b)&&(c.overflow=[p.overflow,p.overflowX,p.overflowY],j=m.css(a,"display"),l="none"===j?m._data(a,"olddisplay")||Fa(a.nodeName):j,"inline"===l&&"none"===m.css(a,"float")&&(k.inlineBlockNeedsLayout&&"inline"!==Fa(a.nodeName)?p.zoom=1:p.display="inline-block")),c.overflow&&(p.overflow="hidden",k.shrinkWrapBlocks()||n.always(function(){p.overflow=c.overflow[0],p.overflowX=c.overflow[1],p.overflowY=c.overflow[2]}));for(d in b)if(e=b[d],ab.exec(e)){if(delete b[d],f=f||"toggle"===e,e===(q?"hide":"show")){if("show"!==e||!r||void 0===r[d])continue;q=!0}o[d]=r&&r[d]||m.style(a,d)}else j=void 0;if(m.isEmptyObject(o))"inline"===("none"===j?Fa(a.nodeName):j)&&(p.display=j);else{r?"hidden"in r&&(q=r.hidden):r=m._data(a,"fxshow",{}),f&&(r.hidden=!q),q?m(a).show():n.done(function(){m(a).hide()}),n.done(function(){var b;m._removeData(a,"fxshow");for(b in o)m.style(a,b,o[b])});for(d in o)g=hb(q?r[d]:0,d,n),d in r||(r[d]=g.start,q&&(g.end=g.start,g.start="width"===d||"height"===d?1:0))}}function jb(a,b){var c,d,e,f,g;for(c in a)if(d=m.camelCase(c),e=b[d],f=a[c],m.isArray(f)&&(e=f[1],f=a[c]=f[0]),c!==d&&(a[d]=f,delete a[c]),g=m.cssHooks[d],g&&"expand"in g){f=g.expand(f),delete a[d];for(c in f)c in a||(a[c]=f[c],b[c]=e)}else b[d]=e}function kb(a,b,c){var d,e,f=0,g=db.length,h=m.Deferred().always(function(){delete i.elem}),i=function(){if(e)return!1;for(var b=$a||fb(),c=Math.max(0,j.startTime+j.duration-b),d=c/j.duration||0,f=1-d,g=0,i=j.tweens.length;i>g;g++)j.tweens[g].run(f);return h.notifyWith(a,[j,f,c]),1>f&&i?c:(h.resolveWith(a,[j]),!1)},j=h.promise({elem:a,props:m.extend({},b),opts:m.extend(!0,{specialEasing:{}},c),originalProperties:b,originalOptions:c,startTime:$a||fb(),duration:c.duration,tweens:[],createTween:function(b,c){var d=m.Tween(a,j.opts,b,c,j.opts.specialEasing[b]||j.opts.easing);return j.tweens.push(d),d},stop:function(b){var c=0,d=b?j.tweens.length:0;if(e)return this;for(e=!0;d>c;c++)j.tweens[c].run(1);return b?h.resolveWith(a,[j,b]):h.rejectWith(a,[j,b]),this}}),k=j.props;for(jb(k,j.opts.specialEasing);g>f;f++)if(d=db[f].call(j,a,k,j.opts))return d;return m.map(k,hb,j),m.isFunction(j.opts.start)&&j.opts.start.call(a,j),m.fx.timer(m.extend(i,{elem:a,anim:j,queue:j.opts.queue})),j.progress(j.opts.progress).done(j.opts.done,j.opts.complete).fail(j.opts.fail).always(j.opts.always)}m.Animation=m.extend(kb,{tweener:function(a,b){m.isFunction(a)?(b=a,a=["*"]):a=a.split(" ");for(var c,d=0,e=a.length;e>d;d++)c=a[d],eb[c]=eb[c]||[],eb[c].unshift(b)},prefilter:function(a,b){b?db.unshift(a):db.push(a)}}),m.speed=function(a,b,c){var d=a&&"object"==typeof a?m.extend({},a):{complete:c||!c&&b||m.isFunction(a)&&a,duration:a,easing:c&&b||b&&!m.isFunction(b)&&b};return d.duration=m.fx.off?0:"number"==typeof d.duration?d.duration:d.duration in m.fx.speeds?m.fx.speeds[d.duration]:m.fx.speeds._default,(null==d.queue||d.queue===!0)&&(d.queue="fx"),d.old=d.complete,d.complete=function(){m.isFunction(d.old)&&d.old.call(this),d.queue&&m.dequeue(this,d.queue)},d},m.fn.extend({fadeTo:function(a,b,c,d){return this.filter(U).css("opacity",0).show().end().animate({opacity:b},a,c,d)},animate:function(a,b,c,d){var e=m.isEmptyObject(a),f=m.speed(b,c,d),g=function(){var b=kb(this,m.extend({},a),f);(e||m._data(this,"finish"))&&b.stop(!0)};return g.finish=g,e||f.queue===!1?this.each(g):this.queue(f.queue,g)},stop:function(a,b,c){var d=function(a){var b=a.stop;delete a.stop,b(c)};return"string"!=typeof a&&(c=b,b=a,a=void 0),b&&a!==!1&&this.queue(a||"fx",[]),this.each(function(){var b=!0,e=null!=a&&a+"queueHooks",f=m.timers,g=m._data(this);if(e)g[e]&&g[e].stop&&d(g[e]);else for(e in g)g[e]&&g[e].stop&&cb.test(e)&&d(g[e]);for(e=f.length;e--;)f[e].elem!==this||null!=a&&f[e].queue!==a||(f[e].anim.stop(c),b=!1,f.splice(e,1));(b||!c)&&m.dequeue(this,a)})},finish:function(a){return a!==!1&&(a=a||"fx"),this.each(function(){var b,c=m._data(this),d=c[a+"queue"],e=c[a+"queueHooks"],f=m.timers,g=d?d.length:0;for(c.finish=!0,m.queue(this,a,[]),e&&e.stop&&e.stop.call(this,!0),b=f.length;b--;)f[b].elem===this&&f[b].queue===a&&(f[b].anim.stop(!0),f.splice(b,1));for(b=0;g>b;b++)d[b]&&d[b].finish&&d[b].finish.call(this);delete c.finish})}}),m.each(["toggle","show","hide"],function(a,b){var c=m.fn[b];m.fn[b]=function(a,d,e){return null==a||"boolean"==typeof a?c.apply(this,arguments):this.animate(gb(b,!0),a,d,e)}}),m.each({slideDown:gb("show"),slideUp:gb("hide"),slideToggle:gb("toggle"),fadeIn:{opacity:"show"},fadeOut:{opacity:"hide"},fadeToggle:{opacity:"toggle"}},function(a,b){m.fn[a]=function(a,c,d){return this.animate(b,a,c,d)}}),m.timers=[],m.fx.tick=function(){var a,b=m.timers,c=0;for($a=m.now();c<b.length;c++)a=b[c],a()||b[c]!==a||b.splice(c--,1);b.length||m.fx.stop(),$a=void 0},m.fx.timer=function(a){m.timers.push(a),a()?m.fx.start():m.timers.pop()},m.fx.interval=13,m.fx.start=function(){_a||(_a=setInterval(m.fx.tick,m.fx.interval))},m.fx.stop=function(){clearInterval(_a),_a=null},m.fx.speeds={slow:600,fast:200,_default:400},m.fn.delay=function(a,b){return a=m.fx?m.fx.speeds[a]||a:a,b=b||"fx",this.queue(b,function(b,c){var d=setTimeout(b,a);c.stop=function(){clearTimeout(d)}})},function(){var a,b,c,d,e;b=y.createElement("div"),b.setAttribute("className","t"),b.innerHTML="  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>",d=b.getElementsByTagName("a")[0],c=y.createElement("select"),e=c.appendChild(y.createElement("option")),a=b.getElementsByTagName("input")[0],d.style.cssText="top:1px",k.getSetAttribute="t"!==b.className,k.style=/top/.test(d.getAttribute("style")),k.hrefNormalized="/a"===d.getAttribute("href"),k.checkOn=!!a.value,k.optSelected=e.selected,k.enctype=!!y.createElement("form").enctype,c.disabled=!0,k.optDisabled=!e.disabled,a=y.createElement("input"),a.setAttribute("value",""),k.input=""===a.getAttribute("value"),a.value="t",a.setAttribute("type","radio"),k.radioValue="t"===a.value}();var lb=/\r/g;m.fn.extend({val:function(a){var b,c,d,e=this[0];{if(arguments.length)return d=m.isFunction(a),this.each(function(c){var e;1===this.nodeType&&(e=d?a.call(this,c,m(this).val()):a,null==e?e="":"number"==typeof e?e+="":m.isArray(e)&&(e=m.map(e,function(a){return null==a?"":a+""})),b=m.valHooks[this.type]||m.valHooks[this.nodeName.toLowerCase()],b&&"set"in b&&void 0!==b.set(this,e,"value")||(this.value=e))});if(e)return b=m.valHooks[e.type]||m.valHooks[e.nodeName.toLowerCase()],b&&"get"in b&&void 0!==(c=b.get(e,"value"))?c:(c=e.value,"string"==typeof c?c.replace(lb,""):null==c?"":c)}}}),m.extend({valHooks:{option:{get:function(a){var b=m.find.attr(a,"value");return null!=b?b:m.trim(m.text(a))}},select:{get:function(a){for(var b,c,d=a.options,e=a.selectedIndex,f="select-one"===a.type||0>e,g=f?null:[],h=f?e+1:d.length,i=0>e?h:f?e:0;h>i;i++)if(c=d[i],!(!c.selected&&i!==e||(k.optDisabled?c.disabled:null!==c.getAttribute("disabled"))||c.parentNode.disabled&&m.nodeName(c.parentNode,"optgroup"))){if(b=m(c).val(),f)return b;g.push(b)}return g},set:function(a,b){var c,d,e=a.options,f=m.makeArray(b),g=e.length;while(g--)if(d=e[g],m.inArray(m.valHooks.option.get(d),f)>=0)try{d.selected=c=!0}catch(h){d.scrollHeight}else d.selected=!1;return c||(a.selectedIndex=-1),e}}}}),m.each(["radio","checkbox"],function(){m.valHooks[this]={set:function(a,b){return m.isArray(b)?a.checked=m.inArray(m(a).val(),b)>=0:void 0}},k.checkOn||(m.valHooks[this].get=function(a){return null===a.getAttribute("value")?"on":a.value})});var mb,nb,ob=m.expr.attrHandle,pb=/^(?:checked|selected)$/i,qb=k.getSetAttribute,rb=k.input;m.fn.extend({attr:function(a,b){return V(this,m.attr,a,b,arguments.length>1)},removeAttr:function(a){return this.each(function(){m.removeAttr(this,a)})}}),m.extend({attr:function(a,b,c){var d,e,f=a.nodeType;if(a&&3!==f&&8!==f&&2!==f)return typeof a.getAttribute===K?m.prop(a,b,c):(1===f&&m.isXMLDoc(a)||(b=b.toLowerCase(),d=m.attrHooks[b]||(m.expr.match.bool.test(b)?nb:mb)),void 0===c?d&&"get"in d&&null!==(e=d.get(a,b))?e:(e=m.find.attr(a,b),null==e?void 0:e):null!==c?d&&"set"in d&&void 0!==(e=d.set(a,c,b))?e:(a.setAttribute(b,c+""),c):void m.removeAttr(a,b))},removeAttr:function(a,b){var c,d,e=0,f=b&&b.match(E);if(f&&1===a.nodeType)while(c=f[e++])d=m.propFix[c]||c,m.expr.match.bool.test(c)?rb&&qb||!pb.test(c)?a[d]=!1:a[m.camelCase("default-"+c)]=a[d]=!1:m.attr(a,c,""),a.removeAttribute(qb?c:d)},attrHooks:{type:{set:function(a,b){if(!k.radioValue&&"radio"===b&&m.nodeName(a,"input")){var c=a.value;return a.setAttribute("type",b),c&&(a.value=c),b}}}}}),nb={set:function(a,b,c){return b===!1?m.removeAttr(a,c):rb&&qb||!pb.test(c)?a.setAttribute(!qb&&m.propFix[c]||c,c):a[m.camelCase("default-"+c)]=a[c]=!0,c}},m.each(m.expr.match.bool.source.match(/\w+/g),function(a,b){var c=ob[b]||m.find.attr;ob[b]=rb&&qb||!pb.test(b)?function(a,b,d){var e,f;return d||(f=ob[b],ob[b]=e,e=null!=c(a,b,d)?b.toLowerCase():null,ob[b]=f),e}:function(a,b,c){return c?void 0:a[m.camelCase("default-"+b)]?b.toLowerCase():null}}),rb&&qb||(m.attrHooks.value={set:function(a,b,c){return m.nodeName(a,"input")?void(a.defaultValue=b):mb&&mb.set(a,b,c)}}),qb||(mb={set:function(a,b,c){var d=a.getAttributeNode(c);return d||a.setAttributeNode(d=a.ownerDocument.createAttribute(c)),d.value=b+="","value"===c||b===a.getAttribute(c)?b:void 0}},ob.id=ob.name=ob.coords=function(a,b,c){var d;return c?void 0:(d=a.getAttributeNode(b))&&""!==d.value?d.value:null},m.valHooks.button={get:function(a,b){var c=a.getAttributeNode(b);return c&&c.specified?c.value:void 0},set:mb.set},m.attrHooks.contenteditable={set:function(a,b,c){mb.set(a,""===b?!1:b,c)}},m.each(["width","height"],function(a,b){m.attrHooks[b]={set:function(a,c){return""===c?(a.setAttribute(b,"auto"),c):void 0}}})),k.style||(m.attrHooks.style={get:function(a){return a.style.cssText||void 0},set:function(a,b){return a.style.cssText=b+""}});var sb=/^(?:input|select|textarea|button|object)$/i,tb=/^(?:a|area)$/i;m.fn.extend({prop:function(a,b){return V(this,m.prop,a,b,arguments.length>1)},removeProp:function(a){return a=m.propFix[a]||a,this.each(function(){try{this[a]=void 0,delete this[a]}catch(b){}})}}),m.extend({propFix:{"for":"htmlFor","class":"className"},prop:function(a,b,c){var d,e,f,g=a.nodeType;if(a&&3!==g&&8!==g&&2!==g)return f=1!==g||!m.isXMLDoc(a),f&&(b=m.propFix[b]||b,e=m.propHooks[b]),void 0!==c?e&&"set"in e&&void 0!==(d=e.set(a,c,b))?d:a[b]=c:e&&"get"in e&&null!==(d=e.get(a,b))?d:a[b]},propHooks:{tabIndex:{get:function(a){var b=m.find.attr(a,"tabindex");return b?parseInt(b,10):sb.test(a.nodeName)||tb.test(a.nodeName)&&a.href?0:-1}}}}),k.hrefNormalized||m.each(["href","src"],function(a,b){m.propHooks[b]={get:function(a){return a.getAttribute(b,4)}}}),k.optSelected||(m.propHooks.selected={get:function(a){var b=a.parentNode;return b&&(b.selectedIndex,b.parentNode&&b.parentNode.selectedIndex),null}}),m.each(["tabIndex","readOnly","maxLength","cellSpacing","cellPadding","rowSpan","colSpan","useMap","frameBorder","contentEditable"],function(){m.propFix[this.toLowerCase()]=this}),k.enctype||(m.propFix.enctype="encoding");var ub=/[\t\r\n\f]/g;m.fn.extend({addClass:function(a){var b,c,d,e,f,g,h=0,i=this.length,j="string"==typeof a&&a;if(m.isFunction(a))return this.each(function(b){m(this).addClass(a.call(this,b,this.className))});if(j)for(b=(a||"").match(E)||[];i>h;h++)if(c=this[h],d=1===c.nodeType&&(c.className?(" "+c.className+" ").replace(ub," "):" ")){f=0;while(e=b[f++])d.indexOf(" "+e+" ")<0&&(d+=e+" ");g=m.trim(d),c.className!==g&&(c.className=g)}return this},removeClass:function(a){var b,c,d,e,f,g,h=0,i=this.length,j=0===arguments.length||"string"==typeof a&&a;if(m.isFunction(a))return this.each(function(b){m(this).removeClass(a.call(this,b,this.className))});if(j)for(b=(a||"").match(E)||[];i>h;h++)if(c=this[h],d=1===c.nodeType&&(c.className?(" "+c.className+" ").replace(ub," "):"")){f=0;while(e=b[f++])while(d.indexOf(" "+e+" ")>=0)d=d.replace(" "+e+" "," ");g=a?m.trim(d):"",c.className!==g&&(c.className=g)}return this},toggleClass:function(a,b){var c=typeof a;return"boolean"==typeof b&&"string"===c?b?this.addClass(a):this.removeClass(a):this.each(m.isFunction(a)?function(c){m(this).toggleClass(a.call(this,c,this.className,b),b)}:function(){if("string"===c){var b,d=0,e=m(this),f=a.match(E)||[];while(b=f[d++])e.hasClass(b)?e.removeClass(b):e.addClass(b)}else(c===K||"boolean"===c)&&(this.className&&m._data(this,"__className__",this.className),this.className=this.className||a===!1?"":m._data(this,"__className__")||"")})},hasClass:function(a){for(var b=" "+a+" ",c=0,d=this.length;d>c;c++)if(1===this[c].nodeType&&(" "+this[c].className+" ").replace(ub," ").indexOf(b)>=0)return!0;return!1}}),m.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error contextmenu".split(" "),function(a,b){m.fn[b]=function(a,c){return arguments.length>0?this.on(b,null,a,c):this.trigger(b)}}),m.fn.extend({hover:function(a,b){return this.mouseenter(a).mouseleave(b||a)},bind:function(a,b,c){return this.on(a,null,b,c)},unbind:function(a,b){return this.off(a,null,b)},delegate:function(a,b,c,d){return this.on(b,a,c,d)},undelegate:function(a,b,c){return 1===arguments.length?this.off(a,"**"):this.off(b,a||"**",c)}});var vb=m.now(),wb=/\?/,xb=/(,)|(\[|{)|(}|])|"(?:[^"\\\r\n]|\\["\\\/bfnrt]|\\u[\da-fA-F]{4})*"\s*:?|true|false|null|-?(?!0\d)\d+(?:\.\d+|)(?:[eE][+-]?\d+|)/g;m.parseJSON=function(b){if(a.JSON&&a.JSON.parse)return a.JSON.parse(b+"");var c,d=null,e=m.trim(b+"");return e&&!m.trim(e.replace(xb,function(a,b,e,f){return c&&b&&(d=0),0===d?a:(c=e||b,d+=!f-!e,"")}))?Function("return "+e)():m.error("Invalid JSON: "+b)},m.parseXML=function(b){var c,d;if(!b||"string"!=typeof b)return null;try{a.DOMParser?(d=new DOMParser,c=d.parseFromString(b,"text/xml")):(c=new ActiveXObject("Microsoft.XMLDOM"),c.async="false",c.loadXML(b))}catch(e){c=void 0}return c&&c.documentElement&&!c.getElementsByTagName("parsererror").length||m.error("Invalid XML: "+b),c};var yb,zb,Ab=/#.*$/,Bb=/([?&])_=[^&]*/,Cb=/^(.*?):[ \t]*([^\r\n]*)\r?$/gm,Db=/^(?:about|app|app-storage|.+-extension|file|res|widget):$/,Eb=/^(?:GET|HEAD)$/,Fb=/^\/\//,Gb=/^([\w.+-]+:)(?:\/\/(?:[^\/?#]*@|)([^\/?#:]*)(?::(\d+)|)|)/,Hb={},Ib={},Jb="*/".concat("*");try{zb=location.href}catch(Kb){zb=y.createElement("a"),zb.href="",zb=zb.href}yb=Gb.exec(zb.toLowerCase())||[];function Lb(a){return function(b,c){"string"!=typeof b&&(c=b,b="*");var d,e=0,f=b.toLowerCase().match(E)||[];if(m.isFunction(c))while(d=f[e++])"+"===d.charAt(0)?(d=d.slice(1)||"*",(a[d]=a[d]||[]).unshift(c)):(a[d]=a[d]||[]).push(c)}}function Mb(a,b,c,d){var e={},f=a===Ib;function g(h){var i;return e[h]=!0,m.each(a[h]||[],function(a,h){var j=h(b,c,d);return"string"!=typeof j||f||e[j]?f?!(i=j):void 0:(b.dataTypes.unshift(j),g(j),!1)}),i}return g(b.dataTypes[0])||!e["*"]&&g("*")}function Nb(a,b){var c,d,e=m.ajaxSettings.flatOptions||{};for(d in b)void 0!==b[d]&&((e[d]?a:c||(c={}))[d]=b[d]);return c&&m.extend(!0,a,c),a}function Ob(a,b,c){var d,e,f,g,h=a.contents,i=a.dataTypes;while("*"===i[0])i.shift(),void 0===e&&(e=a.mimeType||b.getResponseHeader("Content-Type"));if(e)for(g in h)if(h[g]&&h[g].test(e)){i.unshift(g);break}if(i[0]in c)f=i[0];else{for(g in c){if(!i[0]||a.converters[g+" "+i[0]]){f=g;break}d||(d=g)}f=f||d}return f?(f!==i[0]&&i.unshift(f),c[f]):void 0}function Pb(a,b,c,d){var e,f,g,h,i,j={},k=a.dataTypes.slice();if(k[1])for(g in a.converters)j[g.toLowerCase()]=a.converters[g];f=k.shift();while(f)if(a.responseFields[f]&&(c[a.responseFields[f]]=b),!i&&d&&a.dataFilter&&(b=a.dataFilter(b,a.dataType)),i=f,f=k.shift())if("*"===f)f=i;else if("*"!==i&&i!==f){if(g=j[i+" "+f]||j["* "+f],!g)for(e in j)if(h=e.split(" "),h[1]===f&&(g=j[i+" "+h[0]]||j["* "+h[0]])){g===!0?g=j[e]:j[e]!==!0&&(f=h[0],k.unshift(h[1]));break}if(g!==!0)if(g&&a["throws"])b=g(b);else try{b=g(b)}catch(l){return{state:"parsererror",error:g?l:"No conversion from "+i+" to "+f}}}return{state:"success",data:b}}m.extend({active:0,lastModified:{},etag:{},ajaxSettings:{url:zb,type:"GET",isLocal:Db.test(yb[1]),global:!0,processData:!0,async:!0,contentType:"application/x-www-form-urlencoded; charset=UTF-8",accepts:{"*":Jb,text:"text/plain",html:"text/html",xml:"application/xml, text/xml",json:"application/json, text/javascript"},contents:{xml:/xml/,html:/html/,json:/json/},responseFields:{xml:"responseXML",text:"responseText",json:"responseJSON"},converters:{"* text":String,"text html":!0,"text json":m.parseJSON,"text xml":m.parseXML},flatOptions:{url:!0,context:!0}},ajaxSetup:function(a,b){return b?Nb(Nb(a,m.ajaxSettings),b):Nb(m.ajaxSettings,a)},ajaxPrefilter:Lb(Hb),ajaxTransport:Lb(Ib),ajax:function(a,b){"object"==typeof a&&(b=a,a=void 0),b=b||{};var c,d,e,f,g,h,i,j,k=m.ajaxSetup({},b),l=k.context||k,n=k.context&&(l.nodeType||l.jquery)?m(l):m.event,o=m.Deferred(),p=m.Callbacks("once memory"),q=k.statusCode||{},r={},s={},t=0,u="canceled",v={readyState:0,getResponseHeader:function(a){var b;if(2===t){if(!j){j={};while(b=Cb.exec(f))j[b[1].toLowerCase()]=b[2]}b=j[a.toLowerCase()]}return null==b?null:b},getAllResponseHeaders:function(){return 2===t?f:null},setRequestHeader:function(a,b){var c=a.toLowerCase();return t||(a=s[c]=s[c]||a,r[a]=b),this},overrideMimeType:function(a){return t||(k.mimeType=a),this},statusCode:function(a){var b;if(a)if(2>t)for(b in a)q[b]=[q[b],a[b]];else v.always(a[v.status]);return this},abort:function(a){var b=a||u;return i&&i.abort(b),x(0,b),this}};if(o.promise(v).complete=p.add,v.success=v.done,v.error=v.fail,k.url=((a||k.url||zb)+"").replace(Ab,"").replace(Fb,yb[1]+"//"),k.type=b.method||b.type||k.method||k.type,k.dataTypes=m.trim(k.dataType||"*").toLowerCase().match(E)||[""],null==k.crossDomain&&(c=Gb.exec(k.url.toLowerCase()),k.crossDomain=!(!c||c[1]===yb[1]&&c[2]===yb[2]&&(c[3]||("http:"===c[1]?"80":"443"))===(yb[3]||("http:"===yb[1]?"80":"443")))),k.data&&k.processData&&"string"!=typeof k.data&&(k.data=m.param(k.data,k.traditional)),Mb(Hb,k,b,v),2===t)return v;h=m.event&&k.global,h&&0===m.active++&&m.event.trigger("ajaxStart"),k.type=k.type.toUpperCase(),k.hasContent=!Eb.test(k.type),e=k.url,k.hasContent||(k.data&&(e=k.url+=(wb.test(e)?"&":"?")+k.data,delete k.data),k.cache===!1&&(k.url=Bb.test(e)?e.replace(Bb,"$1_="+vb++):e+(wb.test(e)?"&":"?")+"_="+vb++)),k.ifModified&&(m.lastModified[e]&&v.setRequestHeader("If-Modified-Since",m.lastModified[e]),m.etag[e]&&v.setRequestHeader("If-None-Match",m.etag[e])),(k.data&&k.hasContent&&k.contentType!==!1||b.contentType)&&v.setRequestHeader("Content-Type",k.contentType),v.setRequestHeader("Accept",k.dataTypes[0]&&k.accepts[k.dataTypes[0]]?k.accepts[k.dataTypes[0]]+("*"!==k.dataTypes[0]?", "+Jb+"; q=0.01":""):k.accepts["*"]);for(d in k.headers)v.setRequestHeader(d,k.headers[d]);if(k.beforeSend&&(k.beforeSend.call(l,v,k)===!1||2===t))return v.abort();u="abort";for(d in{success:1,error:1,complete:1})v[d](k[d]);if(i=Mb(Ib,k,b,v)){v.readyState=1,h&&n.trigger("ajaxSend",[v,k]),k.async&&k.timeout>0&&(g=setTimeout(function(){v.abort("timeout")},k.timeout));try{t=1,i.send(r,x)}catch(w){if(!(2>t))throw w;x(-1,w)}}else x(-1,"No Transport");function x(a,b,c,d){var j,r,s,u,w,x=b;2!==t&&(t=2,g&&clearTimeout(g),i=void 0,f=d||"",v.readyState=a>0?4:0,j=a>=200&&300>a||304===a,c&&(u=Ob(k,v,c)),u=Pb(k,u,v,j),j?(k.ifModified&&(w=v.getResponseHeader("Last-Modified"),w&&(m.lastModified[e]=w),w=v.getResponseHeader("etag"),w&&(m.etag[e]=w)),204===a||"HEAD"===k.type?x="nocontent":304===a?x="notmodified":(x=u.state,r=u.data,s=u.error,j=!s)):(s=x,(a||!x)&&(x="error",0>a&&(a=0))),v.status=a,v.statusText=(b||x)+"",j?o.resolveWith(l,[r,x,v]):o.rejectWith(l,[v,x,s]),v.statusCode(q),q=void 0,h&&n.trigger(j?"ajaxSuccess":"ajaxError",[v,k,j?r:s]),p.fireWith(l,[v,x]),h&&(n.trigger("ajaxComplete",[v,k]),--m.active||m.event.trigger("ajaxStop")))}return v},getJSON:function(a,b,c){return m.get(a,b,c,"json")},getScript:function(a,b){return m.get(a,void 0,b,"script")}}),m.each(["get","post"],function(a,b){m[b]=function(a,c,d,e){return m.isFunction(c)&&(e=e||d,d=c,c=void 0),m.ajax({url:a,type:b,dataType:e,data:c,success:d})}}),m._evalUrl=function(a){return m.ajax({url:a,type:"GET",dataType:"script",async:!1,global:!1,"throws":!0})},m.fn.extend({wrapAll:function(a){if(m.isFunction(a))return this.each(function(b){m(this).wrapAll(a.call(this,b))});if(this[0]){var b=m(a,this[0].ownerDocument).eq(0).clone(!0);this[0].parentNode&&b.insertBefore(this[0]),b.map(function(){var a=this;while(a.firstChild&&1===a.firstChild.nodeType)a=a.firstChild;return a}).append(this)}return this},wrapInner:function(a){return this.each(m.isFunction(a)?function(b){m(this).wrapInner(a.call(this,b))}:function(){var b=m(this),c=b.contents();c.length?c.wrapAll(a):b.append(a)})},wrap:function(a){var b=m.isFunction(a);return this.each(function(c){m(this).wrapAll(b?a.call(this,c):a)})},unwrap:function(){return this.parent().each(function(){m.nodeName(this,"body")||m(this).replaceWith(this.childNodes)}).end()}}),m.expr.filters.hidden=function(a){return a.offsetWidth<=0&&a.offsetHeight<=0||!k.reliableHiddenOffsets()&&"none"===(a.style&&a.style.display||m.css(a,"display"))},m.expr.filters.visible=function(a){return!m.expr.filters.hidden(a)};var Qb=/%20/g,Rb=/\[\]$/,Sb=/\r?\n/g,Tb=/^(?:submit|button|image|reset|file)$/i,Ub=/^(?:input|select|textarea|keygen)/i;function Vb(a,b,c,d){var e;if(m.isArray(b))m.each(b,function(b,e){c||Rb.test(a)?d(a,e):Vb(a+"["+("object"==typeof e?b:"")+"]",e,c,d)});else if(c||"object"!==m.type(b))d(a,b);else for(e in b)Vb(a+"["+e+"]",b[e],c,d)}m.param=function(a,b){var c,d=[],e=function(a,b){b=m.isFunction(b)?b():null==b?"":b,d[d.length]=encodeURIComponent(a)+"="+encodeURIComponent(b)};if(void 0===b&&(b=m.ajaxSettings&&m.ajaxSettings.traditional),m.isArray(a)||a.jquery&&!m.isPlainObject(a))m.each(a,function(){e(this.name,this.value)});else for(c in a)Vb(c,a[c],b,e);return d.join("&").replace(Qb,"+")},m.fn.extend({serialize:function(){return m.param(this.serializeArray())},serializeArray:function(){return this.map(function(){var a=m.prop(this,"elements");return a?m.makeArray(a):this}).filter(function(){var a=this.type;return this.name&&!m(this).is(":disabled")&&Ub.test(this.nodeName)&&!Tb.test(a)&&(this.checked||!W.test(a))}).map(function(a,b){var c=m(this).val();return null==c?null:m.isArray(c)?m.map(c,function(a){return{name:b.name,value:a.replace(Sb,"\r\n")}}):{name:b.name,value:c.replace(Sb,"\r\n")}}).get()}}),m.ajaxSettings.xhr=void 0!==a.ActiveXObject?function(){return!this.isLocal&&/^(get|post|head|put|delete|options)$/i.test(this.type)&&Zb()||$b()}:Zb;var Wb=0,Xb={},Yb=m.ajaxSettings.xhr();a.attachEvent&&a.attachEvent("onunload",function(){for(var a in Xb)Xb[a](void 0,!0)}),k.cors=!!Yb&&"withCredentials"in Yb,Yb=k.ajax=!!Yb,Yb&&m.ajaxTransport(function(a){if(!a.crossDomain||k.cors){var b;return{send:function(c,d){var e,f=a.xhr(),g=++Wb;if(f.open(a.type,a.url,a.async,a.username,a.password),a.xhrFields)for(e in a.xhrFields)f[e]=a.xhrFields[e];a.mimeType&&f.overrideMimeType&&f.overrideMimeType(a.mimeType),a.crossDomain||c["X-Requested-With"]||(c["X-Requested-With"]="XMLHttpRequest");for(e in c)void 0!==c[e]&&f.setRequestHeader(e,c[e]+"");f.send(a.hasContent&&a.data||null),b=function(c,e){var h,i,j;if(b&&(e||4===f.readyState))if(delete Xb[g],b=void 0,f.onreadystatechange=m.noop,e)4!==f.readyState&&f.abort();else{j={},h=f.status,"string"==typeof f.responseText&&(j.text=f.responseText);try{i=f.statusText}catch(k){i=""}h||!a.isLocal||a.crossDomain?1223===h&&(h=204):h=j.text?200:404}j&&d(h,i,j,f.getAllResponseHeaders())},a.async?4===f.readyState?setTimeout(b):f.onreadystatechange=Xb[g]=b:b()},abort:function(){b&&b(void 0,!0)}}}});function Zb(){try{return new a.XMLHttpRequest}catch(b){}}function $b(){try{return new a.ActiveXObject("Microsoft.XMLHTTP")}catch(b){}}m.ajaxSetup({accepts:{script:"text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"},contents:{script:/(?:java|ecma)script/},converters:{"text script":function(a){return m.globalEval(a),a}}}),m.ajaxPrefilter("script",function(a){void 0===a.cache&&(a.cache=!1),a.crossDomain&&(a.type="GET",a.global=!1)}),m.ajaxTransport("script",function(a){if(a.crossDomain){var b,c=y.head||m("head")[0]||y.documentElement;return{send:function(d,e){b=y.createElement("script"),b.async=!0,a.scriptCharset&&(b.charset=a.scriptCharset),b.src=a.url,b.onload=b.onreadystatechange=function(a,c){(c||!b.readyState||/loaded|complete/.test(b.readyState))&&(b.onload=b.onreadystatechange=null,b.parentNode&&b.parentNode.removeChild(b),b=null,c||e(200,"success"))},c.insertBefore(b,c.firstChild)},abort:function(){b&&b.onload(void 0,!0)}}}});var _b=[],ac=/(=)\?(?=&|$)|\?\?/;m.ajaxSetup({jsonp:"callback",jsonpCallback:function(){var a=_b.pop()||m.expando+"_"+vb++;return this[a]=!0,a}}),m.ajaxPrefilter("json jsonp",function(b,c,d){var e,f,g,h=b.jsonp!==!1&&(ac.test(b.url)?"url":"string"==typeof b.data&&!(b.contentType||"").indexOf("application/x-www-form-urlencoded")&&ac.test(b.data)&&"data");return h||"jsonp"===b.dataTypes[0]?(e=b.jsonpCallback=m.isFunction(b.jsonpCallback)?b.jsonpCallback():b.jsonpCallback,h?b[h]=b[h].replace(ac,"$1"+e):b.jsonp!==!1&&(b.url+=(wb.test(b.url)?"&":"?")+b.jsonp+"="+e),b.converters["script json"]=function(){return g||m.error(e+" was not called"),g[0]},b.dataTypes[0]="json",f=a[e],a[e]=function(){g=arguments},d.always(function(){a[e]=f,b[e]&&(b.jsonpCallback=c.jsonpCallback,_b.push(e)),g&&m.isFunction(f)&&f(g[0]),g=f=void 0}),"script"):void 0}),m.parseHTML=function(a,b,c){if(!a||"string"!=typeof a)return null;"boolean"==typeof b&&(c=b,b=!1),b=b||y;var d=u.exec(a),e=!c&&[];return d?[b.createElement(d[1])]:(d=m.buildFragment([a],b,e),e&&e.length&&m(e).remove(),m.merge([],d.childNodes))};var bc=m.fn.load;m.fn.load=function(a,b,c){if("string"!=typeof a&&bc)return bc.apply(this,arguments);var d,e,f,g=this,h=a.indexOf(" ");return h>=0&&(d=m.trim(a.slice(h,a.length)),a=a.slice(0,h)),m.isFunction(b)?(c=b,b=void 0):b&&"object"==typeof b&&(f="POST"),g.length>0&&m.ajax({url:a,type:f,dataType:"html",data:b}).done(function(a){e=arguments,g.html(d?m("<div>").append(m.parseHTML(a)).find(d):a)}).complete(c&&function(a,b){g.each(c,e||[a.responseText,b,a])}),this},m.each(["ajaxStart","ajaxStop","ajaxComplete","ajaxError","ajaxSuccess","ajaxSend"],function(a,b){m.fn[b]=function(a){return this.on(b,a)}}),m.expr.filters.animated=function(a){return m.grep(m.timers,function(b){return a===b.elem}).length};var cc=a.document.documentElement;function dc(a){return m.isWindow(a)?a:9===a.nodeType?a.defaultView||a.parentWindow:!1}m.offset={setOffset:function(a,b,c){var d,e,f,g,h,i,j,k=m.css(a,"position"),l=m(a),n={};"static"===k&&(a.style.position="relative"),h=l.offset(),f=m.css(a,"top"),i=m.css(a,"left"),j=("absolute"===k||"fixed"===k)&&m.inArray("auto",[f,i])>-1,j?(d=l.position(),g=d.top,e=d.left):(g=parseFloat(f)||0,e=parseFloat(i)||0),m.isFunction(b)&&(b=b.call(a,c,h)),null!=b.top&&(n.top=b.top-h.top+g),null!=b.left&&(n.left=b.left-h.left+e),"using"in b?b.using.call(a,n):l.css(n)}},m.fn.extend({offset:function(a){if(arguments.length)return void 0===a?this:this.each(function(b){m.offset.setOffset(this,a,b)});var b,c,d={top:0,left:0},e=this[0],f=e&&e.ownerDocument;if(f)return b=f.documentElement,m.contains(b,e)?(typeof e.getBoundingClientRect!==K&&(d=e.getBoundingClientRect()),c=dc(f),{top:d.top+(c.pageYOffset||b.scrollTop)-(b.clientTop||0),left:d.left+(c.pageXOffset||b.scrollLeft)-(b.clientLeft||0)}):d},position:function(){if(this[0]){var a,b,c={top:0,left:0},d=this[0];return"fixed"===m.css(d,"position")?b=d.getBoundingClientRect():(a=this.offsetParent(),b=this.offset(),m.nodeName(a[0],"html")||(c=a.offset()),c.top+=m.css(a[0],"borderTopWidth",!0),c.left+=m.css(a[0],"borderLeftWidth",!0)),{top:b.top-c.top-m.css(d,"marginTop",!0),left:b.left-c.left-m.css(d,"marginLeft",!0)}}},offsetParent:function(){return this.map(function(){var a=this.offsetParent||cc;while(a&&!m.nodeName(a,"html")&&"static"===m.css(a,"position"))a=a.offsetParent;return a||cc})}}),m.each({scrollLeft:"pageXOffset",scrollTop:"pageYOffset"},function(a,b){var c=/Y/.test(b);m.fn[a]=function(d){return V(this,function(a,d,e){var f=dc(a);return void 0===e?f?b in f?f[b]:f.document.documentElement[d]:a[d]:void(f?f.scrollTo(c?m(f).scrollLeft():e,c?e:m(f).scrollTop()):a[d]=e)},a,d,arguments.length,null)}}),m.each(["top","left"],function(a,b){m.cssHooks[b]=La(k.pixelPosition,function(a,c){return c?(c=Ja(a,b),Ha.test(c)?m(a).position()[b]+"px":c):void 0})}),m.each({Height:"height",Width:"width"},function(a,b){m.each({padding:"inner"+a,content:b,"":"outer"+a},function(c,d){m.fn[d]=function(d,e){var f=arguments.length&&(c||"boolean"!=typeof d),g=c||(d===!0||e===!0?"margin":"border");return V(this,function(b,c,d){var e;return m.isWindow(b)?b.document.documentElement["client"+a]:9===b.nodeType?(e=b.documentElement,Math.max(b.body["scroll"+a],e["scroll"+a],b.body["offset"+a],e["offset"+a],e["client"+a])):void 0===d?m.css(b,c,g):m.style(b,c,d,g)},b,f?d:void 0,f,null)}})}),m.fn.size=function(){return this.length},m.fn.andSelf=m.fn.addBack,"function"==typeof define&&define.amd&&define("jquery",[],function(){return m});var ec=a.jQuery,fc=a.$;return m.noConflict=function(b){return a.$===m&&(a.$=fc),b&&a.jQuery===m&&(a.jQuery=ec),m},typeof b===K&&(a.jQuery=a.$=m),m});
        ]]>
      </xsl:text>
      <xsl:text disable-output-escaping="yes">/*]]&gt;*/&lt;/script&gt;</xsl:text>
    </xsl:if>
    <!--načtení vlastních javascriptů-->
    <xsl:text disable-output-escaping="yes">&lt;script type="text/javascript"&gt;/*&lt;![CDATA[*/</xsl:text>
    <xsl:text disable-output-escaping="yes">
      <![CDATA[
        $(document).ready(function(){
          prepareFourFtTables();
          prepareGraphTables();
          prepareCollapsableSections();
        });


        var prepareCollapsableSections = function(){
          var sectionH3s = $('div.section h3');
          sectionH3s.click(function(){
            $(this).parent('div.section').toggleClass('collapsed');
          });
          sectionH3s.addClass('clickable');

          prepareFoundRuleCollapsableDetails();
          $('div#sect5 div.section.foundRule').addClass('collapsed');
          prepareAttributesCollapsableDetails();
          $('div#sect3 div.section.attribute').addClass('collapsed');
          prepareCedentsCollapsableDetails();
          $('div#sect4 div.section#sect4-cedents').addClass('collapsed');
          prepareDataFieldsCollapsableDetails();
          $('div#sect2 div.section.dataField').addClass('collapsed');

          //region připojení akce ke všem odkazům na IDčka, aby při jejich použití došlo k rozbalení příslušné sekce
          $('a[href^="#"]').each(function(){
            $(this).click(function(){
              var href=$(this).attr('href');
              if (href.match('^#')){
                var targetElement=$(href);
                targetElement.removeClass('collapsed');
                targetElement.parents('div.section').removeClass('collapsed');
              }
            });
          });
          //endregion
        };

        /**
         * Funkce pro přípravu detailů o vytvořených atributech
         */
        var prepareAttributesCollapsableDetails = function(){
          $('div#sect3 div.section.attribute').each(function(){
            var h3 = $(this).find('h3');
            //příprava jednoduchých detailů nalezeného pravidla, které se zobrazí, pokud je daná sekce sbalená
            var basicInfoTable = $(this).find('table.fieldBasicInfo');
            if (basicInfoTable){
              var attributeDetailsStr="";
              basicInfoTable.find('tr').each(function(){
                if ($(this).hasClass('more')){return;}
                var name = $(this).find('th').text().trim();
                var value = $(this).find('td').html().trim();
                if (name!=''){
                  if (attributeDetailsStr!=""){
                    attributeDetailsStr+=", ";
                  }
                  attributeDetailsStr+=name+': '+value;
                }
              });
              h3.after('<div class="simpleDetails">'+attributeDetailsStr+'</div>');
            }
          });

          //region odkazy pro hromadné (roz)balení všech detailů
          var attributesCount=$('div#sect3 .attributesCount');
          attributesCount.after(prepareMultiCollapsers('div#sect3 div.section.attribute'));
          //endregion odkazy pro hromadné (roz)balení všech detailů
        };


        /**
         * Funkce pro přípravu detailů o zadání pravidla
         */
        var prepareCedentsCollapsableDetails = function(){
          $('div#sect4 div#sect4-imValues').each(function(){
            var h3 = $(this).find('h3');
            var detailsStr="";
            //příprava jednoduchých detailů nalezeného pravidla, které se zobrazí, pokud je daná sekce sbalená
            $(this).find("td.name").each(function(){
              var str=$(this).text();
              if (str!=""){
                if (detailsStr!=""){
                  detailsStr+=", ";
                }
                detailsStr+=str.trim();
              }
            });

            h3.after('<div class="simpleDetails">'+detailsStr+'</div>');
          });

        };

        /**
         * Funkce pro přípravu detailů o vytvořených atributech
         */
        var prepareDataFieldsCollapsableDetails = function(){
          $('div#sect2 div.section.dataField').each(function(){
            var h3 = $(this).find('h3');
            //příprava jednoduchých detailů nalezeného pravidla, které se zobrazí, pokud je daná sekce sbalená
            var basicInfoTable = $(this).find('table.fieldBasicInfo');
            if (basicInfoTable){
              var attributeDetailsStr="";
              basicInfoTable.find('tr').each(function(){
                if ($(this).hasClass('more')){return;}
                var name = $(this).find('th').text().trim();
                var value = $(this).find('td').html().trim();
                if (name!=''){
                  if (attributeDetailsStr!=""){
                    attributeDetailsStr+=", ";
                  }
                  attributeDetailsStr+=name+': '+value;
                }
              });
              h3.after('<div class="simpleDetails">'+attributeDetailsStr+'</div>');
            }
          });

        };


        /**
         * Funkce pro přípravu detailů o nalezených pravidlech
         */
        var prepareFoundRuleCollapsableDetails = function(){
          var foundRulesCounter=1;
          $('div#sect5 div.section.foundRule').each(function(){
            var h3 = $(this).find('h3');
            //příprava jednoduchých detailů nalezeného pravidla, které se zobrazí, pokud je daná sekce sbalená
            var imValuesTable = $(this).find('table.imValuesTable');
            if (imValuesTable){
              var ruleDetailsStr="";
              imValuesTable.find('tr').each(function(){
                var name = $(this).find('td.name').text().trim();
                var value = $(this).find('td.value').text().trim();
                if (name!=''){
                  if (ruleDetailsStr!=""){
                    ruleDetailsStr+=", ";
                  }
                  ruleDetailsStr+=name+': '+value;
                }
              });
              h3.after('<div class="simpleDetails">'+ruleDetailsStr+'</div>');
            }
            h3.append('<span class="counter">#'+foundRulesCounter+'</span>');
            foundRulesCounter++;
          });

          //region odkazy pro hromadné (roz)balení všech detailů
          var rulesCount=$('div#sect5 .foundRulesCount');
          rulesCount.after(prepareMultiCollapsers('div#sect5 div.section.foundRule'));
          //endregion odkazy pro hromadné (roz)balení všech detailů
        };

        /**
         * Funkce pro připravení odkazů pro hromadné rozbalování/sbalování
         * @returns {*|jQuery|HTMLElement}
         */
        var prepareMultiCollapsers = function(selector){
          var multiCollapsers=$('<div class="multiCollapsers"></div>');
          var uncollapseAllLink=$('<a href="" class="uncollapse">uncollapse all</a>').click(function(e){e.preventDefault();$(selector).removeClass('collapsed');});
          var collapseAllLink=$('<a href="" class="collapse">collapse all</a>').click(function(e){e.preventDefault();$(selector).addClass('collapsed');});
          multiCollapsers.append(uncollapseAllLink, collapseAllLink);
          return multiCollapsers;
        };

        /**
         * Funkce pro přiřazení barevných grafů k buňkám čtyřpolních tabulek
         */
        var prepareFourFtTables = function () {
          $('table.fourFtTable').each(function() {
            var tdA = $(this).find('td.a');
            var tdB = $(this).find('td.b');
            var tdC = $(this).find('td.c');
            var tdD = $(this).find('td.d');
            var a = parseInt(tdA.text());
            var b = parseInt(tdB.text());
            var c = parseInt(tdC.text());
            var d = parseInt(tdD.text());
            var sum = a + b + c + d;
            tdA.addClass('bg'+Math.round(a*100/sum)+'p');
            tdB.addClass('bg'+Math.round(b*100/sum)+'p');
            tdC.addClass('bg'+Math.round(c*100/sum)+'p');
            tdD.addClass('bg'+Math.round(d*100/sum)+'p');
          });
        };

        var prepareGraphTables = function(){
          $('table.graphTable').each(function(){
            generateTdGraphsForGraphTable($(this));
          });
        };

        var generateTdGraphsForGraphTable = function(table){
          //region calculate total count of frequencies
          var frequenciesSum=0;
          var TDs=table.find('td.frequency');
          TDs.each(function(){
            var value=$(this).text();
            if (!isNaN(value)){
              frequenciesSum+=parseInt(value);
            }
          });
          if (frequenciesSum==0){return;}
          //add classes to each td.frequency
          TDs.each(function () {
            var value=$(this).text();
            if (!isNaN(value)){
              value=Math.round(parseInt(value)*100/frequenciesSum);
              $(this).addClass('bg'+value+'p');
            }
          });
        };
      ]]>
    </xsl:text>
    <xsl:text disable-output-escaping="yes">/*]]&gt;*/&lt;/script&gt;</xsl:text>
    <!--načtení skriptů pro samostatnou stránku-->
    <xsl:if test="not($contentOnly)">
      <xsl:text disable-output-escaping="yes">&lt;script type="text/javascript"&gt;/*&lt;![CDATA[*/</xsl:text>
      <xsl:text disable-output-escaping="yes">
        <![CDATA[
          $(document).ready(function(){
          var navigationElement=$('div#navigation');
          var navigationElementTop=navigationElement.offset().top-20;

          $('div#navigation a[href^="#"]').click(function(event){
            var elementId=$(this).attr('href');
            var element=$(elementId);
            if (element){
              event.preventDefault();
              navigationElement.addClass('onTop');
              $(window).scrollTop(element.position().top);
            }
          });

          var solveNavigationPosition = function(){
            if ($(document).scrollTop()>navigationElementTop){
              navigationElement.addClass('onTop');
            }else{
              navigationElement.removeClass('onTop');
            }
          };

          solveNavigationPosition();

          $(window).scroll(function(){
            solveNavigationPosition();
          });
        });
        ]]>
      </xsl:text>
      <xsl:text disable-output-escaping="yes">/*]]&gt;*/&lt;/script&gt;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/p:PMML" mode="body">
    <!-- ===============
         Document header
         =============== -->
    <!-- uses: 4FTPMML2HTML-header -->
    <header>
      <xsl:if test="not($contentOnly)">
        <h1>
          <xsl:text>Description of Data Mining Task</xsl:text>
        </h1>
      </xsl:if>

      <!-- task metadata -->
      <div class="section" id="meta">
        <xsl:apply-templates select="p:Header"/>
      </div>

      <p>
        <xsl:text>This document contains automatically generated report on a data mining task.</xsl:text>
      </p>
    </header>

    <!-- =================
         Table of contents
         ================= -->
    <!-- uses: 4FTPMML2HTML-toc -->
    <div class="section" id="navigation">
      <h2>
        <xsl:text>Content</xsl:text>
      </h2>
      <ol>
        <li>
          <a href="#sect2">
            <xsl:text>Dataset Description</xsl:text>
          </a>
        </li>
        <li>
          <a href="#sect3">
            <xsl:text>Created Attributes</xsl:text>
          </a>
        </li>
        <li>
          <a href="#sect4">
            <xsl:text>Data Mining Task Setting</xsl:text>
          </a>
        </li>
        <li>
          <a href="#sect5">
            <xsl:choose>
              <xsl:when test="/p:PMML/guha:SD4ftModel">
                <xsl:text>Discovered Action Rules</xsl:text>
              </xsl:when>
              <xsl:when test="/p:PMML/guha:Ac4ftModel">
                <xsl:text>Discovered pairs of Association Rules</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Discovered Association Rules</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </a>
        </li>
      </ol>
    </div>
    <!-- ==============================
         Section 1+2 - Data description
         ============================== -->
    <div class="section" id="sect2">

      <h2>
        <xsl:text>Dataset Description</xsl:text>
      </h2>
      <p>
        <xsl:text>This section contains detailed description of the original data set. Below, all the columns used in the analysis are listed and for each column, the frequency analysis is attached. These data columns has been used for derivation of </xsl:text><a href="#sect3"><xsl:text>attributes used in this data mining task</xsl:text></a>.
      </p>

      <div class="section list">
        <h3>
          <xsl:text>List of data fields</xsl:text>
        </h3>
        <xsl:apply-templates select="p:DataDictionary" mode="sect2list"/>
      </div>

      <xsl:apply-templates select="p:DataDictionary" mode="sect2"/>
    </div>

    <!-- ==============================
         Section 3 - Created Attributes
         ============================== -->
    <div class="section" id="sect3">
      <h2>
        <xsl:text>Created Attributes</xsl:text>
      </h2>
      <p>
        <xsl:text>Attribute (in the sense of this analysis) is a mapping of a domain to finite set...</xsl:text>
      </p>
      <p>
        <xsl:text>This part of the analytical report lists all the created attributes and their characteristics:</xsl:text>
      </p>
      <ul>
        <li>
          <xsl:text>Column from which the attribute was derived</xsl:text>
        </li>
        <li>
          <xsl:text>Attribute type (categorical, ordinal, continuous)</xsl:text>
        </li>
        <li>
          <xsl:text>Frequency analysis – histogram of the intervals or enumerations of the attribute. The histograms are ordered by the highest frequent values. If the attribute contains more categories than </xsl:text>
          <xsl:value-of select="$maxCategoriesToList"/>
          <xsl:text>, the remaining categories are grouped into “Other” category.</xsl:text>
        </li>
      </ul>


      <p class="attributesCount">
        <xsl:text>Number of created attributes:</xsl:text>
        <strong>
          <xsl:value-of select="count(p:TransformationDictionary/p:DerivedField)"/>
        </strong>
      </p>

      <div class="section list">
        <h3>
          <xsl:text>List of data fields</xsl:text>
        </h3>
        <xsl:apply-templates select="p:TransformationDictionary" mode="sect3list"/>
      </div>

      <xsl:apply-templates select="p:TransformationDictionary" mode="sect3"/>
    </div>
    <!-- =========================
         Section 4 - Task settings
         ========================= -->
    <div class="section" id="sect4">

      <h2>
        <xsl:text>Data Mining Task Setting</xsl:text>
      </h2>
      <xsl:choose>
        <!-- SD4ftModel -->
        <xsl:when test="/p:PMML/guha:SD4ftModel">
          <p>
            <xsl:text>This part of the analytical report describes the SD4ft procedure setting. The setting consists of </xsl:text>
          </p>
          <ul>
            <li>
              <xsl:text>Set of quantifiers as interest measures for the output pairs of association rules</xsl:text>
            </li>
            <li>
              <xsl:text>Set of Derived Boolean attribute settings for the definition of the first set</xsl:text>
            </li>
            <li>
              <xsl:text>Set of Derived Boolean attribute settings for the definition of the second set</xsl:text>
            </li>
          </ul>
          <p>
            <xsl:text>Below, all the interest measures for the output pairs of association rules are stated. The table contains name of the quantifier (interest measure) and also  minimal values of the quantifier threshold(s).</xsl:text>
          </p>
        </xsl:when>
        <!-- Ac4ftModel -->
        <xsl:when test="/p:PMML/guha:Ac4ftModel">
          <p>
            <xsl:text>This part of the analytical report describes the SD4ft procedure setting. The setting consists of </xsl:text>
          </p>
          <ul>
            <li>
              <xsl:text>Set of quantifiers as interest measures for the output action rules</xsl:text>
            </li>
            <li>
              <xsl:text>Set of Derived Boolean attribute settings for the antecedent stable part and antecedent variable part</xsl:text>
            </li>
            <li>
              <xsl:text>Set of Derived Boolean attribute settings for the consequent stable part and consequent variable part</xsl:text>
            </li>
          </ul>
          <p>
            <xsl:text>Below, all the interest measures for the output action rules are stated. The table contains name of the quantifier (interest measure) and also minimal values of the quantifier threshold(s).</xsl:text>
          </p>
        </xsl:when>
        <!-- AssociationModel -->
        <xsl:otherwise>
          <p>
            <xsl:text>This part of the analytical report describes the ASSOC procedure setting. The setting consists of </xsl:text>
          </p>
          <ul>
            <li>
              <xsl:text>Set of quantifiers as interest measures for the output association rules</xsl:text>
            </li>
            <li>
              <xsl:text>Set of Derived Boolean attribute settings for the antecedent</xsl:text>
            </li>
            <li>
              <xsl:text>Set of Derived Boolean attribute settings for the consequent</xsl:text>
            </li>
          </ul>
          <p>
            <xsl:text>Below, all the interest measures for the output association rules are stated. The table contains name of the quantifier (interest measure) and also minimal values of the quantifier threshold(s).</xsl:text>
          </p>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="guha:AssociationModel | guha:SD4ftModel | guha:Ac4ftModel | guha:CFMinerModel"
                           mode="sect4"/>
    </div>
    <!-- ==========================
         Section 5 - Discovered ARs
         ========================== -->
    <div class="section" id="sect5">

      <xsl:choose>
        <xsl:when test="/p:PMML/guha:SD4ftModel">
          <h2>
            <xsl:text>Discovered Action Rules</xsl:text>
          </h2>
          <p>
            <xsl:text>Below, all the discovered patterns (action rules) are listed. Each association rule contains name, values of the interest measure (quantifier) and a four-fold contingency table for the initial and the final state. The following paragraph complies with the PMML standard and shows, which attributes occur in the discovered action rules. Also, number of discovered rules is stated.</xsl:text>
          </p>
        </xsl:when>
        <xsl:when test="/p:PMML/guha:Ac4ftModel">
          <h2>
            <xsl:text>Discovered pairs of Association Rules</xsl:text>
          </h2>
          <p>
            <xsl:text>Below, all the discovered patterns (pairs of association rules) are listed. Each pair of association rules contains name, values of the interest measure (quantifier) and a four-fold contingency table for each of the rules. The following paragraph complies with the PMML standard and shows, which attributes occur in the discovered association rules. Also, number of discovered rules is stated.</xsl:text>
          </p>
        </xsl:when>
        <xsl:otherwise>
          <h2>
            <xsl:text>Discovered Association Rules</xsl:text>
          </h2>
          <p>
            <xsl:text>Below, all the discovered patterns (association rules) are listed. Each association rule contains name, values of the interest measure (quantifier) and a four-fold contingency table. The following paragraph complies with the PMML standard and shows, which attributes occur in the discovered association rules. Also, number of discovered rules is stated.</xsl:text>
          </p>
        </xsl:otherwise>
      </xsl:choose>
      <p>
        <xsl:text>Discovered rules relate to the following attributes:</xsl:text>
        <xsl:apply-templates select="p:TransformationDictionary/p:DerivedField" mode="sect5"/>.
      </p>

      <p class="foundRulesCount">
        <xsl:text>Number of discovered association rules:</xsl:text>
        <xsl:value-of
            select="guha:AssociationModel/@numberOfRules | guha:SD4ftModel/@numberOfRules | guha:Ac4ftModel/@numberOfRules | guha:CFMinerModel/@numberOfRules"/>
      </p>

      <xsl:apply-templates
          select="guha:AssociationModel/AssociationRules/AssociationRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]"
          mode="sect5"/>
      <xsl:apply-templates
          select="guha:SD4ftModel/SD4ftRules/SD4ftRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]"
          mode="sect5"/>
      <xsl:apply-templates
          select="guha:Ac4ftModel/Ac4ftRules/Ac4ftRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]"
          mode="sect5"/>
      <xsl:apply-templates
          select="guha:CFMinerModel/CFMinerRules/CFMinerRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]"
          mode="sect5"/>

      <xsl:if
          test="($maxRulesToList and (count(guha:AssociationModel/AssociationRules/AssociationRule) > $maxRulesToList))">
        <p style="color:red;">
          <xsl:text>Maximum number of discovered rules exceeded! Number of founded rules:</xsl:text>
          <xsl:value-of
              select="guha:AssociationModel/@numberOfRules | guha:SD4ftModel/@numberOfRules | guha:Ac4ftModel/@numberOfRules | guha:CFMinerModel/@numberOfRules"/>
        </p>
      </xsl:if>
    </div>

  </xsl:template>
  <!--template for data header-->
  <xsl:template match="p:Header">
    <table class="metadata">
      <tr>
        <th scope="row">
          <xsl:text>Task ID</xsl:text>
        </th>
        <td>
          <xsl:value-of select="/p:PMML/guha:AssociationModel/@modelName"/>
          <xsl:value-of select="/p:PMML/guha:SD4ftModel/@modelName"/>
          <xsl:value-of select="/p:PMML/guha:Ac4ftModel/@modelName"/>
          <xsl:value-of select="/p:PMML/guha:CFMinerModel/@modelName"/>
        </td>
      </tr>
      <tr>
        <th scope="row">
          <xsl:text>Software</xsl:text>
        </th>
        <td>
          <xsl:value-of select="p:Application/@name"/>
          <xsl:if test="p:Application/@version">
            (<xsl:value-of select="p:Application/@version"/>)
          </xsl:if>
        </td>
      </tr>
      <tr>
        <th scope="row">
          <xsl:text>Author</xsl:text>
        </th>
        <td>
          <xsl:value-of select="p:Extension[@name='author']/@value"/>
        </td>
      </tr>
    </table>
  </xsl:template>
  <!--endregion-->

  <!-- region Section 2 - Data description -->
  <xsl:template match="p:DataDictionary" mode="sect2">
    <xsl:apply-templates select="p:DataField" mode="sect2"/>
  </xsl:template>

  <xsl:template match="p:DataField" mode="sect2">
    <!-- link name is derived from column name -->
    <div class="section dataField" id="sect2-{@name}">

      <h3>
        <xsl:text>Column: </xsl:text>
        <xsl:value-of select="@name"/>
      </h3>
      <!-- basic info about data field-->
      <xsl:variable name="valueCount" select="count(p:Value)"/>
      <table class="fieldBasicInfo">
        <tr>
          <th scope="row">
            <xsl:text>Number of different values</xsl:text>
          </th>
          <td>
            <xsl:choose>
              <xsl:when test="$valueCount &gt; 0">
                <xsl:value-of select="$valueCount"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$notAvailable"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <th scope="row">
            <xsl:text>Type</xsl:text>
          </th>
          <td>
            <xsl:value-of select="@optype"/>
          </td>
        </tr>
        <xsl:if test="count(p:Interval)>0">
          <tr>
            <th scope="row">
              <xsl:text>Value range</xsl:text>
            </th>
            <td>
              <xsl:apply-templates select="p:Interval" mode="sect2"/>
            </td>
          </tr>
        </xsl:if>
        <xsl:variable name="suppStat" select="p:Extension[@name='Min' or @name='Max' or @name='Avg']"/>
        <xsl:if test="$suppStat">
          <xsl:apply-templates select="p:Extension" mode="sect2"/>
        </xsl:if>
      </table>

      <div class="details">
        <!-- table number depends on previous table count -->

        <!-- frequency table is shown only if any frequence exists -->
        <xsl:variable name="nullPresent" select="count(p:Value[@value=$NullName])"/>
        <xsl:choose>
          <xsl:when test="p:Value">
            <table class="graphTable">
              <tr>
                <th>
                  <xsl:text>Value</xsl:text>
                </th>
                <th>
                  <xsl:text>Frequency</xsl:text>
                </th>
              </tr>

              <xsl:for-each select="p:Value[@value!=$NullName]">
                <xsl:sort select="p:Extension/@value" data-type="number" order="descending"/>
                <xsl:if test="position() &lt;= ($maxValuesToList - $nullPresent) and $maxValuesToList">
                  <!-- apply-templates to p:Value -->
                  <xsl:apply-templates select="self::node()" mode="sect2"/>
                </xsl:if>
              </xsl:for-each>
              <xsl:if test="$nullPresent>0">
                <xsl:apply-templates select="p:Value[@value=$NullName]" mode="sect2"/>
              </xsl:if>
            </table>
          </xsl:when>
          <xsl:otherwise>
            <p class="error">
              <xsl:text>No detail given for this column</xsl:text>
            </p>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="p:Value[position() &gt; $maxValuesToList and $maxValuesToList]">
          <p class="hot">
            <xsl:text>Exceeded </xsl:text>
            maxValuesToList = <xsl:value-of select="$maxValuesToList"/>,
            <xsl:text> first </xsl:text>
            <xsl:value-of select="$maxValuesToList"/>
            <xsl:text> from the total number of </xsl:text>
            <xsl:value-of select="count(p:Value)"/>
            <xsl:text> rules.</xsl:text>
          </p>
        </xsl:if>


      </div>
    </div>
  </xsl:template>

  <xsl:template match="p:Interval" mode="sect2">
    <xsl:choose>
      <xsl:when test="@closure='closedOpen' or @closure='closedClosed'">[</xsl:when>
      <xsl:otherwise>(</xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="@leftMargin"/>;<xsl:value-of select="@rightMargin"/>
    <xsl:choose>
      <xsl:when test="@closure='closedClosed' or @closure='openClosed'">]</xsl:when>
      <xsl:otherwise>)</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="p:Value" mode="sect2">
    <tr>
      <!-- value -->
      <td class="name">
        <xsl:value-of select="@value"/>
      </td>
      <!-- and its freq -->
      <td class="frequency">
        <xsl:value-of select="p:Extension[@name='Frequency']/@value"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="p:Extension[@name='Min' or @name='Max' or @name='Avg' or @name='StDev']" mode="sect2">
    <tr class="more">
      <th scope="row">
        <xsl:choose>
          <xsl:when test="@name='Min'">
            <xsl:text>Minimum</xsl:text>
          </xsl:when>
          <xsl:when test="@name='Max'">
            <xsl:text>Maximum</xsl:text>
          </xsl:when>
          <xsl:when test="@name='Avg'">
            <xsl:text>Average</xsl:text>
          </xsl:when>
          <xsl:when test="@name='StDev'">
            <xsl:text>StDev</xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:text>value of column:</xsl:text>
      </th>
      <td>
        <xsl:value-of select="@value"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="p:DataDictionary" mode="sect2list">
    <!-- tabulka c.1: available columns description: column name, value count, column type -->
    <table>
      <tr>
        <th scope="col">
          <xsl:text>Column name</xsl:text>
        </th>
        <th scope="col">
          <xsl:text>Number of diffrent values</xsl:text>
        </th>
        <th scope="col">
          <xsl:text>Type</xsl:text>
        </th>
      </tr>
      <xsl:apply-templates select="p:DataField" mode="sect2list"/>
    </table>

    <!-- dataFieldCount is sum of first column frequencies -->
    <xsl:variable name="dataFieldCount" select="sum(p:DataField[1]/p:Value/p:Extension[@name='Frequency']/@value)"/>
    <xsl:text>Number of records:</xsl:text>
    <xsl:choose>
      <xsl:when test="$dataFieldCount">
        <xsl:value-of select="$dataFieldCount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$notAvailable"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="p:DataField" mode="sect2list">
    <tr>
      <!-- column name -->
      <td>
        <xsl:apply-templates select="." mode="odkaz"/>
      </td>
      <!-- value count -->
      <td>
        <xsl:variable name="valueCount" select="count(p:Value)"/>
        <xsl:choose>
          <xsl:when test="$valueCount">
            <xsl:value-of select="$valueCount"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$notAvailable"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <!-- column type -->
      <td>
        <xsl:value-of select="@optype"/>
      </td>
    </tr>
  </xsl:template>
  <!-- endregion -->

  <!-- region Section 3 - Created Attributes -->
  <xsl:template match="p:TransformationDictionary" mode="sect3">
    <xsl:apply-templates select="p:DerivedField" mode="sect3"/>
  </xsl:template>

  <xsl:template match="p:TransformationDictionary" mode="sect3list">
    <!-- tabulka c.1: available columns description: column name, value count, column type -->
    <table class="listTable">
      <tr>
        <th scope="col">
          <xsl:text>Attribute</xsl:text>
        </th>
        <th scope="col">
          <xsl:text>Number of categories</xsl:text>
        </th>
        <th scope="col">
          <xsl:text>Derived from column</xsl:text>
        </th>
      </tr>
      <xsl:apply-templates select="p:DerivedField" mode="sect3list"/>
    </table>
  </xsl:template>

  <xsl:template match="p:DerivedField" mode="sect3list">
    <tr>
      <!-- column name -->
      <td>
        <xsl:apply-templates select="." mode="odkaz"/>
      </td>
      <!-- categories count -->
      <td>
        <xsl:value-of
            select="count(p:Discretize/p:DiscretizeBin)+count(p:MapValues/p:InlineTable/p:Extension[@name='Frequency'])"/>
      </td>
      <!-- column reference -->
      <td>
        <xsl:variable name="sourceDataField" select="p:Discretize/@field | p:MapValues/p:FieldColumnPair/@field"/>
        <xsl:apply-templates select="/p:PMML/p:DataDictionary/p:DataField[@name=$sourceDataField]" mode="odkaz"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="p:DerivedField" mode="sect3">
    <xsl:variable name="DerivedFieldName" select="@name"/>
    <xsl:variable name="numOfCategories"
                  select="count(p:Discretize/p:DiscretizeBin)+count(p:MapValues/p:InlineTable/p:Extension[@name='Frequency'])"/>
    <div class="section attribute" id="sect3-{$DerivedFieldName}">
      <h3>
        <xsl:text>Attribute: </xsl:text>
        <xsl:value-of select="@name"/>
      </h3>

      <table class="fieldBasicInfo">
        <tr>
          <th scope="row">
            <xsl:text>Derived from column</xsl:text>
          </th>
          <!-- DataField mode=odkaz is in 4FTPMML2HTML-toc.xsl -->
          <td>
            <xsl:variable name="sourceDataField" select="p:Discretize/@field | p:MapValues/p:FieldColumnPair/@field"/>
            <xsl:apply-templates select="/p:PMML/p:DataDictionary/p:DataField[@name=$sourceDataField]" mode="odkaz"/>
          </td>
        </tr>
        <tr>
          <th scope="row">
            <xsl:text>Attribute type</xsl:text>
          </th>
          <td>
            <xsl:value-of select="@optype"/>
          </td>
        </tr>
        <tr>
          <th scope="row">
            <xsl:text>Number of categories</xsl:text>
          </th>
          <td>
            <xsl:value-of select="$numOfCategories"/>
          </td>
        </tr>
      </table>

      <div class="details">
        <table class="graphTable" id="sect3-graphTable-{$DerivedFieldName}">
          <tr>
            <th scope="col">
              <xsl:text>Category</xsl:text>
            </th>
            <th scope="col">
              <xsl:choose>
                <xsl:when test="p:Discretize">
                  <xsl:text>Interval</xsl:text>
                </xsl:when>
                <xsl:when test="p:MapValues">
                  <xsl:text>Enumeration</xsl:text>
                </xsl:when>
              </xsl:choose>
            </th>
            <th scope="col">
              <xsl:text>Frequency</xsl:text>
            </th>
          </tr>
          <!-- table row depends to attribute is derived (MapValues) or not (Discretize) -->
          <xsl:apply-templates
              select="p:Discretize/p:DiscretizeBin | p:MapValues/p:InlineTable/p:Extension[@name='Frequency']"
              mode="sect3"/>
          <!-- frequency of other values -->
          <xsl:if test="$numOfCategories > $maxCategoriesToList">
            <tr>
              <td colspan="2" class="name others">
                <xsl:text>Other categories</xsl:text>
                (<xsl:value-of select="($numOfCategories - $maxCategoriesToList)"/>)
              </td>
              <td class="frequency">
                <xsl:choose>
                  <xsl:when test="p:MapValues/p:InlineTable">
                    <xsl:value-of
                        select="sum(p:MapValues/p:InlineTable/p:Extension[@name='Frequency'][position() &gt; $maxCategoriesToList]/@value)"/>
                  </xsl:when>
                  <xsl:when test="p:Discretize/p:DiscretizeBin">
                    <xsl:value-of
                        select="sum(p:Discretize/p:DiscretizeBin[position() &gt; $maxCategoriesToList]/p:Extension[@name='Frequency' and @extender=../@binValue]/@value)"/>
                  </xsl:when>
                </xsl:choose>
              </td>
            </tr>
          </xsl:if>
        </table>
        <xsl:if test="$numOfCategories > $maxCategoriesToList">
          <p class="warning">
            <xsl:text>Exceeded </xsl:text>
            maxCategoriesToList = <xsl:value-of select="$maxCategoriesToList"/>,
            <xsl:text> first </xsl:text>
            <xsl:value-of select="$maxCategoriesToList"/>
            <xsl:text> from the total number of </xsl:text>
            <xsl:value-of select="$numOfCategories"/>
            <xsl:text>categories.</xsl:text>
          </p>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <!-- table row for non-derived attribute (interval) -->
  <xsl:template match="p:DiscretizeBin" mode="sect3">
    <xsl:if test="position() &lt;= $maxCategoriesToList">
      <tr>
        <!-- category name -->
        <td class="name">
          <xsl:value-of select="@binValue"/>
        </td>
        <td>
          <xsl:for-each select="p:Interval">
            <xsl:if test="position() &lt; $maxValuesToList or position() = last()">
              <xsl:choose>
                <xsl:when test="position() = last() and position() > $maxValuesToList">
                  ...
                </xsl:when>
                <xsl:when test="position() > 1">;</xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="@leftMargin = @rightMargin">
                  <xsl:value-of select="@leftMargin"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="@closure = 'openClosed' or @closure = 'openOpen'">(</xsl:when>
                    <xsl:otherwise>[</xsl:otherwise>
                  </xsl:choose>
                  <xsl:value-of select="@leftMargin"/>;<xsl:value-of select="@rightMargin"/>
                  <xsl:choose>
                    <xsl:when test="@closure = 'closedClosed' or @closure = 'closedOpen'">)</xsl:when>
                    <xsl:otherwise>]</xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:for-each>
        </td>
        <!-- frequence -->
        <td class="frequency">
          <xsl:value-of select="../p:Extension[@name='Frequency' and @extender=current()/@binValue]/@value"/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <!-- table row for dervited attribute (enumeration) -->
  <xsl:template match="p:Extension[@name='Frequency']" mode="sect3">
    <xsl:if test="position() &lt;= $maxCategoriesToList">
      <xsl:variable name="ext" select="@extender"/>
      <tr>
        <!-- category name -->
        <td class="name">
          <xsl:choose>
            <xsl:when test="$ext = $NullName">
              <em>
                <xsl:value-of select="$ext"/>
              </em>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$ext"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <!-- enumeration -->
        <td>
          <xsl:apply-templates select="../p:row/*[position()=2 and .=$ext]" mode="sect3"/>
        </td>
        <!-- frequence -->
        <td class="frequency">
          <xsl:value-of select="@value"/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <!-- enumeration - comma separated values -->
  <xsl:template match="p:row/*" mode="sect3">
    <xsl:if test="position() &lt; $maxValuesToList or position() = last()">
      <xsl:choose>
        <xsl:when test="position() = last() and position() > $maxValuesToList">
          ...
        </xsl:when>
        <xsl:when test="position() >1">,</xsl:when>
      </xsl:choose>
      <xsl:value-of select="../*[position()=1]"/>
    </xsl:if>
  </xsl:template>
  <!--endregion-->

  <!-- region Data Mining Task Setting -->
  <xsl:template match="guha:AssociationModel | guha:SD4ftModel | guha:Ac4ftModel | guha:CFMinerModel" mode="sect4">
    <div class="section" id="sect4-imValues">
      <!-- Used quantifier table -->
      <!-- table number depends on previous table count -->
      <xsl:variable name="tabs"
                    select="count(/p:PMML/p:DataDictionary/p:DataField)+count(/p:PMML/p:TransformationDictionary/p:DerivedField)"/>

      <h3>
        <xsl:text>Interest Measures used</xsl:text>
      </h3>
      <table>
        <tr>
          <th>
            <xsl:text>Interest Measure</xsl:text>
          </th>
          <th>
            <xsl:text>Minimum value</xsl:text>
          </th>
          <th>Type</th>
          <th>Significance level</th>
          <th>Name</th>
          <th>Compare type</th>
          <th>Source type</th>
        </tr>
        <xsl:apply-templates select="TaskSetting/InterestMeasureSetting/InterestMeasureThreshold" mode="sect4"/>
      </table>
    </div>

    <!-- association rules + detailed list of basic and derived association attributes -->
    <xsl:apply-templates select="TaskSetting" mode="sect4"/>
  </xsl:template>

  <!-- minimumConfidence a minimumSupport is ignored, value from Extension is got -->
  <!-- even if more specific rule is first, priority attribute is needed -->
  <xsl:template match="InterestMeasureThreshold" mode="sect4" priority="1">
    <tr>
      <td class="name">
        <xsl:choose>
          <xsl:when test="Extension[@name='LongName']"><!--TODO-->
            <xsl:value-of select="Extension[@name='LongName']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="InterestMeasure | Formula/@name"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <!-- SignificanceLevel is used for static quantifiers, Threshold is used otherwise -->
      <!-- quantifiers using SignificanceLevel and Threshold together -->
      <td>
        <xsl:value-of select="Threshold"/>
      </td>
      <td>
        <xsl:value-of select="Threshold/@type"/>
      </td>
      <td>
        <xsl:value-of select="SignificanceLevel"/>
      </td>
      <td>
        <xsl:value-of select="SignificanceLevel/@name"/>
      </td>
      <td>
        <xsl:value-of select="CompareType"/>
      </td>
      <td>
        <xsl:value-of select="SourceType"/>
      </td>
    </tr>
  </xsl:template>

  <!-- association rules + detailed list of basic and derived association attributes -->
  <xsl:template match="TaskSetting" mode="sect4">
    <!-- association rules -->
    <div class="section" id="sect4-cedents">
      <h3>
        <xsl:choose>
          <xsl:when test="/p:PMML/guha:SD4ftModel">
            <xsl:text>Sought type of pairs of association rules</xsl:text>
          </xsl:when>
          <xsl:when test="/p:PMML/guha:Ac4ftModel">
            <xsl:text>Sought type of action rules</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Sought type of association rules</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </h3>
      <p>
        <xsl:text>The data mining task found rules in the following form:</xsl:text>
      </p>
      <p id="sect4-rulesPattern">
        <xsl:call-template name="TaskSettingRulePattern">
          <xsl:with-param name="arrowOnly" select="0"/>
        </xsl:call-template>
      </p>

      <p>
        <xsl:text>The basic building blocks of the task setting is the basic Boolean attributes setting...</xsl:text>
      </p>
      <p>
        <xsl:text>Derived Boolean attributes are recursive structures built upon the basic Boolean attributes...</xsl:text>
      </p>

      <!-- basic attributes table -->
      <div class="section cedentsDetails">
        <h4>
          <xsl:text>Detailed list of basic Boolean attributes</xsl:text>
        </h4>
        <table>
          <tr>
            <th class="id">ID</th>
            <th>
              <xsl:text>Name</xsl:text>
            </th>
            <th>
              <xsl:text>Based on attribute</xsl:text>
            </th>
            <th>
              <xsl:text>Coefficient</xsl:text>
            </th>
            <th>
              <xsl:text>Minimal length</xsl:text>
            </th>
            <th>
              <xsl:text>Maximal length</xsl:text>
            </th>
          </tr>
          <!-- table row -->
          <xsl:apply-templates select="BBASettings/BBASetting" mode="sect4"/>
        </table>
      </div>

      <!-- derived attributes table -->
      <div class="section cedentsDetails">
        <h4>
          <xsl:text>Detailed list of derived Boolean attributes</xsl:text>
        </h4>
        <table>
          <tr>
            <th class="id">ID</th>
            <th>
              <xsl:text>Name</xsl:text>
            </th>
            <th>
              <xsl:text>Attribute elements</xsl:text>
            </th>
            <th>
              <xsl:text>Type</xsl:text>
            </th>
            <th>
              <xsl:text>Minimal length</xsl:text>
            </th>
            <th>
              <xsl:text>Maximal length</xsl:text>
            </th>
          </tr>
          <!-- table row -->
          <xsl:apply-templates select="DBASettings/DBASetting" mode="sect4"/>
        </table>
      </div>

    </div>
  </xsl:template>

  <xsl:template name="TaskSettingRulePattern">
    <xsl:param name="arrowOnly"/>
    <xsl:variable name="ante" select="AntecedentSetting"/>
    <xsl:variable name="cons" select="ConsequentSetting | SuccedentSetting"/>
    <xsl:variable name="cond" select="ConditionSetting"/>
    <!-- SD4ft -->
    <xsl:variable name="firstSet" select="FirstSetSetting"/>
    <xsl:variable name="secondSet" select="SecondSetSetting"/>
    <!-- / SD4ft -->
    <!-- Ac4ft -->
    <xsl:variable name="anteVar" select="AntecedentVarSetting"/>
    <xsl:variable name="consVar" select="ConsequentVarSetting"/>
    <!-- / Ac4ft -->

    <!-- Rule format: Antecedent => Consequent [/ Condition]
                or    Antecedent => Consequent : FirstSet x SecondSet [/ Condition]
                or    Antecedent & AntecedentVar => Consequent & ConsequentVar
          - condition is optional
          - each part of rule can be basic (BBASetting)
          or derived attribute (DBASetting),
          - derived attribute can consist of basic or derived attributes...
      -->
    <!-- [Antecedent] -->
    <xsl:apply-templates select="BBASettings/BBASetting[@id=$ante] | DBASettings/DBASetting[@id=$ante]"
                         mode="sect4rule"/>
    <!-- Ac4ft -->
    <xsl:if test="AntecedentVarSetting"> &amp;
      <xsl:apply-templates select="BBASettings/BBASetting[@id=$anteVar] | DBASettings/DBASetting[@id=$anteVar]"
                           mode="sect4rule"/>
    </xsl:if>
    <!-- [Arrow] -->
    <xsl:value-of select="$contentsQuantifier"/>
    <!-- [Consequent] -->
    <xsl:apply-templates select="BBASettings/BBASetting[@id=$cons] | DBASettings/DBASetting[@id=$cons]"
                         mode="sect4rule"/>
    <!-- Ac4ft -->
    <xsl:if test="ConsequentVarSetting"> &amp;
      <xsl:apply-templates select="BBASettings/BBASetting[@id=$consVar] | DBASettings/DBASetting[@id=$consVar]"
                           mode="sect4rule"/>
    </xsl:if>

    <!-- SD4ft -->
    <xsl:if test="FirstSetSetting">:
      <xsl:apply-templates select="BBASettings/BBASetting[@id=$firstSet] | DBASettings/DBASetting[@id=$firstSet]"
                           mode="sect4rule"/>
      x
      <xsl:apply-templates select="BBASettings/BBASetting[@id=$secondSet] | DBASettings/DBASetting[@id=$secondSet]"
                           mode="sect4rule"/>
    </xsl:if>
    <!-- / SD4ft -->

    <!-- [Condition] -->
    <xsl:if test="ConditionSetting">/
      <xsl:apply-templates select="BBASettings/BBASetting[@id=$cond] | DBASettings/DBASetting[@id=$cond]"
                           mode="sect4rule"/>
    </xsl:if>
  </xsl:template>

  <!-- START: rule generation -->
  <!-- rule part - basic attribute -->
  <xsl:template match="BBASetting" mode="sect4rule">
    <xsl:param name="link"/>
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
      <xsl:when test="$link">
        <a href="#sect4-attribute-{$id}" title="{$id}">
          <xsl:value-of select="Name"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span title="{$id}">
          <xsl:value-of select="Name"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- rule part - derived attribute -->
  <xsl:template match="DBASetting" mode="sect4rule">
    <xsl:param name="link"/>
    <xsl:choose>
      <xsl:when test="@type='Literal' and LiteralSign='Both'">
        (
        <xsl:apply-templates select="BASettingRef" mode="sect4rule">
          <xsl:with-param name="link" select="$link"/>
        </xsl:apply-templates>
        <xsl:value-of select="$orOperator"/>
        <!-- V -->
        <xsl:value-of select="$notOperator"/>
        <!-- NOT -->
        <xsl:apply-templates select="BASettingRef" mode="sect4rule">
          <xsl:with-param name="link" select="$link"/>
        </xsl:apply-templates>
        )
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="@type='Literal' and LiteralSign='Negative'">
          <xsl:value-of select="$notOperator"/>
          <!-- NOT -->
        </xsl:if>
        <xsl:apply-templates select="BASettingRef" mode="sect4rule">
          <xsl:with-param name="link" select="$link"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- rule part - derived attribute consist of references to other basic or derived attributes -->
  <xsl:template match="BASettingRef" mode="sect4rule">
    <xsl:param name="link"/>
    <xsl:variable name="ref" select="."/>
    <!-- second and further items of derived attribute are delimited by operator AND or OR -->
    <xsl:if test="position() > 1">
      <xsl:choose>
        <xsl:when test="../@type='Disjunction'">
          <xsl:value-of select="$orOperator"/>
          <!-- V -->
        </xsl:when>
        <xsl:when test="../@type='Conjunction'">
          <xsl:value-of select="$andOperator"/>
          <!-- & -->
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <!--  derived attribute consist of references to other basic or derived attributes - RECURSION -->
    <xsl:apply-templates select="../../../BBASettings/BBASetting[@id=$ref] | ../../DBASetting[@id=$ref]"
                         mode="sect4rule">
      <xsl:with-param name="link" select="$link"/>
    </xsl:apply-templates>
  </xsl:template>
  <!-- END: rule generation -->

  <!-- START: table rows -->
  <!-- basic attribute -->
  <xsl:template match="BBASetting" mode="sect4">
    <tr>
      <xsl:variable name="id" select="@id"/>
      <td class="id">
        <span id="sect4-attribute-{$id}">
          <xsl:value-of select="$id"/>
        </span>
      </td>
      <td>
        <xsl:value-of select="Name"/>
      </td>
      <!-- based on attribut -->
      <td>
        <xsl:value-of select="FieldRef"/>
      </td>
      <td>
        <xsl:value-of select="Coefficient/Type"/>
      </td>
      <td>
        <xsl:value-of select="Coefficient/MinimalLength"/>
      </td>
      <td>
        <xsl:value-of select="Coefficient/MaximalLength"/>
      </td>
    </tr>
  </xsl:template>

  <!-- derived attribut -->
  <xsl:template match="DBASetting" mode="sect4">
    <tr>
      <xsl:variable name="id" select="@id"/>
      <td class="id">
        <xsl:value-of select="$id"/>
      </td>
      <td>
        <xsl:value-of select="Name"/>
      </td>
      <!-- attribute components -->
      <td>
        <xsl:apply-templates select="../../BBASettings/BBASetting[@id=$id] | ../DBASetting[@id=$id]" mode="sect4rule">
          <xsl:with-param name="link" select="1"/>
        </xsl:apply-templates>
      </td>
      <!-- gace(?) -->
      <td>
        <xsl:choose>
          <xsl:when test="@type='Conjunction'">Konjunkce</xsl:when>
          <xsl:when test="@type='Disjunction'">Disjunkce</xsl:when>
          <xsl:when test="@type='Literal' and LiteralSign='Positive'">Positivní literál</xsl:when>
          <xsl:when test="@type='Literal' and LiteralSign='Negative'">Negativní literál</xsl:when>
          <xsl:when test="@type='Literal' and LiteralSign='Both'">Obojaký literál</xsl:when>
        </xsl:choose>
      </td>
      <td>
        <xsl:value-of select="MinimalLength"/>
      </td>
      <td>
        <xsl:value-of select="MaximalLength"/>
      </td>
    </tr>
  </xsl:template>
  <!-- END: table rows -->
  <!--endregion-->

  <!-- region Section 5 - Discovered ARs -->
  <!-- found rule detail -->
  <xsl:template match="AssociationRule | SD4ftRule | Ac4ftRule | CFMinerRule" mode="sect5">
    <!-- rule link is made according to its position (number) -->
    <xsl:variable name="arText">
      <xsl:apply-templates select="." mode="ruleBody"/>
    </xsl:variable>
    <xsl:variable name="rulePos" select="position()"/>

    <xsl:variable name="ruleClass">
      <xsl:choose>
        <xsl:when test="./Extension[@name='mark']/@value='interesting'">selectedRule</xsl:when>
        <xsl:otherwise>otherRule</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div id="sect5-rule{$rulePos}" class="section foundRule {$ruleClass}">
      <h3>
        <xsl:copy-of select="$arText"/>
      </h3>
      <div class="details">
        <!-- table of values of test criteria (quantifiers) -->
        <xsl:if test="local-name() != 'CFMinerRule'">
          <xsl:apply-templates select="." mode="sect5-qtable">
            <xsl:with-param name="rulePos" select="$rulePos"/>
          </xsl:apply-templates>
        </xsl:if>

        <!-- 4FT table for AssociationRule / 4ftMiner -->
        <xsl:if test="local-name()='AssociationRule'">
          <!-- 4FT: four field table -->
          <div class="fourFtTable">
            <h4>
              <xsl:text>Four field contingency table</xsl:text>
            </h4>
            <xsl:call-template name="FourFieldTable">
              <xsl:with-param name="a" select="FourFtTable/@a"/>
              <xsl:with-param name="b" select="FourFtTable/@b"/>
              <xsl:with-param name="c" select="FourFtTable/@c"/>
              <xsl:with-param name="d" select="FourFtTable/@d"/>
              <xsl:with-param name="arText" select="$arText"/>
            </xsl:call-template>
          </div>
        </xsl:if>

        <!-- 4FT table for SD4ftRule / SD4ftMiner -->
        <xsl:if test="local-name()='SD4ftRule'"><!--TODO check...-->
          <!-- 4FT: four field table --> <!-- TODO zabalení do DIV.fourFtTable-->
          <table style="margin: 0 auto;">
            <tbody>
              <tr>
                <td>
                  First set four field quantifier
                  <xsl:apply-templates select="FirstSet" mode="sect5-qtable">
                    <xsl:with-param name="rulePos" select="$rulePos"/>
                  </xsl:apply-templates>
                  First set four field contingency table
                  <xsl:call-template name="FourFieldTable">
                    <xsl:with-param name="a" select="FirstSet/FourFtTable/@a"/>
                    <xsl:with-param name="b" select="FirstSet/FourFtTable/@b"/>
                    <xsl:with-param name="c" select="FirstSet/FourFtTable/@c"/>
                    <xsl:with-param name="d" select="FirstSet/FourFtTable/@d"/>
                    <xsl:with-param name="arText" select="$arText"/>
                  </xsl:call-template>
                </td>
                <td>
                  Second set four field quantifier
                  <xsl:apply-templates select="SecondSet" mode="sect5-qtable">
                    <xsl:with-param name="rulePos" select="$rulePos"/>
                  </xsl:apply-templates>
                  Second set four field contingency table
                  <xsl:call-template name="FourFieldTable">
                    <xsl:with-param name="a" select="SecondSet/FourFtTable/@a"/>
                    <xsl:with-param name="b" select="SecondSet/FourFtTable/@b"/>
                    <xsl:with-param name="c" select="SecondSet/FourFtTable/@c"/>
                    <xsl:with-param name="d" select="SecondSet/FourFtTable/@d"/>
                    <xsl:with-param name="arText" select="$arText"/>
                  </xsl:call-template>
                </td>
              </tr>
            </tbody>
          </table>
        </xsl:if>
        <!-- 4FT table for Ac4ftRule / SD4ftMiner, Ac4ftMiner -->
        <xsl:if test="local-name()='Ac4ftRule'"><!--TODO check...-->
          <!-- 4FT: four field table -->
          <table style="margin: 0 auto;">
            <tbody>
              <tr>
                <td>
                  State before four field quantifier
                  <xsl:apply-templates select="StateBefore" mode="sect5-qtable">
                    <xsl:with-param name="rulePos" select="$rulePos"/>
                  </xsl:apply-templates>
                  State before four field contingency table
                  <xsl:call-template name="FourFieldTable">
                    <xsl:with-param name="a" select="StateBefore/FourFtTable/@a"/>
                    <xsl:with-param name="b" select="StateBefore/FourFtTable/@b"/>
                    <xsl:with-param name="c" select="StateBefore/FourFtTable/@c"/>
                    <xsl:with-param name="d" select="StateBefore/FourFtTable/@d"/>
                    <xsl:with-param name="arText" select="$arText"/>
                  </xsl:call-template>
                </td>
                <td>
                  State after four field quantifier
                  <xsl:apply-templates select="StateAfter" mode="sect5-qtable">
                    <xsl:with-param name="rulePos" select="$rulePos"/>
                  </xsl:apply-templates>
                  State after four field contingency table
                  <xsl:call-template name="FourFieldTable">
                    <xsl:with-param name="a" select="StateAfter/FourFtTable/@a"/>
                    <xsl:with-param name="b" select="StateAfter/FourFtTable/@b"/>
                    <xsl:with-param name="c" select="StateAfter/FourFtTable/@c"/>
                    <xsl:with-param name="d" select="StateAfter/FourFtTable/@d"/>
                    <xsl:with-param name="arText" select="$arText"/>
                  </xsl:call-template>
                </td>
              </tr>
            </tbody>
          </table>
        </xsl:if>
        <!-- attributes table and graph for CFMiner -->
        <xsl:if test="local-name()='CFMinerRule'"><!--TODO check...-->
          <!-- attributes table -->
          <table class="itable" id="sect5-rule{$rulePos}-freqtab">
            <tr>
              <th>Kategorie</th>
              <th>Frekvence</th>
            </tr>
            <xsl:apply-templates select="Frequencies/Frequency"/>
          </table>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <!-- quantifier table -->
  <xsl:template
      match="AssociationRule | SD4ftRule | Ac4ftRule | CFMinerRule | FirstSet | SecondSet | StateBefore | StateAfter"
      mode="sect5-qtable">
    <xsl:param name="rulePos"/>
    <xsl:variable name="sect">
      <xsl:if test="local-name()='FirstSet'">fs-</xsl:if>
      <xsl:if test="local-name()='SecondSet'">ss-</xsl:if>
      <xsl:if test="local-name()='StateBefore'">sb-</xsl:if>
      <xsl:if test="local-name()='StateAfter'">sa-</xsl:if>
    </xsl:variable>
    <xsl:variable name="tableColspan">
      <xsl:choose>
        <xsl:when test="IMValue[@sourceMode]">3</xsl:when>
        <xsl:otherwise>2</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div class="imValues">
      <h4>
        <xsl:text>Interest measure values</xsl:text>
      </h4>
      <table class="imValuesTable">
        <tr>
          <th>
            <xsl:text>Interest Measure</xsl:text>
          </th>
          <th>
            <xsl:text>Value</xsl:text>
          </th>
          <xsl:if test="IMValue[@sourceMode]">
            <th>Source mode</th>
          </xsl:if>
        </tr>

        <!-- previously BASE was Support and FUI was Confidence -->
        <xsl:if test="IMValue[@name='BASE']!=-1 or IMValue[@name='FUI']!=-1">
          <!-- if BASE == -1 then don't include to report; BASE == -1 occurs in Ferda only, LM has always valid value? -->
          <xsl:if test="IMValue[@name='BASE']!=-1">
            <tr>
              <td class="name">
                <xsl:text>BASE</xsl:text>
              </td>
              <td class="value">
                <xsl:value-of select="format-number(IMValue[@name='BASE'],'0.0000')"/>
              </td>
            </tr>
          </xsl:if>
          <!-- if FUI == -1 then don't include to report -->
          <xsl:if test="IMValue[@name='FUI']!=-1">
            <tr>
              <td class="name">
                <xsl:text>FUI</xsl:text>
              </td>
              <td class="value">
                <xsl:value-of select="format-number(IMValue[@name='FUI'],'0.0000')"/>
              </td>
            </tr>
          </xsl:if>
        </xsl:if>
        <!-- AssociationRule or SD4ftRule or Ac4ftRule table rows -->
        <xsl:if test="local-name()='AssociationRule' or local-name()='SD4ftRule' or local-name()='Ac4ftRule'">
          <!-- other quantifiers from task setting -->
          <xsl:apply-templates select="IMValue[not(@name='BASE') and not(@name='FUI') and @imSettingRef]" mode="sect5"/>
          <!--<tbody class="dim hidden" id="sect5-rule{$rulePos}-non-task">
            <!- - other quantifiers not from task setting - ->
            <xsl:apply-templates select="IMValue[not(@name='BASE') and not(@name='FUI') and not(@imSettingRef)]" mode="sect5"/>
          </tbody>-->
        </xsl:if>
        <!-- SD4ftRule/FirstSet or SD4ftRule/SecondSet, Ac4ftRule/StateBefore or Ac4ftRule/StateAfter table rows
        <xsl:if test="local-name()='FirstSet' or local-name()='SecondSet' or local-name()='StateBefore' or local-name()='StateAfter'">
          <tbody class="dim hidden" id="sect5-{$sect}rule{$rulePos}-non-task">
            <!- - other quantifiers from task setting - ->
            <xsl:apply-templates select="IMValue[not(@name='BASE') and not(@name='FUI')]" mode="sect5"/>
          </tbody>
        </xsl:if>-->
      </table>
    </div>
  </xsl:template>

  <!-- fourfield table -->
  <xsl:template name="FourFieldTable">
    <!-- a-d = extender values -->
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:param name="c"/>
    <xsl:param name="d"/>
    <xsl:param name="arText"/>

    <table class="fourFtTable">
      <tr>
        <th class="empty"></th>
        <th>
          <xsl:text>Consequent</xsl:text>
        </th>
        <th>
          <xsl:value-of select="$notOperator"/>
          <!-- NOT -->
          <xsl:text>Consequent</xsl:text>
        </th>
      </tr>
      <tr>
        <th>
          <xsl:text>Antecedent</xsl:text>
        </th>
        <td class="a">
          <xsl:value-of select="$a"/>
        </td>
        <td class="b">
          <xsl:value-of select="$b"/>
        </td>
      </tr>
      <tr>
        <th>
          <xsl:value-of select="$notOperator"/>
          <!-- NOT -->
          <xsl:text>Antecedent</xsl:text>
        </th>
        <td class="c">
          <xsl:value-of select="$c"/>
        </td>
        <td class="d">
          <xsl:value-of select="$d"/>
        </td>
      </tr>
    </table>
  </xsl:template>

  <!-- cfminer frequencies table -->
  <xsl:template match="Frequency">
    <tr>
      <td>
        <xsl:value-of select="@category"/>
      </td>
      <td>
        <xsl:value-of select="@value"/>
      </td>
    </tr>
  </xsl:template>

  <!--
  RULE BODY
  -->
  <xsl:template match="AssociationRule" mode="ruleBody">
    <xsl:choose>
      <xsl:when test="@antecedent">
        <xsl:apply-templates select="../DBA[@id=current()/@antecedent] | ../DBA[@id=current()/@antecedent]">
          <xsl:with-param name="topLevel" select="1"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>*</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$implyOperator"/>
    <xsl:apply-templates select="../DBA[@id=current()/@consequent] | ../DBA[@id=current()/@consequent]">
      <xsl:with-param name="topLevel" select="'1'"/>
    </xsl:apply-templates>
    <xsl:if test="@condition">
      <xsl:text> / </xsl:text>
      <xsl:apply-templates select="../DBA[@id=current()/@condition] | ../DBA[@id=current()/@condition]">
        <xsl:with-param name="topLevel" select="'1'"/>
      </xsl:apply-templates>
    </xsl:if>
    <!--<xsl:value-of select="./Text" />-->
  </xsl:template>

  <!-- CFMinerRule with format Attribute / Condition is bellow ... -->
  <!--<xsl:template match="AssociationRule | SD4ftRule | Ac4ftRule" mode="ruleBody">-->
  <xsl:template match="SD4ftRule | Ac4ftRule" mode="ruleBody">
    <xsl:param name="arrowOnly"/>
    <xsl:variable name="ante" select="@antecedent"/>
    <xsl:variable name="cons" select="@consequent | @succedent"/>
    <xsl:variable name="cond" select="@condition"/>
    <!-- Rule has format: Antecedent => Consequent [/Condition]
      - condition is optional
    -->
    <xsl:choose>
      <xsl:when test="(count(../DBA[@id=$ante]/BARef) + count(../BBA[@id=$ante])) > 0">
        <xsl:call-template name="cedent">
          <xsl:with-param name="cedentID" select="$ante"/>
        </xsl:call-template>
      </xsl:when>
      <!-- antecedent for StateBefore/StateAfter of Ac4ftRule -->
      <xsl:when test="StateBefore/@antecedentVarBefore and StateAfter/@antecedentVarAfter">
        [
        <xsl:call-template name="cedent">
          <xsl:with-param name="cedentID" select="StateBefore/@antecedentVarBefore"/>
        </xsl:call-template>
        -&gt;
        <xsl:call-template name="cedent">
          <xsl:with-param name="cedentID" select="StateAfter/@antecedentVarAfter"/>
        </xsl:call-template>
        ]
      </xsl:when>
      <!-- antecedent exists, but doesn't refer any other items -->
      <xsl:otherwise>
        [[<xsl:text>No restriction</xsl:text>]]
      </xsl:otherwise>
    </xsl:choose>
    <!-- arrow symbol: from quantifier_transformations.xsl -->
    <xsl:value-of select="$contentsQuantifier"/>
    <!-- consequent -->
    <xsl:call-template name="cedent">
      <xsl:with-param name="cedentID" select="$cons"/>
    </xsl:call-template>
    <!-- first set (SD4ftRule) -->
    <xsl:if test="FirstSet">
      :
      <xsl:call-template name="cedent">
        <xsl:with-param name="cedentID" select="FirstSet/@set | FirstSet/@FirstSet"/>
      </xsl:call-template>
    </xsl:if>
    <!-- second set (SD4ftRule) -->
    <xsl:if test="SecondSet">
      x
      <xsl:call-template name="cedent">
        <xsl:with-param name="cedentID" select="SecondSet/@set | SecondSet/@SecondSet"/>
      </xsl:call-template>
    </xsl:if>
    <!-- antecedent for StateBefore/StateAfter of Ac4ftRule -->
    <xsl:if test="StateBefore/@consequentVarBefore and StateAfter/@consequentVarAfter">
      [
      <xsl:call-template name="cedent">
        <xsl:with-param name="cedentID" select="StateBefore/@consequentVarBefore"/>
      </xsl:call-template>
      -&gt;
      <xsl:call-template name="cedent">
        <xsl:with-param name="cedentID" select="StateAfter/@consequentVarAfter"/>
      </xsl:call-template>
      ]
    </xsl:if>
    <!-- condition -->
    <xsl:if test="../BBA[@id=$cond] | ../DBA[@id=$cond]">/
      <xsl:call-template name="cedent">
        <xsl:with-param name="cedentID" select="$cond"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="CFMinerRule" mode="ruleBody">
    <xsl:param name="arrowOnly"/>
    <xsl:variable name="cond" select="@condition"/>
    <!-- Rule has format: Attribute [/Condition]
      - condition is optional ?
    -->
    <xsl:value-of select="@attribute"/>
    <!-- condition -->
    <xsl:if test="../BBA[@id=$cond] | ../DBA[@id=$cond]">/
      <xsl:call-template name="cedent">
        <xsl:with-param name="cedentID" select="$cond"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="IMValue" mode="sect5" priority="1">
    <tr>
      <!-- quantifier name -->
      <td class="name">
        <xsl:value-of select="@name"/>
      </td>
      <!-- quantifier value -->
      <td class="value">
        <xsl:value-of select="format-number(text(),'0.0000')"/>
      </td>
      <xsl:if test="@sourceMode">
        <td>
          <xsl:value-of select="@sourceMode"/>
        </td>
      </xsl:if>
    </tr>
  </xsl:template>

  <xsl:template name="cedent">
    <xsl:param name="cedentID"/>
    <span title="{$cedentID}">
      <xsl:choose>
        <!-- LISp-Miner has a text representation of the whole cedent in the text extension -->
        <xsl:when test="/p:PMML/p:Header/p:Application/@name='LISp-Miner'">
          <xsl:value-of select="../DBA[@id=$cedentID]/Text"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- While Ferda has not, so the textual representation needs to be reconstructed -->
          <!-- beware - this would not work with LISp-Miner very well -->
          <xsl:apply-templates select="../BBA[@id=$cedentID] | ../DBA[@id=$cedentID]">
            <xsl:with-param name="topLevel" select="'1'"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template match="BBA">
    <xsl:param name="topLevel"/>
    <xsl:choose>
      <!--If there is no Text node, we have to prepare it from references-->
      <xsl:when test="./Text">
        <xsl:value-of select="Text"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="bbaText"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="BBA" mode="bbaText">
    <xsl:value-of select="./FieldRef/text()"/>(<xsl:apply-templates select="./CatRef" mode="bbaText"/>)
  </xsl:template>

  <xsl:template match="CatRef" mode="bbaText">
    <xsl:if test="position()>1">, </xsl:if>
    <xsl:value-of select="text()"/>
  </xsl:template>

  <xsl:template match="DBA">
    <xsl:param name="topLevel"/>
    <!-- item can be preceded by NOT operator -->
    <xsl:choose>
      <!--TODO
      <xsl:when test="@connective='Negation'">
        <xsl:value-of select="$notOperator"/>x
        <xsl:apply-templates select="BARef"/>
      </xsl:when>-->
      <xsl:when test="count(BARef)=1">
        <xsl:apply-templates select="BARef">
          <xsl:with-param name="topLevel" select="$topLevel"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$topLevel='1'">
        <xsl:apply-templates select="BARef"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$topLevel"/>
        (<xsl:apply-templates select="BARef"/>)
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="BARef">
    <xsl:param name="topLevel"/>
    <xsl:variable name="ref" select="text()"/>
    <!-- items are delimited by concective AND or OR -->
    <xsl:if test="position() > 1">
      <xsl:choose>
        <xsl:when test="../p:Extension[@name='Connective' and @value='Disjunction']">
          <xsl:value-of select="$orOperator"/>
          <!-- V -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$andOperator"/>
          <!-- & -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <!-- item refers (by ref) to other BBA or DBA - RECURSION -->
    <xsl:apply-templates select="../../BBA[@id=$ref] | ../../DBA[@id=$ref]">
      <xsl:with-param name="topLevel" select="$topLevel"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="p:DataField" mode="sect5">
    <xsl:if test="position()>1">,</xsl:if>
    <a href="#sect2-{@name}">
      <xsl:value-of select="@name"/>
    </a>
  </xsl:template>

  <xsl:template match="p:DerivedField" mode="sect5">
    <xsl:if test="position()>1">,</xsl:if>
    <xsl:variable name="DerivedFieldName" select="@name"/>
    <a href="#sect3-{$DerivedFieldName}">
      <xsl:value-of select="$DerivedFieldName"/>
    </a>
  </xsl:template>
  <!--endregion-->


</xsl:stylesheet>