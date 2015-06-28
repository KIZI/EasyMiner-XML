<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:p="http://www.dmg.org/PMML-4_0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
                exclude-result-prefixes="p xsi guha">

  <xsl:import href="quantifier_transformations.xsl"/>

  <!-- Parametr maxValuesToList omezuje pocet kategorii (hodnot sloupce), ktere mohou byt v 2. oddilu vypsany. Pokud pocet kategorii prekroci hodnotu parametru je vypsano varovani. -->
  <xsl:param name="maxValuesToList" select="100"/>
  <!-- Maximalni pocet vypisovanych kategorii do tabulek popisujicich transformace vstupnich sloupcu na atributy -->
  <xsl:param name="maxCategoriesToList" select="100"/>
  <!-- Parametr maxRulesToList omezuje pocet pravidel, ktere mohou byt v vypsany. Pokud pocet pravidel prekroci hodnotu parametru je vypsano varovani. -->
  <xsl:param name="maxRulesToList" select="1000"/>
  <!-- maximal number of items to show in graph -->
  <xsl:param name="maxCategoriesToListInGraphs" select="100"/>

  <xsl:output method="html" encoding="UTF-8"/>
  <!-- Parametr contentOnly slouzi k potlaceni generovani hlavicky HTML a elementu html, head a body. V pripade, ze je atribut nastaven, vygeneruje se jen obsah elementu body pro pouziti ve slozitejsich dokumentech. Pravidla jsou vypisovana na zaklade jejich poradi v PMML souboru. -->
  <xsl:param name="contentOnly" select="false()"/>
  <!--<xsl:param name="basePath" select="'.'"/>-->
  <xsl:param name="basePath" select="'./guhaPMML2HTML'"/>
  <xsl:param name="loadJquery" select="true()"/>
  <!-- Parametry pro nastaveni znaku nebo retezce znaku reprezentujiciho logicke operatory -->
  <xsl:param name="NullName" select="'Null'"/>
  <xsl:param name="notOperator" select="' &#x00AC;'"/>
  <xsl:param name="andOperator" select="' &amp; '"/>
  <xsl:param name="orOperator" select="' &#x02228; '"/>
  <xsl:param name="implyOperator" select="' &#8594; '"/>
  <xsl:param name="notAvailable" select="'NA'"/>
  <xsl:param name="reportLang" select="'cs'"/>
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
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html>
          <head>
            <xsl:call-template name="resources"/>
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
    <a href="#sect3-{p:Discretize/@field | p:MapValues/@outputColumn}">
      <xsl:value-of select="p:Discretize/@field | p:MapValues/@outputColumn"/>
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
          <xsl:text>Exceeded</xsl:text>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:text>first</xsl:text>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:text>from the total number of</xsl:text>
          <xsl:value-of select="count(AssociationRule)"/>
          <xsl:text>rules</xsl:text>
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
          <xsl:text>Exceeded</xsl:text>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:text>first</xsl:text>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:text>from the total number of</xsl:text>
          <xsl:value-of select="count(SD4ftRule)"/>
          <xsl:text>rules</xsl:text>
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
          <xsl:text>Exceeded</xsl:text>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:text>first</xsl:text>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:text>from the total number of</xsl:text>
          <xsl:value-of select="count(Ac4ftRule)"/>
          <xsl:text>rules</xsl:text>.
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
          <xsl:text>Exceeded</xsl:text>
          maxRulesToList = <xsl:value-of select="$maxRulesToList"/>;
          <xsl:text>first</xsl:text>
          <xsl:value-of select="$maxRulesToList"/>
          <xsl:text>from the total number of</xsl:text>
          <xsl:value-of select="count(CFMinerRule)"/>
          <xsl:text>rules</xsl:text>
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
    <style>
      @import url('<xsl:value-of select="$basePath"/>/css/main.css');
      <xsl:if test="not($contentOnly)">
        @import url('<xsl:value-of select="$basePath"/>/css/page.css');
      </xsl:if>
    </style>
    <xsl:if test="$loadJquery">
      <script type="text/javascript" src="{$basePath}/js/jquery-1.11.3.min.js"></script>
    </xsl:if>
    <xsl:if test="not($contentOnly)">
      <script type="text/javascript" src="{$basePath}/js/page.js"></script>
    </xsl:if>
    <script type="text/javascript" src="{$basePath}/js/main.js"></script>
    <script type="text/javascript" src="{$basePath}/js/chart.js/Chart.js"></script>
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
      <section id="meta">
        <xsl:apply-templates select="p:Header"/>
      </section>

      <p>
        <xsl:text>This document contains automatically generated report on a data mining task.</xsl:text>
      </p>
    </header>

    <!-- =================
         Table of contents
         ================= -->
    <!-- uses: 4FTPMML2HTML-toc -->
    <section id="navigation">
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
    </section>
    <!-- ==============================
         Section 1+2 - Data description
         ============================== -->
    <section id="sect2">

      <h2>
        <xsl:text>Dataset Description</xsl:text>
      </h2>
      <p>
        <xsl:text>This section contains detailed description of the data.  Below, all the columns used in the analysis are listed and for each column, the frequency analysis is attached.</xsl:text>
      </p>

      <section class="list">
        <h3>
          <xsl:text>List of data fields</xsl:text>
        </h3>
        <xsl:apply-templates select="p:DataDictionary" mode="sect2list"/>
      </section>

      <xsl:apply-templates select="p:DataDictionary" mode="sect2"/>
    </section>

    <!-- ==============================
         Section 3 - Created Attributes
         ============================== -->
    <section id="sect3">
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


      <p class="attributesCount"><xsl:text>Number of created attributes:</xsl:text>
        <strong>
          <xsl:value-of select="count(p:TransformationDictionary/p:DerivedField)"/>
        </strong>
      </p>

      <section class="list">
        <h3>
          <xsl:text>List of data fields</xsl:text>
        </h3>
        <xsl:apply-templates select="p:TransformationDictionary" mode="sect3list"/>
      </section>

      <xsl:apply-templates select="p:TransformationDictionary" mode="sect3"/>
    </section>
    <!-- =========================
         Section 4 - Task settings
         ========================= -->
    <section id="sect4">

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
    </section>
    <!-- ==========================
         Section 5 - Discovered ARs
         ========================== -->
    <section id="sect5">

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
      <p><xsl:text>Discovered rules relate to the following attributes:</xsl:text>
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
    </section>

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
    <section id="sect2-{@name}" class="dataField">

      <h3><xsl:text>Column</xsl:text>
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
            <xsl:text>Exceeded</xsl:text>
            maxValuesToList = <xsl:value-of select="$maxValuesToList"/>,
            <xsl:text>first</xsl:text>
            <xsl:value-of select="$maxValuesToList"/>
            <xsl:text>from the total number of</xsl:text>
            <xsl:value-of select="count(p:Value)"/>
            <xsl:text>rules.</xsl:text>
          </p>
        </xsl:if>


      </div>
    </section>
  </xsl:template>

  <xsl:template match="p:Interval" mode="sect2">
    <xsl:choose>
      <xsl:when test="@closure='closedOpen' or @closure='closedClosed'">&lt;</xsl:when>
      <xsl:otherwise>(</xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="@leftMargin"/>;<xsl:value-of select="@rightMargin"/>
    <xsl:choose>
      <xsl:when test="@closure='closedClosed' or @closure='openClosed'">&gt;</xsl:when>
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
        <xsl:variable name="sourceDataField" select="p:Discretize/@field | p:MapValues/p:FieldColumnPair/@column"/>
        <xsl:apply-templates select="/p:PMML/p:DataDictionary/p:DataField[@name=$sourceDataField]" mode="odkaz"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="p:DerivedField" mode="sect3">
    <xsl:variable name="DerivedFieldName" select="p:Discretize/@field | p:MapValues/@outputColumn"/>
    <xsl:variable name="numOfCategories"
                  select="count(p:Discretize/p:DiscretizeBin)+count(p:MapValues/p:InlineTable/p:Extension[@name='Frequency'])"/>
    <section id="sect3-{$DerivedFieldName}" class="attribute">
      <h3><xsl:text>Attribute:</xsl:text>
        <xsl:value-of select="p:Discretize/@field | p:MapValues/@outputColumn"/>
      </h3>

      <table class="fieldBasicInfo">
        <tr>
          <th scope="row">
            <xsl:text>Derived from column</xsl:text>
          </th>
          <!-- DataField mode=odkaz is in 4FTPMML2HTML-toc.xsl -->
          <td>
            <xsl:variable name="sourceDataField" select="p:Discretize/@field | p:MapValues/p:FieldColumnPair/@column"/>
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
            <xsl:text>Exceeded</xsl:text>
            maxCategoriesToList = <xsl:value-of select="$maxCategoriesToList"/>,
            <xsl:text>first</xsl:text>
            <xsl:value-of select="$maxCategoriesToList"/>
            <xsl:text>from the total number of</xsl:text>
            <xsl:value-of select="$numOfCategories"/>
            <xsl:text>categories.</xsl:text>
          </p>
        </xsl:if>
      </div>
    </section>
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
                    <xsl:otherwise>&lt;</xsl:otherwise>
                  </xsl:choose>
                  <xsl:value-of select="@leftMargin"/>;<xsl:value-of select="@rightMargin"/>
                  <xsl:choose>
                    <xsl:when test="@closure = 'closedClosed' or @closure = 'closedOpen'">)</xsl:when>
                    <xsl:otherwise>&gt;</xsl:otherwise>
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
    <section id="sect4-imValues">
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
      <p class="legend">
        <xsl:text>Note: GUHA quantifiers Founded Implication and Base are listed as confidence and support</xsl:text>
      </p>
    </section>

    <!-- association rules + detailed list of basic and derived association attributes -->
    <xsl:apply-templates select="TaskSetting" mode="sect4"/>
  </xsl:template>

  <!-- minimumConfidence a minimumSupport is ignored, value from Extension is got -->
  <!-- even if more specific rule is first, priority attribute is needed -->
  <xsl:template match="InterestMeasureThreshold" mode="sect4" priority="1">
    <tr>
      <td class="name">
        <xsl:copy-of
            select="keg:translateInterestMeasure(InterestMeasure | Formula/@name,'InterestMeasure', 'pmml', $reportLang)"/>
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
    <section id="sect4-cedents">
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
      <section class="cedentsDetails">
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
      </section>

      <!-- derived attributes table -->
      <section class="cedentsDetails">
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
      </section>

    </section>
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
    <xsl:copy-of select="$contentsQuantifier"/>
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

    <xsl:variable name="ruleClass"><!--TODO Standa třída pro označování zajímavých pravidel-->
      <xsl:choose>
        <xsl:when test="./Extension[@name='mark']/@value='interesting'">selectedRule</xsl:when>
        <xsl:otherwise>otherRule</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <section id="sect5-rule{$rulePos}" class="foundRule {$ruleClass}">
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
    </section>
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
                <xsl:copy-of select="keg:translateInterestMeasure('BASE','TestCriterion', 'pmml', $reportLang)"/>
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
                <xsl:copy-of select="keg:translateInterestMeasure('FUI','TestCriterion', 'pmml', $reportLang)"/>
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
    <xsl:copy-of select="$contentsQuantifier"/>
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
        <xsl:copy-of select="keg:translateInterestMeasure(@name,'TestCriterion', 'pmml', $reportLang)"/>
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
    <xsl:if test="position()>1">,</xsl:if>
    <xsl:value-of select="text()"/>
  </xsl:template>

  <xsl:template match="DBA">
    <xsl:param name="topLevel"/>
    <!-- item can be preceded by NOT operator -->
    <xsl:choose>
      <xsl:when test="@connective='Negation'">
        <xsl:value-of select="$notOperator"/>
        <xsl:apply-templates select="BARef"/>
      </xsl:when>
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
    <xsl:variable name="DerivedFieldName" select="p:Discretize/@field | p:MapValues/@outputColumn"/>
    <a href="#sect3-{$DerivedFieldName}">
      <xsl:value-of select="$DerivedFieldName"/>
    </a>
  </xsl:template>
  <!--endregion-->


</xsl:stylesheet>