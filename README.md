PlexNMT-100
===========

Plex Web Server for Older Syabas Network Media Tank (NMT) Players, such as the Popcorn Hour A-110.

There are still many first generation Sybas NMT players around, but unfortunately, they cannot take advantage of the Plex application for Syabas.  That only runs on the 200 or higher models.  The PlexNMT-100 application is a Python web server which can run on a server on your network, point to a Plex Media Server, and dynamically provide web pages that the NMT 100 series can use to navigate and play the media in your library.  It even works with diskless NMT.

Thank You
---------

This application was inspired by the PlexConnect player for Apple TV and it was built starting from the PlexConnect code base.  Since the NMT can work similar to Apple TV, the solution can be delivered the same way.  Thanks to the PlexConnect folks for paving the way.

First Release
-------------

This initial Version 0.1 release is designed to provide the bare minimum viewing experience for NMT owners.  I am currently using it myself, but I have only run it on Linux.  English only and I don't have any channels installed, either.

Future development is needed for the following:
* Searching.
* Channel support - completely untested at this time.
* Multi-user
* Multiple Plex Servers
* Updating configuration through the web interface (currently only via config file).
* Multi-language (like PlexConnect does)
* Support for MyPlex
* Updating of Watched status

Ok - there's a lot that needs to be done.  I just wanted to get something started that I and others could use, since DLNA was not working for my PCH A-110.  Opening DLNA took 3 tries.

How It Works
------------

PlexNMT-100 runs as a Python application (built with Python 2.7) on a host computer and essentially takes the XML returned from the PMS and trnasforms it via XSLT into HTML that the Popcorn Hour can use.  This was an interesting adventure in XSLT and relies on the libxml2 library.  All of the work is done in the library.xsl transformation, so much of the original PlexConnect framework is unused.  I've left the code commented out in case any of it will be useful for further implementation work.

PlexNMT-100 uses the Syabas unique browser features, similar to the way the generated YAMJ html works.  The TVID and VOD attributes make this work.  When on a folder that has more than one page full of folders or videos, pressing the number on the remote will jump to that page number (e.g., press 7 to jump to page 7).

Navigation tends to be a bit tricky going back up the tree or using the back button.  I've separated the "up" link (top left) to always try to go up, whereas the "back" button uses the browser "back" command.  When paging through a long folder, the "back" will not go up.

Limitations
-----------

* Unfortunately, the older NMTs don't have much processing power when it comes to the browser.  Displaying a page full of video thumbnails can take a long time, depending on how big the images are you put into Plex.  A typical 7x2 page takes 10 seconds for me.  I was wondering if the resizing was consuming the time, so I tried pages with the images full size and that didn't improve the performance.  So it is stuck with slow paging on the videos and other objects with thumbnails. The size of your thumbnails will affect the performance and very large thumbnails will cause the NMT to crash and require a cold boot. Forutunately, when displaying a page of simple generic folders (i.e., no thumbnail) it renders quite quickly.

* The older browser lacks many capabilities.  Transparent fan-art displayed behind the detailed screen. Styles appear to be limited.  Overall, the UI is limited, but improvements could be made (look at the YAMJ!).

Change Log
----------

Ver 0.1.1 - Implemented support for video channels using play.xsl.  I've tested this with TED and Vimeo.  To get to the channels, I eliminated the index.html, so that the root level of the Plex is accessible.  This is not very pretty, so something to work on next revision.  Also, the video channel behavior is not perfect - certain paths using the "up" link end up nowhere, so it's best to just use the "back" button.  

The detailed video information page has been cleaned up to match other pages, and handle the absence of some attributes.  Remember, you can press "Play" on the highlighted video from the video gallery - you don't need to open the detail view to play a video.

