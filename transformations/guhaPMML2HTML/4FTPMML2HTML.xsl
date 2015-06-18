<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:p="http://www.dmg.org/PMML-4_0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz" xmlns:guha="http://keg.vse.cz/ns/GUHA0.1rev1"
  extension-element-prefixes="func exsl"
  exclude-result-prefixes="p xsi keg guha">

  <xsl:import href="graph.xsl" />
  <xsl:import href="quantifier_transformations.xsl" />
  <xsl:import href="transformPMMLARtoQueryByAssociationRule.xsl" />
  
  <xsl:import href="4FTPMML2HTML-main.xsl" />
  <xsl:import href="4FTPMML2HTML-header.xsl" />
  <xsl:import href="4FTPMML2HTML-toc.xsl" />
  <xsl:import href="4FTPMML2HTML-sect2.xsl" /><!-- Data description   -->
  <xsl:import href="4FTPMML2HTML-sect3.xsl" /><!-- Created attributes -->
  <xsl:import href="4FTPMML2HTML-sect4.xsl" /><!-- Data Mining Task Setting -->
  <xsl:import href="4FTPMML2HTML-sect5.xsl" /><!-- Discovered ARs -->
  
  
  
  <!-- POZOR NA XSL INCLUDE/IMPORT -->
  <!-- Zrejme z duvodu nejakeho bugu ve verzi PHP5 na webhosting.vse.cz nefunguje spravne xsl:include - jako base se nebere adresar ve kterem je includujici styl, ale root virtualniho web serveru -->
  <xsl:variable name="thisFileVersion">0.4</xsl:variable>

  <!-- exsl umoznuje zpracovani parametru s nodeset obsahem pomoci funkce node-set(param). Neni to treba v XSLT 2.0, ale nas transformacni PHP engine XSLT 2.0 nepodporuje-->

  <!-- pro HTML validni dokument je potreba doplnit k <xsl:output/> atribut
   doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
   v pripade generovani v rezimu contentOnly je naopak tento atribut naobtiz
  -->
  <xsl:output method="html" encoding="UTF-8"/>

  <!-- Parametr maxValuesToList omezuje pocet kategorii (hodnot sloupce), ktere mohou byt v 2. oddilu vypsany.
   Pokud pocet kategorii prekroci hodnotu parametru je vypsano varovani. -->
  <xsl:param name="maxValuesToList" select="100"/>

  <!-- Maximalni pocet vyisovancyh kategorii do tabulek popisujicich transformace vstupnich sloupcu na atributy -->
  <xsl:param name="maxCategoriesToList" select="100"/>
  <!-- Parametr maxRulesToList omezuje pocet pravidel, ktere mohou byt v vypsany.
      Pokud pocet pravidel prekroci hodnotu parametru je vypsano varovani.
  Hodnoty jsou serazeny podle frekvenci, vypisi se tedy pouze ty nejcastejsi
  -->
  <xsl:param name="maxRulesToList" select="1000"/>
  <!-- maximal number of items to show in graph -->
  <xsl:param name="maxCategoriesToListInGraphs" select="100"/>
  <!-- Parametr contentOnly slouzi k potlaceni generovani hlavicky HTML a elementu html, head a body.
   V pripade, ze je atribut nastaven, vygeneruje se jen obsah elementu body pro pouziti ve slozitejsich dokumentech.
   Pravidla jsou vypisovana na zaklade jejich poradi v PMML souboru
  -->
  <xsl:param name="contentOnly" select="1"/>
  <!-- Parametry pro nastaveni znaku nebo retezce znaku reprezentujiciho logicke operatory -->
  <!-- vychozi nastaveni:
  NOT   = '&#x00AC;'
  AND   = '&amp;'
  OR    = '&#x2228;'
  IMPLY = ' &#x21D2; '
  -->
  <xsl:param name="NullName" select="'Null'"/>
  <xsl:param name="notOperator" select="' &#x00AC;'"/>
  <xsl:param name="andOperator" select="' &amp; '"/> <!-- &#x02227; -->
  <xsl:param name="orOperator" select="' &#x02228; '"/>
  <xsl:param name="implyOperator" select="' &#x021D2; '"/>
  <xsl:param name="notAvailable" select="'NA'"/>
  <xsl:param name="reportLang" select="'cs'"/>
  <!-- Polozky Support a Confidence jsou systemove, pouzivaji se pro preklad nazvu povinnych PMML atributu -->

  <!-- MASTER COPY OF INCLUDED TEMPLATES IS LOCATED AT
      sewebar-cms/Specifications/XSLLibraries/
  -->

  <!-- Obsahuje slovnik pojmu generovanych xslt transformaci v ruznych jazycich-->
  <xsl:variable name="LocalizationDictionary" select="document('pmml/dict/PMMLDictionary.xml')"/>

  <!-- Obsahuje lokalizaci znacek vkladanych pro gInclude (nadpisy pro fragmenty dokumentu)-->
  <xsl:variable name="ContentTagsDictionary" select="document('pmml/dict/PMMLContentTagsDictionary.xml')"/>

  <xsl:include href="includes.xsl"/>

<!-- ===========================================
     Transformation root - everyting begins here
     =========================================== -->
  <xsl:template match="/p:PMML">
    <xsl:choose>
      <xsl:when test="$contentOnly">
        <xsl:apply-templates select="/p:PMML" mode="body"/>
      </xsl:when>
      <xsl:otherwise>
        <html>
          <head>
            <!--TODO připojení stylů a skriptů-->
            <title><xsl:value-of select="/p:PMML/guha:AssociationModel/@modelName | /p:PMML/guha:SD4ftModel/@modelName | /p:PMML/guha:Ac4ftModel/@modelName | /p:PMML/guha:CFMinerModel/@modelName"/> - <xsl:copy-of select="keg:translate('Description of Data Mining Task',10)"/></title>
            <link rel="stylesheet" type="text/css" href="design.css"/>
          </head>
          <body>
            <!-- uses: 4FTPMML2HTML-main -->
            <xsl:apply-templates select="/p:PMML" mode="body"/>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- Tomas Kliegr, 2009, klit01@vse.cz -->
<!-- Vojtech Jirkovsky, 2008, 2010, jirkovoj@fit.cvut.cz -->
<!-- Stanislav Vojir, 2015, stanislav.vojir@vse.cz -->
</xsl:stylesheet>