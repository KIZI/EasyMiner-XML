<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:p="http://www.dmg.org/PMML-4_0" exclude-result-prefixes="p">
  <xsl:param name="reportLang"/>
  <xsl:variable name="otherCategoryName">
    <xsl:choose>
      <xsl:when test="$reportLang = 'cs'">Ostatní</xsl:when>
      <xsl:otherwise>Other</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:param name="imgScript" select="'xml/libraries/phpgraphlib/genBarChart.php'"/>
  <xsl:param name="urlSeparator" select="'@@'"/>
  <!-- if set to 1, columns in graphs will be sorted from the highest to the lowest value-->
  <xsl:param name="sortByValue" select="1"/>
  <xsl:param name="sortOrder" select="'ascending'"/>

  <!-- main template -->
  <xsl:template name="drawHistogram">

    <xsl:variable name="graphType">
      <xsl:choose>
        <xsl:when test="local-name()='DerivedField'">
          <xsl:value-of select="./@optype" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'categorical'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$graphType = 'continuous' or $graphType = 'categorical' or $graphType = 'ordinal'">
        <xsl:call-template name="includeIMG">
          <xsl:with-param name="graphType" select="$graphType"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <strong>Graphs available only for continuous, categorical and ordinal variables</strong>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="includeIMG">
    <xsl:param name="graphType"/>
    <xsl:variable name="yAxisTitle" select="'Values'" />
    <xsl:variable name="xAxisTitle" select="'Frequency'" />

    <xsl:variable name="sumOfCategories">
      <xsl:choose>
        <xsl:when test="local-name()='DerivedField'">
          <xsl:choose>
            <xsl:when test="$graphType='continuous'">
              <xsl:value-of select="sum(./p:Discretize/p:Extension/@value)"/>
            </xsl:when>
            <xsl:when test="$graphType='categorical' or $graphType='ordinal'">
              <xsl:value-of select="sum(./p:MapValues/p:InlineTable/p:Extension[@name='Frequency']/@value)"/>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="sum(./Frequencies/Frequency/@value)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="numberOfCategories">
      <xsl:choose>
        <xsl:when test="local-name()='DerivedField'">
          <xsl:choose>
            <xsl:when test="$graphType='continuous'">
              <xsl:value-of select="count(./p:Discretize/p:Extension[@name='Frequency'])"/>
            </xsl:when>
            <xsl:when test="$graphType='categorical' or $graphType='ordinal'">
              <xsl:value-of select="count(./p:MapValues/p:InlineTable/p:Extension[@name='Frequency'])"/>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="count(./Frequencies/Frequency)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="title" select="./p:Discretize/@field | ./p:MapValues/@outputColumn | ./Text"/>

    <xsl:variable name="values">
      <xsl:apply-templates mode="graphValue" select="./p:Discretize/p:Extension[@name='Frequency'] | ./p:MapValues/p:InlineTable/p:Extension[@name='Frequency'] | ./Frequencies/Frequency">
        <xsl:with-param name="graphType" select="$graphType"></xsl:with-param>
        <xsl:with-param name="numberOfCategories" select="$numberOfCategories"></xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="labels">
      <xsl:apply-templates mode="graphLabel" select="./p:Discretize/p:Extension[@name='Frequency'] | ./p:MapValues/p:InlineTable/p:Extension[@name='Frequency'] | ./Frequencies/Frequency">
        <xsl:with-param name="graphType" select="$graphType"></xsl:with-param>
        <xsl:with-param name="numberOfCategories" select="$numberOfCategories"></xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <!-- image src link -->
    <xsl:variable name="path"><xsl:value-of select="$imgScript"/>?title=<xsl:value-of select="$title"/>&amp;xaxis=<xsl:value-of select="$xAxisTitle"/>&amp;yaxis=<xsl:value-of select="$yAxisTitle"/>&amp;from=0&amp;num=<xsl:value-of select="$maxCategoriesToListInGraphs"/>&amp;other=<xsl:value-of select="$otherCategoryName"/>&amp;val=<xsl:value-of select="$values"/>&amp;lab=<xsl:value-of select="$labels"/></xsl:variable>
    <xsl:variable name="pathUrlEncoded" select="translate($path,' ','-')"/>

    <xsl:variable name="grDebug">sumOfCategories=<xsl:value-of select="$sumOfCategories"/>
numberOfCategories=<xsl:value-of select="$numberOfCategories"/>
title=<xsl:value-of select="$title"/>
values=<xsl:value-of select="$values"/>
labels=<xsl:value-of select="$labels"/>
    </xsl:variable>

    <img src="{$pathUrlEncoded}" alt="{$title}" title="{$grDebug}"/>
  </xsl:template>

  <xsl:template match="p:Extension[@name='Frequency'] | Frequency" mode="graphValue">
    <xsl:param name="graphType"/>
    <xsl:param name="numberOfCategories"/>
    <xsl:variable name="value">
      <xsl:if test="$graphType='continuous' or $graphType='categorical' or $graphType='ordinal'">
        <xsl:value-of select="@value"/>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="$value"/>
    <xsl:if test="position() &lt; $numberOfCategories"><xsl:value-of select="$urlSeparator"/></xsl:if>
  </xsl:template>

  <xsl:template match="p:Extension[@name='Frequency'] | Frequency" mode="graphLabel">

    <xsl:param name="graphType"/>
    <xsl:param name="numberOfCategories"/>
    <xsl:variable name="barTitle">
      <xsl:choose>
        <xsl:when test="$graphType='continuous'">
          <xsl:variable name="closure" select="../p:DiscretizeBin[@binValue=current()/@extender]/p:Interval/@closure"></xsl:variable>
          <xsl:variable name="rightMargin" select="../p:DiscretizeBin[@binValue=current()/@extender]/p:Interval/@rightMargin"></xsl:variable>
          <xsl:variable name="leftMargin" select="../p:DiscretizeBin[@binValue=current()/@extender]/p:Interval/@leftMargin"></xsl:variable>
          <xsl:choose>
            <xsl:when test="$closure= 'closedClosed'">
              <xsl:value-of select="concat ('&lt;', $leftMargin, ';', $rightMargin, '&gt;')"/>
            </xsl:when>
            <xsl:when test="$closure= 'closedOpen'">
              <xsl:value-of select="concat ('&lt;', $leftMargin, ';', $rightMargin, ')')"/>
            </xsl:when>
            <xsl:when test="$closure= 'openClosed'">
              <xsl:value-of select="concat ('(', $leftMargin, ';', $rightMargin, '&gt;')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat ('(', $leftMargin, ';', $rightMargin, ')')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$graphType='categorical' or $graphType='ordinal'">
          <xsl:value-of select="@extender | @category"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
  <xsl:value-of select="$barTitle"/>
  <xsl:if test="position() &lt; $numberOfCategories"><xsl:value-of select="$urlSeparator"/></xsl:if>
  </xsl:template>

</xsl:stylesheet>
