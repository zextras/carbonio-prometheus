#!/usr/bin/python3
##coding=utf-8
# ------------------------------------------------------
#
# Carbonio Mailbox Exporter
#
# Script by : Mobius
# Version : 1.0
# Date : 2024/08/08
#
# ------------------------------------------------------

import requests
import prometheus_client
import os
import time
import datetime
from prometheus_client.core import CollectorRegistry
from prometheus_client import Gauge
from prometheus_client import Metric
from prometheus_client import Counter
from flask import Response,Flask

from lib.carbonioAdmin.request import ZimbraMailRequest as mailRqst
import concurrent.futures

def get_admin_password():
    config = os.popen('/opt/zextras/bin/zmlocalconfig -s zimbra_ldap_password').read()
    password = config.split("=")[1].strip()
    return password

# url = "https://mb-del20-prxmta1.demo.zextras.io"
# admin_url = "https://mb-del20-prxmta1.demo.zextras.io:6071"
url = "https://127.0.0.1"
admin_url = "https://127.0.0.1:6071"
# comm = Communication(url)
acct = "zimbra"
# password = "KsWiTJ14"
password = get_admin_password()
mail = mailRqst(admin_url, acct, password)

# ------
# define
# ------

PORT_EXPORTER = 9093

#MAILSERVER = 'mail.zimbra.domain'
#EXCLUDE_DOMAIN = '' # If you want to filter out a specific domain, please add it here.

# PORT_SMTP = '25'
# PORT_IMAP = '143'
# PORT_IMAPS = '993'
# PORT_POP3 = '110'
# PORT_POP3S = '995'
# PORT_WEBCLIENT = '443'

# ------


# -----
# test

# print(test)
def get_active_session(data):
    try:
        sessions = data['DumpSessionsResponse']['activeSessions']
    except KeyError:
        sessions = 0
    return sessions

def get_active_account(data):
    try:
        sessions = data['DumpSessionsResponse']['activeAccounts']
    except KeyError:
        sessions = 0
    return sessions

def set_metrics_soap(regystry: CollectorRegistry, data):
    try:
        parsed_data = data['DumpSessionsResponse']["soap"]["zid"]
        for account in parsed_data:
            regystry.labels(account["name"], "SOAP").set(len(account["s"]))
    except KeyError:
        pass

def set_metrics_admin(regystry: CollectorRegistry, data):
    try:
        parsed_data = data['DumpSessionsResponse']["admin"]["zid"]
        for account in parsed_data:
            regystry.labels(account["name"], "ADMIN").set(len(account["s"]))
    except KeyError:
        pass

def set_metrics_imap(regystry: CollectorRegistry, data):
    try:
        parsed_data = data['DumpSessionsResponse']["imap"]["zid"]
        for account in parsed_data:
            regystry.labels(account["name"], "IMAP").set(len(account["s"]))
    except KeyError:
        pass





# -----
def getcheck():
    REGISTRY = CollectorRegistry(auto_describe=False)
    data = mail.GetActiveSession()
    carbonio_sessions = Gauge("carbonio_sessions","Carbonio Session Count:",["sessions"],registry=REGISTRY)
    carbonio_sessions.labels("active_session").set(get_active_session(data))

    carbonio_active_user = Gauge("carbonio_active_user","Carbonio Active User:",["user","type"],registry=REGISTRY)
    set_metrics_soap(carbonio_active_user,data)
    set_metrics_imap(carbonio_active_user,data)
    set_metrics_admin(carbonio_active_user,data)
    return prometheus_client.generate_latest(REGISTRY)


# metric route
app = Flask(__name__)
@app.route("/metrics")
def ApiResponse():
    return Response(getcheck(),mimetype="text/plain")

@app.route("/")
def RootQuery():
    return 'Check metrics on /metrics', 404

if __name__ == "__main__":
    app.run(host='0.0.0.0',port=PORT_EXPORTER)