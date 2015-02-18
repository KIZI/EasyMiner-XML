<?xml version="1.0" encoding="UTF-8"?>
<!--
    BKEF 1.0 ~ XSLT 1.0
    Background knowledge - visualisation of data matrix, particular attributes and their relationships
    
    Author: Daniel Stastny
            daniel@realmind.org
    Date:   10/2009
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ds="http://keg.vse.cz/bkef"
	xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions" xmlns:keg="http://keg.vse.cz"
	extension-element-prefixes="func exsl" exclude-result-prefixes="keg ds" version="1.0">


	<!-- **** IMPORTANT SETTINGS **** -->
	<xsl:output method="html" encoding="UTF-8" version="1.0" indent="yes"/>

	<!-- ROOT -->
	<!-- csspath is used only if header is created (contentOnly=1) -->
	<!-- otherwise, the css should be automatically loaded, from something like
		templates/rhuk_milkyway/css
	-->
	<xsl:param name="csspath" select="'xml/bkef/css/'"/>
	<xsl:param name="jspath" select="'xml/bkef/js/'"/>
	<xsl:param name="image-url" select="'xml/bkef/img/'"/>        
    
	<!-- LANGUAGE -->
	<!-- en | cs -->
<xsl:param name="reportLang" select="'cs'"/>
	
	 
	
	
	<!-- CONTENT ONLY WITHOUT HEADER: 1 YES | 0 NO -->
	<xsl:param name="contentOnly" select="1"/>
	<xsl:param name="Matrix" select="1"/>

	<!-- Webpage shall be in XHTML 1.0 Strict -->
	<!-- <xsl:output method="xml" encoding="UTF-8" version="1.0"/> -->

	<xsl:variable name="LocalizationDictionary" select="document('bkef/dict/BKEFdictionary.xml')"/>

	<xsl:variable name="ContentTagsDictionary" select="document('bkef/dict/BKEFContentTagsDictionary.xml')"/>

      <xsl:include href="includes.xsl"/>


	<!-- INFLUENCES -->
	<!-- Specific realisations of attribute influences  -->
	<xsl:variable name="someInfluence" select="'Some-influence'"/>
	<xsl:variable name="positiveInfluence" select="'Positive-growth'"/>
	<xsl:variable name="negativeInfluence" select="'Negative-growth'"/>
	<xsl:variable name="positiveFrequency" select="'Positive-bool-growth'"/>
	<xsl:variable name="negativeFrequency" select="'Negative-bool-growth'"/>
	<xsl:variable name="positiveBoolean" select="'Double-bool-growth'"/>
	<!-- <xsl:variable name="negativeBoolean" select="'Negative boolean'"/> -->
	<xsl:variable name="functional" select="'Functional'"/>
	<xsl:variable name="none" select="'None'"/>
	<xsl:variable name="doNotCare" select="'Uninteresting'"/>
	<xsl:variable name="unknown" select="'Unknown'"/>

	<!--
        ******************************
                  MAIN BODY
        ******************************
	-->

	<xsl:template match="/ds:BKEF">
		<xsl:choose>
			<xsl:when test="$contentOnly">
				<!-- 				DOCTYPE script  PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"  -->

				<xsl:apply-templates select="/ds:BKEF" mode="body"/>
			</xsl:when>
			<xsl:otherwise>
				<html>
					<head>
						<title>BKEF - <xsl:value-of select="//ds:Header/ds:Title"/></title>

						<!-- Link to CSS file -->
						<link rel="stylesheet" type="text/css" href="{$csspath}bkef.css"/>

					</head>
					<!-- <body class="bkef" onload="uvodniNastaveni();"> -->
					<body class="bkef">
						<xsl:apply-templates select="/ds:BKEF" mode="body"/>
					</body>
				</html>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/ds:BKEF" mode="body">
		<script type="text/javascript" src="{$jspath}wz_tooltip.js"/>

		<script type="text/javasvript">
			window.onload = function() {
			uvodniNastaveni();
			}
		</script>

		<script type="text/javascript" src="{$jspath}influences.js">window.fg = jk;</script>

		<!--  <xsl:if test="$contentOnly = 1"> -->
		<!-- Link to CSS file -->
		<!--	<link rel="stylesheet" type="text/css" href="{$csspath}style.css"/> -->
		<!-- </xsl:if> -->

		<div id="bkef">
			<!-- JavaScript FOLDING -->
			<script type="text/javascript">
				// Folding of particular formats
				function ShowHide(id) {
				folding = document.getElementById(id).style;
				folding.display = (folding.display == 'block')? 'none': 'block';
				}
			</script>
			<!-- NAVIGATION BOX -->
			<div id="navigation">
				<h5>
					<!-- <xsl:value-of select="document($dictpath)/BKEFDictionary/Strings/str[@lang=$reportLang and @name='Navigation']"/> -->
					<!-- <xsl:copy-of select="keg:translate('Navigation',01)"/>  -->
					<xsl:copy-of select="keg:translate('Navigace',1)"/>
					<span class="folding" onclick="ShowHide('{generate-id()}')">+</span>
				</h5>


				<div id="{generate-id()}" class="hidden">
					<ul class="nav">
						<li>
							<a href="#metaAttr">
								<xsl:attribute name="title">
									<xsl:copy-of select="keg:translate('Meta attributes',2)"/>
								</xsl:attribute>
								<xsl:copy-of select="keg:translate('Meta attributes',2)"/>
							</a>
						</li>
						<li>
							<a href="#definedInfluences">
								<xsl:attribute name="title">
									<xsl:copy-of select="keg:translate('Defined mutual influences',39)"/>
								</xsl:attribute>
								<xsl:copy-of select="keg:translate('Defined mutual influences',39)"/>
							</a>
						</li>
						<li>
							<a href="#influences">
								<xsl:attribute name="title">
									<xsl:copy-of select="keg:translate('Mutual influences',3)"/>
								</xsl:attribute>
								<xsl:copy-of select="keg:translate('Mutual influences',3)"/>
							</a>
						</li>
					</ul>

					<h6>
						<xsl:copy-of select="keg:translate('Meta attributes',2)"/>
					</h6>
					
					<xsl:for-each select="ds:MetaAttributes//ds:MetaAttribute[@level=1]">
						
						<ul class="nav">
							<li>
								<span class="strong">
									<a href="#attribute-detail-{generate-id(current())}"
										title="{@id}">
										<xsl:value-of select="@name"/>
									</a>
								</span>
								<xsl:if test="current()/ds:ChildMetaAttribute[@id]">
									<ul class="nav2">
										<xsl:for-each select="child::*[@id]">
											<xsl:variable name="metaAttribute-name" select="@id"/>
											<xsl:variable name="metaAttribute"
												select="//ds:MetaAttribute[@id = $metaAttribute-name and @name and @level=0]/@name"/>

											<li>
												<input type="checkbox" value="{$metaAttribute}"
												onClick="ShowHideAll(this.value);solveLocation();"/>
												<xsl:variable name="idChildNavigation">
												<xsl:value-of select="@id"/>
												</xsl:variable>
												<a
												href="#attribute-detail-{generate-id(//ds:MetaAttribute[@name and @id=$idChildNavigation and @level])}"
												title="{//ds:MetaAttribute[@name and @id=$idChildNavigation and @level]/@name}">
												<xsl:value-of
												select="//ds:MetaAttribute[@name and @id=$idChildNavigation and @level]/@name"
												/>
												</a>
											</li>
										</xsl:for-each>
									</ul>
								</xsl:if>
							</li>
						</ul>
					</xsl:for-each>

				</div>
			</div>

			<!-- MAIN PAGE -->
			<div id="header">
				<h1>BKEF <xsl:value-of select="//ds:Header/ds:Title"/></h1>
			</div>
			<div id="content">

				<!-- Following order is changeable -->

				<h2>
					<a name="metaAttr">
						<xsl:copy-of select="keg:translate('Meta attributes',2)"/>
					</a>
				</h2>
				<!-- <p><button class="LMA"><xsl:copy-of select="keg:translate('+',41)"/></button></p>  -->
				<div class="MA">
				<xsl:apply-templates select="ds:MetaAttributes"/>
				<!-- <script>
					var count = 0;
					$("button").click(function () {
					$("div.MA").toggle( count++ % 2 == 0 );
					});
					</script>  -->
				</div>
				
				<h2>
					<a name="definedInfluences">
						<xsl:copy-of select="keg:translate('Defined mutual influences',39)"/>
					</a>
				</h2>
				<xsl:call-template name="ds:tableMI"/>
				
				<h2>
					<a name="influences">
						<xsl:copy-of select="keg:translate('Mutual influences',3)"/>
					</a>
				</h2>
				<div id="bkef-matrix">
					<div id="content-matrix">
						
							<div id="tableOverflow">
								<!-- <xsl:attribute name="style">overflow: auto; height: <xsl:value-of
									select="5.25 * count(//ds:MetaAttribute[@name and @id and not(@role) and @level =
									0]/@name) + 21.25"/>em</xsl:attribute> -->
								<table class="matrix">
									<tr>
										
										<td class="attr">
											<em><xsl:copy-of select="keg:translate('Attributes',35)"/></em>
										</td>
										
										<!-- 1st ROW of matrix // Generating of matrix with use of the list of meta-attributes -->
										<xsl:for-each select="//ds:MetaAttribute[@name and @id and not(@role) and @level = 0]">
											<xsl:variable name="name-metaAttr1a" select="current()/@name"></xsl:variable>
											<xsl:variable name="metaAttribute1a" select="//ds:MetaAttribute[@name = $name-metaAttr1a and not (@role)]/@name"/>
											<td class="attr" name="{$metaAttribute1a}" style="display:none;">
												<xsl:value-of select="current()/@name"/>
												<br/>
											</td>
											
										</xsl:for-each>
									</tr>
									
									<!-- OUTER ITERATION -->
									<xsl:for-each select="//ds:MetaAttribute[@name and @id and not(@role) and @level = 0]">
										<xsl:variable name="name-metaAttr1b" select="current()/@name"></xsl:variable>
										<xsl:variable name="metaAttribute1b" select="//ds:MetaAttribute[@name = $name-metaAttr1b and not (@role)]/@name"/>
										<tr name="{$metaAttribute1b}" style="display:none;">
											<td class="attr">
												<a href="#attribute-detail-{generate-id(current())}">
													<xsl:value-of select="current()/@name"/>
												</a>
											</td>
											
											<!-- 1st VAR // Actual value from 1st iteration block -->
											<xsl:variable name="attribute" select="current()/@name"/>
											
											<!-- INNER ITERATION -->
											<xsl:for-each select="//ds:MetaAttribute[@name and @id and not(@role) and @level = 0]">
												
												<!-- 2nd VAR // Actual value from 2nd iteration block -->
												<xsl:variable name="attributeII" select="current()/@name"/>
												
												<xsl:choose>
													<xsl:when
														test="//ds:Influence/ds:MetaAttribute[@role = 'A' and @name = $attribute] and //ds:Influence/ds:MetaAttribute[@role = 'B' and @name = $attributeII]">
														<xsl:variable name="selectAttribute"
															select="//ds:Influence
															[child::ds:MetaAttribute[@role = 'A' and @name = $attribute] and child::ds:MetaAttribute[@role = 'B' and @name = $attributeII]]
															/@type"/>
														
														<xsl:choose>
															
															<!-- THERE CAN BE SOME UNDEFINED INFLUENCE -->
															<xsl:when test="$selectAttribute = $someInfluence">
																<xsl:call-template name="ds:Cell">
																	<xsl:with-param name="selectAttribute" select="$selectAttribute"/>
																	<xsl:with-param name="attribute" select="$attribute"/>
																	<xsl:with-param name="attributeII" select="$attributeII"/>
																	<xsl:with-param name="imgName" select="'someInfluence'"/>
																</xsl:call-template>
															</xsl:when>
															
															<!-- POSITIVE GROWTH -->
															<xsl:when test="$selectAttribute = $positiveInfluence">
																<xsl:call-template name="ds:Cell">
																	<xsl:with-param name="selectAttribute" select="$selectAttribute"/>
																	<xsl:with-param name="attribute" select="$attribute"/>
																	<xsl:with-param name="attributeII" select="$attributeII"/>
																	<xsl:with-param name="imgName" select="'positiveInfluence'"/>
																</xsl:call-template>
															</xsl:when>
															
															<!-- NEGATIVE GROWTH -->
															<xsl:when test="$selectAttribute = $negativeInfluence">
																<xsl:call-template name="ds:Cell">
																	<xsl:with-param name="selectAttribute" select="$selectAttribute"/>
																	<xsl:with-param name="attribute" select="$attribute"/>
																	<xsl:with-param name="attributeII" select="$attributeII"/>
																	<xsl:with-param name="imgName" select="'negativeInfluence'"/>
																</xsl:call-template>
															</xsl:when>
															
															<!-- POSITIVE BOOLEAN GROWTH -->
															<xsl:when test="$selectAttribute = $positiveFrequency">
																<xsl:call-template name="ds:Cell">
																	<xsl:with-param name="selectAttribute" select="$selectAttribute"/>
																	<xsl:with-param name="attribute" select="$attribute"/>
																	<xsl:with-param name="attributeII" select="$attributeII"/>
																	<xsl:with-param name="imgName" select="'positiveFrequency'"/>
																</xsl:call-template>
															</xsl:when>
															
															<!-- NEGATIVE BOOLEAN GROWTH -->
															<xsl:when test="$selectAttribute = $negativeFrequency">
																<xsl:call-template name="ds:Cell">
																	<xsl:with-param name="selectAttribute" select="$selectAttribute"/>
																	<xsl:with-param name="attribute" select="$attribute"/>
																	<xsl:with-param name="attributeII" select="$attributeII"/>
																	<xsl:with-param name="imgName" select="'negativeFrequency'"/>
																</xsl:call-template>
															</xsl:when>
															
															<!-- POSITIVE DOUBLE BOOLEAN -->
															<xsl:when test="$selectAttribute = $positiveBoolean">
																<xsl:call-template name="ds:Cell">
																	<xsl:with-param name="selectAttribute" select="$selectAttribute"/>
																	<xsl:with-param name="attribute" select="$attribute"/>
																	<xsl:with-param name="attributeII" select="$attributeII"/>
																	<xsl:with-param name="imgName" select="'positiveBoolean'"/>
																</xsl:call-template>
															</xsl:when>
															
															<!-- NEGATIVE BOOLEAN - JUST PREPARED FOR EVENTUAL USAGE -->
															<!-- <xsl:when test="$selectAttribute = $negativeBoolean">
																<xsl:call-template name="ds:Cell">
																<xsl:with-param name="selectAttribute" select="$selectAttribute"/>
																<xsl:with-param name="attribute" select="$attribute"/>
																<xsl:with-param name="attributeII" select="$attributeII"/>
																<xsl:with-param name="imgName" select="'negativeBoolean'"/>
																</xsl:call-template>
																</xsl:when>  -->
															
															<!-- FUNCTIONAL INFLUENCE -->
															<xsl:when test="$selectAttribute = $functional">
																<xsl:call-template name="ds:Cell">
																	<xsl:with-param name="selectAttribute" select="$selectAttribute"/>
																	<xsl:with-param name="attribute" select="$attribute"/>
																	<xsl:with-param name="attributeII" select="$attributeII"/>
																	<xsl:with-param name="imgName" select="'functional'"/>
																</xsl:call-template>
															</xsl:when>
															
															<!-- NONE INFLUENCE -->
															<xsl:when test="$selectAttribute = $none">
																<xsl:call-template name="ds:Cell">
																	<xsl:with-param name="selectAttribute" select="$selectAttribute"/>
																	<xsl:with-param name="attribute" select="$attribute"/>
																	<xsl:with-param name="attributeII" select="$attributeII"/>
																	<xsl:with-param name="imgName" select="'none'"/>
																</xsl:call-template>
															</xsl:when>
															
															<!-- WE ARE NOT INTERESTED ABOUT INFLUENCE -->
															<xsl:when test="$selectAttribute = $doNotCare">
																<xsl:call-template name="ds:Cell">
																	<xsl:with-param name="selectAttribute" select="$selectAttribute"/>
																	<xsl:with-param name="attribute" select="$attribute"/>
																	<xsl:with-param name="attributeII" select="$attributeII"/>
																	<xsl:with-param name="imgName" select="'doNotCare'"/>
																</xsl:call-template>
															</xsl:when>
															
															<!-- UNKNOWN -->
															<xsl:when test="$selectAttribute = $unknown">
																<xsl:call-template name="ds:Cell">
																	<xsl:with-param name="selectAttribute" select="$selectAttribute"/>
																	<xsl:with-param name="attribute" select="$attribute"/>
																	<xsl:with-param name="attributeII" select="$attributeII"/>
																	<xsl:with-param name="imgName" select="'unknown'"/>
																</xsl:call-template>
															</xsl:when>
															
															<!-- "Gray" field - intersection of same attributes -->
															<xsl:when test="$attribute = $attributeII">
																<xsl:variable name="name-metaAttr" select="current()/@name"></xsl:variable>
																<xsl:variable name="metaAttribute2" select="//ds:MetaAttribute[@name = $name-metaAttr and not (@role)]/@name"/>
																<td class="cannotMatch" name="{$metaAttribute2}" style="display:none;">
																	<p class="displayNone">XXX</p>
																</td>
																
															</xsl:when>
															
															<!-- Not set -->
															<xsl:otherwise>
																<xsl:variable name="name-metaAttr" select="current()/@name"></xsl:variable>
																<xsl:variable name="metaAttribute2" select="//ds:MetaAttribute[@name = $name-metaAttr and not (@role)]/@name"/>
																<td name="{$metaAttribute2}" style="display:none;">
																	<img src="{$image-url}notSet.png" alt="Not set"/>
																</td>
																
															</xsl:otherwise>
															
														</xsl:choose>
													</xsl:when>
													
													<!-- Intersection of the same attributes -->
													<xsl:when test="$attribute = $attributeII">
														<xsl:variable name="name-metaAttr" select="current()/@name"></xsl:variable>
														<xsl:variable name="metaAttribute2" select="//ds:MetaAttribute[@name = $name-metaAttr and not (@role)]/@name"/>
														<td class="cannotMatch" name="{$metaAttribute2}" style="display:none;">
															<p class="displayNone">XXX</p>
														</td>
														
													</xsl:when>
													
													<!-- The cell value is not set -->
													<xsl:otherwise>
														<xsl:variable name="name-metaAttr" select="current()/@name"></xsl:variable>
														<xsl:variable name="metaAttribute2" select="//ds:MetaAttribute[@name = $name-metaAttr and not (@role)]/@name"/>
														<td name="{$metaAttribute2}" style="display:none;">
															<img src="{$image-url}notSet.png" alt="Not set"/>
														</td>
														
													</xsl:otherwise>
													
												</xsl:choose>
											</xsl:for-each>
										</tr>
									</xsl:for-each>
								</table>
							</div>
					
					</div>
				</div>
				
				<!-- ******************************* -->

			</div>
			<!-- Footer -->
			<p>2009 Daniel Šťastný</p>
			<p>
				<small> ~ Valid XHTML 1.0 Strict ~ </small>
			</p>
		</div>
	</xsl:template>

	<!--
        ******************************
                METAATTRIBUTES
        ******************************
    -->

	<xsl:template match="ds:MetaAttributes">


		<!-- PARENTED BOXES OF METAATTRIBUTES -->		
		
		<xsl:for-each select="//ds:MetaAttribute[@name and @id and @level=1]">
			<xsl:comment><xsl:value-of select="keg:getContentBlockTag('Metaattribute',@name,'start')"/></xsl:comment>			
			<div class="metaAttributeBox">
				<h3>
					<a name="attribute-detail-{generate-id(current())}"><xsl:value-of select="@name"
						/></a> [id <xsl:value-of select="@id"/> ~ <xsl:copy-of
						select="keg:translate('level',5)"/>
					<xsl:value-of select="@level"/>] </h3>
				<xsl:apply-templates select="ds:Annotation">					
					<xsl:with-param name="type">Group Metaattribute</xsl:with-param>
					<xsl:with-param name="name" select="@name"></xsl:with-param>
				</xsl:apply-templates>
				<xsl:for-each select="current()//child::ds:ChildMetaAttribute[@id]">

					<!-- Link with the mutual-influences matrix -->
					<xsl:variable name="idChild">
						<xsl:value-of select="current()/@id"/>
					</xsl:variable>
					<div class="metaAttributeBox">
						<h3>
							<a
								name="attribute-detail-{generate-id(//ds:MetaAttribute[@name and @id=$idChild and @level])}"
									><xsl:value-of
									select="//ds:MetaAttribute[@name and @id = $idChild and @level]/@name"
								/> [id <xsl:value-of
									select="//ds:MetaAttribute[@name and @id = $idChild and @level]/@id"
								/>]</a>
						</h3>

						<xsl:if test="//ds:MetaAttribute[@name and @id=$idChild and @level=0]">
							<xsl:apply-templates
								select="//ds:MetaAttribute[@name and @id=$idChild and @level]"/>
						</xsl:if>

						<xsl:if
							test="//ds:MetaAttribute[@name and @id=$idChild and @level=0]/ds:Formats">
							<xsl:apply-templates
								select="//ds:MetaAttribute[@name and @id=$idChild and @level]/ds:Formats">
								<xsl:with-param name="UID" select="generate-id()"/>
							</xsl:apply-templates>
						</xsl:if>

					</div>
				</xsl:for-each>
			</div>
			<xsl:comment><xsl:value-of select="keg:getContentBlockTag('Metaattribute',@name,'end')"/></xsl:comment>
		</xsl:for-each>
		
	</xsl:template>
	

	<!--
		******************************
		Additional definitions
		******************************
	-->

	<!-- **** META-ATTRIBUTE DETAIL **** -->

	<xsl:template match="ds:MetaAttribute[@name and @id and @level]">
		<!-- <xsl:param name="linkParent"/>  -->
		<ul>
			<xsl:if test="ds:Author">
				<li>
					<span class="item"><xsl:copy-of select="keg:translate('Author',6)"/>: </span>
					<xsl:value-of select="ds:Author"/>
				</li>
			</xsl:if>

			<!-- Call ANNOTATION -->
			<li>
				<span class="item">								
					<xsl:copy-of select="keg:translate('Annotation',8)"/>
				</span>
				<xsl:apply-templates select="ds:Annotation">
					<xsl:with-param name="type">Metaattribute</xsl:with-param>
					<xsl:with-param name="name" select="@name"></xsl:with-param>
				</xsl:apply-templates>
			</li>

				<!-- <xsl:if test="ds:ParentMetaattribute">
				<li>
					<span class="item"><xsl:copy-of select="keg:translate('Parent-metaattribute',9)"/>: </span>
					<xsl:value-of select="ds:ParentMetaattribute"/>
					</li>
					</xsl:if>
				-->		
			<xsl:if test="ds:Variability">
				<li>
					<span class="item"><xsl:copy-of select="keg:translate('Variability',10)"/>: </span>
					<xsl:value-of select="ds:Variability"/>
				</li>
			</xsl:if>
		</ul>
	</xsl:template>


	<!-- ***** FORMATS ***** -->

	<xsl:template match="ds:MetaAttribute[@name and @id and @level]/ds:Formats">
		<xsl:param name="UID" select="generate-id()"/>
		<!-- Boxes of particular formats -->
		<div class="formatsBox">

			<!-- Web-Folding of particular formats -->
			<!-- Search for childs and making toggle menu -->
			<xsl:if test="child::*">
				<h4>
					<xsl:copy-of select="keg:translate('Formats',11)"/>
					<span class="folding" onclick="ShowHide('{$UID}')">+</span>
				</h4>
			</xsl:if>
			<div id="{$UID}" class="hidden">
				<xsl:for-each select="current()//ds:Format">

					<!-- BASIC DETAILS -->
					<div class="formatBox">
						<h5><xsl:copy-of select="keg:translate('Name',12)"/>: <xsl:value-of
								select="@name"/></h5>
						<ul>
							<xsl:if test="ds:Author">
								<li>
									<span class="item"><xsl:copy-of
											select="keg:translate('Author-format',7)"/>: </span>
									<xsl:value-of select="ds:Author"/>
								</li>
							</xsl:if>
							<xsl:if test="ds:Annotation">
								<li>
									<span class="item">
										<xsl:copy-of select="keg:translate('Annotation',8)"/>
									</span>
									<ul>
										<li><xsl:copy-of select="keg:translate('Author',6)"/>:
												<xsl:value-of select="ds:Annotation/ds:Author"
											/></li>
										<li>
											<xsl:value-of select="ds:Annotation/ds:Text"/>
										</li>
									</ul>
								</li>
							</xsl:if>
							<xsl:if test="ds:DataType">
								<li>
									<span class="item"><xsl:copy-of
											select="keg:translate('Data type',13)"/>: </span>
									<xsl:value-of select="ds:DataType"/>
								</li>
							</xsl:if>
							<xsl:if test="ds:ValueType">
								<li>
									<span class="item"><xsl:copy-of
											select="keg:translate('Value type',14)"/>: </span>
									<xsl:value-of select="ds:ValueType"/>
								</li>
							</xsl:if>
						</ul>

						<!-- VALUE ANNOTATIONS -->
						<xsl:if test="ds:ValueAnnotations">
							<h6>
								<xsl:copy-of select="keg:translate('Value annotations',15)"/>
							</h6>

							<!-- Show annotations in table -->
							<table class="annotations">
								<tr>
									<td>
										<span class="item">
											<xsl:copy-of select="keg:translate('Value',16)"/>
										</span>
									</td>
									<td>
										<span class="item">
											<xsl:copy-of select="keg:translate('Annotation',8)"/>
										</span>
									</td>
								</tr>
								<xsl:for-each select="ds:ValueAnnotations//ds:ValueAnnotation">
									<tr>
										<td>
											<xsl:value-of select="ds:Value"/>
										</td>
										<td>
											<xsl:apply-templates select="ds:Annotation">
												<xsl:with-param name="type">Value Annotation</xsl:with-param>
												<xsl:with-param name="name" select="ds:Value"></xsl:with-param>
											</xsl:apply-templates>
										</td>
									</tr>
								</xsl:for-each>
							</table>
						</xsl:if>

						<!-- ALLOWED RANGE -->
						<xsl:if test="ds:AllowedRange">
							<h6>
								<xsl:copy-of select="keg:translate('Allowed range',17)"/>
							</h6>
							<xsl:choose>
								<!-- **** Enumeration -->
								<xsl:when test="ds:AllowedRange/ds:Enumeration">
									<span class="item">
										<xsl:copy-of select="keg:translate('Enumeration',18)"/>
									</span>
									<ul>
										<xsl:for-each
											select="ds:AllowedRange/ds:Enumeration//ds:Value">
											<li>
												<xsl:value-of select="current()"/>
											</li>
										</xsl:for-each>
									</ul>
								</xsl:when>
								<!-- **** Interval -->
								<xsl:when test="ds:AllowedRange/ds:Interval">
									<!-- Left side of an interval -->
									<p>
										<span class="item">
											<xsl:copy-of select="keg:translate('Interval',19)"/>
										</span>
										<span class="interval">
											<xsl:choose>
												<xsl:when
												test="ds:AllowedRange/ds:Interval/ds:LeftBound/@type = 'open'"
												> (<xsl:value-of
												select="ds:AllowedRange/ds:Interval/ds:LeftBound/@value"
												/>; </xsl:when>
												<xsl:when
												test="ds:AllowedRange/ds:Interval/ds:LeftBound/@type = 'closed'"
												> &lt;<xsl:value-of
												select="ds:AllowedRange/ds:Interval/ds:LeftBound/@value"
												/>; </xsl:when>
											</xsl:choose>
											<!-- Right side of an interval -->
											<xsl:choose>
												<xsl:when
												test="ds:AllowedRange/ds:Interval/ds:RightBound/@type = 'open'">
												<xsl:value-of
												select="ds:AllowedRange/ds:Interval/ds:RightBound/@value"
												/>) </xsl:when>
												<xsl:when
												test="ds:AllowedRange/ds:Interval/ds:RightBound/@type = 'closed'">
												<xsl:value-of
												select="ds:AllowedRange/ds:Interval/ds:RightBound/@value"
												/>&gt; </xsl:when>
											</xsl:choose>
										</span>
									</p>
								</xsl:when>
							</xsl:choose>
						</xsl:if>

						<!-- COLLATION -->
						<xsl:if test="ds:Collation">
							<h6>
								<xsl:copy-of select="keg:translate('Collation',20)"/>
							</h6>
							<xsl:choose>
								<xsl:when
									test="ds:Collation[@type = 'Numerical' or @type = 'Alphabetical']">
									<ul>
										<li>
											<span class="item"><xsl:copy-of
												select="keg:translate('Type-collation',21)"/>: </span>
											<xsl:value-of select="ds:Collation/@type"/>
										</li>
										<li>
											<span class="item"><xsl:copy-of
												select="keg:translate('Sense',22)"/>: </span>
											<xsl:value-of select="ds:Collation/@sense"/>
										</li>
									</ul>
								</xsl:when>
								<xsl:when test="ds:Collation[@type = 'Enumeration']">
									<ul>
										<li>
											<span class="item"><xsl:copy-of
												select="keg:translate('Type-collation',21)"/>: </span>
											<xsl:value-of select="ds:Collation/@type"/>
										</li>
										<li>
											<span class="item"><xsl:copy-of
												select="keg:translate('Sense',22)"/>: </span>
											<xsl:value-of select="ds:Collation/@sense"/>
										</li>
									</ul>
									<span class="item">
										<xsl:copy-of select="keg:translate('Values',23)"/>
									</span>
									<ul>
										<xsl:for-each select="ds:Collation//ds:Value">
											<li>
												<xsl:value-of select="current()"/>
											</li>
										</xsl:for-each>
									</ul>
								</xsl:when>
							</xsl:choose>
						</xsl:if>

						<!-- PREPROCESSING HINTS -->
						<xsl:if test="ds:PreprocessingHints">
							<h6>
								<xsl:copy-of select="keg:translate('Preprocessing hints',24)"/>
							</h6>
							<!-- Choose all Preprocessing hints -->
							<xsl:for-each select=".//ds:PreprocessingHint">
								<p>
									<span class="item"><xsl:copy-of select="keg:translate('Name',12)"
										/>: </span>
									<xsl:value-of select="@name"/>
								</p>

								<p>
									<span class="item">
										<strong>
											<xsl:copy-of select="keg:translate('Characteristics',25)"
											/>
										</strong>
									</span>
								</p>
								<!-- Choose all discretization hints -->
								<xsl:for-each select=".//ds:DiscretizationHint">

									<xsl:choose>
										<!-- *** Exhaustive enumeration -->
										<xsl:when test="ds:ExhaustiveEnumeration">
											<xsl:for-each select=".//ds:Bin">
												<div class="bin">
												<p>
												<strong>
												<xsl:copy-of select="keg:translate('Value',16)"/>
												</strong>
												</p>
												<ul>
												<xsl:for-each select=".//ds:Value">
												<li>
												<xsl:value-of select="current()"/>
												</li>
												</xsl:for-each>
												</ul>
												<hr/>
												<p>
												<xsl:apply-templates select="ds:Annotation">
													<xsl:with-param name="type">Exhaustive Enumeration</xsl:with-param>
													<xsl:with-param name="name" select="@name"></xsl:with-param>
													
												</xsl:apply-templates>
												</p>
												</div>
											</xsl:for-each>
										</xsl:when>

										<!-- ***
                                            Combination of two different intervals catching extreme values
                                            and equidistant-interval steps
                                            Interval enumeration + Equidistant
                                        -->
										<xsl:when test="count(child::text()) = 3">
											<span class="item">
												<xsl:copy-of select="keg:translate('Intervals',26)"/>
											</span>
											<xsl:for-each select=".//ds:IntervalBin">
												<div class="bin">
												<p>
												<xsl:value-of select="@name"/>
												</p>
												<xsl:call-template name="ds:Interval"/>
												</div>
											</xsl:for-each>
											<span class="item">
												<xsl:copy-of select="keg:translate('Equidistant',27)"
												/>
											</span>
											<ul>
												<li>
												<span class="item"><xsl:copy-of
												select="keg:translate('Range',29)"/>: </span>
												<xsl:call-template name="ds:Equidistant"/>
												</li>
												<li>
												<span class="item"><xsl:copy-of
												select="keg:translate('Step',29)"/>: </span>
												<xsl:value-of select="ds:Equidistant/ds:Step"/>
												</li>
											</ul>
										</xsl:when>

										<!-- *** Equidistant -->
										<xsl:when test="ds:Equidistant">
											<span class="item">
												<xsl:copy-of select="keg:translate('Equidistant',27)"
												/>
											</span>
											<ul>
												<li>
												<span class="item"><xsl:copy-of
												select="keg:translate('Range',28)"/>: </span>
												<xsl:call-template name="ds:Equidistant"/>
												</li>
												<li>
												<span class="item"><xsl:copy-of
												select="keg:translate('Step',29)"/>: </span>
												<xsl:value-of select="ds:Equidistant/ds:Step"/>
												</li>
											</ul>
										</xsl:when>

										<!-- *** EquifrequentInterval -->
										<xsl:when test="ds:EquifrequentInterval">
											<span class="item">
												<xsl:copy-of
												select="keg:translate('Equifrequent interval',30)"
												/>
											</span>
											<ul>
												<li>
												<span class="item"><xsl:copy-of
												select="keg:translate('Count',31)"/>: </span>
												<xsl:value-of
												select="ds:EquifrequentInterval/ds:Count"/>
												</li>
											</ul>
										</xsl:when>

										<!-- *** IntervalEnumeration -->
										<xsl:when test="ds:IntervalEnumeration">
											<span class="item">
												<xsl:copy-of select="keg:translate('Intervals',26)"/>
											</span>
											<xsl:for-each select=".//ds:IntervalBin">
												<div class="bin">
												<p>
												<xsl:value-of select="@name"/>
												</p>
												<xsl:call-template name="ds:Interval"/>
												</div>
											</xsl:for-each>
										</xsl:when>

									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
						</xsl:if>

						<!-- VALUE DESCRIPTIONS -->
						<xsl:if test="ds:ValueDescriptions">
							<h6>
								<xsl:copy-of select="keg:translate('Value descriptions',32)"/>
							</h6>

							<xsl:for-each select=".//ds:ValueDescription">
								<div class="bin">
									<span class="item"><xsl:copy-of
											select="keg:translate('Type-desc',33)"/>: </span>
									<xsl:value-of select="@type"/>

									<xsl:choose>
										<xsl:when test="child::ds:Value[1]">
											<ul>
												<xsl:for-each select="ds:Value">
												<li>
												<xsl:value-of select="current()"/>
												</li>
												</xsl:for-each>
											</ul>
										</xsl:when>
										<xsl:when test="child::ds:Interval[1]">
											<xsl:call-template name="ds:Interval"/>
										</xsl:when>
									</xsl:choose>
									<hr/>
									<xsl:apply-templates select="ds:Annotation">
										<xsl:with-param name="type">Value Description</xsl:with-param>
										<xsl:with-param name="name" select="@type"></xsl:with-param>
										
									</xsl:apply-templates>
								</div>
							</xsl:for-each>
						</xsl:if>

					</div>
				</xsl:for-each>
			</div>
		</div>
	</xsl:template>

	<!-- **** INTERVAL **** -->
	<xsl:template name="ds:Interval">
		<ul>
			<!-- Interval -->
			<xsl:for-each select=".//ds:Interval">
				<li>
					<span class="interval">
						<xsl:choose>
							<!-- left bound -->
							<xsl:when test="current()/ds:LeftBound/@type = 'closed'">
									&lt;<xsl:value-of select="current()/ds:LeftBound/@value"/>
							</xsl:when>
							<xsl:when test="current()/ds:LeftBound/@type = 'open'"> (<xsl:value-of
									select="current()/ds:LeftBound/@value"/>
							</xsl:when>

						</xsl:choose>

						<!-- Interval semicolon -->
						<xsl:text>;</xsl:text>

						<xsl:choose>
							<!-- right bound -->
							<xsl:when test="current()/ds:RightBound/@type = 'closed'">
								<xsl:value-of select="current()/ds:RightBound/@value"/>&gt; </xsl:when>

							<xsl:when test="current()/ds:RightBound/@type = 'open'">
								<xsl:value-of select="current()/ds:RightBound/@value"/>) </xsl:when>
						</xsl:choose>
					</span>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>

	<!-- **** ANNOTATION **** -->
	<xsl:template match="ds:Annotation">
		<xsl:param name="type"></xsl:param>
		<xsl:param name="name"></xsl:param>
		
			<ul>
				<xsl:choose>
					<xsl:when test="ds:Author">
						<li>
							<span class="item"><xsl:copy-of select="keg:translate('Author',6)"/>: </span>
							<xsl:value-of select="ds:Author"/>
						</li>
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="ds:Text">
						<li>
							<xsl:copy-of select="keg:translate('Annotation',8)"/>:
							<xsl:variable name="ContentBlockString">
								<xsl:value-of select="$type"/> / <xsl:value-of select="$name"/> / <xsl:choose>
									<xsl:when test="string-length(ds:Author)>0"><xsl:value-of select="ds:Author"/></xsl:when>
									<xsl:otherwise>Author Unknown</xsl:otherwise>
								</xsl:choose> / <xsl:value-of select="position()"/>  
							</xsl:variable>
							<xsl:comment><xsl:value-of select="keg:getContentBlockTag('Annotation', $ContentBlockString ,'start')"/></xsl:comment>
							<xsl:text>								
							</xsl:text>						
							<xsl:value-of
								select="ds:Text"/>
							<xsl:text>								
							</xsl:text>
							<xsl:comment><xsl:value-of select="keg:getContentBlockTag('Annotation', $ContentBlockString,'end')"/></xsl:comment>
						</li>
					</xsl:when>
				</xsl:choose>
			</ul>
		
	</xsl:template>

	<!-- **** EQUIDISTANT **** -->
	<xsl:template name="ds:Equidistant">

		<!-- Left side of an interval -->
		<xsl:choose>
			<xsl:when test="ds:Equidistant/ds:Start/@type = 'open'"> (<xsl:value-of
					select="ds:Equidistant/ds:Start"/>; </xsl:when>
			<xsl:when test="ds:Equidistant/ds:Start/@type = 'closed'"> &lt;<xsl:value-of
					select="ds:Equidistant/ds:Start"/>; </xsl:when>
		</xsl:choose>

		<!-- Right side of an interval -->
		<xsl:choose>
			<xsl:when test="ds:Equidistant/ds:End/@type = 'open'">
				<xsl:value-of select="ds:Equidistant/ds:End"/>) </xsl:when>
			<xsl:when test="ds:Equidistant/ds:End/@type = 'closed'">
				<xsl:value-of select="ds:Equidistant/ds:End"/>&gt; </xsl:when>
		</xsl:choose>

	</xsl:template>

	<!-- 
		***********************	
		INFLUENCE TEMPLATES
		***********************
	-->
	
	<!-- **** CELL **** -->
	<!-- Cell is valid only for interstection of two attributes. Therefore it has only two dimensions -->
	<xsl:template name="ds:Cell">
		<xsl:param name="selectAttribute"/>
		<xsl:param name="attribute"/>
		<xsl:param name="attributeII"/>
		<xsl:param name="imgName"/>
		<xsl:param name="knowledge" select="//ds:KnowledgeValidity"/>
		<xsl:param name="scope" select="//ds:InfluenceScope"/>
		
		<xsl:variable name="name-metaAttr" select="current()/@name"></xsl:variable>
		<xsl:variable name="metaAttribute2" select="//ds:MetaAttribute[@name = $name-metaAttr and not (@role)]/@name"/>
		<td name="{$metaAttribute2}" style="display:none;">
			<a class="about" href="javascript:void(0)">
				<xsl:attribute name="onmouseover">
					<xsl:text>Tip('A: </xsl:text>
					<xsl:value-of select="$attribute"/>
					<!-- Path to details of meta-attribute of influence -->
					<xsl:variable name="A-inf" select="//ds:MetaAttribute[@name = $attribute and @role = 'A']/ds:RestrictedTo/ds:Format"/>
					<xsl:call-template name="ds:Restriction">
						<xsl:with-param name="path" select="$A-inf"/>
					</xsl:call-template>
					<xsl:text>&lt;br /&gt; B: </xsl:text>
					<xsl:value-of select="$attributeII"/>
					<xsl:variable name="B-inf" select="//ds:MetaAttribute[@name = $attributeII and @role = 'B']/ds:RestrictedTo/ds:Format"/>
					<xsl:call-template name="ds:Restriction">
						<xsl:with-param name="path" select="$B-inf"/>
					</xsl:call-template>
					<xsl:text>&lt;br /&gt;</xsl:text>
					<xsl:text>&lt;br /&gt; </xsl:text><xsl:copy-of select="keg:translate('Influence scope',35)"/><xsl:text>: </xsl:text>
					<xsl:value-of select="$scope"/>
					<xsl:text>&lt;br /&gt; </xsl:text><xsl:copy-of select="keg:translate('Knowledge validity',36)"/><xsl:text>: </xsl:text>
					<xsl:value-of select="$knowledge"/>
					<xsl:text>', TITLE, '</xsl:text>
					<xsl:value-of select="$selectAttribute"/>
					<xsl:text>', BGCOLOR, '#f7f4f4', FONTCOLOR, '#800000', FONTSIZE, '10pt', FONTFACE, 'Courier New, Courier, mono', BORDERCOLOR, 'gray')</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="onmouseout">
					<xsl:text>UnTip()</xsl:text>
				</xsl:attribute>
				<img src="{$image-url}{$imgName}.png" alt="{$selectAttribute}"/>
			</a>
		</td>
		<xsl:text>
		</xsl:text>
	</xsl:template>
	
	<!-- **** RESTRICTION **** -->
	<xsl:template name="ds:Restriction">
		<xsl:param name="path"/>
		<!-- The name of the restricting format -->
		<xsl:if test="$path/@name">
			<xsl:text>&lt;br /&gt;</xsl:text><xsl:copy-of select="keg:translate('Format name',37)"/><xsl:text>: </xsl:text><xsl:value-of select="$path/@name"/>
		</xsl:if>
		<xsl:choose>
			
			<!-- Enumeration -->
			<xsl:when test="$path/ds:Value">
				<xsl:for-each select="$path//ds:Value">
					<xsl:text>&lt;br /&gt;</xsl:text><xsl:text>- </xsl:text>
					<xsl:value-of select="current()/@format"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="current()"/>
				</xsl:for-each>
			</xsl:when>
			
			<xsl:when test="$path/ds:Intervals">
				<!-- ITEREATION - SELECTING INTERVALS -->		
				<xsl:for-each select="$path/ds:Intervals//ds:Interval">
					<xsl:text>&lt;br /&gt;</xsl:text>
					<xsl:text>- </xsl:text>
					<xsl:choose>
						<xsl:when test="current()/ds:LeftBound/@type = 'closed'">
							<xsl:text>&lt;</xsl:text>
							<xsl:value-of select="current()/ds:LeftBound/@value"/>
						</xsl:when>
						<xsl:when test="current()/ds:LeftBound/@type = 'open'">
							<xsl:text>(</xsl:text>
							<xsl:value-of select="current()/ds:LeftBound/@value"/>
						</xsl:when>
					</xsl:choose>
					<xsl:text>;</xsl:text>
					<xsl:choose>
						<xsl:when test="current()/ds:RightBound/@type = 'closed'">
							<xsl:value-of select="current()/ds:RightBound/@value"/>
							<xsl:text>&gt;</xsl:text>
						</xsl:when>
						<xsl:when test="current()/ds:RightBound/@type = 'open'">
							<xsl:value-of select="current()/ds:RightBound/@value"/>
							<xsl:text>)</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- ******** Defined Mutual Influence *********** -->
	
	<xsl:template name="ds:tableMI">
		<!-- 	<button id="tableMI"><xsl:copy-of select="keg:translate('+',41)"/></button>  -->
		<span class="folding-bigger" onclick="ShowHide('tabMIid')">+</span><br/><br/>
		<div id="tabMIid" class="hidden">
		<table class="listMI">
			<thead>
				<tr>
					<th><xsl:copy-of select="keg:translate('Shortened explanation',101)"/></th>
					<th><xsl:copy-of select="keg:translate('Verbal explanation',100)"/></th>
				</tr>
			</thead>
			<tbody>
				<xsl:comment><xsl:value-of select="keg:getContentBlockTag('Influences','','start')"/></xsl:comment>
				<xsl:for-each select="//ds:Influence[@type != 'none']">
					<xsl:sort select="current()/@type" order="ascending"/>
					<xsl:variable name="toggle" select="generate-id()"/>
					<tr class="{$toggle}">
						<td class="tableMI-graphical">
							<xsl:call-template name="ds:InfluenceTMI-graphic">
								<xsl:with-param name="ds:influenceType" select="current()/@type"/>
								<xsl:with-param name="ds:antecedent" select="child::*[@role='A']/@name"/>
								<xsl:with-param name="ds:succedent" select="child::*[@role='B']/@name"/>
								<xsl:with-param name="ds:restrictionAntecedent" select="child::*[@role='A']/ds:RestrictedTo/ds:Format/@name"/>
								<xsl:with-param name="ds:restrictionSuccedent" select="child::*[@role='B']/ds:RestrictedTo/ds:Format/@name"/>								
							</xsl:call-template>
						</td>
						<td class="tableMI-verbal">							
							<xsl:call-template name="ds:InfluenceTMI">
								<xsl:with-param name="ds:influenceType" select="current()/@type"/>
								<xsl:with-param name="ds:antecedent" select="child::*[@role='A']/@name"/>
								<xsl:with-param name="ds:succedent" select="child::*[@role='B']/@name"/>
								<xsl:with-param name="ds:restrictionAntecedent" select="child::*[@role='A']/ds:RestrictedTo/ds:Format/@name"/>
								<xsl:with-param name="ds:restrictionSuccedent" select="child::*[@role='B']/ds:RestrictedTo/ds:Format/@name"/>
								<xsl:with-param name="ds:restrictionSuccedentValue" select="child::*[@role='B']/ds:RestrictedTo/ds:Format/ds:Value"/>
							</xsl:call-template>							
							
						</td>
					</tr>
				</xsl:for-each>
				<xsl:comment><xsl:value-of select="keg:getContentBlockTag('Influences','','end')"/></xsl:comment>
			</tbody>
		</table>
		</div>
	<!-- <script type="text/javascript" src="{$jspath}jQuery.js">
		$('#tableMI').click(function() {
  			$('#linkedTableMI').toggle();
		});
		</script>  -->	
	</xsl:template>
	
	<xsl:template name="ds:InfluenceTMI">
		<xsl:param name="ds:antecedent"/>
		<xsl:param name="ds:influenceType"/>
		<xsl:param name="ds:restrictionAntecedent"/>
		<xsl:param name="ds:restrictionSuccedent"/>
		<xsl:param name="ds:restrictionSuccedentValue"/>
		<xsl:param name="ds:succedent"/>

		<xsl:variable name="InfluenceContentBlockName">
			 <xsl:value-of select="$ds:antecedent"/> ( <xsl:value-of select="$ds:influenceType"/>) <xsl:value-of select="$ds:succedent"/>
		</xsl:variable>
		
		<xsl:comment><xsl:value-of select="keg:getContentBlockTag('InfluenceText',$InfluenceContentBlockName,'start')"/></xsl:comment>
	
		<xsl:choose>
			<!-- UNINTERESTING -->
			<xsl:when test="$ds:influenceType = $doNotCare">
				<xsl:copy-of select="keg:translate('Uninteresting_1',110)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:antecedent"/></strong>
				<xsl:if test="string-length($ds:restrictionAntecedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionAntecedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('DMG-and',200)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:succedent"/></strong>
				<xsl:if test="string-length($ds:restrictionSuccedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionSuccedent"/></em>
					<xsl:text>]</xsl:text>
				</xsl:if>
			</xsl:when>
			
			<!-- SOME UNDEFINED INFLUENCE -->
			<xsl:when test="$ds:influenceType = $someInfluence">
				<xsl:copy-of select="keg:translate('Some_1',120)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:antecedent"/></strong>
				<xsl:if test="string-length($ds:restrictionAntecedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionAntecedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('DMG-and',200)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:succedent"/></strong>
				<xsl:if test="string-length($ds:restrictionSuccedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionSuccedent"/></em>
					<xsl:text>]</xsl:text>
				</xsl:if>
			</xsl:when>
			
			<!-- POSITIVE INFLUENCE -->
			<xsl:when test="$ds:influenceType = $positiveInfluence">
				<xsl:copy-of select="keg:translate('Positive_1',130)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:antecedent"/></strong>
				<xsl:if test="string-length($ds:restrictionAntecedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionAntecedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('Positive_2',131)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:succedent"/></strong>
				<xsl:if test="string-length($ds:restrictionSuccedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionSuccedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('Positive_3',132)"/>
			</xsl:when>
			
			<!-- NEGATIVE INFLUENCE -->
			<xsl:when test="$ds:influenceType = $negativeInfluence">
				<xsl:copy-of select="keg:translate('Negative_1',140)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:antecedent"/></strong>
				<xsl:if test="string-length($ds:restrictionAntecedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionAntecedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('Negative_2',141)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:succedent"/></strong>
				<xsl:if test="string-length($ds:restrictionSuccedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionSuccedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('Negative_3',142)"/>
			</xsl:when>
			
			<!-- POSITIVE BOOLEAN -->
			<xsl:when test="$ds:influenceType = $positiveInfluence">
				<xsl:copy-of select="keg:translate('PB_1',150)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:antecedent"/></strong>
				<xsl:if test="string-length($ds:restrictionAntecedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionAntecedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('PB_2',151)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:succedent"/></strong>
				<xsl:if test="string-length($ds:restrictionSuccedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionSuccedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('PB_3',152)"/>
			</xsl:when>
			
			<!-- NEGATIVE FREQUENCY -->
			<xsl:when test="$ds:influenceType = $negativeFrequency">
				<xsl:copy-of select="keg:translate('NF_1',160)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:antecedent"/></strong>
				<xsl:if test="string-length($ds:restrictionAntecedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionAntecedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('NF_2',161)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:restrictionSuccedentValue"/></strong>
				<xsl:text> </xsl:text>
				<xsl:copy-of select="keg:translate('NF_3',162)"/>
				<strong><xsl:value-of select="$ds:succedent"/></strong>
				<xsl:if test="string-length($ds:restrictionSuccedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionSuccedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('NF_4',163)"/>
			</xsl:when>
			
			<!-- POSITIVE FREQUENCY -->
			
			<xsl:when test="$ds:influenceType = $positiveFrequency">
				<xsl:copy-of select="keg:translate('PF_1',170)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:antecedent"/></strong>
				<xsl:if test="string-length($ds:restrictionAntecedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionAntecedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('PF_2',171)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:restrictionSuccedentValue"/></strong>	
				<xsl:text> </xsl:text>
				<xsl:copy-of select="keg:translate('PF_3',172)"/>
				<strong><xsl:value-of select="$ds:succedent"/></strong>
				<xsl:if test="string-length($ds:restrictionSuccedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionSuccedent"/></em>
					<xsl:text>] </xsl:text>									
				</xsl:if>
				<xsl:copy-of select="keg:translate('PF_4',173)"/>
			</xsl:when>
			
			<!-- NONE -->
			<xsl:when test="$ds:influenceType = $none">
				<xsl:copy-of select="keg:translate('None_1',180)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:antecedent"/></strong>
				<xsl:if test="string-length($ds:restrictionAntecedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionAntecedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('DMG-and',200)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:succedent"/></strong>
				<xsl:if test="string-length($ds:restrictionSuccedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionSuccedent"/></em>
					<xsl:text>]</xsl:text>
				</xsl:if>
			</xsl:when>
			
			<!-- FUNCTIONAL -->
			<xsl:when test="$ds:influenceType = $functional">
				<xsl:copy-of select="keg:translate('F_1',185)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:antecedent"/></strong>
				<xsl:if test="string-length($ds:restrictionAntecedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionAntecedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('DMG-and',200)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:succedent"/></strong>
				<xsl:if test="string-length($ds:restrictionSuccedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionSuccedent"/></em>
					<xsl:text>]</xsl:text>
				</xsl:if>
			</xsl:when>
			
			<!-- UNKNOWN -->
			<xsl:when test="$ds:influenceType = $unknown">
				<xsl:copy-of select="keg:translate('UK_1',190)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:antecedent"/></strong>
				<xsl:if test="string-length($ds:restrictionAntecedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionAntecedent"/></em>
					<xsl:text>] </xsl:text>
				</xsl:if>
				<xsl:copy-of select="keg:translate('DMG-and',200)"/><xsl:text> </xsl:text>
				<strong><xsl:value-of select="$ds:succedent"/></strong>
				<xsl:if test="string-length($ds:restrictionSuccedent) > 0">
					<xsl:text> [</xsl:text> <xsl:copy-of select="keg:translate('DMF-format',201)"/>
					<em><xsl:value-of select="$ds:restrictionSuccedent"/></em>
					<xsl:text>]</xsl:text>
				</xsl:if>
			</xsl:when>
			
		</xsl:choose>
		<xsl:comment><xsl:value-of select="keg:getContentBlockTag('InfluenceText',$InfluenceContentBlockName,'end')"/></xsl:comment>
		
	</xsl:template>
	
	<xsl:template name="ds:InfluenceTMI-graphic">
		<xsl:param name="ds:antecedent"/>
		<xsl:param name="ds:succedent"/>
		<xsl:param name="ds:influenceType"/>
		<xsl:param name="ds:restrictionAntecedent"/>
		<xsl:param name="ds:restrictionSuccedent"/>
		
		<table class="listMI-inner">
			<tr>
				<td class="LMI-antecedent">
					<xsl:value-of select="$ds:antecedent"/><br />
					<em><xsl:value-of select="$ds:restrictionAntecedent"/></em>
				</td>
			</tr>
			<tr>
				<td>
					<xsl:choose>
						<xsl:when test="$ds:influenceType = $positiveInfluence">
							<img src="{$image-url}positiveInfluence.png" alt="{$positiveInfluence}"/>		
						</xsl:when>
						<xsl:when test="$ds:influenceType = $negativeInfluence">
							<img src="{$image-url}negativeInfluence.png" alt="{$negativeInfluence}"/>		
						</xsl:when>
						<xsl:when test="$ds:influenceType = $positiveFrequency">
							<img src="{$image-url}positiveFrequency.png" alt="{$positiveFrequency}"/>		
						</xsl:when>
						<xsl:when test="$ds:influenceType = $negativeFrequency">
							<img src="{$image-url}negativeFrequency.png" alt="{$negativeFrequency}"/>		
						</xsl:when>
						<xsl:when test="$ds:influenceType = $positiveBoolean">
							<img src="{$image-url}positiveBoolean.png" alt="{$positiveBoolean}"/>		
						</xsl:when>
						<xsl:when test="$ds:influenceType = $none">
							<img src="{$image-url}none.png" alt="{$none}"/>		
						</xsl:when>
						<xsl:when test="$ds:influenceType = $functional">
							<img src="{$image-url}functional.png" alt="{$functional}"/>		
						</xsl:when>
						<xsl:when test="$ds:influenceType = $unknown">
							<img src="{$image-url}unknown.png" alt="{$unknown}"/>		
						</xsl:when>
						<xsl:when test="$ds:influenceType = $doNotCare">
							<img src="{$image-url}doNotCare.png" alt="{$doNotCare}"/>		
						</xsl:when>
						<xsl:when test="$ds:influenceType = $someInfluence">
							<img src="{$image-url}someInfluence.png" alt="{$someInfluence}"/>		
						</xsl:when>
					</xsl:choose>
					</td>
			</tr>
			<tr>
				<td class="LMI-succedent">
					<xsl:value-of select="$ds:succedent"/><br />
					<em><xsl:value-of select="$ds:restrictionSuccedent"/></em>
				</td>
			</tr>
		</table>
	</xsl:template>

	

</xsl:stylesheet>
