<?xml version="1.0" encoding="UTF-8"?>

 <xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns="http://www.w3.org/TR/REC-html40">
<xsl:output method="html"/>

<!-- REQUIRED INPUT PARAMETERS 
PMSURL = the full url to the PMS service including port, without a trailing /
NMTpath = the path from root of the PLexNMT website to the current container, without a trailing /
NMTstart = the starting page number for displaying paged content, first is 1.
NMTback = the path for going back up one level.
NMTview = "library" or "detail"

-->
<xsl:param name="row-size" select="7" />
<xsl:param name="page-size" select="2" />
<xsl:variable name="vs" select="($NMTstart - 1) * $row-size * $page-size"/> <!-- vs = vides start pos and ve is video end -->
<xsl:variable name="ve" select="($row-size * $page-size) + $vs"/>

<xsl:param name="drow-size" select="8" />
<xsl:param name="dpage-size" select="4" />
<xsl:variable name="ds" select="($NMTstart - 1) * $drow-size * $dpage-size"/> <!-- ds = direcotry start pos and de is dir end -->
<xsl:variable name="de" select="($drow-size * $dpage-size) + $ds"/>

<xsl:param name="tpage-size" select="15" />
<xsl:variable name="ts" select="(($NMTstart - 1) * $tpage-size) + 1"/> <!-- ts = track start pos and te is track end -->
<xsl:variable name="te" select="($tpage-size) + $ts"/>

<xsl:variable name="rtheight" select="510"/>
<xsl:variable name="squote">'</xsl:variable>
<xsl:param name="maxrole" select="5"/>
<xsl:param name="maxgenre" select="4"/>
<xsl:variable name="libsec" select="/MediaContainer/@librarySectionID"/>

<!-- ******************** ROOT TEMPLATE ************************** -->
<xsl:template match="/">
   <html>
   <head>
   	  <meta SYABAS-COMPACT="OFF"/> 
	  <meta SYABAS-FULLSCREEN=""/> 
      <meta SYABAS-PLAYERMODE="video"/>
	  <meta http-equiv="Pragma" content="no-cache"/>
	  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <meta SYABAS-KEYOPTION="LOWERCASE"/>
      <meta SYABAS-BACKGROUND="/background.png"/>

    <title>PlexNMT</title>
    <style><!-- Blue Gaya SD Stylesheet -->
	   body { color: B1D3F6; background-color: 2F2F2F }
	   a { font-size:18px; text-decoration:none; color: B1D3F6 }
	   a.infom { font-size:22px;text-decoration:none; color: B1D3F6 }
	   .menu {font-size:18px;color: 999999;font-weight:bold;}
	   .text {font-size:18px;color: AAAAAA;font-weight:bold;}
	   .summary {font-size:18px;color: FFFFFF;font-weight:bold;}
	   .info {font-size:18px;color: FFFFFF;font-weight:bold;}
	   .infol {font-size:28px;color: FFFFFF;font-weight:bold; }
	   .infom {font-size:22px;color: FFFFFF;font-weight:bold; }
	   .server {font-size:18px;color: AAAAAA;font-weight:bold;vertical-align:middle; }
	   .list {font-size:14px;color: B1D3F6;font-weight:bold;}
	   .appmenu {font-size:14px;color: B1D3F6;font-weight:bold;}
	   .bold { font-size:18px; color: B1D3F6;font-weight:bold; }
	   .pagingHighlight { font-size:12px; color: FFFF33 }
	   .paging {font-size:12px;color: 5097CD; }
	   .msg {font-size:14px;color: A8D1E6;font-weight:bold;}
	   .invalid {font-size:14px;color: FFFF00;font-weight:bold;}
	   h1 {color: FFCC00}
	   h2 {color: FFCC00}
       .thumb {width:110px;height:auto}
       .dirthumb {height:80px;width:auto; font-size:18px;color: FFFFFF; vertical-align:bottom}
	   .title {width:150px;height:50px;vertical-align:top;text-align:center; font-size:18px;color: FFFFFF}
       .vid {width:150px;height:160px;vertical-align:bottom;text-align:center; font-size:18px;color: FFFFFF;}
       .dir {width:130px;height:70px;vertical-align:top;text-align:center; font-size:18px;color: FFFFFF;}
   	   .pgdn {font-size:18px;color: FFCC00;font-weight:bold;vertical-align:middle; height:30px; display:inline-block;}
   	   .track {font-size:18px;color: FFCC00;font-weight:bold;vertical-align:middle; height:20px; display:inline-block;}

    </style>
    
    <script type="text/javascript">
	  var markee = 1;
	  function show(mykey, mylink, vod)
	  {
		if ( markee == 1 )
		  markee = document.getElementById('markee');
		markee.firstChild.nodeValue = document.getElementById(mykey).title;
		var play = document.getElementById('play');
		if (mylink != '') {
			play.setAttribute('href', mylink);
			play.setAttribute('tvid', 'PLAY');
			if (vod) {
				play.setAttribute('vod', vod);  //used only for playlists.
			}
		}
	  }
	  function hide()
	  {
		if ( markee == 1 )
		  markee = document.getElementById('markee');
		markee.firstChild.nodeValue = " ";
		document.getElementById('play').setAttribute('tvid', '#');
	  }
	</script>
  </head>

  <body style="margin: 0px; padding: 0px; font-family: 'Trebuchet MS',verdana;" FOCUSCOLOR="#FF0000" FOCUSTEXT="#FFFFFF" tv="/background.png" ONLOADSET="1">
    <xsl:choose>
      <xsl:when test="$NMTview = 'video'" >
        <xsl:apply-templates mode="video" />
      </xsl:when>
      <xsl:when test="$NMTview = 'photo'" >
        <xsl:apply-templates mode="photo" />
      </xsl:when>
      <xsl:when test="$NMTview = 'music'" >
        <xsl:apply-templates mode="music" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="library"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </body>
  </html>
</xsl:template>

<!-- ********************** MAIN PAGE FOR LIBRARY NAVIGATION ********************** -->
<xsl:template match="MediaContainer" mode="library">
    
 <a href="" tvid="#" id="play" vod=""/><a href="#" tvid="refresh"/>

 <table width="100%" style="height: 100%;" cellpadding="7" cellspacing="0" border="0">
  <tr valign="middle">

  <!-- ============ HEADER SECTION ============== -->
    <td  style="height: 40px;" bgcolor="#252525" class="server" valign="middle" width="80%">
		   <img width="10px" src="/spacer.png"/>
			<a>
			<xsl:attribute name="HREF">
               <xsl:choose>
                 <xsl:when test="$NMTback = 'x'">
                   <xsl:value-of select="'javascript:history.go(-1);'"/>
                 </xsl:when>
                 <xsl:when test="contains($NMTback, 'metadata') and Directory and Directory/@parentKey">
                   <xsl:value-of select="Directory/@parentKey"/>
                 </xsl:when>
                 <xsl:when test="contains($NMTback, 'metadata') and Directory">
                   <xsl:value-of select="concat('/library/sections/', @librarySectionID)"/>
                 </xsl:when>
                 <xsl:otherwise>
                   <xsl:value-of select="$NMTback"/>
                 </xsl:otherwise>
               </xsl:choose>
			</xsl:attribute>
            <img height="45px" src="/arrowup.png" class="server" style="display:inline-block;"/>
			<img width="15px" src="/spacer.png"/>
            </a>

			<a href="/"  tvid="home">
		     <img src="/home.png" height="40px" class="server"/>
            <!--font size="+3" color="#FFCC00">PlexNMT</font-->
			</a>
		    <xsl:if test="@title1 != ''">
	          	<img class="server" style="display:inline-block;" src="/divider.png"/>
    	      	<!--img width="10px" src="/spacer.png"/-->
				<font size="+2"><xsl:value-of select="substring(@title1,1,20)"/></font>
            </xsl:if>
		    <xsl:if test="@title2 != ''">
    	      	<img class="server" style="display:inline-block;" src="/divider.png"/>
		        <!--img width="10px" src="/spacer.png"/-->
				<font size="+1"><xsl:value-of select="substring(@title2,1,30)"/></font>
		    </xsl:if>

          </td>
          <td align="right" valign="middle" bgcolor="#252525" width="20%">
            <a href="/pms?PlexNMTview=pms&amp;PlexNMTback=x" ><img src="/info.png" /></a>
            <img src="/spacer.png" height="10px"/>
            <a href="#"><img src="/settings.png" /></a>
          </td>
         </tr>

  <!-- ============ RIGHT COLUMN (CONTENT) ============== -->
   <xsl:choose>
     <xsl:when test="$NMTview = 'pms'">
      <tr valign="top">
       <xsl:attribute name="height"><xsl:value-of select="$rtheight"/>
       </xsl:attribute>
       <td width="100%" valign="top" bgcolor="#2F2F2F" colspan="2">
	   <table border="0" cellspacing="0" cellpadding="5" width="100%" name="detail">
        <tr><td class="text" width="30%">Plex Server Name: </td>
          <td class="info" width="70%"><xsl:value-of select="@friendlyName"/></td></tr>
        <tr><td class="text">Platform: </td>
          <td class="info"><xsl:value-of select="@platform"/></td></tr>
        <tr><td class="text">Platform Version: </td>
          <td class="info"><xsl:value-of select="@platformVersion"/></td></tr>
        <tr><td class="text">Plex Version: </td>
          <td class="info"><xsl:value-of select="@version"/></td></tr>
        <tr><td class="text">myPlex State: </td>
          <td class="info"><xsl:value-of select="@myPlexMappingState"/></td></tr>
        <tr><td class="text">myPlex Username: </td>
          <td class="info"><xsl:value-of select="@myPlexUsername"/></td></tr>
        <tr><td class="text">myPlex Sign-in State: </td>
          <td class="info"><xsl:value-of select="@myPlexSigninState"/></td></tr>
        <tr><td class="text">Multiuser:</td>
          <td class="info"><xsl:value-of select="@multiuser"/></td></tr>
	  </table>
      </td></tr>
	  <xsl:call-template name="footer"/>
     </xsl:when>

     <xsl:when test="$NMTview = 'search'">
      <tr valign="top">
       <xsl:attribute name="height"><xsl:value-of select="$rtheight"/>
       </xsl:attribute>
       <td width="100%" valign="top" bgcolor="#2F2F2F" colspan="2">
       	<xsl:apply-templates mode="search"/>
        </td></tr>
        <xsl:call-template name="footer"/>
     </xsl:when>

     <!-- default is 'library' for directories, episodes, or videos -->
     <xsl:otherwise>
	  <!-- MAIN LIBRARY SECTION -->
      <tr valign="top">
       <xsl:attribute name="height"><xsl:value-of select="$rtheight - 50"/>
       </xsl:attribute>
       <td width="100%" valign="top" bgcolor="#2F2F2F" colspan="2">
      <table border="0" cellspacing="0" cellpadding="5" name="rows">

        <xsl:if test="Directory and (@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season')">
            <!-- show episode and music collection rows -->
           <xsl:apply-templates select="Directory[(position() mod $row-size) = 1 and position() &gt;= $vs and position() &lt; $ve]" mode="episode" />
    	</xsl:if>
        <xsl:if test="Directory and not(@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season') and (@size=1 and (Directory/@type='album' or Directory/@type='artist' or Directory/@type='show' or Directory/@type='season'))">
            <!-- One child album -->
           <xsl:apply-templates select="Directory[(position() mod $row-size) = 1 and position() &gt;= $vs and position() &lt; $ve]" mode="episode" />
    	</xsl:if>

        <!-- show video rows -->
        <xsl:apply-templates select="Video[(position() mod $row-size) = 1 and position() &gt;= $vs and position() &lt; $ve]" mode="library"/>
    
        <!-- show photo rows -->
        <xsl:apply-templates select="Photo[(position() mod $row-size) = 1 and position() &gt;= $vs and position() &lt; $ve]" mode="library"/>
    
        <!-- show music album rows -->
        <xsl:apply-templates select="Music[(position() mod $row-size) = 1 and position() &gt;= $vs and position() &lt; $ve]" mode="library"/>
    
        <!-- show track rows -->
        <xsl:apply-templates select="Track[ position() &gt;= $ts and position() &lt; $te]" mode="library"/>

		<xsl:if test="Directory and not(@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season') and (@size &gt; 1 or (@size=1 and not(Directory/@type='album' or Directory/@type='artist' or Directory/@type='show' or Directory/@type='season')))">
            <!-- show directory rows -->
           <xsl:apply-templates select="Directory[(position() mod $drow-size) = 1 and position() &gt;= $ds and position() &lt; $de ]" mode="library" />
    	</xsl:if>

      </table>
     </td></tr>
      
     <!-- title display -->
     <tr height="35px"><td align="center" id="markee" colspan="2" class="infom" width="100%" bgcolor="#2F2F2F"><xsl:value-of select="' ...'"/>
       
     </td></tr>
       <!-- FOOTER -->
    <tr><td align="center" colspan="2" width="100%">
     <table width="100%" name="footer">
     <tr>
     <td width="20%" align="left"><a tvid="back" href="javascript:history.go(-1);"><img src="/back.png" class="server" style="display:inline-block;" height="30px"/></a>
     </td>
     <td width="60%" align="center">
	   <xsl:choose>
    	 <xsl:when test="$NMTstart = 1 and Directory and not(@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season') and @size &lt;= ($drow-size * $dpage-size)" >
			<font color="#666666"> </font>
         </xsl:when>
    	 <xsl:when test="$NMTstart = 1 and Directory and (@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season') and @size &lt;= ($row-size * $page-size)">
			<font color="#666666"> </font>
         </xsl:when>
    	 <xsl:when test="$NMTstart = 1 and (((Video or Photo or Music) and @size &lt;= ($row-size * $page-size)) or (Track and @size &lt;= $tpage-size))">
			<font color="#666666"> </font>
         </xsl:when>
    	 <xsl:when test="Directory and not(@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season') and @size &lt;= ($NMTstart * $drow-size * $dpage-size)">
            <a tvid="pgdn"><xsl:attribute name="HREF"><xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=1' )"/></xsl:attribute>
            <img src="/pgdn.png" class="pgdn" /></a>
         </xsl:when>
    	 <xsl:when test="Track and @size &lt;= ($NMTstart * $tpage-size)">
            <a tvid="pgdn"><xsl:attribute name="HREF"><xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=1' )"/></xsl:attribute>
            <img src="/pgdn.png" class="pgdn" /></a>
         </xsl:when>
    	 <xsl:when test="Directory and (@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season') and @size &lt;= ($NMTstart * $row-size * $page-size)">
            <a tvid="pgdn"><xsl:attribute name="HREF"><xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=1' )"/></xsl:attribute>
            <img src="/pgdn.png" class="pgdn" /></a>
         </xsl:when>
    	 <xsl:when test="(Video or Photo or Music) and @size &lt;= ($NMTstart * $row-size * $page-size)">
            <a tvid="pgdn"><xsl:attribute name="HREF"><xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=1' )"/></xsl:attribute>
            <img src="/pgdn.png" class="pgdn" /></a>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="gonext" select="$NMTstart + 1"/>
            <a tvid="pgdn"><xsl:attribute name="HREF"><xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=', $gonext )"/></xsl:attribute>
            <img src="/pgdn.png" class="pgdn" /></a>
         </xsl:otherwise>
         </xsl:choose>

	   <xsl:choose>
    	 <xsl:when test="$NMTstart = 1 and Directory and not(@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season') and @size &lt;= ($NMTstart * $drow-size * $dpage-size)">
			<font color="#666666"> </font>
         </xsl:when>
    	 <xsl:when test="$NMTstart = 1 and Directory and (@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season') and @size &lt;= ($NMTstart * $row-size * $page-size)">
			<font color="#666666"> </font>
         </xsl:when>
    	 <xsl:when test="$NMTstart = 1 and ((Video or Photo or Music) and @size &lt;= ($NMTstart * $row-size * $page-size)) or (Track and @size &lt;= $tpage-size)">
			<font color="#666666"> </font>
         </xsl:when>
    	 <xsl:when test="$NMTstart = 1 and Directory and not(@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season')">
            <xsl:variable name="goback" select="ceiling(@size div ($drow-size * $dpage-size))"/>
            <a tvid="pgup"><xsl:attribute name="HREF"><xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=', $goback )"/></xsl:attribute>
            <img src="/pgup.png" class="pgdn" /></a>
         </xsl:when>
    	 <xsl:when test="$NMTstart = 1 and Directory and (@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season')">
            <xsl:variable name="goback" select="ceiling(@size div ($row-size * $page-size))"/>
            <a tvid="pgup"><xsl:attribute name="HREF"><xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=', $goback )"/></xsl:attribute>
            <img src="/pgup.png" class="pgdn" /></a>
         </xsl:when>
    	 <xsl:when test="$NMTstart = 1 and (Video or Photo or Music)">
            <xsl:variable name="goback" select="ceiling(@size div ($row-size * $page-size))"/>
            <a tvid="pgup"><xsl:attribute name="HREF"><xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=', $goback )"/></xsl:attribute>
            <img src="/pgup.png" class="pgdn" /></a>
         </xsl:when>
    	 <xsl:when test="$NMTstart = 1 and Track">
            <xsl:variable name="goback" select="ceiling(@size div $tpage-size)"/>
            <a tvid="pgup"><xsl:attribute name="HREF"><xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=', $goback )"/></xsl:attribute>
            <img src="/pgup.png" class="pgdn" /></a>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="goback" select="$NMTstart - 1"/>
            <a tvid="pgup"><xsl:attribute name="HREF"><xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=', $goback )"/></xsl:attribute>
            <img src="/pgup.png" class="pgdn" /></a>
         </xsl:otherwise>
       </xsl:choose>
         
	</td>
	<td width="20%" align="right" class="text" colspan="2">Page <xsl:value-of select="$NMTstart"/> of
	  <xsl:choose>
	      <xsl:when test="Directory and not(@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season')">
	  		<xsl:value-of select="ceiling(@size div ($drow-size * $dpage-size))"/>
          </xsl:when>
		  <xsl:when test="Track">
		    <xsl:value-of select="ceiling(@size div $tpage-size)"/>
		  </xsl:when>
          <xsl:otherwise>
	  		<xsl:value-of select="ceiling(@size div ($row-size * $page-size))"/>
          </xsl:otherwise>
       </xsl:choose>
    <!-- end footer -->

       </td></tr>
	  </table>

    	<!-- Write invisible links for keying in page numbers. -->
        <xsl:if test="Directory and not(@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season')">
          <xsl:apply-templates select="Directory[(position() mod ($drow-size * $dpage-size)) = 1]" mode="pagelinks" />
        </xsl:if>
        <xsl:if test="Directory and (@viewGroup='album' or @viewGroup='artist' or @viewGroup='show' or @viewGroup='season')">
          <xsl:apply-templates select="Directory[(position() mod ($row-size * $page-size)) = 1]" mode="pagelinks" />
        </xsl:if>
        <xsl:apply-templates select="Video[(position() mod ($row-size * $page-size)) = 1 ]" mode="pagelinks" />
        <xsl:apply-templates select="Photo[(position() mod ($row-size * $page-size)) = 1 ]" mode="pagelinks" />
        <xsl:apply-templates select="Music[(position() mod ($row-size * $page-size)) = 1 ]" mode="pagelinks" />
      </td></tr>
     </xsl:otherwise>
   </xsl:choose>
 </table>
 <script type="text/javascript">
 	hide();
 </script>

</xsl:template>
 
<!-- ***************** GALLERY of VIDEOS *********************** -->
<xsl:template match="Video" mode="library">
     <!-- VIDEOS -->

       <xsl:variable name="row-no" select="position()" />
         <tr>
           <xsl:for-each select=". | following-sibling::Video[position() &lt; $row-size]">
            <xsl:variable name="item-no" select="(($row-no - 1) * $row-size) + position()"/>
            <td class="vid" width="150px" height="160px" valign="bottom" align="center">
             <a tvid="">
               <xsl:attribute name="name">
                 <xsl:number value="$item-no" format="1" />
               </xsl:attribute>
               <xsl:attribute name="id">
                 <xsl:value-of select="concat('video', $item-no)"/>
               </xsl:attribute>
               <xsl:attribute name="title">
                 <xsl:value-of select="@title"/>
               </xsl:attribute>
               <xsl:attribute name="onfocus">
                  <xsl:choose>
                   <xsl:when test="starts-with(Media/Part/@key, '/:') and contains(Media/Part/@key, 'mediaInfo')">
                 	 <xsl:value-of select="concat('show(', $squote, 'video', $item-no, $squote, ', ', $squote, substring-before(Media/Part/@key, '&amp;mediaInfo'), '&amp;PlexNMTXSL=play.xsl', $squote, ',', $squote, 'playlist', $squote, ')')"/>
                   </xsl:when>
                   <xsl:when test="starts-with(Media/Part/@key, '/:')">
                 	 <xsl:value-of select="concat('show(', $squote, 'video', $item-no, $squote, ', ', $squote, Media/Part/@key, '&amp;PlexNMTXSL=play.xsl', $squote, ',', $squote, 'playlist', $squote,  ')')"/>
                   </xsl:when>
                   <xsl:otherwise>
                 	 <xsl:value-of select="concat('show(', $squote, 'video', $item-no, $squote, ', ', $squote, $PMSURL, Media/Part/@key, $squote, ')')"/>
                   </xsl:otherwise>
                  </xsl:choose>            
               </xsl:attribute>
               <xsl:attribute name="onblur">
                 <xsl:value-of select="'hide()'"/>
               </xsl:attribute>
               <xsl:attribute name="HREF">
                 <xsl:value-of select="concat(@key, '?PlexNMTview=video')"/>
               </xsl:attribute>
             <img class="thumb" width="110px" >
               <xsl:attribute name="SRC">
                 <xsl:choose>
                   <xsl:when test="starts-with(@thumb, 'http')">
                     <xsl:value-of select="@thumb"/>
                   </xsl:when>
                   <xsl:otherwise>
                 	 <xsl:value-of select="concat($PMSURL, @thumb)"/>
                   </xsl:otherwise>
                 </xsl:choose>
               </xsl:attribute>
               <xsl:attribute name="onmouseover">
                  <xsl:choose>
                   <xsl:when test="starts-with(Media/Part/@key, '/:') and contains(Media/Part/@key, 'mediaInfo')">
                 	 <xsl:value-of select="concat('show(', $squote, 'video', $item-no, $squote, ', ', $squote, substring-before(Media/Part/@key, '&amp;mediaInfo'), '&amp;PlexNMTXSL=play.xsl', $squote, ',', $squote, 'playlist', $squote, ')')"/>
                   </xsl:when>
                   <xsl:when test="starts-with(Media/Part/@key, '/:')">
                 	 <xsl:value-of select="concat('show(', $squote, 'video', $item-no, $squote, ', ', $squote, Media/Part/@key, '&amp;PlexNMTXSL=play.xsl', $squote, ',', $squote, 'playlist', $squote,  ')')"/>
                   </xsl:when>
                   <xsl:otherwise>
                 	 <xsl:value-of select="concat('show(', $squote, 'video', $item-no, $squote, ', ', $squote, $PMSURL, Media/Part/@key, $squote, ')')"/>
                   </xsl:otherwise>
                  </xsl:choose>            
               </xsl:attribute>
               <xsl:attribute name="onmouseout">
                 <xsl:value-of select="'hide()'"/>
               </xsl:attribute>
             </img></a>
            </td>
           </xsl:for-each>
           </tr>
           <tr>
           <xsl:for-each select=". | following-sibling::Video[position() &lt; $row-size]">
            <td class="title" width="150px" height="50px" valign="top" align="center">
               <xsl:value-of select="substring(@title,1,20)"/>
               <xsl:if test="substring(@title,21)">
                  <xsl:value-of select="'...'"/>
               </xsl:if>
            </td>
           </xsl:for-each>
         </tr>
</xsl:template>

<!-- ********************** LIST OF DIRECTORIES (Folders) *************** -->
<xsl:template match="Directory" mode="library">  

         <xsl:variable name="row-no" select="position()" />
         <tr>
           <xsl:for-each select=". | following-sibling::Directory[position() &lt; $drow-size]  ">
             <xsl:variable name="item-no" select="(($row-no - 1) * $drow-size) + position()"/>
             <xsl:if test="$NMTpath != '' or (@key != 'clients' and @key != 'playQueues' and @key != 'player' and @key != 'playlists' and @key != 'search' and @key != 'servers' and @key != 'system' and @key != 'transcode')">
                 <td class="dir"  align="center" valign="top" width="130px">
                 <a>
                   <xsl:attribute name="name">
                     <xsl:number value="$item-no" format="1" />
                   </xsl:attribute>
                   <xsl:attribute name="HREF">
                     <xsl:choose>
                       <xsl:when test="starts-with(@key, '/')">
                         <xsl:value-of select="@key" />
                       </xsl:when>
                       <xsl:otherwise>
                         <xsl:value-of select="concat($NMTpath, '/', @key)"/>
                       </xsl:otherwise>
                     </xsl:choose>
                   </xsl:attribute>
                   <xsl:attribute name="id">
                     <xsl:value-of select="concat('dir', $item-no)"/>
                   </xsl:attribute>
                   <xsl:attribute name="title">
                     <xsl:value-of select="@title"/>
                   </xsl:attribute>
                   <xsl:attribute name="onfocus">
                     <xsl:value-of select="concat('show(', $squote, 'dir', $item-no, $squote, ', ', $squote, $squote, ')')"/>
                   </xsl:attribute>
                   <xsl:attribute name="onblur">
                     <xsl:value-of select="'hide()'"/>
                   </xsl:attribute>
                 <img class="dirthumb" src="/folder.png">
                   <xsl:attribute name="onmouseover">
                     <xsl:value-of select="concat('show(', $squote, 'dir', $item-no, $squote, ', ', $squote, $squote, ')')"/>
                   </xsl:attribute>
                   <xsl:attribute name="onmouseout">
                     <xsl:value-of select="'hide()'"/>
                   </xsl:attribute>
                 </img></a>
                 <br></br>
                   <xsl:value-of select="substring(@title,1,20)"/>
                   <xsl:if test="substring(@title,21)">
                      <xsl:value-of select="'...'"/>
                   </xsl:if>
               </td>
           </xsl:if>
       </xsl:for-each>
       </tr>
</xsl:template>

<!-- ***************** GALLERY of COLLECTIONS: EPISODES, SEASONS, ARTISTS, ALBUMS *********************** -->
<xsl:template match="Directory" mode="episode">

         <xsl:variable name="row-no" select="position()" />
         <tr>
           <xsl:for-each select=". | following-sibling::Directory[position() &lt; $row-size]">
            <xsl:variable name="item-no" select="(($row-no - 1) * $row-size) + position()"/>
            <td class="vid" align="center" valign="bottom">
             <a>
               <xsl:attribute name="name">
                 <xsl:number value="$item-no" format="1" />
               </xsl:attribute>
               <xsl:attribute name="id">
                 <xsl:value-of select="concat('col', $item-no)"/>
               </xsl:attribute>
               <xsl:attribute name="title">
                 <xsl:value-of select="@title"/>
               </xsl:attribute>
               <xsl:attribute name="onfocus">
                 <xsl:value-of select="concat('show(', $squote, 'col', $item-no, $squote, ', ', $squote, $squote, ')')"/>
               </xsl:attribute>
               <xsl:attribute name="onblur">
                 <xsl:value-of select="'hide()'"/>
               </xsl:attribute>
               <xsl:attribute name="HREF">
			     <xsl:choose>
				   <xsl:when test="starts-with(@key, '/')">
					 <xsl:value-of select="concat(@key, '?PlexNMTback=', $NMTpath)" />
				   </xsl:when>
				   <xsl:otherwise>
					 <xsl:value-of select="concat($NMTpath, '/', @key)"/>
				   </xsl:otherwise>
				 </xsl:choose>
               </xsl:attribute>
               <xsl:attribute name="id">
                 <xsl:value-of select="concat('col', $item-no)"/>
               </xsl:attribute>
               <xsl:attribute name="title">
                 <xsl:value-of select="@title"/>
               </xsl:attribute>
               <xsl:attribute name="onfocus">
                 <xsl:value-of select="concat('show(', $squote, 'col', $item-no, $squote, ', ', $squote, $squote, ')')"/>
               </xsl:attribute>
               <xsl:attribute name="onblur">
                 <xsl:value-of select="'hide()'"/>
               </xsl:attribute>
             <img class="thumb">
               <xsl:attribute name="SRC">
                 <xsl:choose>
                   <xsl:when test="@thumb">
                 		<xsl:value-of select="concat($PMSURL, @thumb)"/>
                   </xsl:when>
                   <xsl:when test="@type='artist' or @type='album'">
                 	 <xsl:value-of select="'/unk-music.png'"/>
                   </xsl:when>
                   <xsl:when test="@type='show' or @type='season'">
                 	 <xsl:value-of select="'/unk-show.png'"/>
                   </xsl:when>
				   <xsl:otherwise>
                 	 <xsl:value-of select="'/unknown.png'"/>
                   </xsl:otherwise>
                 </xsl:choose>
               </xsl:attribute>
               <xsl:attribute name="onmouseover">
                 <xsl:value-of select="concat('show(', $squote, 'col', $item-no, $squote, ', ', $squote, $squote, ')')"/>
               </xsl:attribute>
               <xsl:attribute name="onmouseout">
                 <xsl:value-of select="'hide()'"/>
               </xsl:attribute>
             </img></a>
            </td>
         </xsl:for-each>
           </tr>
           <tr>
           <xsl:for-each select=". | following-sibling::Directory[position() &lt; $row-size]">
            <td class="title" width="150px" height="50px" valign="top" align="center">
               <xsl:value-of select="substring(@title,1,20)"/>
               <xsl:if test="substring(@title,21)">
                  <xsl:value-of select="'...'"/>
               </xsl:if>
			   <xsl:if test="@leafCount">
				<xsl:value-of select="concat(' (', @leafCount, ')')"/>
			   </xsl:if>
            </td>
           </xsl:for-each>
       </tr>
</xsl:template>

<!-- ***************** LIST OF TRACKS *********************** -->
<xsl:template match="Track" mode="library">

       <xsl:variable name="track-no" select="position() + $ts - 1" />
       <tr>
            <td class="info" align="left" valign="middle">
             <a vod="">
               <xsl:attribute name="name">
                 <xsl:number value="position()" format="1" />
               </xsl:attribute>
               <xsl:attribute name="HREF">
				 <xsl:value-of select="concat($PMSURL, Media/Part/@key)" />
               </xsl:attribute>
               <img class="track" src="/play.png"/>
             </a>
             <img width="10px" src="/spacer.png"/>
             <img class="track" src="/note.png"/>
             <img width="10px" src="/spacer.png"/>
		   	 <xsl:value-of select="concat($track-no, ' - ', substring(@title,1,60))"/>
            </td>
       </tr>
</xsl:template>

<!-- ******************** PHOTO GALLERY ************************** -->
<xsl:template match="Photo" mode="library">
     <!-- PHOTOS -->

         <xsl:variable name="row-no" select="position()" />
         <tr>
           <xsl:for-each select=". | following-sibling::Photo[position() &lt; $row-size]">
            <xsl:variable name="item-no" select="(($row-no - 1) * $row-size) + position()"/>
            <td class="vid" align="center" valign="bottom">
             <a>
               <xsl:attribute name="name">
                 <xsl:number value="$item-no" format="1" />
               </xsl:attribute>
               <xsl:attribute name="id">
                 <xsl:value-of select="concat('photo', $item-no)"/>
               </xsl:attribute>
               <xsl:attribute name="title">
                 <xsl:value-of select="@title"/>
               </xsl:attribute>
               <xsl:attribute name="onfocus">
                 <xsl:value-of select="concat('show(', $squote, 'photo', $item-no, $squote, ', ', $squote, $squote, ')')"/>
               </xsl:attribute>
               <xsl:attribute name="onblur">
                 <xsl:value-of select="'hide()'"/>
               </xsl:attribute>
               <xsl:attribute name="HREF">
                 <xsl:value-of select="concat($NMTpath, '?PlexNMTview=photo&amp;PlexNMTstart=', @ratingKey)"/>
               </xsl:attribute>
             <img class="thumb">
               <xsl:attribute name="SRC">
                 <xsl:value-of select="concat($PMSURL, @thumb)"/>
               </xsl:attribute>
               <xsl:attribute name="onmouseover">
                 <xsl:value-of select="concat('show(', $squote, 'photo', $item-no, $squote, ', ', $squote, $squote, ')')"/>
               </xsl:attribute>
               <xsl:attribute name="onmouseout">
                 <xsl:value-of select="'hide()'"/>
               </xsl:attribute>
             </img>
             </a>
             </td>
           </xsl:for-each>
           </tr>
           <tr>
             <xsl:for-each select=". | following-sibling::Photo[position() &lt; $row-size]">
               <td class="title" align="center" valign="top">
                <xsl:value-of select="substring(@title,1,22)"/>
                <xsl:if test="substring(@title,23)">
                  <xsl:value-of select="'...'"/>
                </xsl:if>
               </td>
              </xsl:for-each>
            </tr>
</xsl:template>


<xsl:template match="Video | Directory | Photo | Music" mode="pagelinks">  
  <a>
  <xsl:attribute name="TVID"><xsl:value-of select="position()"/></xsl:attribute>
  <xsl:attribute name="HREF"><xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=', position() )"/></xsl:attribute>
  </a>
</xsl:template>

<!-- ******************** VIDEO DETAIL ************************** -->
<xsl:template match="MediaContainer" mode="video">  
  
  <table width="100%" style="height: 100%;" cellpadding="10" cellspacing="0" border="0">
    <tr>
     <td colspan="3" style="height: 40px;" bgcolor="#252525" class="server">
      <table cellpadding="0" cellspacing="0" border="0" width="100%">
        <tr valign="middle">
          <td valign="middle" style="height: 40px;" bgcolor="#252525" class="server">
		   <img width="10px" src="/spacer.png"/>
			<a tvid="back" href="javascript:history.go(-1);">
            <img height="45px" src="/arrowup.png" class="server" style="display:inline-block;"/>
			<img width="15px" src="/spacer.png"/>
            </a>

			<a href="/"  tvid="home">
		     <img src="/home.png" height="40px" class="server"/>
			</a>
          </td>
         </tr>
      </table>
     </td>
    </tr>
    <tr height="530">
      <td width="100%" valign="top" bgcolor="#2F2F2F" >
        <table border="0" cellspacing="0" cellpadding="0" name="movie" width="100%">
          <tr  valign="top">
            <td width="120" height="100%" align="center">
              <table border="0" cellspacing="0" cellpadding="0" name="thumb" width="280px">
                <tr class="infom">
                  <td colspan="3">
                    <img  width="280px" height="auto" >
                    <xsl:attribute name="SRC">
                     <xsl:choose>
                       <xsl:when test="starts-with(Video/@thumb, 'http')">
                         <xsl:value-of select="Video/@thumb"/>
                       </xsl:when>
                       <xsl:otherwise>
                         <xsl:value-of select="concat($PMSURL, Video/@thumb)"/>
                       </xsl:otherwise>
                     </xsl:choose>
					</xsl:attribute></img>
                  </td>
                </tr>
                <tr>
                  <td colspan="3" height="10px"> 
                  </td>
                </tr>
                <tr>
                  <td colspan="3" align="center" bgcolor="#FF9900">
                    <a name="1" vod="" tvid="play" style="color:#000">
                      <xsl:choose>
                      	<xsl:when test="starts-with(Video/Media/Part/@key, '/:') and contains(Video/Media/Part/@key, '?')">
	                      <xsl:attribute name="HREF">
                            <xsl:choose>
                              <!-- the mediaInfo tag makes it too long for NMT to play. -->
                              <xsl:when test="contains(Video/Media/Part/@key, 'mediaInfo')">
                                <xsl:value-of select="concat(substring-before(Video/Media/Part/@key, '&amp;mediaInfo'), '&amp;PlexNMTXSL=play.xsl')"/>
                              </xsl:when>
                              <xsl:otherwise>
                            	<xsl:value-of select="concat(Video/Media/Part/@key, '&amp;PlexNMTXSL=play.xsl')"/>
                               </xsl:otherwise>
                             </xsl:choose>
                          </xsl:attribute>
	                      <xsl:attribute name="vod">
                            <xsl:value-of select="'playlist'"/>
                          </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="starts-with(Video/Media/Part/@key, '/:')">
	                      <xsl:attribute name="vod">
                            <xsl:value-of select="'playlist'"/>
                          </xsl:attribute>
	                      <xsl:attribute name="HREF">
                            <xsl:value-of select="concat(Video/Media/Part/@key, '?PlexNMTXSL=play.xsl')"/>
                          </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:attribute name="vod"/>
	                      <xsl:attribute name="HREF">
	                        <xsl:value-of select="concat($PMSURL, Video/Media/Part/@key)"/>
                          </xsl:attribute>
                        </xsl:otherwise>
                      </xsl:choose>
                    Play</a>
                  </td>
                </tr>

                <tr class="infom" height="30px">
                  <td align="left">
                    <xsl:choose>
                      <xsl:when test="Video/Media/@videoResolution &lt;= 480">
                      		480p
                      </xsl:when>
                      <xsl:when test="Video/Media/@videoResolution &lt;= 720">
                      		720p
                      </xsl:when>
                      <xsl:when test="Video/Media/@videoResolution &lt;= 1080">
                      		1080p
                      </xsl:when>
                      <xsl:otherwise>
                     		<xsl:value-of select="Video/Media/@videoResolution"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    </td>
                  <td align="center">
                    <xsl:choose>
                      <xsl:when test="Video/Media/Part/Stream[@codec='dca']">
                      		DTS HD
                      </xsl:when>
                      <xsl:when test="Video/Media/Part/Stream[@codec='ac3']">
                      		Dolby Digital
                      </xsl:when>
                      <xsl:otherwise>
                     		<xsl:value-of select="Video/Media/Part/Steam/@codec"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>
                  <td align="right">
                    <xsl:choose>
                      <xsl:when test="Video/Media/Part/Stream[@channels &gt; 6]">
                      		7.1
                      </xsl:when>
                      <xsl:when test="Video/Media/Part/Stream[@channels &gt; 5]">
                      		5.1
                      </xsl:when>
                      <xsl:when test="Video/Media/Part/Stream[@channels = 2]">
                      		Stereo
                      </xsl:when>
                      <xsl:otherwise>
                     		<xsl:value-of select="Video/Media/Part/Steam/@channels"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>
                </tr>
              </table>
            </td>
            <td width="70%">
          	  <table border="0" cellspacing="0" cellpadding="0" name="description" width="100%">
	            <tr valign="top" class="infom">
                  <td>
                      <p class="infol"><xsl:value-of select="Video/@title"/></p>
                      <xsl:apply-templates select="Video/Genre[position() &lt;= $maxgenre]" mode="detail"/>
					  <br></br>
                      <xsl:if test="Video/@duration &gt;= 3600000">
                      	<xsl:value-of select="floor(Video/@duration div 3600000)"/> hr
                      </xsl:if>
                      <xsl:if test="Video/@duration &gt;= 60000">
                      	<xsl:value-of select="floor((Video/@duration div 60000) mod 60)"/> min
                      </xsl:if>
                      <xsl:if test="Video/@duration &lt; 60000">
                        <xsl:value-of select="floor(Video/@duration div 1000)"/> sec
                      </xsl:if>
                  </td>
                  <td width="15%" align="right"><p class="infol"><xsl:value-of select="Video/@year"/></p>
                    <xsl:choose>
                      <xsl:when test="Video[@contentRating='R']">
                      		R
                      </xsl:when>
                      <xsl:when test="Video[@contentRating='PG-13']">
                      		PG-13
                      </xsl:when>
                      <xsl:when test="Video[@contentRating='PG']">
                      		PG
                      </xsl:when>
                      <xsl:when test="Video[@contentRating='G']">
                      		G
                      </xsl:when>
                      <xsl:when test="Video[@contentRating='TV-MA']">
                      		TV-MA
                      </xsl:when>
                      <xsl:when test="Video[@contentRating='TV-14']">
                      		TV-14
                      </xsl:when>
                      <xsl:otherwise>
                     		<xsl:value-of select="Video/@contentRating"/>
                      </xsl:otherwise>
                    </xsl:choose>
	                <br></br>
                    <xsl:if test="Video/@rating">
                      <xsl:value-of select="format-number(Video/@rating, '###.##')"/> / 10
                    </xsl:if>
	              </td>
                </tr>
                <tr>
                  <td height="40px" class="infom" colspan="2"><i>
                    <xsl:value-of select="Video/@tagline"/></i>
                  </td>
                </tr>
                <tr>
                  <td colspan="2" class="infom">
                    <xsl:if test="Video/Director">
                	  DIRECTOR:  
                      <xsl:apply-templates select="Video/Director" mode="detail"/><br></br>
					</xsl:if>
                    
                    <xsl:if test="Video/Writer">
    	              WRITER: 
                      <xsl:apply-templates select="Video/Writer" mode="detail"/><br></br>
					</xsl:if>
                    
                    <xsl:if test="Video/Role">
            	      CAST: 
                      <xsl:apply-templates select="Video/Role[position() &lt;= $maxrole]" mode="detail"/><br></br>
                    </xsl:if>
                    <xsl:if test="Video/Media/Part/Stream[@streamType=2]">
          	          AUDIO: 
                      <xsl:apply-templates select="Video/Media/Part/Stream[@streamType=2]" mode="audio"/>
                    </xsl:if>
                  </td>
                </tr>
                <tr height="20" ><td> </td></tr>
                <tr>
                  <td colspan="2" class="summary">
                  <xsl:value-of select="Video/@summary"/>
                  </td>
                </tr>
                <tr>
                  <td colspan="2" align="right" class="info">
                  <xsl:value-of select="Video/@studio"/>
                  </td>
                 </tr>
	          </table>
	        </td>
    	  </tr>
        </table>
      </td>
    </tr>
    <!--tr>
      <td align="center"  bgcolor="#252525">
        <table width="100%" name="footer"  bgcolor="#252525">
          <tr>
            <td width="20%" align="left">
              <a tvid="back" href="javascript:history.go(-1);"><img src="/back.png" class="server" style="display:inline-block;" height="30px"/></a>
              <a tvid="refresh" HREF="/library/metadata/6"></a>

            </td>
            <td width="60%" align="center"></td>
            <td width="20%" align="right"></td>
          </tr>
        </table>
      </td>
    </tr-->
  </table>
</xsl:template>

<!-- ******************** INVIDIDUAL PHOTO VIEWER ************************** -->
<xsl:template match="MediaContainer" mode="photo">  

  <xsl:variable name="Psize" select="@size"/>
  <xsl:variable name="Ptitle1" select="@title1"/>
  <xsl:variable name="Ptitle2" select="@title2"/>
  
  <xsl:for-each select="Photo" >
    <!-- only display photo indicated by the NMTstart parameter -->
    <xsl:if test="@ratingKey = $NMTstart">
  
      <table width="100%" style="height: 100%;" cellpadding="10" cellspacing="0" border="0">
        <tr>
         <td colspan="3" style="height: 40px;" bgcolor="#252525" class="server">
              <table cellpadding="0" cellspacing="0" border="0" width="100%">
                <tr valign="middle">
                  <td valign="middle" style="height: 40px;" bgcolor="#252525" class="server">
					<a tvid="back">
					<xsl:attribute name="HREF">
                       <xsl:choose>
                         <xsl:when test="$NMTback = 'x'">
                           <xsl:value-of select="'javascript:history.go(-1);'"/>
                         </xsl:when>
                         <xsl:otherwise>
                           <xsl:value-of select="concat($NMTpath, '&amp;PlexNMTstart=', ceiling(position() div ($page-size * $row-size)))"/>
                         </xsl:otherwise>
                       </xsl:choose>
					</xsl:attribute>
					<img height="45px" src="/arrowup.png" class="server" style="display:inline-block;"/>
					<img width="15px" src="/spacer.png"/>
					</a>

					<a href="/"  tvid="home">
                    <img src="/home.png" height="40px" class="server"/>
                    <!--font size="+3" color="#FFCC00">PlexNMT</font-->
                   </a>
                    <xsl:if test="@title1 != ''">
                        <img class="server" style="display:inline-block;" src="/divider.png"/>
                        <font size="+2"><xsl:value-of select="substring($Ptitle1,1,20)"/></font>
                    </xsl:if>
                    <xsl:if test="$Ptitle2 != ''">
                        <img class="server" style="display:inline-block;" src="/divider.png"/>
                        <font size="+1"><xsl:value-of select="substring($Ptitle2,1,20)"/></font>
                    </xsl:if>
                    <img class="server" src="/divider.png"/>
                  </td>
                  <td align="right" valign="middle">
                    <!--
                    <a href="/pms?PlexNMTview=pms&amp;PlexNMTback=x" ><img src="/info.png" /></a>
                    <img src="/background.png" height="10px"/>
                    <a href="#"><img src="/settings.png" /></a>
                    -->
                  </td>
                 </tr>
              </table>
         </td>
        </tr>

        <tr height="510">
          <td width="100%" valign="top" bgcolor="#2F2F2F" >
            <table border="0" cellspacing="0" cellpadding="0" name="navframe" width="100%">
              <tr  valign="top">
                <td width="20" height="100%" align="center" valign="middle">
                  <xsl:if test="preceding-sibling::Photo">
                    <a tvid="left">
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat($NMTpath, '?PlexNMTview=photo&amp;PlexNMTstart=', (preceding-sibling::Photo)[last()]/@ratingKey)"/>
                        </xsl:attribute>
                        <img  src="/left.png" height="60px"/>
                     </a>
                  </xsl:if>
                </td>
                <td width="90%" valign="middle" align="center">
                  <table border="0" cellspacing="0" cellpadding="0" name="photo" width="100%">
                    <tr valign="top" class="infom">
                      <td  valign="middle" align="center">
                        <img height="500px" width="auto">
                          <xsl:attribute name="src"><xsl:value-of select="concat($PMSURL, @thumb)"/></xsl:attribute> 
                        </img>
                        <br></br>
                        <xsl:value-of select="@title"/>
                        <img src="/spacer.png" width="20px"/>
                        <a name="1" id="1" href="#">
                          <img src="/info.png" class="pgdn" height="25px"/>
                        </a>
                        <xsl:if test="@summary">
                          <br></br><font class="info">
                          <xsl:value-of select="substring(@summary,0,50)"/>
                          </font>
                        </xsl:if>
                      </td>
                    </tr>
                    <tr>
                      <td width="100%">
                      </td>
                    </tr>
                  </table>
                </td>
                <td width="20" height="100%" align="center" valign="middle">
                  <xsl:if test="following-sibling::Photo">
                    <a tvid="right">
                        <xsl:attribute name="href"><xsl:value-of select="concat($NMTpath, '?PlexNMTview=photo&amp;PlexNMTstart=', following-sibling::Photo/@ratingKey)"/>
                        </xsl:attribute>
                        <img  src="/right.png" height="60px"/>
                    </a>
                  </xsl:if>
                </td>
              </tr>
              <tr>
                <td align="left" valign="middle" colspan="3" class="info">
                  <xsl:value-of select="concat(position(), ' of ', $Psize)" />
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <tr>
          <td align="center"  bgcolor="#252525">
            <table width="100%" name="footer"  bgcolor="#252525">
              <tr>
                <td width="20%" align="left">
                  <!--
                  <a tvid="back" href="javascript:history.go(-1);"><img src="/back.png" class="server" style="display:inline-block;" height="30px"/></a>
                  <a tvid="refresh" HREF="/library/metadata/6"></a>
    			  -->
                </td>
                <td width="60%" align="center"></td>
                <td width="20%" align="right"></td>
              </tr>
            </table>
          </td>
        </tr>
      </table>

      </xsl:if>
    </xsl:for-each>
</xsl:template>


<xsl:template match="Genre" mode="detail">
  <a class="infom">
  <xsl:attribute name="HREF">
  	<xsl:value-of select="concat('/library/sections/', $libsec, '/genre/', @id)"/>
  </xsl:attribute>
  <xsl:value-of select="@tag"/></a><xsl:if test="following-sibling::Genre and position() &lt; $maxgenre">, </xsl:if>
</xsl:template>

<xsl:template match="Director" mode="detail">
  <a class="infom">
  <xsl:attribute name="HREF">
  	<xsl:value-of select="concat('/library/sections/', $libsec, '/director/', @id)"/>
  </xsl:attribute>
  <xsl:value-of select="@tag"/></a><xsl:if test="following-sibling::Director">, </xsl:if>
</xsl:template>

<xsl:template match="Writer" mode="detail">
  <a class="infom">
  <xsl:attribute name="HREF">
  	<xsl:value-of select="concat('/library/sections/', $libsec, '/writer/', @id)"/>
  </xsl:attribute>
  <xsl:value-of select="@tag"/></a><xsl:if test="following-sibling::Writer">, </xsl:if>
</xsl:template>

<xsl:template match="Role" mode="detail">
  <a class="infom">
  <xsl:attribute name="HREF">
  	<xsl:value-of select="concat('/library/sections/', $libsec, '/actor/', @id)"/>
  </xsl:attribute>
  <xsl:value-of select="@tag"/></a><xsl:if test="following-sibling::Role and position() &lt; $maxrole">, </xsl:if>
</xsl:template>

<xsl:template match="Stream" mode="audio">
  <xsl:value-of select="@language"/>
  <xsl:value-of select="concat(' ',@codec)"/>
  <xsl:choose>
      <xsl:when test="@channels &gt; 6"> 7.1</xsl:when>
      <xsl:when test="@channels &gt; 5"> 5.1</xsl:when>
      <xsl:when test="@channels = 2"> Stereo</xsl:when>
      <xsl:otherwise>
            <xsl:value-of select="concat(' ',@channels)"/>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:if test="following-sibling::Stream[@streamType=2]">, </xsl:if>
</xsl:template>


<xsl:template name="footer">
    <tr><td align="center">
       <table width="100%" name="footer"><tr>
		<td width="20%" align="left"><a tvid="back" href="javascript:history.go(-1);"><img src="/back.png" class="server" style="display:inline-block;" height="30px"/></a>
		</td><td width="60%" align="center"></td>
    	<td width="20%" align="right"></td>
	    </tr>
       </table>
    </td></tr>
</xsl:template>
 
</xsl:stylesheet> 