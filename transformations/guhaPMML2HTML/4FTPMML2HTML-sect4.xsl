<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:p="http://www.dmg.org/PMML-4_0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common"
                xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz"
                xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
                extension-element-prefixes="func exsl"
                exclude-result-prefixes="p xsi keg guha">
  <!-- ========================
       Data Mining Task Setting
       ======================== -->
  <xsl:template match="guha:AssociationModel | guha:SD4ftModel | guha:Ac4ftModel | guha:CFMinerModel" mode="sect4">
    <section id="sect4-imValues">
      <xsl:call-template name="keg:ContentBlock">
        <xsl:with-param name="contentBlockName">QuantifiersUsed</xsl:with-param>
        <xsl:with-param name="element"/>
      </xsl:call-template>

      <!-- Used quantifier table -->
      <!-- table number depends on previous table count -->
      <xsl:variable name="tabs"
                    select="count(/p:PMML/p:DataDictionary/p:DataField)+count(/p:PMML/p:TransformationDictionary/p:DerivedField)"/>

      <h3>
        <xsl:copy-of select="keg:translate('Interest Measures used',420)"/>
      </h3>
      <table>
        <tr>
          <th>
            <xsl:copy-of select="keg:translate('Interest Measure',590)"/>
          </th>
          <th>
            <xsl:copy-of select="keg:translate('Minimum value',430)"/>
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
        <xsl:copy-of
            select="keg:translate('Note: GUHA quantifiers Founded Implication and Base are listed as confidence and support',450)"/>
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
      <xsl:call-template name="keg:ContentBlock">
        <xsl:with-param name="contentBlockName">SoughtRulePattern</xsl:with-param>
        <xsl:with-param name="element"/>
      </xsl:call-template>

      <h3>
        <xsl:choose>
          <xsl:when test="/p:PMML/guha:SD4ftModel">
            <xsl:copy-of select="keg:translate('Sought type of pairs of association rules',980)"/>
          </xsl:when>
          <xsl:when test="/p:PMML/guha:Ac4ftModel">
            <xsl:copy-of select="keg:translate('Sought type of action rules',900)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="keg:translate('Sought type of association rules',460)"/>
          </xsl:otherwise>
        </xsl:choose>
      </h3>
      <p>
        <xsl:copy-of select="keg:translate('The data mining task found rules in the following form:',760)"/>
      </p>
      <p id="sect4-rulesPattern">
        <xsl:call-template name="TaskSettingRulePattern"/>
      </p>

      <p>
        <xsl:copy-of
            select="keg:translate('The basic building blocks of the task setting is the basic Boolean attributes setting...',770)"/>
      </p>
      <p>
        <xsl:copy-of
            select="keg:translate('Derived Boolean attributes are recursive structures built upon the basic Boolean attributes...',780)"/>
      </p>

      <!-- basic attributes table -->
      <section class="cedentsDetails">
        <xsl:call-template name="keg:ContentBlock">
          <xsl:with-param name="contentBlockName">BasicBooleanAttributes</xsl:with-param>
          <xsl:with-param name="element"/>
        </xsl:call-template>
        <h4>
          <xsl:copy-of select="keg:translate('Detailed list of basic Boolean attributes',470)"/>
        </h4>
        <table>
          <tr>
            <th class="id">ID</th>
            <th>
              <xsl:copy-of select="keg:translate('Name',480)"/>
            </th>
            <th>
              <xsl:copy-of select="keg:translate('Based on attibute',490)"/>
            </th>
            <th>
              <xsl:copy-of select="keg:translate('Coefficient',500)"/>
            </th>
            <th>
              <xsl:copy-of select="keg:translate('Minimal length',510)"/>
            </th>
            <th>
              <xsl:copy-of select="keg:translate('Maximal length',520)"/>
            </th>
          </tr>
          <!-- table row -->
          <xsl:apply-templates select="BBASettings/BBASetting" mode="sect4"/>
        </table>
      </section>

      <!-- derived attributes table -->
      <section class="cedentsDetails">
        <xsl:call-template name="keg:ContentBlock">
          <xsl:with-param name="contentBlockName">DerivedBooleanAttributes</xsl:with-param>
          <xsl:with-param name="element"/>
        </xsl:call-template>

        <h4>
          <xsl:copy-of select="keg:translate('Detailed list of derived Boolean attributes',530)"/>
        </h4>
        <table>
          <tr>
            <th class="id">ID</th>
            <th>
              <xsl:copy-of select="keg:translate('Name',480)"/>
            </th>
            <th>
              <xsl:copy-of select="keg:translate('Attribute elements',550)"/>
            </th>
            <th>
              <xsl:copy-of select="keg:translate('Type',540)"/>
            </th>
            <th>
              <xsl:copy-of select="keg:translate('Minimal length',510)"/>
            </th>
            <th>
              <xsl:copy-of select="keg:translate('Maximal length',520)"/>
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

</xsl:stylesheet>