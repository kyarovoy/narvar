#!/usr/bin/env python

import argparse
import os
from pprint import pprint,pformat
from collections import namedtuple
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# Parse command line options
parser = argparse.ArgumentParser(description='This script sends email notifications when resource usage thresholds are reached')
parser.add_argument('-d', type=float, metavar='disk_threshold', dest='disk_threshold', default = '90', help='Disk threshold in %')
parser.add_argument('-c', type=float, metavar='cpu_threshold', dest='cpu_threshold', default = '80', help='CPU usage threshold for last 5 mins in %')
parser.add_argument('--smtp-server', type=str, metavar='smtp_server', dest='smtp_server', default = 'smtp.gmail.com', help='SMTP server')
parser.add_argument('--smtp-port', type=str, metavar='smtp_port', dest='smtp_port', default = '465', help='SMTP port')
parser.add_argument('--smtp-user', type=str, metavar='smtp_user', dest='smtp_user', default = 'narvar.monitor@gmail.com', help='SMTP username')
parser.add_argument('--smtp-pass', type=str, metavar='smtp_pass', dest='smtp_pass', default = '123456qwerty!', help='SMTP password')
parser.add_argument('--smtp-from', type=str, metavar='smtp_from', dest='smtp_from', default = 'narvar.monitor@gmail.com', help='SMTP from email')
parser.add_argument('--smtp-to', type=str, metavar='smtp_to', dest='smtp_to', default = 'narvar.monitor@gmail.com', help='Email for notifications')
args = parser.parse_args()

disk_ntuple = namedtuple('partition',  'device mountpoint fstype')
usage_ntuple = namedtuple('usage',  'total used free percent')

def disk_partitions(all=False):
    """Return all mountd partitions as a nameduple.
    If all == False return phyisical partitions only.
    """
    phydevs = []
    f = open("/proc/filesystems", "r")
    for line in f:
        if not line.startswith("nodev"):
            phydevs.append(line.strip())

    retlist = []
    f = open('/etc/mtab', "r")
    for line in f:
        if not all and line.startswith('none'):
            continue
        fields = line.split()
        device = fields[0]
        mountpoint = fields[1]
        fstype = fields[2]
        if not all and fstype not in phydevs:
            continue
        if device == 'none':
            device = ''
        ntuple = disk_ntuple(device, mountpoint, fstype)
        retlist.append(ntuple)
    return retlist

def disk_usage(path):
    """Return disk usage associated with path."""
    st = os.statvfs(path)
    free = (st.f_bavail * st.f_frsize)
    total = (st.f_blocks * st.f_frsize)
    used = (st.f_blocks - st.f_bfree) * st.f_frsize
    try:
        percent = ret = (float(used) / total) * 100
    except ZeroDivisionError:
        percent = 0
    return usage_ntuple(total, used, free, round(percent, 1))

def send_email(subj,text):
  msg = MIMEText(text)
  msg['Subject'] = subj
  msg['From'] = args.smtp_from
  msg['To'] = args.smtp_to

  try:
    server = smtplib.SMTP_SSL(args.smtp_server, args.smtp_port)
    server.login(args.smtp_user, args.smtp_pass)
    server.sendmail(args.smtp_from, args.smtp_to, msg.as_string())
    server.quit()
  except:
    print "Can't send notification using SMTP server"

def process_events(events):
    for event in events:
      send_email('ALERT: '+event['metric']+': '+str(event['value'])+'%',pformat(event))

# List of events
events = []

# Process disk usage
for part in disk_partitions():
  du=disk_usage(part.mountpoint)
  if du.percent > args.disk_threshold:
    events.append({'metric': 'disk', 'value': du.percent, 'threshold': args.disk_threshold, 'details': 'mountpoint: '+part.mountpoint})

# Process CPU usage
cpu_usage = os.getloadavg()[1]
if cpu_usage > args.cpu_threshold:
  events.append({'metric': 'cpu', 'value': cpu_usage, 'threshold': args.cpu_threshold, 'details': ''})

pprint(events)
process_events(events)