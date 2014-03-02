<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns="http://www.w3.org/TR/REC-html40">
<xsl:output method="html"/>
<!-- This xslt transform is used for generating a playlist when the video/media/part key is redirected back to the PMS 
to get the real external url.
-->
<!-- ******************** ROOT TEMPLATE ************************** -->
<xsl:template match="/MediaContainer/Video">
  <html>
	<xsl:value-of select="concat(@type, '|0|0|', Media/Part/@key, '|')" />
  </html>
</xsl:template>
</xsl:stylesheet> 