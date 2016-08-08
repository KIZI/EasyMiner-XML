<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:p="http://www.dmg.org/PMML-4_3"
                xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz"
                exclude-result-prefixes="p keg">

    <xsl:param name="contentOnly" select="false()"/>
    <xsl:param name="loadJQuery" select="true()"/>
    <xsl:param name="basePath" select="'./guhaPMML2HTML'"/><!--TODO-->
    <xsl:param name="notOperator" select="' &#x00AC;'"/>
    <xsl:param name="andOperator" select="' &amp; '"/>
    <xsl:param name="emptyAntecedent" select="' * '"/>
    <xsl:param name="ruleOperator" select="' -&gt; '"/>

    <xsl:param name="reportLang" select="'en'"/>

    <xsl:output method="html" encoding="UTF-8"/>

    <!-- Obsahuje slovnik pojmu generovanych xslt transformaci v ruznych jazycich-->
    <xsl:variable name="LocalizationDictionary" select="document('../guhaPMML2HTML/dict/LocalizationDictionary.xml')"/>
    <xsl:include href="../guhaPMML2HTML/lib/localization-lib.xsl"/>

    <!-- region Transformation root - everyting begins here -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$contentOnly">
                <xsl:call-template name="resources"/>
                <xsl:apply-templates select="/p:PMML"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"&gt;</xsl:text>
                <html>
                    <head>
                        <xsl:call-template name="resources"/>
                        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                        <title>
                            <xsl:text>Description of Data Mining Task</xsl:text>
                        </title>
                    </head>
                    <body>
                        <xsl:apply-templates select="/p:PMML"/>
                    </body>
                </html>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--endregion-->

    <xsl:template name="resources">
        <xsl:param name="loadJquery" select="true()"/>
        <xsl:param name="navigationCSS" select="true()"/>
        <style>
            @import url('<xsl:value-of select="$basePath"/>/css/main.css');
            <xsl:if test="$navigationCSS">
                @import url('<xsl:value-of select="$basePath"/>/css/navigation.css');
            </xsl:if>
            <xsl:if test="not($contentOnly)">
                @import url('<xsl:value-of select="$basePath"/>/css/page.css');
            </xsl:if>
        </style>
        <xsl:if test="$loadJquery">
            <script type="text/javascript" src="{$basePath}/js/jquery-1.11.3.min.js"></script>
        </xsl:if>
        <xsl:if test="not($contentOnly)">
            <script type="text/javascript" src="{$basePath}/js/page.js"></script>
        </xsl:if>
        <script type="text/javascript" src="{$basePath}/js/main.js"></script>
        <script type="text/javascript" src="{$basePath}/js/chart.js/Chart.js"></script>
    </xsl:template>


    <xsl:template match="p:PMML">
        <xsl:apply-templates select="p:AssociationModel[@functionName='associationRules']"/>
    </xsl:template>

    <xsl:template match="p:AssociationModel">
        <section id="sect5" data-ginclude-id="DiscoveredARs" data-ginclude-level="0"
                 data-ginclude-title="{keg:translate('Founded association rules')}">
            <h2>
                <xsl:copy-of select="keg:translate('Founded association rules')"/>
            </h2>
            <xsl:apply-templates select="p:AssociationRule"/>
        </section>
    </xsl:template>

    <xsl:template match="p:Item" mode="name">
        <xsl:choose>
            <xsl:when test="p:Extension[@name='field']">
                <xsl:value-of select="p:Extension[@name='field']/@value"/>
                <xsl:text>(</xsl:text>
                <xsl:for-each select="p:Extension[@name='value']">
                    <xsl:if test="position()>1"><xsl:text>, </xsl:text></xsl:if>
                    <xsl:value-of select="@value"/>
                </xsl:for-each>
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="p:Itemset" mode="name">
        <xsl:for-each select="p:ItemRef">
            <xsl:if test="position()>1"><xsl:value-of select="$andOperator"/></xsl:if>
            <xsl:variable name="id" select="text()"/>
            <xsl:apply-templates select="../../p:Item[@id=$id]" mode="name"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="p:AssociationRule" mode="name">
        <xsl:choose>
            <xsl:when test="@antecedent">
                <xsl:variable name="cedentId" select="@antecedent"/>
                <xsl:apply-templates select="../p:Itemset[@id=$cedentId]" mode="name"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$emptyAntecedent"/></xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$ruleOperator"/>
        <xsl:variable name="cedentId" select="@consequent"/>
        <xsl:apply-templates select="../p:Itemset[@id=$cedentId]" mode="name"/>
    </xsl:template>

    <xsl:template match="p:AssociationRule">
        <xsl:variable name="rulePos" select="position()"/>
        <xsl:variable name="ruleClass">
            <xsl:choose>
                <xsl:when test="./Extension[@name='mark']/@value='interesting'">selectedRule</xsl:when>
                <xsl:otherwise>otherRule</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <section id="sect5-rule{$rulePos}" class="foundRule {$ruleClass}">
            <h3><xsl:apply-templates select="." mode="name" /></h3>
            <div class="imValues">
                <h4>
                    <xsl:copy-of select="keg:translate('Interest measure values', 840)"/>
                </h4>
                <table class="imValuesTable">
                    <tr>
                        <th>
                            <xsl:copy-of select="keg:translate('Interest Measure',590)"/>
                        </th>
                        <th>
                            <xsl:copy-of select="keg:translate('Value',252)"/>
                        </th>
                    </tr>
                    <xsl:if test="@confidence">
                        <tr>
                            <td class="name">Confidence</td>
                            <td class="value"><xsl:value-of select="@confidence"/></td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="@support">
                        <tr>
                            <td class="name">Support</td>
                            <td class="value"><xsl:value-of select="@support"/></td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="@lift">
                        <tr>
                            <td class="name">Lift</td>
                            <td class="value"><xsl:value-of select="@lift"/></td>
                        </tr>
                    </xsl:if>
                </table>
            </div>

            <xsl:if test="p:Extension[@name='a']">
                <div class="fourFtTable">
                    <xsl:copy-of select="keg:translate('Four field contingency table',13)"/>
                    <xsl:call-template name="FourFieldTable">
                        <xsl:with-param name="a" select="p:Extension[@name='a']/@value"/>
                        <xsl:with-param name="b" select="p:Extension[@name='b']/@value"/>
                        <xsl:with-param name="c" select="p:Extension[@name='c']/@value"/>
                        <xsl:with-param name="d" select="p:Extension[@name='d']/@value"/>
                    </xsl:call-template>
                </div>
            </xsl:if>

        </section>
    </xsl:template>


    <!-- fourfield table -->
    <xsl:template name="FourFieldTable">
        <!-- a-d = extender values -->
        <xsl:param name="a"/>
        <xsl:param name="b"/>
        <xsl:param name="c"/>
        <xsl:param name="d"/>

        <table class="fourFtTable">
            <tr>
                <th class="empty"></th>
                <th>
                    <xsl:copy-of select="keg:translate('Consequent',600)"/>
                </th>
                <th>
                    <xsl:value-of select="$notOperator"/>
                    <!-- NOT -->
                    <xsl:copy-of select="keg:translate('Consequent',600)"/>
                </th>
            </tr>
            <tr>
                <th>
                    <xsl:copy-of select="keg:translate('Antecedent',610)"/>
                </th>
                <td class="a">
                    <xsl:value-of select="$a"/>
                </td>
                <td class="b">
                    <xsl:value-of select="$b"/>
                </td>
            </tr>
            <tr>
                <th>
                    <xsl:value-of select="$notOperator"/>
                    <!-- NOT -->
                    <xsl:copy-of select="keg:translate('Antecedent',610)"/>
                </th>
                <td class="c">
                    <xsl:value-of select="$c"/>
                </td>
                <td class="d">
                    <xsl:value-of select="$d"/>
                </td>
            </tr>
        </table>
    </xsl:template>
</xsl:stylesheet>