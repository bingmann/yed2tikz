<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:g="http://graphml.graphdrawing.org/xmlns"
   xmlns:y="http://www.yworks.com/xml/graphml"
	>


	<xsl:variable name="version">
		<xsl:text>1.0.0</xsl:text>
	</xsl:variable>


	<xsl:variable name="versiontext">
		<xsl:text>%yed2tikz version:</xsl:text>
		<xsl:value-of select="$version"/>
	</xsl:variable>

	<xsl:output method="text" indent="no" encoding="UTF-8"/>
	<xsl:strip-space elements="*"/> 

	<xsl:variable name="br">
		<xsl:text>&#10;</xsl:text>
	</xsl:variable>
	<xsl:variable name="metric">
		<xsl:text>pt</xsl:text>
	</xsl:variable>

	<xsl:template name="define-color">
		<xsl:param name="colorlist"></xsl:param>
		<xsl:param name="idx"></xsl:param>
		<xsl:param name="end"></xsl:param>
		<xsl:param name="current-color"
			select="(//*[@color] | //*[@textColor])[$idx]/@*[starts-with(.,'#')]"></xsl:param>
		<xsl:if test="not(contains($colorlist,$current-color))">
			<xsl:text>\definecolor{</xsl:text>
			<xsl:value-of select="concat('C',substring($current-color,2,6))" />
			<xsl:text>}{HTML}{</xsl:text>
			<xsl:value-of select="substring($current-color,2)" />
			<xsl:text>}</xsl:text>
			<xsl:copy-of select="$br" />
		</xsl:if>
		<xsl:if test="$idx &lt; $end">
			<xsl:call-template name="define-color">
				<xsl:with-param name="colorlist"
					select="concat($colorlist,$current-color)"></xsl:with-param>
				<xsl:with-param name="idx" select="$idx + 1"></xsl:with-param>
				<xsl:with-param name="end" select="$end"></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template match="g:graphml">
		<xsl:value-of select="$versiontext"/>
		<xsl:value-of select="$br" />
		<!--<xsl:value-of select="count(//*[@color] | //*[@textColor])"/> -->
		<xsl:text>%define color </xsl:text>
		<!-- <xsl:value-of select="count(//@*[starts-with(.,'#')])"/> <xsl:text> 
			</xsl:text> <xsl:value-of select="count(//*[@*[starts-with(.,'#')]])"/> -->
		<xsl:value-of select="$br" />
		<xsl:call-template name="define-color">
			<xsl:with-param name="idx" select="1"></xsl:with-param>
			<xsl:with-param name="end" select="count(//@*[starts-with(.,'#')])"></xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$br" />
		<!-- options inner sep is 0-->
		<xsl:text>\begin{tikzpicture}[inner sep=0pt]</xsl:text>
		<xsl:copy-of select="$br" />
		<xsl:apply-templates></xsl:apply-templates>
		<xsl:text>\end{tikzpicture}</xsl:text>
		<xsl:copy-of select="$br" />
	</xsl:template>

	<xsl:template match="g:node">
		<xsl:text>\node (</xsl:text>
		<xsl:value-of select="@id" />
		<xsl:text>) </xsl:text>
		<xsl:apply-templates></xsl:apply-templates>
		<xsl:copy-of select="$br" />
	</xsl:template>

	<xsl:template match="y:ShapeNode">
		<xsl:text>[</xsl:text>
		<xsl:apply-templates></xsl:apply-templates>
		<xsl:text>] {</xsl:text>
		<xsl:if test="y:NodeLabel/@modelPosition='c'">
			<xsl:value-of select="y:NodeLabel" />
		</xsl:if>
		<xsl:text>};</xsl:text>
		<xsl:if test="y:NodeLabel/@modelPosition !='c' and y:NodeLabel/text()">
			<xsl:call-template name="makeLabelNode"></xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template match="y:GenericNode">
		<xsl:text>[</xsl:text>
		<xsl:apply-templates></xsl:apply-templates>
		<xsl:text>,</xsl:text>
		<xsl:call-template name="getGenericNodeShape">
			<xsl:with-param name="configuration" select="@configuration"></xsl:with-param>
		</xsl:call-template>
		<xsl:text>] {</xsl:text>
		<xsl:if test="y:NodeLabel/@modelPosition='c'">
			<xsl:value-of select="y:NodeLabel" />
		</xsl:if>
		<xsl:text>};</xsl:text>
		<xsl:value-of select="$br"></xsl:value-of>
		<xsl:if test="y:NodeLabel/@modelPosition !='c' and y:NodeLabel/text()">
			<xsl:call-template name="makeLabelNode"></xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="getGenericNodeShape">
		<xsl:param name="configuration"></xsl:param>
		<xsl:choose>
			<xsl:when test="$configuration = 'com.yworks.flowchart.document'">
				<xsl:text>tape,tape bend top=none</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>rectangle</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- template for geometry -->
	<xsl:template match="y:Geometry">
		<xsl:text>minimum height=</xsl:text>
		<xsl:value-of select="concat(@height,$metric)" />
		<xsl:text>, minimum width=</xsl:text>
		<xsl:value-of select="concat(@width,$metric)" />
		<xsl:text>,at={(</xsl:text>
		<xsl:value-of select="concat((@x + @width div 2),$metric)" />
		<xsl:text>,</xsl:text>
		<xsl:value-of select="concat((-1 * @y - @height div 2),$metric)" />
		<xsl:text>)}</xsl:text>
	</xsl:template>

	<xsl:template match="y:Shape">
		<xsl:text>, shape=</xsl:text>
		<xsl:choose>
			<xsl:when test="@type='circle'">
				<xsl:text>circle</xsl:text>
			</xsl:when>
			<xsl:when test="@type='roundrectangle'">
				<xsl:text>rectangle, rounded corners</xsl:text>
			</xsl:when>
			<xsl:when test="@type='parallelogram'">
				<xsl:text>trapezium,trapezium left angle=80,trapezium right angle=100</xsl:text>
			</xsl:when>
			<xsl:when test="@type='triangle'">
				<xsl:text>isosceles triangle,shape border rotate=90</xsl:text>
			</xsl:when>
			<xsl:when test="@type='diamond'">
				<xsl:text>diamond</xsl:text>
			</xsl:when>
			<xsl:when test="@type='trapezoid'">
				<xsl:text>trapezium,trapezium left angle=70,trapezium right angle=70</xsl:text>
			</xsl:when>
			<xsl:when test="@type='trapezoid2'">
				<xsl:text>trapezium,trapezium left angle=110,trapezium right angle=110</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>rectangle</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- color HEX to .. -->
	<xsl:template match="y:Fill">
		<xsl:choose>
			<xsl:when test="@hasColor='false'">
			</xsl:when>
			<xsl:when test="@color='#000000'">
		<xsl:text>, fill</xsl:text>
			</xsl:when>
			<xsl:otherwise>
		<xsl:text>, fill=</xsl:text>
		<xsl:value-of select="concat('C',substring(@color,2,6))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="y:BorderStyle">
		<xsl:choose>
			<xsl:when test="@hasColor='false'">
			</xsl:when>
			<xsl:when test="@color='#000000'">
		<xsl:text>, draw</xsl:text>
			</xsl:when>
			<xsl:otherwise>
		<xsl:text>, draw=</xsl:text>
		<xsl:value-of select="concat('C',substring(@color,2,6))" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>, line width=</xsl:text>
		<xsl:value-of select="concat(@width,$metric)" />
		<xsl:choose>
			<xsl:when test="@type='dashed'">
				<xsl:text>, dashed</xsl:text>
			</xsl:when>
			<xsl:when test="@type='dotted'">
				<xsl:text>, dotted</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- use label node in pgf -->
	<xsl:template match="y:NodeLabel">
		<xsl:text>,align=</xsl:text>
		<xsl:value-of select="@alignment"/>
		<xsl:text>,text width=</xsl:text>
		<xsl:value-of select="@width"/>
		<xsl:choose>
			<xsl:when test="@textColor = '#000000'">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>,text=</xsl:text>
				<xsl:value-of select="concat('C',substring(@textColor,2,6))"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>,font=\fontfamily{</xsl:text>
		<xsl:choose>
			<xsl:when test="@fontFamily='Dialog'">
				<xsl:text>phv</xsl:text>
			</xsl:when>
			<xsl:when test="@fontFamily='DialogInput'">
				<xsl:text>ptm</xsl:text>
			</xsl:when>
			<xsl:when test="@fontFamily='SansSerif'">
				<xsl:text>bch</xsl:text>
			</xsl:when>
			<xsl:when test="@fontFamily='Serif'">
				<xsl:text>pnc</xsl:text>
			</xsl:when>
			<xsl:when test="@fontFamily='Monospaced'">
				<xsl:text>pcr</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>ptm</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}\fontsize{</xsl:text>
		<xsl:value-of select="@fontSize"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="@fontSize + 1"/>
		<xsl:text>}</xsl:text>
		<xsl:choose>
			<xsl:when test="@fontStyle = 'plain'">
			</xsl:when>
			<xsl:when test="@fontStyle = 'bold'">
				<xsl:text>\fontseries{b}</xsl:text>
			</xsl:when>
			<xsl:when test="@fontStyle = 'italic'">
				<xsl:text>\fontshape{it}</xsl:text>
			</xsl:when>
			<xsl:when test="@fontStyle = 'bolditalic'">
				<xsl:text>\fontshape{it}\fontseries{b}</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:text>\selectfont</xsl:text>
	</xsl:template>

	<xsl:template name="makeLabelNode">
		<xsl:if test="y:NodeLabel/@modelPosition !='c' and y:NodeLabel/text()">
			<xsl:text>\node[below right =</xsl:text>
			<xsl:value-of select="y:NodeLabel/@y"></xsl:value-of>
			<xsl:value-of select="$metric" />
			<xsl:text> and </xsl:text>
			<xsl:value-of select="y:NodeLabel/@x"></xsl:value-of>
			<xsl:value-of select="$metric" />
			<xsl:text> of </xsl:text>
			<xsl:value-of select="../../@id"></xsl:value-of>
			<xsl:text>.north west</xsl:text>
			<xsl:apply-templates select="y:NodeLabel"/>
			<xsl:text>]</xsl:text>
			<xsl:text>{</xsl:text>
			<xsl:value-of select="y:NodeLabel" />
			<xsl:text>};</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="create-arrow">
		<xsl:param name="tip"></xsl:param>
		<xsl:choose>
			<xsl:when test="$tip='none'"></xsl:when>
			<xsl:when test="$tip='standard'">
				<xsl:text>stealth'</xsl:text>
			</xsl:when>
			<xsl:when test="$tip='diamond'">
				<xsl:text>diamond</xsl:text>
			</xsl:when>
			<xsl:when test="$tip='white_diamond'">
				<xsl:text>open diamond</xsl:text>
			</xsl:when>
			<xsl:when test="$tip='delta'">
				<xsl:text>triangle 60</xsl:text>
			</xsl:when>
			<xsl:when test="$tip='white_delta'">
				<xsl:text>open triangle 60</xsl:text>
			</xsl:when>
			<xsl:when test="$tip='circle'">
				<xsl:text>*</xsl:text>
			</xsl:when>
			<xsl:when test="$tip='transparent_circle'">
				<xsl:text>o</xsl:text>
			</xsl:when>
			<xsl:when test="$tip='plain'">
				<xsl:text>angle 45</xsl:text>
			</xsl:when>
			<xsl:when test="$tip='short'">
				<xsl:text>stealth</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-- TODO 
				<xsl:value-of select="@source"/>
				-->
				<xsl:text>to</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="y:Arrows">
		<xsl:call-template name="create-arrow">
			<xsl:with-param name="tip" select="@source"/>
		</xsl:call-template>
		<xsl:text>-</xsl:text>
		<xsl:call-template name="create-arrow">
			<xsl:with-param name="tip" select="@target"/>
		</xsl:call-template>
		<xsl:text>,</xsl:text>
	</xsl:template>


	<xsl:template match="g:edge">
		<xsl:apply-templates select="./*/y:PolyLineEdge"/>
		<xsl:apply-templates select="./*/y:BezierEdge"/>
		<xsl:apply-templates select="./*/y:QuadCurveEdge"/>
		<xsl:apply-templates select="./*/*/y:EdgeLabel"/>
	</xsl:template>

	<xsl:template match="y:LineStyle">
		<!-- line width -->
		<xsl:text>line width=</xsl:text>
		<xsl:value-of select="@width"/>
		<xsl:text>pt,</xsl:text>
		<!-- line color -->
		<xsl:choose>
			<xsl:when test="@hasColor='false'">
			</xsl:when>
			<xsl:when test="@color='#000000'">
		<xsl:text>draw,</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-- seperate draw and color, set arrow color-->
				<xsl:text>draw,</xsl:text>
				<xsl:value-of select="concat('C',substring(@color,2,6))" />
				<xsl:text>,</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!-- line type -->
		<xsl:choose>
			<xsl:when test="@type='dashed'">
				<xsl:text>dashed,</xsl:text>
			</xsl:when>
			<xsl:when test="@type='dotted'">
				<xsl:text>dotted,</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="create-anchor">
		<xsl:param name="base"/>
		<xsl:param name="name"/>
		<xsl:param name="x"/>
		<xsl:param name="y"/>
		<xsl:choose>
			<xsl:when test="$x = 0 and $y = 0">
			</xsl:when>
			<!-- four sepcial anchor -->
			<xsl:when test="$x=0">
				<xsl:text>\coordinate (</xsl:text>
				<xsl:value-of select="$name"/>
				<xsl:text>) at (node cs:name=</xsl:text>
				<xsl:value-of select="$base"/>
				<xsl:choose>
					<xsl:when test="$y=0">
						<xsl:text>);</xsl:text>
					</xsl:when>
					<xsl:when test="$y &lt; 0">
						<xsl:text>, anchor=north);</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>, anchor=south);</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$y=0">
				<xsl:text>\coordinate (</xsl:text>
				<xsl:value-of select="$name"/>
				<xsl:text>) at (node cs:name=</xsl:text>
				<xsl:value-of select="$base"/>
				<xsl:choose>
					<xsl:when test="$x &gt; 0">
						<xsl:text>, anchor=east);</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>, anchor=west);</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- 1).  -->
				<xsl:text>\path (node cs:name=</xsl:text>
				<xsl:value-of select="$base"/>
				<xsl:text>)++(</xsl:text>
				<xsl:value-of select="$x"/>
				<xsl:text>pt,</xsl:text>
				<xsl:value-of select="-1 * $y"/>
				<xsl:text>pt) coordinate (</xsl:text>
				<xsl:value-of select="$name"/>
				<xsl:text>){};</xsl:text>
				<xsl:value-of select="$br"/>



				<!-- 2).  
				<xsl:text>\pgfmathparse{atan(</xsl:text>
				<xsl:value-of select="-1 * $y"/>
				<xsl:text>/</xsl:text>
				<xsl:value-of select="$x"/>
				<xsl:text>)</xsl:text>
				<xsl:if test="$x &lt; 0">
					<xsl:text>+180</xsl:text>
				</xsl:if>
				<xsl:text>}</xsl:text>
				<xsl:value-of select="$br"/>

				<xsl:text>\coordinate (</xsl:text>
				<xsl:value-of select="$name"/>
				<xsl:text>)at (node cs:name=</xsl:text>
				<xsl:value-of select="$base"/>
				<xsl:text>, angle=\pgfmathresult);</xsl:text>
				 -->
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$br"/>
	</xsl:template>

	<xsl:template match="y:PolyLineEdge">
		<!--parse source -->
		<xsl:call-template name="create-anchor">
			<xsl:with-param name="base" select="../../@source"/>
			<xsl:with-param name="name" select="concat(../../@id,../../@source)"/>
			<xsl:with-param name="x" select="./y:Path/@sx"/>
			<xsl:with-param name="y" select="./y:Path/@sy"/>
		</xsl:call-template>
		<!-- parse target -->
		<xsl:call-template name="create-anchor">
			<xsl:with-param name="base" select="../../@target"/>
			<xsl:with-param name="name" select="concat(../../@id,../../@target)"/>
			<xsl:with-param name="x" select="./y:Path/@tx"/>
			<xsl:with-param name="y" select="./y:Path/@ty"/>
		</xsl:call-template>

		<!-- parse style -->
		<xsl:text>\path [</xsl:text>
		<xsl:apply-templates select="y:Arrows"/>
		<xsl:apply-templates select="y:LineStyle"/>
		<xsl:text>]</xsl:text>

		<!-- set up source -->
		<xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="./y:Path/@sx=0 and ./y:Path/@sy=0">
				<xsl:value-of select="../../@source"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(../../@id,../../@source)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>)</xsl:text>

		<!-- parse path -->
		<xsl:for-each select="./y:Path/y:Point">
			<xsl:text>--(</xsl:text>
			<xsl:apply-templates select="."/>
			<xsl:text>)</xsl:text>
		</xsl:for-each>
		<xsl:text>--</xsl:text>

		<!-- set up target -->
		<xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="./y:Path/@tx=0 and ./y:Path/@ty=0">
				<xsl:value-of select="../../@target"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(../../@id,../../@target)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>);</xsl:text>
		<xsl:value-of select="$br"/>
	</xsl:template>


	<xsl:template match="y:BezierEdge">
		<!--parse source -->
		<xsl:call-template name="create-anchor">
			<xsl:with-param name="base" select="../../@source"/>
			<xsl:with-param name="name" select="concat(../../@id,../../@source)"/>
			<xsl:with-param name="x" select="./y:Path/@sx"/>
			<xsl:with-param name="y" select="./y:Path/@sy"/>
		</xsl:call-template>
		<!-- parse target -->
		<xsl:call-template name="create-anchor">
			<xsl:with-param name="base" select="../../@target"/>
			<xsl:with-param name="name" select="concat(../../@id,../../@target)"/>
			<xsl:with-param name="x" select="./y:Path/@tx"/>
			<xsl:with-param name="y" select="./y:Path/@ty"/>
		</xsl:call-template>

		<!-- parse style -->
		<xsl:text>\path [</xsl:text>
		<xsl:apply-templates select="y:Arrows"/>
		<xsl:apply-templates select="y:LineStyle"/>
		<xsl:text>]</xsl:text>

		<!-- set up source -->
		<xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="./y:Path/@sx=0 and ./y:Path/@sy=0">
				<xsl:value-of select="../../@source"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(../../@id,../../@source)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>)</xsl:text>

		<!-- parse path -->
		<xsl:for-each select="./y:Path/y:Point[position() mod 2 = 1 ]">
			<xsl:text>.. controls (</xsl:text>
			<xsl:apply-templates select="."/>
			<xsl:text>)</xsl:text>
			<xsl:if test="following-sibling::y:Point[position() =1]">
				<xsl:text>and (</xsl:text>
				<xsl:apply-templates select="following-sibling::y:Point[position() =1]"/>
				<xsl:text>) ..</xsl:text>
				<xsl:if test="following-sibling::y:Point[position() = 2]">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="(following-sibling::y:Point[position() = 1]/attribute::x + following-sibling::y:Point[position() = 2]/attribute::x ) div 2"/>
					<xsl:text>pt,</xsl:text>
					<xsl:value-of select="-1 * (following-sibling::y:Point[position() = 1]/attribute::y + following-sibling::y:Point[position() = 2]/attribute::y ) div 2"/>
					<xsl:text>pt)</xsl:text>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>

		<xsl:choose>
			<xsl:when test="./y:Path/y:Point">
				<xsl:text>..</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-- A straitline in fact -->
				<xsl:text>--</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<!-- set up target -->
		<xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="./y:Path/@tx=0 and ./y:Path/@ty=0">
				<xsl:value-of select="../../@target"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(../../@id,../../@target)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>);</xsl:text>
		<xsl:value-of select="$br"/>
	</xsl:template>

	<xsl:template match="y:QuadCurveEdge">
		<!--parse source -->
		<xsl:call-template name="create-anchor">
			<xsl:with-param name="base" select="../../@source"/>
			<xsl:with-param name="name" select="concat(../../@id,../../@source)"/>
			<xsl:with-param name="x" select="./y:Path/@sx"/>
			<xsl:with-param name="y" select="./y:Path/@sy"/>
		</xsl:call-template>
		<!-- parse target -->
		<xsl:call-template name="create-anchor">
			<xsl:with-param name="base" select="../../@target"/>
			<xsl:with-param name="name" select="concat(../../@id,../../@target)"/>
			<xsl:with-param name="x" select="./y:Path/@tx"/>
			<xsl:with-param name="y" select="./y:Path/@ty"/>
		</xsl:call-template>

		<!-- parse style -->
		<xsl:text>\path [</xsl:text>
		<xsl:apply-templates select="y:Arrows"/>
		<xsl:apply-templates select="y:LineStyle"/>
		<xsl:text>]</xsl:text>

		<!-- set up source -->
		<xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="./y:Path/@sx=0 and ./y:Path/@sy=0">
				<xsl:value-of select="../../@source"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(../../@id,../../@source)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>)</xsl:text>

		<!-- parse path -->
		<xsl:for-each select="./y:Path/y:Point">
			<xsl:text>.. controls (</xsl:text>
			<xsl:apply-templates select="."/>
			<xsl:text>)</xsl:text>
			<xsl:if test="following-sibling::y:Point[position() =1]">
				<xsl:text>..(</xsl:text>
				<xsl:value-of select="(following-sibling::y:Point[position() = 1]/attribute::x + @x ) div 2"/>
				<xsl:text>pt,</xsl:text>
				<xsl:value-of select="-1 * (following-sibling::y:Point[position() = 1]/attribute::y + @y ) div 2"/>
				<xsl:text>pt)</xsl:text>
			</xsl:if>
		</xsl:for-each>

		<xsl:choose>
			<xsl:when test="./y:Path/y:Point">
				<xsl:text>..</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-- A straitline in fact -->
				<xsl:text>--</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<!-- set up target -->
		<xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="./y:Path/@tx=0 and ./y:Path/@ty=0">
				<xsl:value-of select="../../@target"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(../../@id,../../@target)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>);</xsl:text>
		<xsl:value-of select="$br"/>
	</xsl:template>

	<xsl:template match="y:Point">
		<xsl:value-of select="@x"/>
		<xsl:text>pt,</xsl:text>
		<xsl:value-of select="-1 * @y"/>
		<xsl:text>pt</xsl:text>
	</xsl:template>

	<!-- use edge label node in pgf -->
	<xsl:template match="y:EdgeLabel">
		<xsl:text>\path </xsl:text>

		<xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="../y:Path/@sx=0 and ../y:Path/@sy=0">
				<xsl:value-of select="../../../@source"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(../../../@id,../../../@source)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>) ++(</xsl:text>
		<xsl:value-of select="@x + @width div 2"/>
		<xsl:text>pt,</xsl:text>
		<xsl:value-of select="-@y - @height div 2"/>
		<xsl:text>pt)node[align=</xsl:text>
		<xsl:value-of select="@alignment"/>
		<xsl:text>,text width=</xsl:text>
		<xsl:value-of select="@width"/>
		<xsl:choose>
			<xsl:when test="@textColor = '#000000'">
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>,text=</xsl:text>
				<xsl:value-of select="concat('C',substring(@textColor,2,6))"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>,font=\fontfamily{</xsl:text>
		<xsl:choose>
			<xsl:when test="@fontFamily='Dialog'">
				<xsl:text>phv</xsl:text>
			</xsl:when>
			<xsl:when test="@fontFamily='DialogInput'">
				<xsl:text>ptm</xsl:text>
			</xsl:when>
			<xsl:when test="@fontFamily='SansSerif'">
				<xsl:text>bch</xsl:text>
			</xsl:when>
			<xsl:when test="@fontFamily='Serif'">
				<xsl:text>pnc</xsl:text>
			</xsl:when>
			<xsl:when test="@fontFamily='Monospaced'">
				<xsl:text>pcr</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>ptm</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}\fontsize{</xsl:text>
		<xsl:value-of select="@fontSize"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="@fontSize + 1"/>
		<xsl:text>}</xsl:text>
		<xsl:choose>
			<xsl:when test="@fontStyle = 'plain'">
			</xsl:when>
			<xsl:when test="@fontStyle = 'bold'">
				<xsl:text>\fontseries{b}</xsl:text>
			</xsl:when>
			<xsl:when test="@fontStyle = 'italic'">
				<xsl:text>\fontshape{it}</xsl:text>
			</xsl:when>
			<xsl:when test="@fontStyle = 'bolditalic'">
				<xsl:text>\fontshape{it}\fontseries{b}</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:text>\selectfont]</xsl:text>
		<xsl:text>{</xsl:text>
		<xsl:value-of select="text()"/>
		<xsl:text>};</xsl:text>
	</xsl:template>

</xsl:stylesheet>
