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

	<!-- Constants -->
	<xsl:variable name="MIN_VERTICAL_SPAN" select="75" />

	<!-- Prints a simple bar chart with grid -->
	<xsl:template name="barChart">
		<xsl:param name="xData" />
		<xsl:param name="yData" />
		<xsl:param name="width" select="300" />
		<xsl:param name="height" select="300" />
		<xsl:param name="barWidth" select="15" />
		<xsl:param name="leftPadding" select="20" />
		<xsl:param name="rightPadding" select="10" />
		<xsl:param name="verticalSpan" select="100" />

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
				<xsl:variable name="yDataMin">
					<xsl:call-template name="minimum">
						<xsl:with-param name="numbers" select="$yData" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="yDataMax">
					<xsl:call-template name="maximum">
						<xsl:with-param name="numbers" select="$yData" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="yScale"	select="$_verticalSpan div ($yDataMax - $yDataMin)" />
				<xsl:variable name="yDelta"	select="round(($yDataMax - $yDataMin) div $yCount)*2" />
				<xsl:variable name="xMin" select="$leftPadding" />
				<xsl:variable name="xMax" select="$xMin+count($yData)*$barWidth+$rightPadding" />
				<xsl:variable name="yMin">
					<xsl:choose>
						<xsl:when test="$yDataMin &lt; 0">
							<xsl:value-of select="$yDataMin - $yDelta" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="0" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="yMax" select="$yDataMax+$yDelta" />
				<xsl:variable name="bottom">
					<xsl:choose>
						<xsl:when test="$yDataMin &lt; 0">
							<xsl:value-of select="- $_verticalSpan" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="0" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="yStep" select="$yDelta*$yScale" />
				<xsl:variable name="totalHeight" select="floor($_verticalSpan+$bottom+2*$yStep)" />
				<xsl:variable name="yStart">
					<xsl:choose>
						<xsl:when test="$yDataMin &lt; 0">
							<xsl:value-of select="$bottom - $yStep" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$bottom" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="yCentre">
					<xsl:choose>
						<xsl:when test="$yMin &lt; 0">
							<xsl:value-of select="floor($yScale*($yMax + $yDelta div 2))" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="floor($yScale*$yMax)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>


				<!-- Print centre -->
				<svg:circle cx="{$xMin}" cy="{$yCentre}" r="1" />

				<!-- Print y-axis -->
				<xsl:call-template name="printYAxis">
					<xsl:with-param name="index" select="$yMin" />
					<xsl:with-param name="step" select="$yDelta" />
					<xsl:with-param name="xMin" select="$xMin" />
					<xsl:with-param name="xMax" select="$xMax" />
					<xsl:with-param name="yMin" select="$yMin" />
					<xsl:with-param name="yMax" select="$yMax" />
					<xsl:with-param name="yScale" select="$yScale" />
				</xsl:call-template>
				<svg:g transform="translate(0 {$totalHeight}) scale(1 -1)">
					<svg:line x1="{$xMin}" y1="{$yStart}" x2="{$xMin}" y2="{$totalHeight}"
						stroke="black" stroke-width="2" />
				</svg:g>

				<!-- Print bars -->
				<svg:g transform="translate(0 {$yCentre}) scale(1 -1)">
					<xsl:for-each select="$yData">
						<xsl:variable name="colour">
							<xsl:call-template name="colour">
								<xsl:with-param name="index" select="position()" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="height" select=".*$yScale" />
						<xsl:variable name="absoluteHeight">
							<xsl:call-template name="absolute">
								<xsl:with-param name="number" select="floor($height)" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="y">
							<xsl:choose>
								<xsl:when test="$height &gt;= 0">
									<xsl:value-of select="0" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$height" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<svg:rect x="{$xMin+(position() - 1)*$barWidth}" y="{$y}" rx="2" ry="2"
						    width="{$barWidth}" height="{$absoluteHeight}"
							fill="{$colour}" stroke="black" stroke-width="1" />
					</xsl:for-each>
				</svg:g>

				<!-- Print x-axis -->
				<svg:g transform="translate(0 {$yCentre})">
					<xsl:call-template name="printXAxis">
						<xsl:with-param name="xData" select="$xData" />
						<xsl:with-param name="step" select="$barWidth" />
						<xsl:with-param name="xMin" select="$xMin+$barWidth div 2" />
						<xsl:with-param name="xMax" select="$yCount" />
					</xsl:call-template>
					<svg:line x1="{$xMin}" y1="0" x2="{$xMax}" y2="0" stroke="black" stroke-width="2" />
				</svg:g>
			</xsl:if>
		</svg:svg>
	</xsl:template>
</xsl:stylesheet>
