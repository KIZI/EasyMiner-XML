<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions"
                xmlns:keg="http://keg.vse.cz"
                extension-element-prefixes="func exsl"
                exclude-result-prefixes="keg">
  <!-- MASTER COPY OF THIS TEMPLATE IS LOCATED AT https://github.com/KIZI/EasyMiner-XML -->

  <!-- When including to other stylesheet, set the $ContentTagsDictionary variable first -->

  <!-- Funkce generujici tagy pro markovani obsahu -->
  <func:function name="keg:getContentBlockID">
    <xsl:param name="contentBlockName"/>
    <!-- parametr element je  volitelný a používá se pro odlišení vícero bloků stejného typu (např. atributů)-->
    <xsl:param name="element"/>
    <!-- gInclude{"level":"0","title":"Název zobrazovaný ve výběru","id":"IDčko"} -->
    <xsl:variable name="BaseblockID"
                  select="exsl:node-set($ContentTagsDictionary)/ContentTagsDictionary/Entry[name=$contentBlockName]/IDbase"></xsl:variable>
    <xsl:choose>
      <xsl:when test="$BaseblockID and $element">
        <!-- hodnota elementu v id ma dva vyznamy: jedna, umoznuje odliseni bloku stejneho typu,
            a dale umoznuje aplikaci zjistit, zda se stejny blok nachazi v aktualizovanem PMML.
            Napr. id asociacniho pravidla 'AR3' by sice plnilo prvni funkci, ale nikoliv druhou,
            zato 'AR - vek(stredni) -> zdravi(pevne) plni obe funkce.'
        -->
        <xsl:variable name="unescaped" select="concat($BaseblockID,'_',$element)"/>
        <!--  ESCAPING -->
        <xsl:variable name="upperCaseChars" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ&amp;?+≈⇑⇒⇔≡*〈&#9002;&#8776;'"/>
        <xsl:variable name="lowerCaseChars" select="'abcdefghijklmnopqrstuvwxyz____________'"/>
        <xsl:variable name="uCaseCharsPlus" select="concat($upperCaseChars,  &quot; &quot;)"/>
        <xsl:variable name="lCaseCharsPlus" select="concat($lowerCaseChars, '')"/>
        <func:result select="translate($unescaped, $uCaseCharsPlus, $lCaseCharsPlus)"/>
      </xsl:when>
      <xsl:when test="$BaseblockID and not($element)">
        <func:result select="$BaseblockID"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="concat('BaseBlockIDNotFound','_',$element)"/>
      </xsl:otherwise>
    </xsl:choose>
  </func:function>

  <xsl:template name="keg:ContentBlock">
    <xsl:param name="contentBlockName"/>
    <xsl:param name="element"/>

    <xsl:variable name="BlockID"/>
    <!-- Title will contain the element parametr only if this is allowed for this entity type - the @append attribute exists-->
    <xsl:attribute name="data-ginclude-title">
      <xsl:choose>
        <xsl:when
            test="exsl:node-set($ContentTagsDictionary)/ContentTagsDictionary/Entry[name=$contentBlockName]/Title/@append=1">
          <xsl:value-of
              select="concat(exsl:node-set($ContentTagsDictionary)/ContentTagsDictionary/Entry[name=$contentBlockName]/Title,$element)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of
              select="exsl:node-set($ContentTagsDictionary)/ContentTagsDictionary/Entry[name=$contentBlockName]/Title"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="data-ginclude-level">
      <xsl:value-of
          select="exsl:node-set($ContentTagsDictionary)/ContentTagsDictionary/Entry[name=$contentBlockName]/Level"/>
    </xsl:attribute>
    <xsl:attribute name="data-ginclude-id">
      <xsl:value-of select="keg:getContentBlockID($contentBlockName, $element)"/>
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>
