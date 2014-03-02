#!/usr/bin/env python

"""
Sources:
PlexConnect: https://github.com/iBaa/PlexConnect/wiki
http://fragments.turtlemeat.com/pythonwebserver.php
http://www.linuxjournal.com/content/tech-tip-really-simple-http-server-python
...stackoverflow.com and such
"""


import sys
import string, cgi, time
from os import sep, path
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
#import ssl
from multiprocessing import Pipe  # inter process communication
import urllib
import signal

import Settings, NMTSettings
from Debug import *  # dprint()
import XMLConverter  # XML_PMS2aTV, XML_PlayVideo
import re
import Localize



g_param = {}
def setParams(param):
    global g_param
    g_param = param



def JSConverter(file, options):
    f = open(sys.path[0] + "/assets/js/" + file)
    JS = f.read()
    f.close()
    
    # PlexNMT {{URL()}}->baseURL
    for path in set(re.findall(r'\{\{URL\((.+?)\)\}\}', JS)):
        JS = JS.replace('{{URL(%s)}}' % path, g_param['baseURL']+path)
    
    # localization
    JS = Localize.replaceTEXT(JS, options['NMTLanguage']).encode('utf-8')
    
    return JS



class MyHandler(BaseHTTPRequestHandler):
    
    # Fixes slow serving speed under Windows
    def address_string(self):
      host, port = self.client_address[:2]
      #return socket.getfqdn(host)
      return host
      
    def log_message(self, format, *args):
      pass
    
    def do_GET(self):
        global g_param
        try:
            dprint(__name__, 2, "http request header:\n{0}", self.headers)
            dprint(__name__, 2, "http request path:\n{0}", self.path)
            
            # check for PMS address
            PMSaddress = ''
            # Build PMS address from settings. PSR
            PMSaddress = 'http://' + g_param['CSettings'].getSetting('ip_pms') + ':' + g_param['CSettings'].getSetting('port_pms')

            pms_end = self.path.find(')')
            if self.path.startswith('/PMS(') and pms_end>-1:
                PMSaddress = urllib.unquote_plus(self.path[5:pms_end])
                self.path = self.path[pms_end+1:]
            
            # break up path, separate PlexNMT options
            options = {}
            while True:
                cmd_start = self.path.find('&PlexNMT')
                if cmd_start==-1:
                    cmd_start = self.path.find('?PlexNMT')
                cmd_end = self.path.find('&', cmd_start+1)
                
                if cmd_start==-1:
                    break
                if cmd_end>-1:
                    cmd = self.path[cmd_start+1:cmd_end]
                    self.path = self.path[:cmd_start] + self.path[cmd_end:]
                else:
                    cmd = self.path[cmd_start+1:]
                    self.path = self.path[:cmd_start]
                
                parts = cmd.split('=', 1)
                if len(parts)==1:
                    options[parts[0]] = ''
                else:
                    options[parts[0]] = urllib.unquote(parts[1])
            
            # break up path, separate additional arguments
            # clean path needed for filetype decoding... has to be merged back when forwarded.
            parts = self.path.split('?', 1)
            if len(parts)==1:
                args = ''
            else:
                self.path = parts[0]
                args = '?'+parts[1]
            
            # get NMT language setting
            options['NMTLanguage'] = Localize.pickLanguage(self.headers.get('Accept-Language', 'en'))
            
            # add client address - to be used in case UDID is unknown
            options['NMTAddress'] = self.client_address[0]
            
            # get aTV hard-/software parameters
#            options['aTVFirmwareVersion'] = self.headers.get('X-Apple-TV-Version', '5.1')
#            options['aTVScreenResolution'] = self.headers.get('X-Apple-TV-Resolution', '720')

            dprint(__name__, 2, "pms address:\n{0}", PMSaddress)
            dprint(__name__, 2, "cleaned path:\n{0}", self.path)
            dprint(__name__, 2, "PlexNMT options:\n{0}", options)
            dprint(__name__, 2, "additional arguments:\n{0}", args)
            
            if 'User-Agent' in self.headers: # and \
#               'AppleTV' in self.headers['User-Agent']:
                
                # recieve simple logging messages from the NMT
                if 'PlexConnectNMTLogLevel' in options:
                    dprint('NMTLogger', int(options['PlexConnectNMTLogLevel']), options['PlexNMTLog'])
                    self.send_response(200)
                    self.send_header('Content-type', 'text/plain')
                    self.end_headers()
                    return
                    
                # serve .js files 
                # application, main: ignore path, send /assets/js/application.js
                # otherwise: path should be '/js', send /assets/js/*.js
                dirname = path.dirname(self.path)
                basename = path.basename(self.path)
                if basename in ("application.js", "main.js", "javascript-packed.js") or \
                   basename.endswith(".js") and dirname == '/js':
                    if basename in ("main.js", "javascript-packed.js"):
                        basename = "application.js"
                    dprint(__name__, 1, "serving /js/{0}", basename)
                    JS = JSConverter(basename, options)
                    self.send_response(200)
                    self.send_header('Content-type', 'text/javascript')
                    self.end_headers()
                    self.wfile.write(JS)
                    return
                
                # serve "*.ico" - favicon.ico
                if self.path.endswith(".ico"):
                    dprint(__name__, 1, "serving *.ico: "+self.path)
                    f = open(sys.path[0] + sep + "assets" + self.path, "rb")
                    self.send_response(200)
                    self.send_header('Content-type', 'image/ico')
                    self.end_headers()
                    self.wfile.write(f.read())
                    f.close()
                    return
                
                # serve "*.jpg" - thumbnails for old-style mainpage
                if self.path.endswith(".jpg"):
                    dprint(__name__, 1, "serving *.jpg: "+self.path)
                    f = open(sys.path[0] + sep + "assets" + self.path, "rb")
                    self.send_response(200)
                    self.send_header('Content-type', 'image/jpeg')
                    self.end_headers()
                    self.wfile.write(f.read())
                    f.close()
                    return
                
                # serve "*.png" - only png's support transparent colors
                if self.path.endswith(".png"):
                    dprint(__name__, 1, "serving *.png: "+self.path)
                    f = open(sys.path[0] + sep + "assets" + self.path, "rb")
                    self.send_response(200)
                    self.send_header('Content-type', 'image/png')
                    self.end_headers()
                    self.wfile.write(f.read())
                    f.close()
                    return
                
                # serve "*.js" - js are all from PlexNMT
                if self.path.endswith(".js"):
                    dprint(__name__, 1, "serving *.png: "+self.path)
                    f = open(sys.path[0] + sep + "assets" + self.path, "rb")
                    self.send_response(200)
                    self.send_header('Content-type', 'text/javascript')
                    self.end_headers()
                    self.wfile.write(f.read())
                    f.close()
                    return

                # serve "*.xsl" 
                if self.path.endswith(".xsl"):
                    dprint(__name__, 1, "serving *.xsl: "+self.path)
                    f = open(sys.path[0] + sep + "assets" + self.path, "rb")
                    self.send_response(200)
                    self.send_header('Content-type', 'text/xml')
                    self.end_headers()
                    self.wfile.write(f.read())
                    f.close()
                    return
               
                # serve "*.html" 
                if self.path.endswith(".html"):
                    dprint(__name__, 1, "serving *.html: "+self.path)
                    f = open(sys.path[0] + sep + "assets" + self.path, "rb")
                    self.send_response(200)
                    self.send_header('Content-type', 'text/html')
                    self.end_headers()
                    self.wfile.write(f.read())
                    f.close()
                    return

                # serve "/index.html" 
                if self.path == "/" and 0:
                    dprint(__name__, 1, "serving /index.html")
                    f = open(sys.path[0] + sep + "assets" + sep + "index.html", "rb")
                    self.send_response(200)
                    self.send_header('Content-type', 'text/html')
                    self.end_headers()
                    self.wfile.write(f.read())
                    f.close()
                    return

                # get everything else from XMLConverter 
                if True:
                    if self.path == "/pms":
                        self.path = "/"
                    dprint(__name__, 1, "serving .xml: "+self.path)
                    HTML = XMLConverter.XML_PMS2NMT(PMSaddress, self.path + args, options)
                    self.send_response(200)
                    self.send_header('Content-type', 'text/html')
                    self.end_headers()
                    self.wfile.write(HTML)
                    return

                """
                # unexpected request
                self.send_error(403,"Access denied: %s" % self.path)
                """
            
            else:
                self.send_error(403,"Not Serving Client %s" % self.client_address[0])
        except IOError:
            self.send_error(404,"File Not Found: %s" % self.path)



def Run(cmdPipe, param):
    if not __name__ == '__main__':
        signal.signal(signal.SIGINT, signal.SIG_IGN)
    
    dinit(__name__, param)  # init logging, WebServer process
    
    cfg_IP_WebServer = param['IP_self']
    cfg_Port_WebServer = param['CSettings'].getSetting('port_webserver')
    try:
        server = HTTPServer((cfg_IP_WebServer,int(cfg_Port_WebServer)), MyHandler)
        server.timeout = 1
    except Exception, e:
        dprint(__name__, 0, "Failed to connect to HTTP on {0} port {1}: {2}", cfg_IP_WebServer, cfg_Port_WebServer, e)
        sys.exit(1)
    
    socketinfo = server.socket.getsockname()
    
    dprint(__name__, 0, "***")
    dprint(__name__, 0, "WebServer: Serving HTTP on {0} port {1}.", socketinfo[0], socketinfo[1])
    dprint(__name__, 0, "***")
    
    setParams(param)
    XMLConverter.setParams(param)
    cfg = NMTSettings.CNMTSettings()
    XMLConverter.setNMTSettings(cfg)
    
    try:
        while True:
            # check command
            if cmdPipe.poll():
                cmd = cmdPipe.recv()
                if cmd=='shutdown':
                    break
            
            # do your work (with timeout)
            server.handle_request()
    
    except KeyboardInterrupt:
        signal.signal(signal.SIGINT, signal.SIG_IGN)  # we heard you!
        dprint(__name__, 0,"^C received.")
    finally:
        dprint(__name__, 0, "Shutting down.")
        cfg.saveSettings()
        del cfg
        server.socket.close()


if __name__=="__main__":
    cmdPipe = Pipe()
    
    cfg = Settings.CSettings()
    param = {}
    param['CSettings'] = cfg
    
    param['IP_self'] = '192.168.15.210'  # IP_self?
    param['baseURL'] = 'http://'+ param['IP_self'] +':'+ cfg.getSetting('port_webserver')
    
    if len(sys.argv)==1:
        Run(cmdPipe[1], param)
