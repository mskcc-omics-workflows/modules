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
 ** \file FlowcellSummaryPage.xsl
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


<xsl:template name="generateFlowcellYieldSummaryTable">
    <xsl:param name="projectNode" select="../.."/>
    <xsl:param name="sampleId" select="../@name"/>
    <xsl:param name="barcodeId" select="@name"/>


    <xsl:variable name="clustersPF" select="sum($projectNode/Sample[@name=$sampleId]/Barcode[@name=$barcodeId]/Lane/Tile/Pf/ClusterCount)"/>
    <xsl:variable name="clustersRaw" select="sum($projectNode/Sample[@name=$sampleId]/Barcode[@name=$barcodeId]/Lane/Tile/Raw/ClusterCount)"/>
        
    <xsl:variable name="flowcellYieldPf" select="sum($projectNode/Sample[@name=$sampleId]/Barcode[@name=$barcodeId]/Lane/Tile/Pf/Read/Yield)"/>

    <table border="1" ID="ReportTable">
    <tr><th>Clusters (Raw)</th><th>Clusters(PF)</th><th>Yield (MBases)</th></tr>
    <tr>
        <td><xsl:value-of select="format-number($clustersRaw, '###,###,###,###,###')"/></td>
        <td><xsl:value-of select="format-number($clustersPF, '###,###,###,###,###')"/></td>
        <td><xsl:value-of select="format-number(round($flowcellYieldPf) div 1000000, '###,###,###,###,###')"/></td>
    </tr>
    </table>
</xsl:template>

<xsl:template name="generateFlowcellSummaryTables">
    <xsl:param name="flowcellNode" select="../../.."/>
    <xsl:param name="projectId" select="../../@name"/>
    <xsl:param name="sampleId" select="../@name"/>
    <xsl:param name="barcodeId" select="@name"/>

    <xsl:variable name="conversionStatsFlowcellNode" 
        select="/Stats/Flowcell[@flowcell-id=$flowcellNode/@flowcell-id]"/>

    <xsl:call-template name="generateFlowcellYieldSummaryTable">
        <xsl:with-param name="projectNode" select="$conversionStatsFlowcellNode/Project[@name=$projectId]"/>
    </xsl:call-template>

</xsl:template>

<xsl:template name="generateFlowcellSummaryPage">
    <xsl:param name="flowcellNode" select="../../.."/>
    <xsl:param name="projectId" select="../../@name"/>
    <xsl:param name="sampleId" select="../@name"/>
    <xsl:param name="barcodeId" select="@name"/>
    <xsl:param name="showBarcodes"/>
    <xsl:param name="alternativeViewRef"/>
    <xsl:param name="alternativeViewText"/>
<html>
<link rel="stylesheet" href="../../../../{$CSS_FILE_NAME}" type="text/css"/>
<body>

    <table width="100%">
        <tr>
            <td>
    <p><xsl:call-template name="getBarcodeDisplayPath"/></p>
            </td>
            <td>
    <xsl:if test="../../../@flowcell-id!='all' and $barcodeId='all'">
                <p align="right">
    <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="$alternativeViewRef"/></xsl:attribute>
        <xsl:value-of select="$alternativeViewText"/>
    </xsl:element>
                </p>
    </xsl:if>
            </td>
        </tr>
    </table>

<h2>Flowcell Summary</h2>
    <xsl:call-template name="generateFlowcellSummaryTables"/>

<h2>Lane Summary</h2>
    <xsl:call-template name="generateExpandedLaneResultsSummaryTable">
        <xsl:with-param name="showBarcodes" select="$showBarcodes"/>
    </xsl:call-template>

    <xsl:if test="'unknown'=$barcodeId or 'all'=$projectId and 'all'=$sampleId and 'all'=$barcodeId and $showBarcodes">
<h2>Top Unknown Barcodes</h2>
        <xsl:call-template name="generateUnknownBarcodesTable"/>
    </xsl:if>

<p></p>


</body>
</html>

</xsl:template>

</xsl:stylesheet>
