<?xml version="1.0"?>
<!--
/**
 ** BCL to FASTQ file converter
 ** Copyright (c) 2007-2015 Illumina, Inc.
 **
 ** This software is covered by the accompanying EULA
 ** and certain third party copyright/licenses, and any user of this
 ** source file is bound by the terms therein.
 **
 ** \file GenerateReport.xsl
 **
 ** \author Roman Petrovski
 ** \author Mauricio Varea
 **/
-->
<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:bcl2fastq="http://www.illumina.com/bcl2fastq"
xmlns:str="http://exslt.org/strings"
xmlns:math="http://exslt.org/math"
xmlns:exsl="http://exslt.org/common"
extension-element-prefixes="exsl"
exclude-result-prefixes="str math"
> 

<xsl:variable name="DEMULTIPLEXING_STATS_XML" select="document($DEMULTIPLEXING_STATS_XML_PARAM)"/>

<xsl:include href="../common/Utils.xsl"/>
<xsl:include href="NameUtils.xsl"/>
<xsl:include href="PathUtils.xsl"/>
<xsl:include href="LaneSummary.xsl"/>
<xsl:include href="FlowcellSummaryPage.xsl"/>

<xsl:variable name="homeFilePath" select="concat($OUTPUT_DIRECTORY_HTML_PARAM, '/index.html')"/>

<xsl:variable name="CSS_FILE_NAME" select="'Report.css'"/>
<xsl:variable name="outputCssFilePath" select="concat($OUTPUT_DIRECTORY_HTML_PARAM, '/', $CSS_FILE_NAME)"/>
<xsl:variable name="inputCssFilePath" select="concat($BCL2FASTQ_FULL_DATADIR_PARAM, '/css/Report.css.xml')"/>


<xsl:template match="/"> 

    <exsl:document href="{$outputCssFilePath}" method="text">
        <xsl:value-of select="document($inputCssFilePath)/css"/>
    </exsl:document>

    <exsl:document href="{$homeFilePath}" method="html" version="4.0" indent="yes">
<html>
    <frameset cols="15%, 85%">
        <frame>
            <xsl:attribute name="src"><xsl:call-template name="getFlowcellRefsLocalPath"/></xsl:attribute>
        </frame>
        <frame name="flowcellsummaryframe">
            <xsl:attribute name="src">
                <xsl:call-template name="getFlowcellSampleBarcodeSimpleLocalPath">
                    <xsl:with-param name="flowcellId">
                        <xsl:value-of select="/Stats/Flowcell/@flowcell-id"/>
                    </xsl:with-param>
                    <xsl:with-param name="projectId" select="'all'"/>
                    <xsl:with-param name="sampleId" select="'all'"/>
                    <xsl:with-param name="barcodeId" select="'all'"/>
                </xsl:call-template>
            </xsl:attribute>
        </frame>
    </frameset>
<body>
<p></p>
</body>
</html>
    </exsl:document>

    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/Stats">
    <xsl:variable name="flowcellsPageFilePath"><xsl:call-template name="getFlowcellRefsGlobalPath"/></xsl:variable>
    <exsl:document href="{$flowcellsPageFilePath}" method="html" version="4.0" indent="yes">

<link rel="stylesheet" href="{$CSS_FILE_NAME}" type="text/css"/>

<table>
        <xsl:for-each select="Flowcell">
            <xsl:variable name="flowcellDisplayName"><xsl:call-template name="getNodeDisplayName"/></xsl:variable>

    <tr><td colspan="4">
            <xsl:for-each select="Project[@name='all']/Sample[@name='all']/Barcode[@name='all']">
                <xsl:element name="a">
                    <xsl:attribute name="href"><xsl:call-template name="getFlowcellSampleBarcodeSimpleLocalPath"/></xsl:attribute>
                    <xsl:attribute name="target">flowcellsummaryframe</xsl:attribute>
                    <xsl:value-of select="$flowcellDisplayName"/>
                </xsl:element>
            </xsl:for-each>
    </td></tr>
            <xsl:for-each select="Project[@name != 'all']">
                <xsl:variable name="projectDisplayName"><xsl:call-template name="getNodeDisplayName"/></xsl:variable>

    <tr><td/><td colspan="3">
                <xsl:for-each select="Sample[@name = 'all']/Barcode[@name='all']">
                    <xsl:element name="a">
                        <xsl:attribute name="href"><xsl:call-template name="getFlowcellSampleBarcodeSimpleLocalPath"/></xsl:attribute>
                        <xsl:attribute name="target">flowcellsummaryframe</xsl:attribute>
                        <xsl:value-of select="$projectDisplayName"/>
                    </xsl:element>
                </xsl:for-each>
    </td></tr>

                <xsl:for-each select="Sample[@name != 'all']">

                    <xsl:variable name="sampleDisplayName"><xsl:call-template name="getNodeDisplayName"/></xsl:variable>

                    <xsl:variable name="items">
                    <xsl:for-each select="Barcode[@name != 'all']">
                        <xsl:variable name="displayName"><xsl:call-template name="getNodeDisplayName"/></xsl:variable>

                        <xsl:variable name="sortName">
                            <xsl:choose>
                                <xsl:when test="@name='unknown'">1</xsl:when>
                                <xsl:otherwise><xsl:value-of select="concat('2', @name)"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

    <tr>
                        <xsl:attribute name="sortname"><xsl:value-of select="$sortName"/></xsl:attribute>
        <td/><td/><td/><td>
                        <xsl:element name="a">
                            <xsl:attribute name="href"><xsl:call-template name="getFlowcellSampleBarcodeSimpleLocalPath"/></xsl:attribute>
                            <xsl:attribute name="target">flowcellsummaryframe</xsl:attribute>
                            <xsl:value-of select="$displayName"/>
                        </xsl:element>
       </td>
    </tr>
                    </xsl:for-each>
                    </xsl:variable>
                    <tr><td/><td/><td colspan="2">
                        <xsl:for-each select="Barcode[@name = 'all']">
                            <xsl:element name="a">
                                <xsl:attribute name="href"><xsl:call-template name="getFlowcellSampleBarcodeSimpleLocalPath"/></xsl:attribute>
                                <xsl:attribute name="target">flowcellsummaryframe</xsl:attribute>
                                <xsl:value-of select="$sampleDisplayName"/>
                            </xsl:element>
                        </xsl:for-each>
                    </td></tr>
                    <xsl:for-each select="exsl:node-set($items)/tr">
                        <xsl:sort select="@sortname"/>
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
</table>
    </exsl:document>
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/Stats/Flowcell/Project/Sample/Barcode">
    <xsl:variable name="flowcellSummaryPageFilePath"><xsl:call-template name="getFlowcellSampleBarcodeGlobalPath"/></xsl:variable>
    <xsl:variable name="flowcellSimpleSummaryPageFilePath"><xsl:call-template name="getFlowcellSampleBarcodeSimpleGlobalPath"/></xsl:variable>

    <exsl:document href="{$flowcellSummaryPageFilePath}" method="html" version="4.0" indent="yes">
        <xsl:call-template name="generateFlowcellSummaryPage">
            <xsl:with-param name="showBarcodes" select="../../../@flowcell-id!='all' and @name='all'"/>
            <xsl:with-param name="alternativeViewRef">../../../../<xsl:call-template name="getFlowcellSampleBarcodeSimpleLocalPath"/></xsl:with-param>
            <xsl:with-param name="alternativeViewText" select="'hide barcodes'"/>
        </xsl:call-template>
    </exsl:document>

    <exsl:document href="{$flowcellSimpleSummaryPageFilePath}" method="html" version="4.0" indent="yes">
        <xsl:call-template name="generateFlowcellSummaryPage">
            <xsl:with-param name="showBarcodes" select="false()"/>
            <xsl:with-param name="alternativeViewRef">../../../../<xsl:call-template name="getFlowcellSampleBarcodeLocalPath"/></xsl:with-param>
            <xsl:with-param name="alternativeViewText" select="'show barcodes'"/>
        </xsl:call-template>
    </exsl:document>

</xsl:template>

<xsl:template match="/Stats/Flowcell/Project[@name='all']/Sample[@name='all']/Barcode[@name='all']">
    <xsl:variable name="flowcellSummaryPageFilePath"><xsl:call-template name="getFlowcellSampleBarcodeGlobalPath"/></xsl:variable>
    <xsl:variable name="flowcellSimpleSummaryPageFilePath"><xsl:call-template name="getFlowcellSampleBarcodeSimpleGlobalPath"/></xsl:variable>

    <exsl:document href="{$flowcellSummaryPageFilePath}" method="html" version="4.0" indent="yes">
        <xsl:call-template name="generateFlowcellSummaryPage">
            <xsl:with-param name="showBarcodes" select="true()"/>
            <xsl:with-param name="alternativeViewRef">../../../../<xsl:call-template name="getFlowcellSampleBarcodeSimpleLocalPath"/></xsl:with-param>
            <xsl:with-param name="alternativeViewText" select="'hide barcodes'"/>
        </xsl:call-template>
    </exsl:document>

    <exsl:document href="{$flowcellSimpleSummaryPageFilePath}" method="html" version="4.0" indent="yes">
        <xsl:call-template name="generateFlowcellSummaryPage">
            <xsl:with-param name="showBarcodes" select="false()"/>
            <xsl:with-param name="alternativeViewRef">../../../../<xsl:call-template name="getFlowcellSampleBarcodeLocalPath"/></xsl:with-param>
            <xsl:with-param name="alternativeViewText" select="'show barcodes'"/>
        </xsl:call-template>
    </exsl:document>

</xsl:template>

</xsl:stylesheet>
