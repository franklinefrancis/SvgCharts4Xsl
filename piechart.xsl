<?xml version="1.0" encoding="UTF-8"?>
<!--
Original Author: Frankline Francis

Copyright (c) 2012, Imaginea. All rights reserved.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND DEVELOPERS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT OWNER OR DEVELOPERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Redistribution and use, with or without modification, are permitted provided that the following conditions are met:
    # Redistribution of source code must retain the above copyright notice, this list of conditions and the disclaimer.
    # Neither the name of Imaginea nor the names of the developers may be used to endorse or promote products derived from
      this software without specific prior written permission.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:math="http://exslt.org/math" xmlns:exsl="http://exslt.org/common">
	<xsl:import href="common.xsl" />

	<!-- Constants -->
	<xsl:variable name="MIN_VERTICAL_SPAN" select="100" />
	<xsl:variable name="CUT_OFF_PERCENTAGE" select="0.05" />
	<xsl:variable name="DEGREE_RADIAN_RATIO" select="0.0175" /> <!-- 1 degree = 0.0175 radians -->
	<xsl:variable name="HALF_CIRCLE_ANGLE" select="3.1415" /> <!-- 180 degrees = 3.14 radians -->
	<xsl:variable name="FULL_CIRCLE_ANGLE" select="$HALF_CIRCLE_ANGLE*2" /> <!-- 360 degrees = 6.29 radians -->

	<!--
	Prints a simple pie chart with legend
	1. Will not work on transformers not supporting EXSLT extension
	2. Percentages may not be accurate
	-->
	<xsl:template name="pieChart">
		<xsl:param name="xData" />
		<xsl:param name="yData" />
		<xsl:param name="width" select="300" />
		<xsl:param name="height" select="300" />
		<xsl:param name="padding" select="10" />
		<xsl:param name="verticalSpan" select="100" />
		<xsl:param name="othersLabel" select="'Others'" />

		<xsl:variable name="xCount" select="count($xData)" />
		<xsl:variable name="yCount" select="count($yData)" />
		<xsl:variable name="_verticalSpan">
		    <xsl:choose>
                <xsl:when test="$verticalSpan &lt; $MIN_VERTICAL_SPAN">
                    <xsl:value-of select="$MIN_VERTICAL_SPAN" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$verticalSpan" />
                </xsl:otherwise>
            </xsl:choose>
		</xsl:variable>

		<svg:svg version="1.1" width="100%" height="100%" preserveAspectRatio="xMinYMid" viewBox="0 0 {$width} {$height}"
		    xmlns:svg="http://www.w3.org/2000/svg">
			<xsl:if test="$xCount &gt; 0 and $yCount &gt; 0">
				<xsl:variable name="_aggregatedData">
					<xsl:call-template name="_aggregate">
						<xsl:with-param name="xData" select="$xData" />
						<xsl:with-param name="yData" select="$yData" />
						<xsl:with-param name="othersLabel" select="$othersLabel" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="aggregatedData" select="exsl:node-set($_aggregatedData)/*" />

				<xsl:call-template name="_printPies">
					<xsl:with-param name="data" select="$aggregatedData" />
					<xsl:with-param name="padding" select="$padding" />
					<xsl:with-param name="radius" select="$verticalSpan div 2" />
				</xsl:call-template>
				<xsl:call-template name="_printLegend">
					<xsl:with-param name="data" select="$aggregatedData" />
					<xsl:with-param name="xStart" select="$padding*2.5+$_verticalSpan" />
					<xsl:with-param name="yStart" select="$padding" />
				</xsl:call-template>
			</xsl:if>
		</svg:svg>
	</xsl:template>

	<!-- Aggregates data to be printed; merges small values under 'Others' -->
	<xsl:template name="_aggregate">
		<xsl:param name="xData" />
		<xsl:param name="yData" />
		<xsl:param name="othersLabel" />
		
		<xsl:variable name="_transformedData">
			<xsl:call-template name="_transform">
				<xsl:with-param name="xData" select="$xData" />
				<xsl:with-param name="yData" select="$yData" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="transformedData" select="exsl:node-set($_transformedData)/*" />

		<!-- filter 'other' items -->
		<xsl:for-each select="$transformedData">
			<xsl:sort select="." order="descending" data-type="number" />
			<xsl:if test="name()='item'">
				<xsl:copy-of select="." />
			</xsl:if>
		</xsl:for-each>

		<!-- add 'Others' with summed up value of 'other' items -->
		<xsl:variable name="sumOfOthers" select="sum($transformedData[name()='other'])" />
		<xsl:if test="$sumOfOthers &gt; 0">
			<xsl:element name="item">
				<xsl:attribute name="name">
                    <xsl:value-of select="$othersLabel" />
                </xsl:attribute>
				<xsl:value-of select="$sumOfOthers" />
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<!-- Converts raw data to a unified result-tree for ease of processing -->
	<xsl:template name="_transform">
		<xsl:param name="xData" />
		<xsl:param name="yData" />

        <xsl:variable name="total" select="sum($yData[. &gt; 0])" />
		<xsl:for-each select="$yData">
			<xsl:variable name="index" select="position()" />

			<xsl:choose>
			    <xsl:when test=". &lt;= 0">
                    <!-- ignore negative values -->
                </xsl:when>
				<!-- collect insignificant values (< cut-off) as 'other' -->
				<xsl:when test="(. div $total) &lt; $CUT_OFF_PERCENTAGE">
					<xsl:element name="other">
						<xsl:value-of select="." />
					</xsl:element>
				</xsl:when>
				<!-- collect significant values (> cut-off%) as 'item' -->
				<xsl:otherwise>
					<xsl:element name="item">
						<xsl:attribute name="name">
                               <xsl:value-of select="$xData[$index]" />
                         </xsl:attribute>
						<xsl:value-of select="." />
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- Prints each pie recursively -->
	<xsl:template name="_printPies">
		<xsl:param name="data" />
		<xsl:param name="total" select="sum($data)" />
		<xsl:param name="padding" />
		<xsl:param name="radius" />
		<xsl:param name="index" select="1" />

		<xsl:variable name="rotationInDegrees" select="270+(360*(sum($data[position()&lt;$index]) div $total))" />
		<xsl:variable name="angleInRadians" select="($data[$index] div $total)*$FULL_CIRCLE_ANGLE" />

		<xsl:call-template name="_printPie">
			<xsl:with-param name="index" select="$index" />
			<xsl:with-param name="rotationInDegrees" select="$rotationInDegrees" />
			<xsl:with-param name="angleInRadians" select="$angleInRadians" />
			<xsl:with-param name="padding" select="$padding" />
			<xsl:with-param name="radius" select="$radius" />
		</xsl:call-template>

		<xsl:call-template name="_printLabel">
			<xsl:with-param name="data" select="$data" />
			<xsl:with-param name="total" select="$total" />
			<xsl:with-param name="index" select="$index" />
			<xsl:with-param name="rotationInRadians" select="$rotationInDegrees*$DEGREE_RADIAN_RATIO" />
			<xsl:with-param name="angleInRadians" select="$angleInRadians div 2" />
			<xsl:with-param name="padding" select="$padding" />
			<xsl:with-param name="radius" select="$radius" />
		</xsl:call-template>

		<xsl:if test="$index &lt; count($data)">
			<xsl:call-template name="_printPies">
				<xsl:with-param name="data" select="$data" />
				<xsl:with-param name="total" select="$total" />
				<xsl:with-param name="padding" select="$padding" />
				<xsl:with-param name="index" select="$index+1" />
				<xsl:with-param name="radius" select="$radius" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- Prints pie -->
	<xsl:template name="_printPie">
		<xsl:param name="index" />
		<xsl:param name="rotationInDegrees" />
		<xsl:param name="angleInRadians" />
		<xsl:param name="padding" />
		<xsl:param name="radius" />

		<xsl:variable name="colour">
			<xsl:call-template name="colour">
				<xsl:with-param name="index" select="$index" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="largeArcFlag">
			<xsl:choose>
				<xsl:when test="$angleInRadians &gt; $HALF_CIRCLE_ANGLE">
					<xsl:value-of select="1" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="0" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="centre" select="$padding+$radius" />

		<svg:path fill="{$colour}" stroke="white" stroke-width="1"
		    transform="translate({$centre} {$centre}) rotate({$rotationInDegrees})"
			d="M {$radius} 0 A {$radius} {$radius} 0 {$largeArcFlag} 1 {$radius*math:cos($angleInRadians)} {$radius*math:sin($angleInRadians)} L 0 0 Z"
			xmlns:svg="http://www.w3.org/2000/svg" />
	</xsl:template>

	<!-- Prints label inside the pie -->
	<xsl:template name="_printLabel">
		<xsl:param name="data" />
		<xsl:param name="total" />
		<xsl:param name="index" />
		<xsl:param name="rotationInRadians" />
		<xsl:param name="angleInRadians" />
		<xsl:param name="padding" />
		<xsl:param name="radius" />

		<xsl:variable name="labelRadius" select="$radius*0.7" />
		<xsl:variable name="cosine" select="math:cos($rotationInRadians)" />
		<xsl:variable name="sine" select="math:sin($rotationInRadians)" />
		<xsl:variable name="x" select="math:cos($angleInRadians)*$labelRadius" />
		<xsl:variable name="y" select="math:sin($angleInRadians)*$labelRadius" />
		<xsl:variable name="centre" select="$padding+$radius" />

		<svg:text text-anchor="middle" fill="black" transform="translate({$centre} {$centre})"
		    font-family="{$FONT}" font-size="{$FONT_SIZE}" xmlns:svg="http://www.w3.org/2000/svg">
			<xsl:attribute name="x">
                 <xsl:value-of select="($x*$cosine)-($y*$sine)" />
            </xsl:attribute>
			<xsl:attribute name="y">
                 <xsl:value-of select="($x*$sine)+($y*$cosine)" />
            </xsl:attribute>
			<xsl:value-of select="round(100*($data[$index] div $total))" />
			<xsl:text>%</xsl:text>
		</svg:text>
	</xsl:template>

	<!-- Prints legend -->
	<xsl:template name="_printLegend">
		<xsl:param name="data" />
		<xsl:param name="xStart" />
		<xsl:param name="yStart" />

		<xsl:for-each select="$data">
			<xsl:variable name="y" select="$yStart+(position()-1)*8" />
			<xsl:variable name="colour">
				<xsl:call-template name="colour">
					<xsl:with-param name="index" select="position()" />
				</xsl:call-template>
			</xsl:variable>

			<svg:rect x="{$xStart}" y="{$y}" rx="1" ry="1" width="10" height="5" fill="{$colour}"
			    stroke="black" stroke-width="0.5" xmlns:svg="http://www.w3.org/2000/svg" />

			<svg:text text-anchor="start" x="{$xStart+15}" y="{$y + 4}" font-family="{$FONT}" font-size="{$FONT_SIZE}"
			    xmlns:svg="http://www.w3.org/2000/svg">
				<xsl:value-of select="@name" />
				<xsl:text> (</xsl:text><xsl:value-of select="." /><xsl:text>)</xsl:text>
			</svg:text>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
