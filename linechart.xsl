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
	<xsl:variable name="POINT_RADIUS" select="1.5" />

	<!-- Prints a simple line chart with grid -->
	<xsl:template name="lineChart">
		<xsl:param name="xData" />
		<xsl:param name="yData" />
		<xsl:param name="lineColour" select="'black'" />
		<xsl:param name="pointColour" select="'red'" />
		<xsl:param name="width" select="'100%'" />
		<xsl:param name="height" select="'100%'" />
		<xsl:param name="viewBoxWidth" select="300" />
        <xsl:param name="viewBoxHeight" select="300" />
		<xsl:param name="xDelta" select="15" />
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

		<svg:svg version="1.1" width="{$width}" height="{$height}" preserveAspectRatio="xMinYMin" viewBox="0 0 {$viewBoxWidth} {$viewBoxHeight}"
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
				<xsl:variable name="yScale" select="$_verticalSpan div ($yDataMax - $yDataMin)" />
				<xsl:variable name="yDelta" select="round(($yDataMax - $yDataMin) div $yCount)*2" />
				<xsl:variable name="xMin" select="$leftPadding" />
				<xsl:variable name="xMax" select="$xMin+count($yData)*$xDelta+$rightPadding" />
				<xsl:variable name="xStart" select="$xMin+$xDelta div 2" />
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
				<xsl:variable name="totalHeight" select="round($_verticalSpan+$bottom+2*$yStep)" />
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

				<!-- Print points -->
				<svg:g transform="translate(0 {$yCentre}) scale(1 -1)">
					<xsl:call-template name="_printPoints">
						<xsl:with-param name="yData" select="$yData" />
						<xsl:with-param name="xMin" select="$xStart" />
						<xsl:with-param name="xDelta" select="$xDelta" />
						<xsl:with-param name="yScale" select="$yScale" />
						<xsl:with-param name="lineColour" select="$lineColour" />
						<xsl:with-param name="pointColour" select="$pointColour" />
					</xsl:call-template>
				</svg:g>

				<!-- Print x-axis -->
				<svg:g transform="translate(0 {$yCentre})">
					<xsl:call-template name="printXAxis">
						<xsl:with-param name="xData" select="$xData" />
						<xsl:with-param name="step" select="$xDelta" />
						<xsl:with-param name="xMin" select="$xStart" />
						<xsl:with-param name="xMax" select="$yCount" />
					</xsl:call-template>
					<svg:line x1="{$xMin}" y1="0" x2="{$xMax}" y2="0" stroke="black" stroke-width="2" />
				</svg:g>
			</xsl:if>
		</svg:svg>
	</xsl:template>

	<!-- Prints points and joins them -->
	<xsl:template name="_printPoints">
		<xsl:param name="yData" />
		<xsl:param name="index" select="1" />
		<xsl:param name="xMin" />
		<xsl:param name="xDelta" />
		<xsl:param name="yScale" />
		<xsl:param name="lineColour" />
		<xsl:param name="pointColour" />

		<xsl:variable name="x" select="$xMin+($index - 1)*$xDelta" />
		<xsl:variable name="y" select="$yData[$index]*$yScale" />
		<xsl:if test="$yData[$index+1]">
			<svg:line x1="{$x}" y1="{$y}" x2="{$xMin+($index)*$xDelta}" y2="{$yData[$index+1]*$yScale}"
			    stroke="{$lineColour}" stroke-width="1" xmlns:svg="http://www.w3.org/2000/svg" />
		</xsl:if>
		<svg:circle cx="{$x}" cy="{$y}" r="{$POINT_RADIUS}" fill="white" stroke="{$pointColour}" stroke-width="1"
		    xmlns:svg="http://www.w3.org/2000/svg" />

		<xsl:if test="$index &lt; count($yData)">
			<xsl:call-template name="_printPoints">
				<xsl:with-param name="yData" select="$yData" />
				<xsl:with-param name="index" select="$index+1" />
				<xsl:with-param name="xMin" select="$xMin" />
				<xsl:with-param name="xDelta" select="$xDelta" />
				<xsl:with-param name="yScale" select="$yScale" />
				<xsl:with-param name="lineColour" select="$lineColour" />
				<xsl:with-param name="pointColour" select="$pointColour" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
