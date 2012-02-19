<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:colours="http://colours.data">
    <xsl:import href="../barchart.xsl" />
    <xsl:output method="xml" omit-xml-declaration="no" indent="yes" version="1.0" encoding="UTF-8"
       doctype-system="-//W3C//DTD SVG 1.0//EN" doctype-public="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" />
    <xsl:template match="data">
        <xsl:call-template name="barChart">
            <xsl:with-param name="xData" select="datum/x" />
            <xsl:with-param name="yData" select="datum/y" />
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>