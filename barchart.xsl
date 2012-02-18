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
	<xsl:import href="common.xsl" />
	<xsl:output method="xml" omit-xml-declaration="no" indent="yes" version="1.0" encoding="UTF-8" doctype-system="-//W3C//DTD SVG 1.0//EN"
		doctype-public="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" />

	<!-- Prints a simple bar chart -->
	<xsl:template name="simpleBarChart">
		<xsl:param name="xData" />
		<xsl:param name="yData" />
		<xsl:param name="width" select="300" />
		<xsl:param name="height" select="300" />

		<!-- constants -->
		<xsl:variable name="barWidth" select="15" />
		<xsl:variable name="leftPadding" select="15" />
		<xsl:variable name="topPadding" select="20" />
		<xsl:variable name="rightPadding" select="10" />
		<xsl:variable name="xCount" select="count($xData)" />
		<xsl:variable name="yCount" select="count($yData)" />

		<xsl:if test="$xCount &gt; 0 and $yCount &gt; 0">
			<xsl:variable name="yDataMax">
				<xsl:call-template name="maximum">
					<xsl:with-param name="numbers" select="$yData" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="xMax"
				select="count($yData)*$barWidth+$leftPadding+$rightPadding" />
			<xsl:variable name="yMax" select="$yDataMax+$topPadding" />
			<xsl:variable name="reductionFactor" select="100 div $yMax" />
			<xsl:variable name="yDelta" select="round($yDataMax div $yCount)*2" />

			<svg:svg version="1.1" width="100%" height="100%" xmlns:svg="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMid"
				viewBox="0 0 {$width} {$height}">
				<svg:g transform="translate(0 100) scale(1 -1)"><!-- Rotate viewport co-ordinates to match user co-ordindates -->

					<!-- Print centre -->
					<svg:circle cx="{$leftPadding}" cy="0" r="1" />

					<!-- Print y-axis -->
					<svg:g transform="translate(0 100) scale(1 -1)">
						<xsl:call-template name="printYAxis">
							<xsl:with-param name="step" select="$yDelta" />
							<xsl:with-param name="xMin" select="$leftPadding" />
							<xsl:with-param name="xMax" select="$xMax" />
							<xsl:with-param name="yMin" select="$topPadding" />
							<xsl:with-param name="yMax" select="$yMax" />
							<xsl:with-param name="reductionFactor" select="$reductionFactor" />
						</xsl:call-template>
					</svg:g>
					<svg:line x1="{$leftPadding}" y1="0" x2="{$leftPadding}" y2="100" stroke="black" stroke-width="2" />
					
					<!-- Print x-axis -->
                    <svg:g transform="scale(1 -1)">
                        <xsl:call-template name="printXAxis">
                            <xsl:with-param name="xData" select="$xData" />
                            <xsl:with-param name="step" select="$barWidth" />
                            <xsl:with-param name="xMin" select="$leftPadding+$barWidth div 2" />
                            <xsl:with-param name="xMax" select="$yCount" />
                        </xsl:call-template>
                    </svg:g>
                    <svg:line x1="{$leftPadding}" y1="0" x2="{$xMax}" y2="0" stroke="black" stroke-width="2" />

					<!-- Print bars -->
					<xsl:for-each select="$yData">
						<xsl:variable name="colour">
							<xsl:call-template name="colour">
								<xsl:with-param name="index" select="position()" />
							</xsl:call-template>
						</xsl:variable>

						<svg:rect x="{$leftPadding+(position() - 1)*$barWidth}" y="0" rx="2" ry="2" width="{$barWidth}" height="{.*$reductionFactor}"
							fill="{$colour}" stroke="black" stroke-width="1" />
					</xsl:for-each>
				</svg:g>
			</svg:svg>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
