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
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Constants -->
	<xsl:variable name="COLOURS" select="document('colours.xml')/colours/colour" />
	<xsl:variable name="FONT" select="'Arial'" />
	<xsl:variable name="FONT_SIZE" select="5" />

	<!-- Helper template to return the maximum of given items -->
	<xsl:template name="maximum">
		<xsl:param name="numbers" />

		<xsl:for-each select="$numbers">
			<xsl:sort select="." data-type="number" order="descending" />
			<xsl:if test="position()=1">
				<xsl:value-of select="." />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Helper template to return the minimum of given items -->
	<xsl:template name="minimum">
		<xsl:param name="numbers" />

		<xsl:for-each select="$numbers">
			<xsl:sort select="." data-type="number" order="ascending" />
			<xsl:if test="position()=1">
				<xsl:value-of select="." />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Helper template to return the absolute value -->
	<xsl:template name="absolute">
		<xsl:param name="number" />

		<xsl:choose>
			<xsl:when test="$number &gt;= 0">
				<xsl:value-of select="$number" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="- $number" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Returns a named colour for the given index -->
	<xsl:template name="colour">
		<xsl:param name="index" />
		<xsl:value-of select="$COLOURS[@index=($index mod count($COLOURS))]" />
	</xsl:template>

	<!-- Helper template to print x-axis -->
	<xsl:template name="printXAxis">
		<xsl:param name="xData" />
		<xsl:param name="step" />
		<xsl:param name="xMin" />
		<xsl:param name="xMax" />

		<xsl:for-each select="$xData">
			<xsl:if test="position() &lt;= $xMax">
				<svg:text writing-mode="tb" x="{$xMin+(position() - 1)*$step}"
					dy="5" fill="black" font-family="{$FONT}" font-weight="bold"
					font-size="{$FONT_SIZE}" xmlns:svg="http://www.w3.org/2000/svg">
					<xsl:value-of select="." />
				</svg:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Helper template to print y-axis -->
	<xsl:template name="printYAxis">
		<xsl:param name="index" />
		<xsl:param name="step" />
		<xsl:param name="xMin" />
		<xsl:param name="xMax" />
		<xsl:param name="yMin" />
		<xsl:param name="yMax" />
		<xsl:param name="yScale" />

		<xsl:variable name="labelDelta" select="$FONT_SIZE div 2" />
		<xsl:if test="$index &lt; $yMax">
			<xsl:variable name="y">
				<xsl:choose>
					<xsl:when test="$yMin &lt; 0">
						<xsl:value-of select="floor($yScale*($yMax - $index + $step div 2))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="floor($yScale*($yMax - $index))" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<svg:text x="{($xMin - 5)}" y="{($y + $labelDelta)}"
				text-anchor="end" fill="black" font-family="{$FONT}" font-weight="bold"
				font-size="{$FONT_SIZE}" xmlns:svg="http://www.w3.org/2000/svg">
				<xsl:value-of select="$index" />
			</svg:text>
			<svg:line x1="{$xMin}" y1="{$y}" x2="{$xMax}" y2="{$y}"
				stroke="grey" stroke-width="0.25" xmlns:svg="http://www.w3.org/2000/svg" />

			<xsl:call-template name="printYAxis">
				<xsl:with-param name="index" select="$index+$step" />
				<xsl:with-param name="step" select="$step" />
				<xsl:with-param name="xMin" select="$xMin" />
				<xsl:with-param name="xMax" select="$xMax" />
				<xsl:with-param name="yMin" select="$yMin" />
				<xsl:with-param name="yMax" select="$yMax" />
				<xsl:with-param name="yScale" select="$yScale" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
