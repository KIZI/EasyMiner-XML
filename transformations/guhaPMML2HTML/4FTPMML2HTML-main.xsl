<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:p="http://www.dmg.org/PMML-4_0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz" xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
  xmlns:date="http://exslt.org/dates-and-times"
  extension-element-prefixes="func exsl date"
  exclude-result-prefixes="p xsi keg guha">

  <xsl:template match="/p:PMML" mode="body">
  <!-- TODO -->  
    <style>@import url('index.css');</style>
    <script type="text/javascript" src="jquery-1.11.3.min.js"></script>
    <script type="text/javascript" src="main.js"></script>
    <script type="text/javascript" src="Chart.js-2.0-alpha/Chart.js-2.0-alpha/Chart.js"></script>
  <!-- ===============
       Document header
       =============== -->
       <!-- uses: 4FTPMML2HTML-header -->
    <h1><xsl:copy-of select="keg:translate('Description of Data Mining Task', 10)"/><!-- „<xsl:value-of select="/p:PMML/guha:AssociationModel/@modelName | /p:PMML/guha:SD4ftModel/@modelName | /p:PMML/guha:Ac4ftModel/@modelName | /p:PMML/guha:CFMinerModel/@modelName"/>“--></h1>
    <p>
      <xsl:choose>
        <xsl:when test="/p:PMML/guha:SD4ftModel">
          <xsl:copy-of select="keg:translate('This document contains automatically generated report on a data mining task.',930)"/>
        </xsl:when>
        <xsl:when test="/p:PMML/guha:Ac4ftModel">
          <xsl:copy-of select="keg:translate('This document contains automatically generated report on a data mining task.',850)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="keg:translate('This document contains automatically generated report on a data mining task.',20)"/>
        </xsl:otherwise>
      </xsl:choose>
    </p>
    <p><xsl:copy-of select="keg:translate('The report contains firstly describes the data, then provides information about the created attributes, that is how the data was discretized. Afterwards the document provides the task setting and finally the patterns (association rules) found.',640)"/></p>
    <!-- task metadata -->
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('TaskMetadata','','start')"/></xsl:comment>
    <div id="sectMeta">
      <xsl:apply-templates select="p:Header"/>
    </div>

    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('TaskMetadata','','end')"/></xsl:comment>
  <!-- =================
       Table of contents
       ================= -->
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('ListOfContents','','start')"/></xsl:comment>
    <!-- uses: 4FTPMML2HTML-toc -->
    <div id="sectTOC">
    <h2><xsl:copy-of select="keg:translate('Content',11)"/></h2>
    <ol type="I">
      <li><a href="#sect1"><xsl:copy-of select="keg:translate('Dataset Description',30)"/></a>
        <xsl:apply-templates select="p:DataDictionary" mode="toc">
          <xsl:with-param name="checkbox" select="0"/>
        </xsl:apply-templates>
      </li>
      <li><a href="#sect3"><xsl:copy-of select="keg:translate('Created Attributes',40)"/></a>
        <xsl:apply-templates select="p:TransformationDictionary" mode="toc"/></li>
      <li><a href="#sect4"><xsl:copy-of select="keg:translate('Data Mining Task Setting',50)"/></a>
        <div class="dim"><xsl:apply-templates select="guha:AssociationModel/TaskSetting" mode="toc"/></div>
      </li>
      <li>
        <a href="#sect5">
          <xsl:choose>
            <xsl:when test="/p:PMML/guha:SD4ftModel">
              <xsl:copy-of select="keg:translate('Discovered Action Rules',910)"/>
            </xsl:when>
            <xsl:when test="/p:PMML/guha:Ac4ftModel">
              <xsl:copy-of select="keg:translate('Discovered pairs of Association Rules',990)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="keg:translate('Discovered Association Rules',60)"/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
        <xsl:apply-templates select="guha:AssociationModel | guha:SD4ftModel | guha:Ac4ftModel | guha:CFMinerModel" mode="toc"/>
      </li>
    </ol>
    </div>

    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('ListOfContents','','end')"/></xsl:comment>
  <!-- ==============================
       Section 1+2 - Data description
       ============================== -->
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DataDescription','','start')"/></xsl:comment>

    <div id="sect1">
      <h2><xsl:copy-of select="keg:translate('Dataset Description',30)"/></h2>
      <p><xsl:copy-of select="keg:translate('This section contains detailed description of the data.  Below, all the columns used in the analysis are listed and for each column, the frequency analysis is attached. ',650)"/></p>
      <xsl:apply-templates select="p:DataDictionary" mode="sect1" />

      <div id="sect2">
        <h2><xsl:copy-of select="keg:translate('Frequency analysis - columns',70)"/></h2>
        <xsl:apply-templates select="p:DataDictionary" mode="sect2" />
      </div>
    </div>

    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DataDescription','','end')"/></xsl:comment>
  <!-- ==============================
       Section 3 - Created Attributes
       ============================== -->
    <section id="sect3">
      <!--TODO úprava úvodního textu -->
      <h2><xsl:copy-of select="keg:translate('Created Attributes',40)"/></h2>
      <p>
        <xsl:copy-of select="keg:translate('Attribute (in the sense of this analysis) is a mapping of a domain to finite set...',80)"/>
      </p>
      <p>
        <xsl:copy-of select="keg:translate('This part of the analytical report lists all the created attributes and their characteristics:',660)"/>
      </p>
      <ul>
        <li>
          <xsl:copy-of select="keg:translate('Column from which the attribute was derived',670)"/>
        </li>
        <li>
          <xsl:copy-of select="keg:translate('Attribute type (categorical, ordinal, continuous)',680)"/>
        </li>
        <li>
          <xsl:copy-of select="keg:translate('Frequency analysis – histogram of the intervals or enumerations of the attribute. The histograms are ordered by the highest frequent values. If the attribute contains more categories than ',690)"/>
          45<xsl:copy-of select="keg:translate(', the remaining categories are grouped into the “Other” column in the histogram.',700)"/>
        </li>
      </ul>

      <xsl:comment><xsl:value-of select="keg:getContentBlockTag('CreatedAttributes','','start')"/></xsl:comment>

      <xsl:comment><xsl:value-of select="keg:getContentBlockTag('CreatedAttributes_Contents','','start')"/></xsl:comment>

      <h3><xsl:copy-of select="keg:translate('List of created attributes',90)"/></h3>
      <xsl:apply-templates select="p:TransformationDictionary" mode="toc"/>

      <xsl:comment><xsl:value-of select="keg:getContentBlockTag('CreatedAttributes_Contents','','end')"/></xsl:comment>

      <p><xsl:copy-of select="keg:translate('Number of created attributes',100)"/>: <strong><xsl:value-of select="count(p:TransformationDictionary/p:DerivedField)"/></strong></p>
      <xsl:apply-templates select="p:TransformationDictionary" mode="sect3"/>

      <xsl:comment><xsl:value-of select="keg:getContentBlockTag('CreatedAttributes','','end')"/></xsl:comment>
    </section>
  <!-- =========================
       Section 4 - Task settings
       ========================= -->
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DMTaskSetting','','start')"/></xsl:comment>

    <div id="sect4">
      <h2><xsl:copy-of select="keg:translate('Data Mining Task Setting',50)"/></h2>
      <xsl:choose>
          <!-- SD4ftModel -->
          <xsl:when test="/p:PMML/guha:SD4ftModel">
            <p><xsl:copy-of select="keg:translate('This part of the analytical report describes the SD4ft procedure setting. The setting consists of ',1010)"/></p>
            <ul>
              <li>
                <xsl:copy-of select="keg:translate('Set of quantifiers as interest measures for the output pairs of association rules',940)"/>
              </li>
              <li>
                <xsl:copy-of select="keg:translate('Set of Derived Boolean attribute settings for the definition of the first set',950)"/>
              </li>
              <li>
                <xsl:copy-of select="keg:translate('Set of Derived Boolean attribute settings for the definition of the second set',960)"/>
              </li>
            </ul>
            <p>
              <xsl:copy-of select="keg:translate('Below, all the interest measures for the output pairs of association rules are stated. The table contains name of the quantifier (interest measure) and also  minimal values of the quantifier threshold(s).',970)"/>
            </p>
          </xsl:when>
          <!-- Ac4ftModel -->
          <xsl:when test="/p:PMML/guha:Ac4ftModel">
            <p><xsl:copy-of select="keg:translate('This part of the analytical report describes the SD4ft procedure setting. The setting consists of ',1020)"/></p>
            <ul>
              <li>
                <xsl:copy-of select="keg:translate('Set of quantifiers as interest measures for the output action rules',860)"/>
              </li>
              <li>
                <xsl:copy-of select="keg:translate('Set of Derived Boolean attribute settings for the antecedent stable part and antecedent variable part',870)"/>
              </li>
              <li>
                <xsl:copy-of select="keg:translate('Set of Derived Boolean attribute settings for the consequent stable part and consequent variable part',880)"/>
              </li>
            </ul>
            <p>
              <xsl:copy-of select="keg:translate('Below, all the interest measures for the output action rules are stated. The table contains name of the quantifier (interest measure) and also minimal values of the quantifier threshold(s).',890)"/>
            </p>
          </xsl:when>
          <!-- AssociationModel -->
          <xsl:otherwise>
            <p><xsl:copy-of select="keg:translate('This part of the analytical report describes the ASSOC procedure setting. The setting consists of ',710)"/></p>
            <ul>
              <li>
                <xsl:copy-of select="keg:translate('Set of quantifiers as interest measures for the output association rules',720)"/>
              </li>
              <li>
                <xsl:copy-of select="keg:translate('Set of Derived Boolean attribute settings for the antecedent',730)"/>
              </li>
              <li>
                <xsl:copy-of select="keg:translate('Set of Derived Boolean attribute settings for the consequent',740)"/>
              </li>
            </ul>
            <p>
              <xsl:copy-of select="keg:translate('Below, all the interest measures for the output association rules are stated. The table contains name of the quantifier (interest measure) and also minimal values of the quantifier threshold(s).',750)"/>
            </p>
          </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="guha:AssociationModel | guha:SD4ftModel | guha:Ac4ftModel | guha:CFMinerModel" mode="sect4"/>
    </div>

    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DMTaskSetting','','end')"/></xsl:comment>
  <!-- ==========================
       Section 5 - Discovered ARs
       ========================== -->
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DiscoveredARs','','start')"/></xsl:comment>
    <section id="sect5">
      <xsl:choose>
        <xsl:when test="/p:PMML/guha:SD4ftModel">
          <h2><xsl:copy-of select="keg:translate('Discovered Action Rules',910)"/></h2>
          <p><xsl:copy-of select="keg:translate('Below, all the discovered patterns (action rules) are listed. Each association rule contains name, values of the interest measure (quantifier) and a four-fold contingency table for the initial and the final state. The following paragraph complies with the PMML standard and shows, which attributes occur in the discovered action rules. Also, number of discovered rules is stated.',920)"/></p>
        </xsl:when>
        <xsl:when test="/p:PMML/guha:Ac4ftModel">
          <h2><xsl:copy-of select="keg:translate('Discovered pairs of Association Rules',990)"/></h2>
          <p><xsl:copy-of select="keg:translate('Below, all the discovered patterns (pairs of association rules) are listed. Each pair of association rules contains name, values of the interest measure (quantifier) and a four-fold contingency table for each of the rules. The following paragraph complies with the PMML standard and shows, which attributes occur in the discovered association rules. Also, number of discovered rules is stated.',1000)"/></p>
        </xsl:when>
        <xsl:otherwise>
          <h2><xsl:copy-of select="keg:translate('Discovered Association Rules',60)"/></h2>
          <p><xsl:copy-of select="keg:translate('Below, all the discovered patterns (association rules) are listed. Each association rule contains name, values of the interest measure (quantifier) and a four-fold contingency table. The following paragraph complies with the PMML standard and shows, which attributes occur in the discovered association rules. Also, number of discovered rules is stated.',790)"/></p>
        </xsl:otherwise>
      </xsl:choose>
      <p><xsl:copy-of select="keg:translate('Discovered rules relate to the following attributes',110)"/>: <xsl:apply-templates select="p:DataDictionary/p:DataField" mode="sect5" />.</p>

      <xsl:comment><xsl:value-of select="keg:getContentBlockTag('NumberOfRulesFound','','start')"/></xsl:comment>
      <p class="foundRulesCount"><xsl:copy-of select="keg:translate('Number of discovered association rules',120)"/>: <xsl:value-of select="guha:AssociationModel/@numberOfRules | guha:SD4ftModel/@numberOfRules | guha:Ac4ftModel/@numberOfRules | guha:CFMinerModel/@numberOfRules"/></p>
      <xsl:comment><xsl:value-of select="keg:getContentBlockTag('NumberOfRulesFound','','end')"/></xsl:comment>

      <xsl:apply-templates select="guha:AssociationModel/AssociationRules/AssociationRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]" mode="sect5"/>
      <xsl:apply-templates select="guha:SD4ftModel/SD4ftRules/SD4ftRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]" mode="sect5"/>
      <xsl:apply-templates select="guha:Ac4ftModel/Ac4ftRules/Ac4ftRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]" mode="sect5"/>
      <xsl:apply-templates select="guha:CFMinerModel/CFMinerRules/CFMinerRule[position() &lt;= $maxRulesToList or not($maxRulesToList)]" mode="sect5"/>
      
      <xsl:if test="($maxRulesToList and (count(guha:AssociationModel/AssociationRules/AssociationRule) > $maxRulesToList))">
        <p style="color:red;">
          <xsl:copy-of select="keg:translate('Maximum number of discovered rules exceeded! Number of founded rules:',61)"/> <xsl:value-of select="guha:AssociationModel/@numberOfRules | guha:SD4ftModel/@numberOfRules | guha:Ac4ftModel/@numberOfRules | guha:CFMinerModel/@numberOfRules"/>
        </p>
      </xsl:if>
    </section>

    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DiscoveredARs','','end')"/></xsl:comment>
  </xsl:template>
</xsl:stylesheet>
