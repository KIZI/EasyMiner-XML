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
    <section id="sect3-{$DerivedFieldName}" class="attribute">
      <h3><xsl:copy-of select="keg:translate('Attribute',360)"/>: <xsl:value-of select="p:Discretize/@field | p:MapValues/@outputColumn"/></h3>

      <table class="fieldBasicInfo">
        <tr>
          <th scope="row"><xsl:copy-of select="keg:translate('derived from column',370)" /></th>
          <!-- DataField mode=odkaz is in 4FTPMML2HTML-toc.xsl -->
          <td>
            <xsl:variable name="sourceDataField" select="p:Discretize/@field | p:MapValues/p:FieldColumnPair/@column"/>
            <xsl:apply-templates select="/p:PMML/p:DataDictionary/p:DataField[@name=$sourceDataField]" mode="odkaz" />
          </td>
        </tr>
        <tr>
          <th scope="row"><xsl:copy-of select="keg:translate('Attribute type',361)" /></th>
          <td><xsl:value-of select="@optype" /></td>
        </tr>
        <tr>
          <th scope="row"><xsl:copy-of select="keg:translate('Number of categories',362)" /></th>
          <td><xsl:value-of select="$numOfCategories" /></td>
        </tr>
      </table>

      <div class="details">
        <table class="graphTable" id="sect3-graphTable-{$DerivedFieldName}">
          <tr>
            <th scope="col"><xsl:copy-of select="keg:translate('Category',380)"/></th>
            <th scope="col">
              <xsl:choose>
                <xsl:when test="p:Discretize"><xsl:copy-of select="keg:translate('Interval',390)"/></xsl:when>
                <xsl:when test="p:MapValues"><xsl:copy-of select="keg:translate('Enumeration',400)"/></xsl:when>
              </xsl:choose>
            </th>
            <th scope="col"><xsl:copy-of select="keg:translate('Frequency',253)"/></th>
          </tr>
          <!-- table row depends to attribute is derived (MapValues) or not (Discretize) -->
          <xsl:apply-templates select="p:Discretize/p:DiscretizeBin | p:MapValues/p:InlineTable/p:Extension[@name='Frequency']" mode="sect3"/>
          <!-- frequency of other values -->
          <xsl:if test="$numOfCategories > $maxCategoriesToList">
            <tr>
              <td colspan="2" class="name others"><xsl:copy-of select="keg:translate('Other categories',801)" /> (<xsl:value-of select="($numOfCategories - $maxCategoriesToList)" />)</td>
              <td class="frequency">
                <xsl:choose>
                  <xsl:when test="p:MapValues/p:InlineTable">
                    <xsl:value-of select="sum(p:MapValues/p:InlineTable/p:Extension[@name='Frequency'][position() &gt; $maxCategoriesToList]/@value)" />
                  </xsl:when>
                  <xsl:when test="p:Discretize/p:DiscretizeBin" >
                    <xsl:value-of select="sum(p:Discretize/p:DiscretizeBin[position() &gt; $maxCategoriesToList]/p:Extension[@name='Frequency' and @extender=../@binValue]/@value)" />
                  </xsl:when>
                </xsl:choose>
              </td>
            </tr>
          </xsl:if>
        </table>
        <xsl:if test="$numOfCategories > $maxCategoriesToList">
          <p class="warning">
            <xsl:copy-of select="keg:translate('Exceeded',190)"/> maxCategoriesToList = <xsl:value-of select="$maxCategoriesToList"/>, <xsl:copy-of select="keg:translate('first',200)"/> <xsl:value-of select="$maxCategoriesToList"/> <xsl:copy-of select="keg:translate('from the total number of',210)"/> <xsl:value-of select="$numOfCategories"/> <xsl:copy-of select="keg:translate('categories',290)"/>.
          </p>
        </xsl:if>
      </div>

    </section>
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DerivedFieldDetail',$DerivedFieldName,'start')"/></xsl:comment>

    <!-- link name is derived from field name -->
    <xsl:variable name="tabs" select="count(/p:PMML/p:DataDictionary/p:DataField)"/>
    <!-- table number depends on previous table count -->
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('DerivedFieldDetail',$DerivedFieldName,'end')"/></xsl:comment>
  </xsl:template>

  <!-- table row for non-derived attribute (interval) -->
  <xsl:template match="p:DiscretizeBin" mode="sect3">
    <xsl:if test="position() &lt;= $maxCategoriesToList">
      <tr>
        <!-- category name -->
        <td class="name"><xsl:value-of select="@binValue"/></td>
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
        <td class="frequency"><xsl:value-of select="../p:Extension[@name='Frequency' and @extender=current()/@binValue]/@value"/></td>
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
            <xsl:when test="$ext = $NullName"><em><xsl:value-of select="$ext"/></em></xsl:when>
            <xsl:otherwise><xsl:value-of select="$ext"/></xsl:otherwise>
          </xsl:choose>
        </td>
        <!-- enumeration -->
        <td><xsl:apply-templates select="../p:row/*[position()=2 and .=$ext]" mode="sect3" /></td>
        <!-- frequence -->
        <td class="frequency"><xsl:value-of select="@value"/></td>
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