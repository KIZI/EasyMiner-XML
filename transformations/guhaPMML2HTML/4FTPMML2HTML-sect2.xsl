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
    <!-- link name is derived from column name -->
    <section id="sect2-{@name}" class="dataField">
      <xsl:call-template name="keg:ContentBlock" >
        <xsl:with-param name="contentBlockName">ColumnDetail</xsl:with-param>
        <xsl:with-param name="element" select="@name"/>
      </xsl:call-template>

      <h3><xsl:copy-of select="keg:translate('Column',251)"/>: <xsl:value-of select="@name"/></h3>
      <!-- basic info about data field-->
      <xsl:variable name="valueCount" select="count(p:Value)"/>
      <table class="fieldBasicInfo">
        <tr>
          <th scope="row"><xsl:copy-of select="keg:translate('Number of different values',260)"/></th>
          <td>
            <xsl:choose>
              <xsl:when test="$valueCount &gt; 0">
                <xsl:value-of select="$valueCount"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$notAvailable"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
        <tr>
          <th scope="row"><xsl:copy-of select="keg:translate('Type',270)"/></th>
          <td><xsl:value-of select="@optype"/></td>
        </tr>
        <xsl:if test="count(p:Interval)>0">
          <tr>
            <th scope="row"><xsl:copy-of select="keg:translate('Value range',311)"/></th>
            <td><xsl:apply-templates select="p:Interval" mode="sect2"/></td>
          </tr>
        </xsl:if>
        <xsl:variable name="suppStat" select="p:Extension[@name='Min' or @name='Max' or @name='Avg']"/>
        <xsl:if test="$suppStat">
          <xsl:apply-templates select="p:Extension" mode="sect2"/>
        </xsl:if>
      </table>

      <div class="details">
        <!-- table number depends on previous table count -->

          <!-- frequency table is shown only if any frequence exists -->
          <xsl:variable name="nullPresent" select="count(p:Value[@value=$NullName])"/>
          <!-- TODO Standa předělat výpis hodnot... -->
          <xsl:choose>
            <xsl:when test="p:Value">
              <table class="graphTable">
                <tr>
                  <th>
                    <xsl:copy-of select="keg:translate('Value',252)"/>
                  </th>
                  <th>
                    <xsl:copy-of select="keg:translate('Frequency',253)"/>
                  </th>
                </tr>

                <xsl:for-each select="p:Value[@value!=$NullName]">
                  <xsl:sort select="p:Extension/@value" data-type="number" order="descending"/>
                  <xsl:if test="position() &lt;= ($maxValuesToList - $nullPresent) and $maxValuesToList">
                    <!-- apply-templates to p:Value -->
                    <xsl:apply-templates select="self::node()" mode="sect2"/>
                  </xsl:if>
                  <!--TODO součet hodnot v kategorii OTHERS-->
                </xsl:for-each>
                <xsl:if test="$nullPresent>0">
                  <xsl:apply-templates select="p:Value[@value=$NullName]" mode="sect2"/>
                </xsl:if>
              </table>
            </xsl:when>
            <xsl:otherwise>
                <p class="error">
                  <xsl:copy-of select="keg:translate('No detail given for this column',254)"/>
                </p>
            </xsl:otherwise>
          </xsl:choose>

        <xsl:if test="p:Value[position() &gt; $maxValuesToList and $maxValuesToList]">
          <p class="hot">
            <xsl:copy-of select="keg:translate('Exceeded',190)"/>
            maxValuesToList = <xsl:value-of
              select="$maxValuesToList"/>,
            <xsl:copy-of select="keg:translate('first',200)"/>
            <xsl:value-of select="$maxValuesToList"/>
            <xsl:copy-of select="keg:translate('from the total number of',210)"/>
            <xsl:value-of select="count(p:Value)"/>
            <xsl:copy-of select="keg:translate('rules',290)"/>.
          </p>
        </xsl:if>


      </div>
    </section>
  </xsl:template>

  <xsl:template match="p:Interval" mode="sect2">
    <xsl:choose>
      <xsl:when test="@closure='closedOpen' or @closure='closedClosed'"><xsl:copy-of select="keg:translate('[',1)"/></xsl:when>
      <xsl:otherwise>(</xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="@leftMargin"/>;<xsl:value-of select="@rightMargin"/>
    <xsl:choose>
      <xsl:when test="@closure='closedClosed' or @closure='openClosed'"><xsl:copy-of select="keg:translate(']',2)"/></xsl:when>
      <xsl:otherwise>)</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="p:Value" mode="sect2">
    <tr>
      <!-- value -->
      <td class="name">
        <xsl:value-of select="@value"/>
      </td>
      <!-- and its freq -->
      <td class="frequency">
        <xsl:value-of select="p:Extension[@name='Frequency']/@value"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="p:Extension[@name='Min' or @name='Max' or @name='Avg' or @name='StDev']" mode="sect2">
    <tr class="more">
      <th scope="row">
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
        <xsl:copy-of select="keg:translate('value of column',350)"/>:
      </th>
      <td>
        <xsl:value-of select="@value"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="p:DataDictionary" mode="sect2list">
    <!-- tabulka c.1: available columns description: column name, value count, column type -->
    <table>
      <xsl:call-template name="keg:ContentBlock" >
        <xsl:with-param name="contentBlockName">ColumnList</xsl:with-param>
        <xsl:with-param name="element" />
      </xsl:call-template>
      <tr>
        <th scope="col"><xsl:copy-of select="keg:translate('Column name',250)"/></th>
        <th scope="col"><xsl:copy-of select="keg:translate('Number of diffrent values',260)"/></th>
        <th scope="col"><xsl:copy-of select="keg:translate('Type',270)"/></th>
      </tr>
      <xsl:apply-templates select="p:DataField" mode="sect2list"/>
    </table>

    <!-- dataFieldCount is sum of first column frequencies -->
    <xsl:variable name="dataFieldCount" select="sum(p:DataField[1]/p:Value/p:Extension[@name='Frequency']/@value)"/>
    <xsl:copy-of select="keg:translate('Number of records',280)"/>:
    <xsl:choose>
      <xsl:when test="$dataFieldCount">
        <xsl:value-of select="$dataFieldCount"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$notAvailable"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="p:DataField" mode="sect2list">
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
