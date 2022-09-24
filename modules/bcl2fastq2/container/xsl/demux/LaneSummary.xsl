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
 ** \file LaneSummary.xsl
 **
 ** \author Roman Petrovski
 ** \author Mauricio Varea
 **/
-->
<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:str="http://exslt.org/strings"
xmlns:math="http://exslt.org/math"
xmlns:bcl2fastq="http://www.illumina.com/bcl2fastq"
>

<xsl:template name="generateConversionStatsCells">
    <xsl:param name="flowcellNode" select="../../../.."/>
    <xsl:param name="projectId" select="../../../@name"/>
    <xsl:param name="sampleId" select="../../@name"/>
    <xsl:param name="barcodeId" select="../@name"/>
    <xsl:variable name="laneNumber" select="@number"/>

    <xsl:variable name="conversionStatsFlowcellNode" 
        select="/Stats/Flowcell[@flowcell-id=$flowcellNode/@flowcell-id]"/>

    <xsl:variable name="conversionStatsBarcodeLaneNode" select="$conversionStatsFlowcellNode/Project[@name=$projectId]/Sample[@name=$sampleId]/Barcode[@name=$barcodeId]/Lane[@number=$laneNumber]"/>

    <xsl:variable name="conversionStatsLaneNode" select="$conversionStatsFlowcellNode/Project[@name='all']/Sample[@name='all']/Barcode[@name='all']/Lane[@number=$laneNumber]"/>

    <xsl:variable name="clustersRaw" select="sum($conversionStatsBarcodeLaneNode/Tile/Raw/ClusterCount)"/>
    <xsl:variable name="clustersPF" select="sum($conversionStatsBarcodeLaneNode/Tile/Pf/ClusterCount)"/>

    <xsl:variable name="yieldPF" select="sum($conversionStatsBarcodeLaneNode/Tile/Pf/Read/Yield)"/>

    <xsl:variable name="yieldPFQ30" select="sum($conversionStatsBarcodeLaneNode/Tile/Pf/Read/YieldQ30)"/>

    <xsl:variable name="qualityScoreSumPF" select="sum($conversionStatsBarcodeLaneNode/Tile/Pf/Read/QualityScoreSum)"/>

    <td><xsl:value-of select="format-number(round($yieldPF div 1000000), '###,###,###,###,###')"/></td>
    <td><xsl:if test="0 != $clustersRaw"><xsl:value-of select="format-number($clustersPF div $clustersRaw * 100, '0.00')"/></xsl:if></td>
    <td><xsl:if test="0 != $yieldPF"><xsl:value-of select="format-number($yieldPFQ30 div $yieldPF * 100, '0.00')"/></xsl:if></td>
    <td><xsl:if test="0 != $yieldPF"><xsl:value-of select="format-number($qualityScoreSumPF div $yieldPF, '0.00')"/></xsl:if></td>

</xsl:template>

<xsl:template name="generateDemultiplexingStatsCells">
    <xsl:param name="flowcellNode" select="../../../.."/>
    <xsl:param name="projectId" select="../../../@name"/>
    <xsl:param name="sampleId" select="../../@name"/>
    <xsl:param name="barcodeId" select="../@name"/>
    <xsl:variable name="laneNumber" select="@number"/>

    <xsl:variable name="conversionStatsFlowcellNode" 
        select="/Stats/Flowcell[@flowcell-id=$flowcellNode/@flowcell-id]"/>
    <xsl:variable name="conversionStatsBarcodeLaneNode" select="$conversionStatsFlowcellNode/Project[@name=$projectId]/Sample[@name=$sampleId]/Barcode[@name=$barcodeId]/Lane[@number=$laneNumber]"/>

    <xsl:variable name="demuxStatsFlowcellNode" 
        select="$DEMULTIPLEXING_STATS_XML/Stats/Flowcell[@flowcell-id=$flowcellNode/@flowcell-id]"/>

    <xsl:variable name="demuxStatsBarcodeLaneNode" select="$demuxStatsFlowcellNode/
Project[@name=$projectId]/Sample[@name=$sampleId]/Barcode[@name=$barcodeId]/Lane[@number=$laneNumber]"/>

    <xsl:variable name="demuxStatsLaneNode" select="$demuxStatsFlowcellNode/
Project[@name='all']/Sample[@name='all']/Barcode[@name='all']/Lane[@number=$laneNumber]"/>

    <xsl:variable name="clustersPF">
        <xsl:choose>
            <xsl:when test="0 != $demuxStatsBarcodeLaneNode/BarcodeCount"><xsl:value-of select="$demuxStatsBarcodeLaneNode/BarcodeCount"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="sum($conversionStatsBarcodeLaneNode/Tile/PF/ClusterCount)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="laneClustersPF">
        <xsl:choose>
            <xsl:when test="0 != $demuxStatsLaneNode/BarcodeCount"><xsl:value-of select="$demuxStatsLaneNode/BarcodeCount"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$clustersPF"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>    
    <xsl:variable name="perfectBarcodePF" select="$demuxStatsBarcodeLaneNode/PerfectBarcodeCount"/>
    <xsl:variable name="oneMismatchBarcodePF" select="$demuxStatsBarcodeLaneNode/OneMismatchBarcodeCount"/>

    <td><xsl:value-of select="format-number($clustersPF, '###,###,###,###,###')"/></td>
    <td><xsl:if test="0 != $laneClustersPF"><xsl:value-of select="format-number($clustersPF div $laneClustersPF * 100, '0.00')"/></xsl:if></td>
    <xsl:element name="td">
        <xsl:choose>
            <xsl:when test="$sampleId='unknown'">N/A</xsl:when>
            <xsl:otherwise>
                <xsl:if test="0 != $clustersPF">
                    <xsl:value-of select="format-number($perfectBarcodePF div $clustersPF * 100, '0.00')"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:element>
    <xsl:element name="td">
        <xsl:choose>
            <xsl:when test="$sampleId='unknown'">N/A</xsl:when>
            <xsl:otherwise>
                <xsl:if test="0 != $clustersPF">
                    <xsl:value-of select="format-number($oneMismatchBarcodePF div $clustersPF * 100, '0.00')"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:element>

</xsl:template>

<xsl:template name="generateExpandedLaneResultsSummaryTable">
    <xsl:param name="flowcellNode" select="../../.."/>
    <xsl:param name="projectId" select="../../@name"/>
    <xsl:param name="sampleId" select="../@name"/>
    <xsl:param name="barcodeId" select="@name"/>
    <xsl:param name="showBarcodes"/>

    <table border="1" ID="ReportTable">

    <tr>
        <th>Lane</th>
        <xsl:if test="$showBarcodes and $projectId='all'">
            <th>Project</th>
        </xsl:if>
        <xsl:if test="$showBarcodes and $sampleId='all'">
            <th>Sample</th>
        </xsl:if>
        <xsl:if test="$showBarcodes and $barcodeId='all'">
            <th>Barcode sequence</th>
        </xsl:if>

        <th>PF Clusters</th>
        <th>% of the<br/>lane</th>
        <th>% Perfect<br/>barcode</th>
        <th>% One mismatch<br/>barcode</th>

        <th>Yield (Mbases)</th>
        <th>% PF<br/>Clusters</th>
        <th>% >= Q30<br/>bases</th>
        <th>Mean Quality<br/>Score</th>
    </tr>

    <xsl:for-each select="$flowcellNode/
Project[(true()=$showBarcodes and (($projectId='all' and @name!='all') or ($projectId!='all' and @name=$projectId))) or 
(false()=$showBarcodes and @name=$projectId)]/
Sample[(true()=$showBarcodes and (($sampleId='all' and @name!='all') or ($sampleId!='all' and @name=$sampleId))) or 
(false()=$showBarcodes and @name=$sampleId)]/
Barcode[(true()=$showBarcodes and (($barcodeId='all' and @name!='all') or ($barcodeId!='all' and @name=$barcodeId))) or
(false()=$showBarcodes and @name=$barcodeId)]/
Lane">
    <xsl:sort select="@number"/>
    <xsl:sort select="../../../@name"/>
    <xsl:sort select="../../@name"/>
    <xsl:sort select="../@name"/>

    <tr>
        <td><xsl:value-of select="@number"/></td>
        <xsl:if test="$showBarcodes and $projectId='all'">
            <td><xsl:value-of select="../../../@name"/></td>
        </xsl:if>
        <xsl:if test="$showBarcodes and $sampleId='all'">
            <!--td><xsl:value-of select="../../@name"/></td-->
            <xsl:element name="td">
                <xsl:if test="../../@name='unknown'">
                    <xsl:attribute name="style">font-style:italic</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="../../@name"/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="$showBarcodes and $barcodeId='all'">
            <xsl:element name="td">
                <xsl:if test="../@name='unknown'">
                    <xsl:attribute name="style">font-style:italic</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="../@name"/>
            </xsl:element>
        </xsl:if>
        <xsl:call-template name="generateDemultiplexingStatsCells"/>
        <xsl:call-template name="generateConversionStatsCells">
        </xsl:call-template>
    </tr>
    </xsl:for-each>

    </table>

</xsl:template>


<xsl:template name="generateUnknownBarcodesTable">
    <xsl:param name="flowcellNode" select="../../.."/>

<table border="1" ID="ReportTable">

<tr>
    <xsl:for-each select="/Stats/Flowcell[@flowcell-id=$flowcellNode/@flowcell-id]/Lane">
    <xsl:element name="th">
        <xsl:if test="position()!=1">
            <xsl:attribute name="style">border-left:double</xsl:attribute>
        </xsl:if>
        Lane
    </xsl:element>
    <th>Count</th>
    <th>Sequence</th>
    </xsl:for-each>
</tr>
<tr>
    <xsl:for-each select="/Stats/Flowcell[@flowcell-id=$flowcellNode/@flowcell-id]/Lane">
    <xsl:element name="th">
        <xsl:attribute name="rowspan"><xsl:value-of select="1+count(TopUnknownBarcodes/Barcode)"/></xsl:attribute>
        <xsl:if test="position()!=1">
            <xsl:attribute name="style">border-left:double</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@number"/>
    </xsl:element>
    <td><xsl:value-of select="format-number(TopUnknownBarcodes/Barcode[position()=1]/@count,'###,###,###,###,###')"/></td>
    <td><xsl:value-of select="TopUnknownBarcodes/Barcode[position()=1]/@sequence"/></td>
    </xsl:for-each>
</tr>
    <xsl:for-each select="/Stats/Flowcell[@flowcell-id=$flowcellNode/@flowcell-id]/Lane[position()=1]/TopUnknownBarcodes/Barcode">
        <xsl:variable name="position" select="position()"/>
<tr>
        <xsl:if test="position()!=1">
        <xsl:for-each select="/Stats/Flowcell[@flowcell-id=$flowcellNode/@flowcell-id]/Lane">
    <td><xsl:value-of select="format-number(TopUnknownBarcodes/Barcode[position()=$position]/@count,'###,###,###,###,###')"/></td>
    <td><xsl:value-of select="TopUnknownBarcodes/Barcode[position()=$position]/@sequence"/></td>
        </xsl:for-each>
        </xsl:if>
</tr>
    </xsl:for-each>

</table>

</xsl:template>

</xsl:stylesheet>
