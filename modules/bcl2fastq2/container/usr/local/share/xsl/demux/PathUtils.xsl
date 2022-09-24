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
 ** \file PathUtils.xsl
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


<xsl:template name="getFlowcellSampleBarcodeSimpleLocalPath">
    <xsl:param name="flowcellId" select="../../../@flowcell-id"/>
    <xsl:param name="projectId" select="../../@name"/>
    <xsl:param name="sampleId" select="../@name"/>
    <xsl:param name="barcodeId" select="@name"/>
    
    <xsl:value-of select="concat($flowcellId, '/', $projectId, '/', $sampleId, '/', $barcodeId, '/lane.html')"/>
</xsl:template>

<xsl:template name="getFlowcellSampleBarcodeSimpleGlobalPath">
    <xsl:variable name="flowcellSummaryPageFileName" ><xsl:call-template name="getFlowcellSampleBarcodeSimpleLocalPath"/></xsl:variable>
    <xsl:value-of select="concat($OUTPUT_DIRECTORY_HTML_PARAM, '/', $flowcellSummaryPageFileName)"/>
</xsl:template>

<xsl:template name="getFlowcellSampleBarcodeLocalPath">
    <xsl:param name="flowcellId" select="../../../@flowcell-id"/>
    <xsl:param name="projectId" select="../../@name"/>
    <xsl:param name="sampleId" select="../@name"/>
    <xsl:param name="barcodeId" select="@name"/>
    
    <xsl:value-of select="concat($flowcellId, '/', $projectId, '/', $sampleId, '/', $barcodeId, '/laneBarcode.html')"/>
</xsl:template>

<xsl:template name="getFlowcellSampleBarcodeGlobalPath">
    <xsl:variable name="flowcellSummaryPageFileName" ><xsl:call-template name="getFlowcellSampleBarcodeLocalPath"/></xsl:variable>
    <xsl:value-of select="concat($OUTPUT_DIRECTORY_HTML_PARAM, '/', $flowcellSummaryPageFileName)"/>
</xsl:template>


<xsl:template name="getFlowcellRefsLocalPath">
    <xsl:value-of select="'tree.html'"/>
</xsl:template>

<xsl:template name="getFlowcellRefsGlobalPath">
    <xsl:variable name="flowcellRefsLocalPath" ><xsl:call-template name="getFlowcellRefsLocalPath"/></xsl:variable>
    <xsl:value-of select="concat($OUTPUT_DIRECTORY_HTML_PARAM, '/', $flowcellRefsLocalPath)"/>
</xsl:template>

</xsl:stylesheet>
