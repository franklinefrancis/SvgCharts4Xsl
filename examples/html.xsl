<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="exsl">
	<xsl:import href="../charts.xsl" />
	<xsl:output method="html" indent="yes" omit-xml-declaration="yes" />
	<xsl:template match="/">
	    <xsl:text disable-output-escaping="yes">&lt;!doctype html&gt;</xsl:text>
		<html>
			<body>
				<xsl:variable name="data">
					<p>
						<xsl:call-template name="lineChart">
							<xsl:with-param name="xData" select="/data/x" />
							<xsl:with-param name="yData" select="/data/y" />
							<xsl:with-param name="width" select="'640px'" />
							<xsl:with-param name="height" select="'250px'" />
							<xsl:with-param name="viewBoxWidth" select="325" />
                            <xsl:with-param name="viewBoxHeight" select="150" />
						</xsl:call-template>
					</p>
					<p>
						<xsl:call-template name="barChart">
							<xsl:with-param name="xData" select="/data/x" />
							<xsl:with-param name="yData" select="/data/y" />
							<xsl:with-param name="width" select="'640px'" />
							<xsl:with-param name="height" select="'250px'" />
							<xsl:with-param name="viewBoxWidth" select="325" />
                            <xsl:with-param name="viewBoxHeight" select="150" />
						</xsl:call-template>
					</p>
					<p>
						<xsl:call-template name="pieChart">
							<xsl:with-param name="xData" select="/data/x" />
							<xsl:with-param name="yData" select="/data/y" />
							<xsl:with-param name="width" select="'640px'" />
							<xsl:with-param name="height" select="'250px'" />
							<xsl:with-param name="viewBoxWidth" select="325" />
                            <xsl:with-param name="viewBoxHeight" select="150" />
						</xsl:call-template>
					</p>
				</xsl:variable>
				<xsl:call-template name="removePrefix">
					<xsl:with-param name="data" select="exsl:node-set($data)/*" />
				</xsl:call-template>
			</body>
		</html>
	</xsl:template>

    <!-- Removes namespace prefix -->
	<xsl:template name="removePrefix">
		<xsl:param name="data" />
		<xsl:for-each select="$data">
			<xsl:element name="{local-name()}">
				<xsl:for-each select="@*">
					<xsl:attribute name="{local-name()}">
                        <xsl:value-of select="." />
                    </xsl:attribute>
				</xsl:for-each>
				<xsl:value-of select="text()" />
				<xsl:call-template name="removePrefix">
					<xsl:with-param name="data" select="exsl:node-set(.)/*" />
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
