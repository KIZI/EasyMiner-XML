<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:p="http://www.dmg.org/PMML-4_0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions"
  xmlns:keg="http://keg.vse.cz" xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
  extension-element-prefixes="func exsl" exclude-result-prefixes="p xsi keg guha">
  <!-- ============================
       Section 2 - Data description
       ============================ -->
  <xsl:template match="p:DataDictionary" mode="sect2">
    <xsl:apply-templates select="p:DataField" mode="sect2"/>
  </xsl:template>

  <xsl:template match="p:DataField" mode="sect2">
    <xsl:comment>
      <xsl:value-of select="keg:getContentBlockTag('ColumnDetail',@name,'start')"/>
    </xsl:comment>
    <xsl:variable name="cat" select="count(p:Value)"/>
    <!-- link name is derived from column name -->
    <div class="idiv" id="sect2-{@name}">
      <!-- table number depends on previous table count -->
      <table class="itable" summary="Freqency Table: sloupec {@name}">
        <tr>
          <th colspan="2">
            <xsl:copy-of select="keg:translate('Column',251)"/>
            <xsl:value-of select="@name"/>
          </th>
        </tr>
        <tr>
          <th>
            <xsl:copy-of select="keg:translate('Value',252)"/>
          </th>
          <th>
            <xsl:copy-of select="keg:translate('Frequency',253)"/>
          </th>
        </tr>
        <!-- frequency table is shown only if any frequence exists -->
        <xsl:variable name="nullPresent" select="count(p:Value[@value=$NullName])"/>
        <xsl:choose>
          <xsl:when test="p:Value">
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
          </xsl:when>
          <xsl:otherwise>
            <tr>
              <td colspan="2">
                <xsl:copy-of select="keg:translate('No detail given for this column',254)"/>
              </td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
      </table>
      <xsl:if test="p:Value[position() &gt; $maxValuesToList and $maxValuesToList]">
        <p class="hot">
          <xsl:copy-of select="keg:translate('Exceeded',190)"/> maxValuesToList = <xsl:value-of
            select="$maxValuesToList"/>, <xsl:copy-of select="keg:translate('first',200)"/>
          <xsl:value-of select="$maxValuesToList"/>
          <xsl:copy-of select="keg:translate('from the total number of',210)"/>
          <xsl:value-of select="count(p:Value)"/>
          <xsl:copy-of select="keg:translate('rules',290)"/>. </p>
      </xsl:if>
      <xsl:apply-templates select="p:Interval" mode="sect2"/>
      <xsl:variable name="suppStat" select="p:Extension[@name='Min' or @name='Max' or @name='Avg']"/>
      <xsl:if test="$suppStat">
        <strong><xsl:copy-of select="keg:translate('Supplemental statistics',310)"/>:</strong>
        <ul>
          <xsl:apply-templates select="p:Extension" mode="sect2"/>
        </ul>
      </xsl:if>
    </div>
    <xsl:comment>
      <xsl:value-of select="keg:getContentBlockTag('ColumnDetail',@name,'end')"/>
    </xsl:comment>
  </xsl:template>

  <xsl:template match="p:Interval" mode="sect2">
    <p>
      <strong><xsl:copy-of select="keg:translate('Value range',311)"/>:</strong>
      <xsl:choose>
        <xsl:when test="@closure='closedOpen' or @closure='closedClosed'">&lt;</xsl:when>
        <xsl:otherwise>(</xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="@leftMargin"/>;<xsl:value-of select="@rightMargin"/>
      <xsl:choose>
        <xsl:when test="@closure='closedClosed' or @closure='openClosed'">&gt;</xsl:when>
        <xsl:otherwise>)</xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:template>

  <xsl:template match="p:Value" mode="sect2">
    <tr>
      <!-- value -->
      <td>
        <xsl:value-of select="@value"/>
      </td>
      <!-- and its freq -->
      <td>
        <xsl:value-of select="p:Extension[@name='Frequency']/@value"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="p:Extension[@name='Min' or @name='Max' or @name='Avg' or @name='StDev']"
    mode="sect2">
    <li>
      <xsl:choose>
        <xsl:when test="@name='Min'">
          <xsl:copy-of select="keg:translate('Minimum',320)"/>
        </xsl:when>
        <xsl:when test="@name='Max'">
          <xsl:copy-of select="keg:translate('Maximum',330)"/>
        </xsl:when>
        <xsl:when test="@name='Avg'">
          <xsl:copy-of select="keg:translate('Average',340)"/>
        </xsl:when>
        <xsl:when test="@name='StDev'">
          <xsl:copy-of select="keg:translate('StDev',342)"/>
        </xsl:when>
      </xsl:choose>
      <xsl:copy-of select="keg:translate('value of column',350)"/>: <em><xsl:value-of
          select="@value"/></em>
    </li>
  </xsl:template>

</xsl:stylesheet>
