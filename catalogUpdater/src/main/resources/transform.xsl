<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:java="http://xml.apache.org/xalan/java"
                xmlns:xalan="http://xml.apache.org/xslt"
                exclude-result-prefixes="xalan java">
    
    <xsl:output method="xml" version="1.0" indent="yes" xalan:indent-amount="4"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="book">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:variable name="currentBook" select="." />
                <xsl:for-each select="java:ru.trylogic.ios.homeworks.CatalogUpdater.getList(string(../../@id), string(../@id), string(@id))">
                    <answer>
                        <xsl:attribute name="file">
                            <xsl:value-of select="@file"/>
                        </xsl:attribute>
                        <xsl:attribute name="ext">
                            <xsl:value-of select="@ext"/>
                        </xsl:attribute>
                </answer>
                </xsl:for-each>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>