<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:p="http://www.dmg.org/PMML-4_0" xmlns="http://www.dmg.org/PMML-4_0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz" xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
  extension-element-prefixes="func exsl"
  exclude-result-prefixes="p keg">
    <!-- This XSLT transformation  corrects errors in PMML input of Ferda and LISp-Miner
        and normalizes interest measure names
    -->
    <!-- When changing this transformation, create new elements always with
xsl:element construct. Typing new elements directly will append to them unneccessary
namespace prefixes as explained at http://www.stylusstudio.com/xsllist/200308/post40840.html
    -->

    <!-- Author Tomas Kliegr-->
    <!-- TO DO
        keg:includeSigLevelIfMissing is currently disabled because it was too slow
    -->
  <xsl:variable name="thisFileVersion">0.12</xsl:variable>
  <xsl:variable name="thisFileName">CheckAndNormalization.xsl</xsl:variable>

  <xsl:param name="dictionaryURL" select="'../pmml/dict/GUHAQuantifier-InterestMeasureDictionary.xml'"/>
  <xsl:variable name="appName" select="/p:PMML/p:Header/p:Application/@name"/>

  <!--  This function is here to bridge the gap between BKEF 1.0 and BKEF 2.0 -->
  <func:function name="keg:getTestCriterionName">
    <xsl:param name="InterestMeasureName"/>
    <xsl:variable name="translated"  select="document($dictionaryURL)/InterestMeasures/InterestMeasure[str=$InterestMeasureName]/TestCriteria/TestCriterion[1]/str[@lang='MasterName']"/>
    <xsl:choose>
      <xsl:when test="$translated and not($translated='')"><func:result select="$translated"/></xsl:when>
      <xsl:otherwise><func:result select="$InterestMeasureName"/></xsl:otherwise>
    </xsl:choose>
  </func:function>
  <!-- if interest measure has a significance level and the data mining tool does not include it in the results (it is only in task setting),
  this system returns an xml fragment describing the significance level. The fragment is in the format used in the results
  -->
  <func:function name="keg:includeSigLevelIfMissing">
    <!-- This function is very slow, the results of the xpath queries need to be cached -->
    <xsl:param name="testCriterionMasterName"/>
    <!-- //InterestMeasure[./TestCriteria/TestCriterion/str[@lang='MasterName']/text()='Lower Critical Implication' and ./TestCriteria/TestCriterion[@type='SignificanceLevel']/str[@software='LISp-Miner' and @missing='true']]/str[@lang='pmml' and @software='LISp-Miner']/text() -->
    <xsl:variable name="interestMeasurePMMLName"  select="document($dictionaryURL)//InterestMeasure[./TestCriteria/TestCriterion/str[@lang='MasterName']/text()=$testCriterionMasterName and ./TestCriteria/TestCriterion[@type='SignificanceLevel']/str[@software=$appName and @missing='true']]/str[@lang='pmml' and @software=$appName]/text()"/>
    <xsl:choose>
      <xsl:when test="$interestMeasurePMMLName and not(interestMeasurePMMLName = '')">
        <xsl:variable name="sigLevelMasterName" select="document($dictionaryURL)//InterestMeasure[str/@lang='pmml' and str/@software=$appName and str/text()=$interestMeasurePMMLName]/TestCriteria/TestCriterion[@type='SignificanceLevel']/str[@lang='MasterName']"/>
        <xsl:variable name="sigLevel" select="//InterestMeasure[text() = $interestMeasurePMMLName]/SignificanceLevel"/>
        <func:result>
          <xsl:text>
          </xsl:text>
          <Extension name="{$sigLevelMasterName}"><xsl:value-of select="$sigLevel+0"/></Extension>
        </func:result>
      </xsl:when>
      <xsl:otherwise><func:result select="''"/></xsl:otherwise>
    </xsl:choose>
  </func:function>

  <func:function name="keg:getSignificanceLevelName">
    <xsl:param name="InterestMeasureName"/>
    <xsl:variable name="translated"  select="document($dictionaryURL)/InterestMeasures/InterestMeasure[str=$InterestMeasureName]/TestCriteria/TestCriterion[@type='SignificanceLevel']/str[@lang='MasterName']"/>
    <xsl:choose>
      <xsl:when test="$translated and not($translated='')"> <func:result select="$translated"/></xsl:when>
      <xsl:otherwise><func:result select="$InterestMeasureName"/></xsl:otherwise>
    </xsl:choose>
  </func:function>

  <func:function name="keg:closuresMatch">
    <xsl:param name="closureofLeftInterval"/>
    <xsl:param name="closureofRightInterval"/>
    <xsl:choose>
      <xsl:when test="($closureofLeftInterval='closedOpen' and $closureofRightInterval='openClosed') or ($closureofLeftInterval='closedOpen' and $closureofRightInterval='openOpen') or ($closureofLeftInterval='openOpen' and $closureofRightInterval='openOpen') or ($closureofLeftInterval='openOpen' and $closureofRightInterval='openClosed')">
        <func:result select="'false'"/></xsl:when>
      <xsl:otherwise><func:result select="'true'"/></xsl:otherwise>
    </xsl:choose>
  </func:function>

  <func:function name="keg:closureMerge">
    <xsl:param name="closureofLeftInterval"/>
    <xsl:param name="closureofRightInterval"/>
    <xsl:variable name="leftB">
      <xsl:choose>
        <xsl:when test="substring($closureofLeftInterval,1,2)='op'">open</xsl:when>
        <xsl:otherwise>closed</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rightB">
      <xsl:choose>
        <xsl:when test="(string-length($closureofRightInterval)=8) or (string-length($closureofRightInterval)=10 and substring($closureofRightInterval,1,2)='cl')">Open</xsl:when>
        <xsl:otherwise>Closed</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <func:result select="concat($leftB,$rightB)"/>
  </func:function>

  <func:function name="keg:translateInterestMeasure">
    <!-- parametr name je volitelny. povinny je tehdy, pokud nezname id prekladaneho vyrazu, coz nastava pri prekladu z XML-->
    <xsl:param name="name"/>
    <xsl:param name="type"/> <!-- InterestMeasure nebo TestCriterion -->
    <xsl:param name="fromLang"/>
    <xsl:param name="toLang"/>
    <xsl:variable name="translated" >
      <xsl:choose>
        <xsl:when test="$type='InterestMeasure'">
          <xsl:value-of select="document($dictionaryURL)/InterestMeasures/InterestMeasure[str/@lang=$fromLang and str=$name]/str[@lang=$toLang]"/>
        </xsl:when>
        <xsl:when test="$type='TestCriterion'">
          <xsl:value-of select="document($dictionaryURL)/InterestMeasures/InterestMeasure/TestCriteria/TestCriterion[str/@lang=$fromLang and str=$name]/str[@lang=$toLang]"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="'Cannot translate interest measure'"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$translated and not($translated='')"> <func:result select="$translated"/></xsl:when>
      <xsl:otherwise><func:result select="$name"/></xsl:otherwise>
    </xsl:choose>
  </func:function>

  <xsl:template match="node()|@*" >
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="p:Header/p:Application" >
    <xsl:element name="Extension">
      <xsl:attribute name="name">NormalizedBy</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="$thisFileVersion"/></xsl:attribute>
        <xsl:attribute name="extender"><xsl:value-of select="$thisFileName"/></xsl:attribute>
    </xsl:element>
    <xsl:text></xsl:text>
    <xsl:element name="Extension">
      <xsl:attribute name="name">NormalizationDictionary</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="document($dictionaryURL)/InterestMeasures/@dictionaryVersion"/></xsl:attribute>
      <xsl:attribute name="extender"><xsl:value-of select="$dictionaryURL"/></xsl:attribute>
    </xsl:element>
    <xsl:text></xsl:text>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!-- adds id attribute to AssociationRule -->
  <xsl:template match="AssociationRule">
    <xsl:copy>
      <xsl:attribute name="id"><xsl:number /></xsl:attribute>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="InterestMeasure" priority="100">
    <xsl:variable name="norm" select="keg:translateInterestMeasure(text(), 'InterestMeasure', 'pmml', 'MasterName')"></xsl:variable>
    <!-- translates name within element -->
    <xsl:element name="{local-name()}" xmlns="">
      <xsl:value-of select="$norm"/>
      <xsl:apply-templates select="Threshold">
        <xsl:with-param name="testCriterionName" select="keg:getTestCriterionName($norm)"/>
      </xsl:apply-templates>
      <xsl:apply-templates  select="SignificanceLevel">
        <xsl:with-param name="significanceLevelName" select="keg:getSignificanceLevelName($norm)"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="InterestMethodThreshold/Threshold">
    <xsl:param name="testCriterionName"/>
    <xsl:element name="{local-name()}" xmlns="">
      <xsl:attribute name="name"><xsl:value-of select="$testCriterionName"/></xsl:attribute>
      <xsl:value-of select="text()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="InterestMethodThreshold/SignificanceLevel">
    <xsl:param name="significanceLevelName"></xsl:param>
    <xsl:element name="{local-name()}" xmlns="">
      <xsl:attribute name="name"><xsl:value-of select="$significanceLevelName"/></xsl:attribute>
      <xsl:value-of select="text()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="IMValue" priority="100">
    <xsl:variable name="norm" select="keg:translateInterestMeasure(@name,'TestCriterion','pmml', 'MasterName')"/>
    <xsl:copy>
      <xsl:attribute name="name"><xsl:value-of select="$norm"/></xsl:attribute>
      <xsl:apply-templates select="node()|@*[local-name() != 'name']"/>
    </xsl:copy>
    <!-- <xsl:copy-of select="keg:includeSigLevelIfMissing($norm)"/> -->
  </xsl:template>

  <xsl:template match="p:DiscretizeBin/p:Interval">
    <xsl:choose>
      <xsl:when test="count(../p:Interval)=1">
        <!-- Performance optimization for nodes that need not be merged -->
        <xsl:element name="{local-name()}">
          <xsl:attribute name="closure"><xsl:value-of select="@closure"/></xsl:attribute>
          <xsl:attribute name="leftMargin"><xsl:value-of select="@leftMargin"/></xsl:attribute>
          <xsl:attribute name="rightMargin"><xsl:value-of select="@rightMargin"/></xsl:attribute>
        </xsl:element>
      </xsl:when>
      <xsl:when test="@rightMargin = following-sibling::*[1]/@leftMargin and keg:closuresMatch(@closure,following-sibling::*[1]/@closure) ='true'">
        <xsl:comment>Interval was merged during normalization</xsl:comment>
      </xsl:when>
      <xsl:when test="@leftMargin = preceding-sibling::*[local-name(.)='Interval'][1]/@rightMargin and keg:closuresMatch(preceding-sibling::*[1]/@closure,@closure)='true'">
      <!-- This Interval has a preceding connecting interval that was skipped, but the following interval is not connecting and cannot be merged -->
        <xsl:apply-templates select="preceding-sibling::*[local-name(.)='Interval'][1]" mode="getMerged">
          <xsl:with-param name="origRightMargin" select="@rightMargin"/>
          <xsl:with-param name="origClosure" select="@closure"/>
          <xsl:with-param name="lastClosure" select="@closure"/>
          <xsl:with-param name="lastLeftMargin" select="@leftMargin"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{local-name()}">
          <xsl:attribute name="closure"><xsl:value-of select="@closure"/></xsl:attribute>
          <xsl:attribute name="leftMargin"><xsl:value-of select="@leftMargin"/></xsl:attribute>
          <xsl:attribute name="rightMargin"><xsl:value-of select="@rightMargin"/></xsl:attribute>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template  match="p:Interval" mode="getMerged">
    <xsl:param name="origRightMargin"/>
    <xsl:param name="lastLeftMargin"/>
    <xsl:param name="lastClosure"/>
    <xsl:param name="origClosure"/>
    <xsl:param name="openningMargin"/>
    <xsl:choose>
      <xsl:when test="$lastLeftMargin = @rightMargin and keg:closuresMatch(@closure,$lastClosure)='true' and count(preceding-sibling::*[local-name(.)='Interval'])>0">
        <xsl:apply-templates select="preceding-sibling::*[local-name(.)='Interval'][1]" mode="getMerged">
          <xsl:with-param name="origRightMargin" select="$origRightMargin"/>
          <xsl:with-param name="origClosure" select="$origClosure"/>
          <xsl:with-param name="lastLeftMargin" select="@leftMargin"/>
          <xsl:with-param name="lastClosure" select="@closure"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$lastLeftMargin = @rightMargin and keg:closuresMatch(@closure,$lastClosure)='true'">
        <xsl:element name="{local-name()}">
          <xsl:attribute name="closure"><xsl:value-of select="keg:closureMerge(@closure,$origClosure)"/></xsl:attribute>
          <xsl:attribute name="leftMargin"><xsl:value-of select="@leftMargin"/></xsl:attribute>
          <xsl:attribute name="rightMargin"><xsl:value-of select="$origRightMargin"/></xsl:attribute>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{local-name()}">
          <xsl:attribute name="closure"><xsl:value-of select="keg:closureMerge(@lastClosure,$origClosure)"/></xsl:attribute>
          <xsl:attribute name="leftMargin"><xsl:value-of select="$lastLeftMargin"/></xsl:attribute>
          <xsl:attribute name="rightMargin"><xsl:value-of select="$origRightMargin"/></xsl:attribute>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>