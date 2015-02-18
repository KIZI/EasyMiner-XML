<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:p="http://www.dmg.org/PMML-4_0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz" xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
  extension-element-prefixes="func exsl"
  exclude-result-prefixes="p xsi keg guha">
  <!-- ==============================
       Section 3 - Created Attributes
       ============================== -->
  <xsl:template match="p:TransformationDictionary" mode="sect3">
    <xsl:apply-templates select="p:DerivedField" mode="sect3"/>
  </xsl:template>

  <xsl:template match="p:DerivedField" mode="sect3">
    <xsl:variable name="DerivedFieldName" select="p:Discretize/@field | p:MapValues/@outputColumn"/>
    <xsl:variable name="numOfCategories" select="count(p:Discretize/p:DiscretizeBin)+count(p:MapValues/p:InlineTable/p:Extension[@name='Frequency'])"/>
    <div id="sect3-{$DerivedFieldName}">
      <h3><xsl:copy-of select="keg:translate('Attribute',360)"/> <xsl:value-of select="p:Discretize/@field | p:MapValues/@outputColumn"/></h3>
      <xsl:variable name="sourceDataField" select="p:Discretize/@field | p:MapValues/p:FieldColumnPair/@column"/>
      <xsl:copy-of select="keg:translate('derived from column',370)"/>:
      <!-- DataField mode=odkaz is in 4FTPMML2HTML-toc.xsl -->
      <em><xsl:apply-templates select="/p:PMML/p:DataDictionary/p:DataField[@name=$sourceDataField]" mode="odkaz"/></em>
      <br/>
      <xsl:copy-of select="keg:translate('Attribute type',361)"/>:
      <em><xsl:value-of select="@optype"/></em>
      <br/>
      <xsl:copy-of select="keg:translate('Number of categories',362)"/>:
      <em><xsl:value-of select="$numOfCategories"/></em>
    </div>
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DerivedFieldDetail',$DerivedFieldName,'start')"/></xsl:comment>

    <!-- link name is derived from field name -->
    <div class="idiv">
      <xsl:variable name="tabs" select="count(/p:PMML/p:DataDictionary/p:DataField)"/>
      <!-- table number depends on previous table count -->
      <table class="itable" summary="Tabulka {position()+$tabs+1}: atribut {$DerivedFieldName}">
        <tr>
          <th><xsl:copy-of select="keg:translate('Category',380)"/></th>
          <th>
            <xsl:choose>
              <xsl:when test="p:Discretize"><xsl:copy-of select="keg:translate('Interval',390)"/></xsl:when>
              <xsl:when test="p:MapValues"><xsl:copy-of select="keg:translate('Enumeration',400)"/></xsl:when>
            </xsl:choose>
          </th>
          <th><xsl:copy-of select="keg:translate('Frequency',253)"/></th>
        </tr>
        <!-- table row depends to attribute is derived (MapValues) or not (Discretize) -->
        <xsl:apply-templates select="p:Discretize/p:DiscretizeBin | p:MapValues/p:InlineTable/p:Extension[@name='Frequency']" mode="sect3"/>
      </table>
      <xsl:if test="$numOfCategories > $maxCategoriesToList">
        <p class="hot">
          <xsl:copy-of select="keg:translate('Exceeded',190)"/> maxCategoriesToList = <xsl:value-of select="$maxCategoriesToList"/>, <xsl:copy-of select="keg:translate('first',200)"/> <xsl:value-of select="$maxCategoriesToList"/> <xsl:copy-of select="keg:translate('from the total number of',210)"/> <xsl:value-of select="$numOfCategories"/> <xsl:copy-of select="keg:translate('categories',290)"/>.
        </p>
      </xsl:if>
    </div>
    <xsl:copy-of select="keg:translate('Histogram of most frequent categories',630)"/>
    <br/>
    <xsl:variable name="histId" select="generate-id()"/>
    <xsl:variable name="otherCategoryName">
      <xsl:choose>
        <xsl:when test="$reportLang = 'cs'">Ostatní</xsl:when>
        <xsl:otherwise>Other</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
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
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DerivedFieldDetail',$DerivedFieldName,'end')"/></xsl:comment>
    <hr/>
  </xsl:template>

  <!-- table row for non-derived attribute (interval) -->
  <xsl:template match="p:DiscretizeBin" mode="sect3">
    <xsl:if test="position() &lt;= $maxCategoriesToList">
      <tr>
        <!-- category name -->
        <td><xsl:value-of select="@binValue"/></td>
        <td>
          <xsl:for-each select="p:Interval">
            <xsl:if test="position() &lt; $maxValuesToList or position() = last()">
              <xsl:choose>
                <xsl:when test="position() = last() and position() > $maxValuesToList">
                  ...
                </xsl:when>
                <xsl:when test="position() > 1">; </xsl:when>
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
        <td><xsl:value-of select="../p:Extension[@name='Frequency' and @extender=current()/@binValue]/@value"/></td>
      </tr>
    </xsl:if>
  </xsl:template>

  <!-- table row for dervited attribute (enumeration) -->
  <xsl:template match="p:Extension[@name='Frequency']" mode="sect3">
    <xsl:if test="position() &lt;= $maxCategoriesToList">
      <xsl:variable name="ext" select="@extender"/>
      <tr>
        <!-- category name -->
        <td>
          <xsl:choose>
            <xsl:when test="$ext = $NullName"><em><xsl:value-of select="$ext"/></em></xsl:when>
            <xsl:otherwise><xsl:value-of select="$ext"/></xsl:otherwise>
          </xsl:choose>
        </td>
        <!-- enumeration -->
        <td><xsl:apply-templates select="../p:row/*[position()=2 and .=$ext]" mode="sect3" /></td>
        <!-- frequence -->
        <td><xsl:value-of select="@value"/></td>
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
        <xsl:when test="position() >1">, </xsl:when>
      </xsl:choose>
      <xsl:value-of select="../*[position()=1]"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>