#!/usr/bin/python3

import subprocess
import sys
import os
import signal
import logging

logger = logging.getLogger()
logging.basicConfig(format='%(asctime)s|%(levelname)s|%(module)s|%(funcName)s|%(lineno)d|%(message)s',level=logging.DEBUG if os.getenv('DEBUG','0') > '0' else logging.INFO)

logger.info(sys.version)
cmd = "echo -n sleeping 10;echo -n this is stderr >&2; sleep 10"
timeout = 5
def problem():
    logger.info("executing %s with timeout = %s;this pid = %s",cmd,timeout,os.getpid())
    p = subprocess.Popen(cmd
                       ,stdout = subprocess.PIPE
                       ,stderr = subprocess.PIPE
                       ,shell  = True
                       ,universal_newlines = True
                       ,executable = '/bin/bash'
                       #,start_new_session = True #this has the same effect as preexec_fn = os.setsid
                        )
    stdout = stderr = None
    try:
        stdout,stderr = p.communicate(timeout = timeout)
    except subprocess.TimeoutExpired as ex:
        pgrp = os.getpgid(p.pid)
        logger.info ("Timeout expired will kill pid %s. this pid =%s, pgrp=%s" , p.pid,os.getpid(),pgrp)
        p.kill()
        logger.info ("doing p.communicate to get stdout,stderr")
        stdout,stderr = p.communicate()
        logger.info ("p.communicate done")

    p.stdout.close()
    p.stderr.close()
    rc = p.wait()
    logger.info("stdout:%s" , stdout)
    logger.info("stderr:%s" , stderr)
    logger.info("rc:%s" , rc)
    return rc

def solution():
    logger.info("executing %s with timeout = %s;this pid = %s",cmd,timeout,os.getpid())
    p = subprocess.Popen(cmd
                       ,stdout = subprocess.PIPE
                       ,stderr = subprocess.PIPE
                       ,shell  = True
                       ,universal_newlines = True
                       ,executable        = '/bin/bash'
                       ,start_new_session = True #this has the same effect as preexec_fn = os.setsid.
                                                 #This makes the child to become the new group leader, so when killing the entire group we don't commit suicide
                        )
    stdout = stderr = None
    try:
        stdout,stderr = p.communicate(timeout = timeout)
    except subprocess.TimeoutExpired as ex:
        pgrp = os.getpgid(p.pid)                                #pgrp will be = p.pid if we os.setsid in the child
        logger.info ("Timeout expired will kill pgrp = %s (should be = p.pid= %s)" ,pgrp, p.pid)
        #p.kill()                                               #This is wrong because it only kills the child, but not the grandchidlren
        os.killpg(pgrp, signal.SIGKILL)                         #This will kill all descendants, and would also commit suicide if  we did not os.setsid in the child
        logger.info ("doing p.communicate to get stdout,stderr")
        stdout,stderr = p.communicate()                         #This should now return immediately, because sleep process should be gone.
        logger.info ("p.communicate done")

    p.stdout.close()
    p.stderr.close()
    rc = p.wait()
    logger.info("stdout:%s" , stdout)
    logger.info("stderr:%s" , stderr)
    logger.info("rc:%s" , rc)
    return rc

rc = problem()
rc = solution()

sys.exit(rc)


