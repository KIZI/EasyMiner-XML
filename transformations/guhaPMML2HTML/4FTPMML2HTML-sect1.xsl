<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:p="http://www.dmg.org/PMML-4_0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz" xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
  extension-element-prefixes="func exsl"
  exclude-result-prefixes="p xsi keg guha">
  <!-- ============================
       Section 1 - Data description
       ============================ -->
  <xsl:template match="p:DataDictionary" mode="sect1">
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('ColumnList','','start')"/></xsl:comment>
    <!-- tabulka c.1: available columns description: column name, value count, column type -->
    <table class="itable" summary="Tabulka 1: popis dat">
      <tr>
        <th colspan="3"><xsl:copy-of select="keg:translate('Available columns',240)"/></th>
      </tr>
      <tr>
        <th><xsl:copy-of select="keg:translate('Column name',250)"/></th>
        <th><xsl:copy-of select="keg:translate('Number of diffrent values',260)"/></th>
        <th><xsl:copy-of select="keg:translate('Type',270)"/></th>
      </tr>
      <xsl:apply-templates select="p:DataField" mode="sect1"/>
    </table>
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('ColumnList','','end')"/></xsl:comment>
    <!-- dataFieldCount is sum of first column frequencies -->
    <xsl:variable name="dataFieldCount" select="sum(p:DataField[1]/p:Value/p:Extension[@name='Frequency']/@value)"/>
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('RecordCount','','start')"/></xsl:comment>
    <xsl:copy-of select="keg:translate('Number of records',280)"/>:
    <xsl:choose>
      <xsl:when test="$dataFieldCount">
        <xsl:value-of select="$dataFieldCount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$notAvailable"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:comment><xsl:value-of select="keg:getContentBlockTag('RecordCount','','end')"/></xsl:comment>
  </xsl:template>

  <xsl:template match="p:DataField" mode="sect1">
    <tr>
      <!-- column name -->
      <td><xsl:apply-templates select="." mode="odkaz"/></td>
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
      <td><xsl:value-of select="@optype"/></td>
    </tr>
  </xsl:template>

</xsl:stylesheet>