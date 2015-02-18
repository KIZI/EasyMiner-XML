<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:p="http://www.dmg.org/PMML-4_0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz" xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
  extension-element-prefixes="func exsl"
  exclude-result-prefixes="p xsi keg guha">
  <!-- =========================
       Header with task metadata
       ========================= -->
  <xsl:template match="p:Header">
      <table id="metadata" summary="Metadata ulohy">
          <tr>
              <th colspan="2"><xsl:copy-of select="keg:translate('Task Metadata',140)"/></th>
          </tr>
          <tr>
              <td align="right"><xsl:copy-of select="keg:translate('Task ID',150)"/>: </td>
              <td><i><xsl:value-of select="/p:PMML/guha:AssociationModel/@modelName"/>
                  <xsl:value-of select="/p:PMML/guha:SD4ftModel/@modelName"/>
                  <xsl:value-of select="/p:PMML/guha:Ac4ftModel/@modelName"/>
                  <xsl:value-of select="/p:PMML/guha:CFMinerModel/@modelName"/>
              </i></td>
          </tr>
          <tr>
              <td align="right"><xsl:copy-of select="keg:translate('Software used',160)"/>: </td>
              <td><xsl:value-of select="p:Application/@name"/></td>
          </tr>
          <tr>
              <td align="right"><xsl:copy-of select="keg:translate('Version',170)"/>: </td>
              <td><xsl:value-of select="p:Application/@version"/></td>
          </tr>
          <tr>
              <td align="right"><xsl:copy-of select="keg:translate('Author',180)"/>: </td>
              <td><xsl:value-of select="p:Extension[@name='author']/@value"/></td>
          </tr>
          <tr>
              <td align="right"><xsl:copy-of select="keg:translate('Visualization XSLT Version',810)"/>: </td>
              <td><xsl:value-of select="$thisFileVersion"/></td>
          </tr>
          <tr>
              <td align="right"><xsl:copy-of select="keg:translate('Normalization XSLT Version',820)"/>: </td>
              <td><xsl:value-of select="p:Extension[@name='NormalizedBy']/@value"/></td>
          </tr>
          <tr>
              <td align="right"><xsl:copy-of select="keg:translate('Normalization Dictionary Version',830)"/>: </td>
              <td><xsl:value-of select="p:Extension[@name='NormalizationDictionary']/@value"/></td>
          </tr>
          <tr>
              <td align="right"><xsl:copy-of select="keg:translate('Export template version',835)"/>: </td>
              <td><xsl:value-of select="p:Extension[@name='version']/@value"/></td>
          </tr>
      </table>
  </xsl:template>

</xsl:stylesheet>