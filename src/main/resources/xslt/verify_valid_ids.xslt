<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom"
>
    <xsl:output method="text"/>
    <xsl:template match="text()|@*"/>
    <xsl:template match="gedcom:value[@gedcom:id-valid = 'false']">
        <xsl:sequence select="fn:error()"/>
    </xsl:template>
</xsl:stylesheet>
