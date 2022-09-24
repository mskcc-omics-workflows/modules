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
 ** \file NameUtils.xsl
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
<xsl:template name="getNodeDisplayName">
    <xsl:param name="node" select="."/>

    <xsl:choose>
        <xsl:when test="name()='Flowcell'">
            <xsl:choose>
                <xsl:when test="@flowcell-id=''">[unknown flowcell]</xsl:when>
                <xsl:otherwise><xsl:value-of select="@flowcell-id"/></xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="name()='Project'">
            <xsl:choose>
                <xsl:when test="@name='all'">[all projects]</xsl:when>
                <xsl:when test="@name='default'">[default project]</xsl:when>
                <xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="name()='Sample'">
            <xsl:choose>
                <xsl:when test="@name='all'">[all samples]</xsl:when>
                <xsl:when test="@name='unknown'">[unknown sample]</xsl:when>
                <xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="name()='Barcode'">
            <xsl:choose>
                <xsl:when test="@name='all'">[all barcodes]</xsl:when>
                <xsl:when test="@name='unknown'">[unknown barcode]</xsl:when>
                <xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
            </xsl:choose>
        </xsl:when>

        <xsl:otherwise>
                <xsl:value-of select="@name"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="getBarcodeDisplayPath">
    <p>
        <xsl:for-each select="../../.."><xsl:call-template name="getNodeDisplayName"/></xsl:for-each> /
        <xsl:for-each select="../.."><xsl:call-template name="getNodeDisplayName"/></xsl:for-each> /
        <xsl:for-each select=".."><xsl:call-template name="getNodeDisplayName"/></xsl:for-each> /
        <xsl:for-each select="."><xsl:call-template name="getNodeDisplayName"/></xsl:for-each>
    </p>
</xsl:template>

</xsl:stylesheet>
