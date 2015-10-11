<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:p="http://www.dmg.org/PMML-4_0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common"
                xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz"
                xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
                extension-element-prefixes="func exsl"
                exclude-result-prefixes="p xsi keg guha">
  <!-- =========================
       Header with task metadata
       ========================= -->
  <xsl:template match="p:Header">
    <table class="metadata">
      <tr>
        <th scope="row">
          <xsl:copy-of select="keg:translate('Task ID',150)"/>
        </th>
        <td>
          <xsl:value-of select="/p:PMML/guha:AssociationModel/@modelName"/>
          <xsl:value-of select="/p:PMML/guha:SD4ftModel/@modelName"/>
          <xsl:value-of select="/p:PMML/guha:Ac4ftModel/@modelName"/>
          <xsl:value-of select="/p:PMML/guha:CFMinerModel/@modelName"/>
        </td>
      </tr>
      <tr>
        <th scope="row">
          <xsl:copy-of select="keg:translate('Software used',160)"/>
        </th>
        <td>
          <xsl:value-of select="p:Application/@name"/>
          <xsl:if test="p:Extension[@name='subsystem']">
            <xsl:text> - </xsl:text><xsl:value-of select="p:Extension[@name='subsystem']/@value"/>
          </xsl:if>
          <xsl:if test="p:Application/@version">
            (<xsl:value-of select="p:Application/@version"/>)
          </xsl:if>
        </td>
      </tr>
      <tr>
        <th scope="row">
          <xsl:copy-of select="keg:translate('Author',180)"/>
        </th>
        <td>
          <xsl:value-of select="p:Extension[@name='author']/@value"/>
        </td>
      </tr>
    </table>
  </xsl:template>

</xsl:stylesheet>