<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:p="http://www.dmg.org/PMML-4_0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz" xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
  extension-element-prefixes="func exsl"
  exclude-result-prefixes="p xsi keg guha">
  <!-- ==========================
       Section 5 - Discovered ARs
       ========================== -->
  <!-- found rule detail -->
  <xsl:template match="AssociationRule | SD4ftRule | Ac4ftRule | CFMinerRule" mode="sect5">
    <!-- rule link is made according to its position (number) -->
    <xsl:variable name="arText">
      <xsl:apply-templates select="." mode="ruleBody"/>
    </xsl:variable>
    <xsl:variable name="arDebug">
      <xsl:apply-templates select="." mode="debug"/>
    </xsl:variable>
    <xsl:variable name="query">
      <xsl:apply-templates select="." mode="createQueryMain"/>
    </xsl:variable>
    <xsl:variable name="rulePos" select="position()"/>

    <xsl:variable name="ruleClass">
        <xsl:choose>
            <xsl:when test="./Extension[@name='mark']/@value='interesting'">selectedRule</xsl:when>
            <xsl:otherwise>otherRule</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <div id="sect5-rule{$rulePos}" class="{$ruleClass}" >
      <h3 title="{$arDebug}"><xsl:copy-of select="keg:translate('Rule',12)"/> <xsl:value-of select="$rulePos"/></h3>
      <p class="ruleText">
        <!-- Rule has format: Antecedent => Consequent
        -->
        <xsl:variable name="arTextWithNumber">
            <xsl:copy-of select="keg:translate('Rule',12)"/> <xsl:value-of select="$rulePos"/><xsl:if test="$ruleClass='selectedRule'"><xsl:text> - </xsl:text><xsl:value-of select="keg:translate('selected rule',14)"/></xsl:if><xsl:text>: </xsl:text><xsl:copy-of select="$arText"/>
        </xsl:variable>

        <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DiscoveredRule',$arTextWithNumber,'start')"/></xsl:comment>
        <xsl:copy-of select="$arText"/>
        <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DiscoveredRule',$arTextWithNumber,'end')"/></xsl:comment>
      </p>
      <div id="arb{position()}" class="hidden">
        <xsl:text disable-output-escaping="yes">&lt;!--[CDATA[</xsl:text>
        <xsl:copy-of select="$query"/>
        <xsl:text disable-output-escaping="yes">]]--&gt;</xsl:text>
      </div>
      <!--
      <xsl:for-each select="document('queries.xml')/queries/query">
        <img src="{icon}" onclick="return KbiPostArb({$rulePos}, {source/@id}, {@id}, {xslt/@id});" title="{name}" alt="{name}" />
      </xsl:for-each>-->
      <div id="arb_result{position()}" class="hidden">...</div>
      <!-- table of values of test criteria (quantifiers) -->
      <xsl:if test="local-name() != 'CFMinerRule'">
        <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DiscoveredRule_Quantifiers',$arText,'start')"/></xsl:comment>
        <xsl:apply-templates select="." mode="sect5-qtable">
          <xsl:with-param name="rulePos" select="$rulePos"/>
        </xsl:apply-templates>
        <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DiscoveredRule_Quantifiers',$arText,'end')"/></xsl:comment>
      </xsl:if>
      <!-- 4FT table for AssociationRule / 4ftMiner -->
      <xsl:if test="local-name()='AssociationRule'">
        <!-- 4FT: four field table -->
        <xsl:copy-of select="keg:translate('Four field contingency table',13)"/>
        <xsl:call-template name="FourFieldTable">
          <xsl:with-param name="a" select="FourFtTable/@a"/>
          <xsl:with-param name="b" select="FourFtTable/@b"/>
          <xsl:with-param name="c" select="FourFtTable/@c"/>
          <xsl:with-param name="d" select="FourFtTable/@d"/>
          <xsl:with-param name="arText" select="$arText"/>
        </xsl:call-template>
      </xsl:if>
      <!-- 4FT table for SD4ftRule / SD4ftMiner -->
      <xsl:if test="local-name()='SD4ftRule'">
        <!-- 4FT: four field table -->
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
      <xsl:if test="local-name()='Ac4ftRule'">
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
      <xsl:if test="local-name()='CFMinerRule'">
        <!-- attributes table -->
        <table class="itable" id="sect5-rule{$rulePos}-freqtab">
          <tr>
            <th>Kategorie</th>
            <th>Frekvence</th>
          </tr>
          <xsl:apply-templates select="Frequencies/Frequency" />
        </table>
        <!-- graph -->
        <xsl:variable name="histId" select="$rulePos + 1000"/>
        <xsl:variable name="numOfCategories" select="count(Frequencies/Frequency)"/>
        <div class="graphUI noprint">
          <label for="cbg{$histId}">Graph:
          <input id="cbg{$histId}" type="checkbox" onclick="ShowChecked(this,'hist{$histId}')" checked="checked"/>
          </label>
          <label for="cbo{$histId}"><xsl:value-of select="$otherCategoryName"/>:
          <input id="cbo{$histId}" type="checkbox" onclick="GraphUrlOther(this,'{$histId}','{$otherCategoryName}')" checked="checked"/>
          </label>
          <label for="from{$histId}">From:
          <input type="button" onclick="GraphUrlFrom('{$histId}',-1,{$numOfCategories})" value="-"/>
          <input id="from{$histId}" type="text" onblur="GraphUrlFrom('{$histId}',0,{$numOfCategories})" value="0"/>
          <input type="button" onclick="GraphUrlFrom('{$histId}',+1,{$numOfCategories})" value="+"/>
          </label>
          <label for="num{$histId}">Columns:
          <input id="num{$histId}" type="text" onblur="GraphUrlNum('{$histId}')" value="{$maxCategoriesToListInGraphs}"/>
          </label>
        </div>
        <div id="hist{$histId}">
          <xsl:call-template name="drawHistogram"/>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- quantifier table -->
  <xsl:template match="AssociationRule | SD4ftRule | Ac4ftRule | CFMinerRule | FirstSet | SecondSet | StateBefore | StateAfter" mode="sect5-qtable">
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
    <table class="itable" summary="Values of associated test criteria">
      <thead>
        <tr>
          <th colspan="{$tableColspan}">
            <input type="checkbox" onclick="ShowChecked(this,'sect5-{$sect}rule{$rulePos}-non-task')"/>
            <xsl:choose>
              <xsl:when test="local-name()='AssociationRule' or local-name()='SD4ftRule' or local-name()='Ac4ftRule'">
                <xsl:copy-of select="keg:translate('Table of values for test criteria', 422)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="keg:translate('Interest measure values', 840)"/>
              </xsl:otherwise>
            </xsl:choose>
          </th>
        </tr>
        <tr>
          <th><xsl:copy-of select="keg:translate('Interest Measure',590)"/></th>
          <th><xsl:copy-of select="keg:translate('Value',252)"/></th>
          <xsl:if test="IMValue[@sourceMode]">
            <th>Source mode</th>
          </xsl:if>
        </tr>
      </thead>
      <!-- previously BASE was Support and FUI was Confidence -->
      <xsl:if test="IMValue[@name='BASE']!=-1 or IMValue[@name='FUI']!=-1">
        <tbody>
          <!-- if BASE == -1 then don't include to report; BASE == -1 occurs in Ferda only, LM has always valid value? -->
          <xsl:if test="IMValue[@name='BASE']!=-1">
            <tr>
              <td><xsl:copy-of select="keg:translateInterestMeasure('BASE','TestCriterion', 'pmml', $reportLang)"/></td>
              <td><xsl:value-of select="format-number(IMValue[@name='BASE'],'0.0000')"/></td>
            </tr>
          </xsl:if>
          <!-- if FUI == -1 then don't include to report -->
          <xsl:if test="IMValue[@name='FUI']!=-1">
            <tr>
              <td><xsl:copy-of select="keg:translateInterestMeasure('FUI','TestCriterion', 'pmml', $reportLang)"/></td>
              <td><xsl:value-of select="format-number(IMValue[@name='FUI'],'0.0000')"/></td>
            </tr>
          </xsl:if>
        </tbody>
      </xsl:if>
      <!-- AssociationRule or SD4ftRule or Ac4ftRule table rows -->
      <xsl:if test="local-name()='AssociationRule' or local-name()='SD4ftRule' or local-name()='Ac4ftRule'">
        <tbody id="sect5-rule{$rulePos}-task">
          <!-- other quantifiers from task setting -->
          <xsl:apply-templates select="IMValue[not(@name='BASE') and not(@name='FUI') and @imSettingRef]" mode="sect5"/>
        </tbody>
        <tbody class="dim hidden" id="sect5-rule{$rulePos}-non-task">
          <!-- other quantifiers not from task setting -->
          <xsl:apply-templates select="IMValue[not(@name='BASE') and not(@name='FUI') and not(@imSettingRef)]" mode="sect5"/>
        </tbody>
      </xsl:if>
      <!-- SD4ftRule/FirstSet or SD4ftRule/SecondSet, Ac4ftRule/StateBefore or Ac4ftRule/StateAfter table rows -->
      <xsl:if test="local-name()='FirstSet' or local-name()='SecondSet' or local-name()='StateBefore' or local-name()='StateAfter'">
        <tbody class="dim hidden" id="sect5-{$sect}rule{$rulePos}-non-task">
          <!-- other quantifiers from task setting -->
          <xsl:apply-templates select="IMValue[not(@name='BASE') and not(@name='FUI')]" mode="sect5"/>
        </tbody>
      </xsl:if>
    </table>
  </xsl:template>

  <!-- fourfield table -->
  <xsl:template name="FourFieldTable">
    <!-- a-d = extender values -->
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:param name="c"/>
    <xsl:param name="d"/>
    <xsl:param name="arText"/>
    <!-- const: row count / 255 -->
    <xsl:variable name="konst" select="($a+$b+$c+$d) div 255"/>
    <!-- ca-cd: a-d table cell colors
      - red = 255
      - green = extender / const
      - blue = extender / const
    -->
    <xsl:variable name="ca" select="concat('background: rgb(255,',255-round($a div $konst),',',255-round($a div $konst),');')"/>
    <xsl:variable name="cb" select="concat('background: rgb(255,',255-round($b div $konst),',',255-round($b div $konst),');')"/>
    <xsl:variable name="cc" select="concat('background: rgb(255,',255-round($c div $konst),',',255-round($c div $konst),');')"/>
    <xsl:variable name="cd" select="concat('background: rgb(255,',255-round($d div $konst),',',255-round($d div $konst),');')"/>

    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('ContingencyTable',$arText,'start')"/></xsl:comment>
    <table class="itable" summary="Four field table">
      <tr>
        <td></td>
        <td><xsl:copy-of select="keg:translate('Consequent',600)"/></td>
        <td><xsl:value-of select="$notOperator"/><!-- NOT --><xsl:copy-of select="keg:translate('Consequent',600)"/></td>
      </tr>
      <tr>
        <td><xsl:copy-of select="keg:translate('Antecedent',610)"/></td>
        <!-- extender values with calculated background color -->
        <td style="{$ca}"><xsl:value-of select="$a"/></td>
        <td style="{$cb}"><xsl:value-of select="$b"/></td>
      </tr>
      <tr>
        <td><xsl:value-of select="$notOperator"/><!-- NOT --><xsl:copy-of select="keg:translate('Antecedent',610)"/></td>
        <!-- extender values with calculated background color -->
        <td style="{$cc}"><xsl:value-of select="$c"/></td>
        <td style="{$cd}"><xsl:value-of select="$d"/></td>
      </tr>
    </table>
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('ContingencyTable',$arText,'end')"/></xsl:comment>

  </xsl:template>

  <!-- cfminer frequencies table -->
  <xsl:template match="Frequency">
    <tr>
      <td><xsl:value-of select="@category" /></td>
      <td><xsl:value-of select="@value" /></td>
    </tr>
  </xsl:template>

<!-- Debug: Rule parts overview -->
  <xsl:template match="AssociationRule | SD4ftRule | Ac4ftRule | CFMinerRule" mode="debug">antecedent=<xsl:value-of select="@antecedent" />
consequent=<xsl:value-of select="@consequent | @succedent"/>
condition=<xsl:value-of select="@condition"/>

firstSet=<xsl:value-of select="FirstSet/@set | FirstSet/@FirstSet"/>
secondSet=<xsl:value-of select="SecondSet/@set | SecondSet/@SecondSet"/>

antecedentVarBefore=<xsl:value-of select="StateBefore/@antecedentVarBefore"/>
antecedentVarAfter=<xsl:value-of select="StateAfter/@antecedentVarAfter"/>

consequentVarBefore=<xsl:value-of select="StateBefore/@consequentVarBefore"/>
consequentVarAfter=<xsl:value-of select="StateAfter/@consequentVarAfter"/>

attribute=<xsl:value-of select="@attribute"/>
  </xsl:template>

  <!--
  RULE BODY
  -->
  <!-- CFMinerRule with format Attribute / Condition is bellow ... -->
  <xsl:template match="AssociationRule | SD4ftRule | Ac4ftRule" mode="ruleBody">
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
        [ <xsl:call-template name="cedent">
          <xsl:with-param name="cedentID" select="StateBefore/@antecedentVarBefore"/>
        </xsl:call-template> -&gt;
        <xsl:call-template name="cedent">
          <xsl:with-param name="cedentID" select="StateAfter/@antecedentVarAfter"/>
        </xsl:call-template>
        ]
      </xsl:when>
      <!-- antecedent exists, but doesn't refer any other items -->
      <xsl:otherwise>
        [[ <xsl:copy-of select="keg:translate('No restriction',221)"/>]]
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
      : <xsl:call-template name="cedent">
        <xsl:with-param name="cedentID" select="FirstSet/@set | FirstSet/@FirstSet"/>
      </xsl:call-template>
    </xsl:if>
    <!-- second set (SD4ftRule) -->
    <xsl:if test="SecondSet">
      x <xsl:call-template name="cedent">
        <xsl:with-param name="cedentID" select="SecondSet/@set | SecondSet/@SecondSet"/>
      </xsl:call-template>
    </xsl:if>
    <!-- antecedent for StateBefore/StateAfter of Ac4ftRule -->
    <xsl:if test="StateBefore/@consequentVarBefore and StateAfter/@consequentVarAfter">
      [ <xsl:call-template name="cedent">
        <xsl:with-param name="cedentID" select="StateBefore/@consequentVarBefore"/>
      </xsl:call-template> -&gt;
      <xsl:call-template name="cedent">
        <xsl:with-param name="cedentID" select="StateAfter/@consequentVarAfter"/>
      </xsl:call-template>
      ]
    </xsl:if>
    <!-- condition -->
    <xsl:if test="../BBA[@id=$cond] | ../DBA[@id=$cond]"> /
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
    <xsl:value-of select="@attribute" />
    <!-- condition -->
    <xsl:if test="../BBA[@id=$cond] | ../DBA[@id=$cond]"> /
      <xsl:call-template name="cedent">
        <xsl:with-param name="cedentID" select="$cond"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="IMValue" mode="sect5" priority="1">
    <tr>
      <!-- quantifier name -->
      <td>
        <xsl:copy-of select="keg:translateInterestMeasure(@name,'TestCriterion', 'pmml', $reportLang)"/>
      </td>
      <!-- quantifier value -->
      <td><xsl:value-of select="format-number(text(),'0.0000')"/></td>
      <xsl:if test="@sourceMode">
        <td><xsl:value-of select="@sourceMode"/></td>
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
        <xsl:apply-templates select="." mode="bbaText" />
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="BBA" mode="bbaText">
    <xsl:value-of select="./FieldRef/text()" />(<xsl:apply-templates select="./CatRef" mode="bbaText" />)
  </xsl:template>

  <xsl:template match="CatRef" mode="bbaText">
    <xsl:if test="position()>1">, </xsl:if>
    <xsl:value-of select="text()"/>
  </xsl:template>

  <xsl:template match="DBA">
    <xsl:param name="topLevel"/>
    <!-- item can be preceded by NOT operator -->
    <xsl:choose>
      <xsl:when test="@connective='Negation'">
        <xsl:value-of select="$notOperator"/><xsl:apply-templates select="BARef"/>
      </xsl:when>
      <xsl:when test="$topLevel='1' or count(BARef) =1">
        <xsl:apply-templates select="BARef"/>
      </xsl:when>
      <xsl:otherwise>
        (<xsl:apply-templates select="BARef"/>)
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="BARef">
    <xsl:variable name="ref" select="text()"/>
    <!-- items are delimited by concective AND or OR -->
    <xsl:if test="position() > 1">
        <xsl:choose>
            <xsl:when test="../p:Extension[@name='Connective' and @value='Disjunction']"> <xsl:value-of select="$orOperator"/> <!-- V --></xsl:when>
            <xsl:otherwise> <xsl:value-of select="$andOperator"/> <!-- & --></xsl:otherwise>
        </xsl:choose>
    </xsl:if>
    <!-- item refers (by ref) to other BBA or DBA - RECURSION -->
    <xsl:apply-templates select="../../BBA[@id=$ref] | ../../DBA[@id=$ref]"/>
  </xsl:template>

  <xsl:template match="p:DataField" mode="sect5">
    <xsl:if test="position()>1">, </xsl:if>
    <xsl:value-of select="@name"/>
  </xsl:template>

</xsl:stylesheet>