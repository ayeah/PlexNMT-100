#!/usr/bin/env python

"""
PlexNMT

Sources:
PlexConnect: https://github.com/iBaa/PlexConnect/wiki
inter-process-communication (queue): http://pymotw.com/2/multiprocessing/communication.html
"""


import sys, time
from os import sep
import socket
from multiprocessing import Process, Pipe
import signal, errno

from Version import __VERSION__
import WebServer
import Settings
from Debug import *  # dprint()



def getIP_self():
    cfg = param['CSettings']
    if cfg.getSetting('enable_plexnmt_autodetect')=='True':
        # get public ip of machine running PlexNMT
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('1.2.3.4', 1000))
        IP = s.getsockname()[0]
        dprint('PlexNMT', 0, "IP_self: "+IP)
    else:
        # manual override from "settings.cfg"
        IP = cfg.getSetting('ip_plexnmt')
        dprint('PlexNMT', 0, "IP_self (from settings): "+IP)
    
    return IP



procs = {}
pipes = {}
param = {}
running = False

def startup():
    global procs
    global pipes
    global param
    global running
    
    # Settings
    cfg = Settings.CSettings()
    param['CSettings'] = cfg
    
    # Logfile
    if cfg.getSetting('logpath').startswith('.'):
        # relative to current path
        logpath = sys.path[0] + sep + cfg.getSetting('logpath')
    else:
        # absolute path
        logpath = cfg.getSetting('logpath')
    
    param['LogFile'] = logpath + sep + 'PlexNMT.log'
    param['LogLevel'] = cfg.getSetting('loglevel')
    dinit('PlexNMT', param, True)  # init logging, new file, main process
    
    dprint('PlexNMT', 0, "Version: {0}", __VERSION__)
    dprint('PlexNMT', 0, "Python: {0}", sys.version)
    dprint('PlexNMT', 0, "Host OS: {0}", sys.platform)
    
    # more Settings
    param['IP_self'] = getIP_self()
#    param['HostToIntercept'] = cfg.getSetting('hosttointercept')
#    param['baseURL'] = 'http://'+ param['HostToIntercept']
    
    running = True
    
    # init WebServer
    if running:
        master, slave = Pipe()  # endpoint [0]-PlexNMT, [1]-WebServer
        proc = Process(target=WebServer.Run, args=(slave, param))
        proc.start()
        
        time.sleep(0.1)
        if proc.is_alive():
            procs['WebServer'] = proc
            pipes['WebServer'] = master
        else:
            dprint('PlexNMT', 0, "WebServer not alive. Shutting down.")
            running = False
    
    # not started successful - clean up
    if not running:
        cmdShutdown()
        shutdown()
    
    return running

def run():
    while running:
        # do something important
        try:
            time.sleep(60)
        except IOError as e:
            if e.errno == errno.EINTR and not running:
                pass  # mask "IOError: [Errno 4] Interrupted function call"
            else:
                raise

def shutdown():
    for slave in procs:
        procs[slave].join()
    dprint('PlexNMT', 0, "shutdown")

def cmdShutdown():
    global running
    running = False
    # send shutdown to all pipes
    for slave in pipes:
        pipes[slave].send('shutdown')
    dprint('PlexNMT', 0, "Shutting down.")



def sighandler_shutdown(signum, frame):
    signal.signal(signal.SIGINT, signal.SIG_IGN)  # we heard you!
    cmdShutdown()



if __name__=="__main__":
    signal.signal(signal.SIGINT, sighandler_shutdown)
    signal.signal(signal.SIGTERM, sighandler_shutdown)
    
    dprint('PlexNMT', 0, "***")
    dprint('PlexNMT', 0, "PlexNMT")
    dprint('PlexNMT', 0, "Press CTRL-C to shut down.")
    dprint('PlexNMT', 0, "***")
    
    success = startup()
    
    if success:
        run()
        
        shutdown()
