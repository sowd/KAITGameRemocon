#!/usr/bin/python3
# -*- coding:utf-8 -*-

__author__ = "omori"
__version__ = "1.0.0"


import argparse
import json
from http.server import BaseHTTPRequestHandler, HTTPServer

from urllib.parse import urlparse
from urllib.parse import parse_qs

import serial
import time
from datetime import datetime
import sys



# LED display rule. Normal Off.
DISPLAY_RULE_NORMALLY_OFF = 0

# LED display rule. Normal On.
DISPLAY_RULE_NORMALLY_ON = 1


def calc_crc(buf, length):
    """
    CRC-16 calculation.
    """
    crc = 0xFFFF
    for i in range(length):
        crc = crc ^ buf[i]
        for i in range(8):
            carrayFlag = crc & 1
            crc = crc >> 1
            if (carrayFlag == 1):
                crc = crc ^ 0xA001
    crcH = crc >> 8
    crcL = crc & 0x00FF
    return (bytearray([crcL, crcH]))


def now_utc_str():
    """
    Get now utc.
    """
    return datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")


def startSensor():

    """
    try:
        # LED On. Color of Green.
        command = bytearray([0x52, 0x42, 0x0a, 0x00, 0x02, 0x11, 0x51, DISPLAY_RULE_NORMALLY_ON, 0x00, 0, 255, 0])
        command = command + calc_crc(command, len(command))
        serSensor.write(command)
        time.sleep(0.1)
        ret = serSensor.read(serSensor.inWaiting())

    except KeyboardInterrupt:
        # LED Off.
        command = bytearray([0x52, 0x42, 0x0a, 0x00, 0x02, 0x11, 0x51, DISPLAY_RULE_NORMALLY_OFF, 0x00, 0, 0, 0])
        command = command + calc_crc(command, len(command))
        serSensor.write(command)
        time.sleep(1)
        # script finish.
        serSensor.exit
    """



class MyHandler(BaseHTTPRequestHandler):
    """
    Received the request as json, send the response as json
    please you edit the your processing
    """
    def do_GET(self):
        try:
            #content_len=int(self.headers.get('content-length'))
            #requestBody = json.loads(self.rfile.read(content_len).decode('utf-8'))
            parsed = urlparse(self.path)

            #print(parsed)

            # Get sensor data

            if serPato.isOpen():
              serPato.write(str.encode(parsed.query))

              """
              # Get Latest data Long.
              command = bytearray([0x52, 0x42, 0x05, 0x00, 0x01, 0x21, 0x50])
              command = command + calc_crc(command, len(command))
              tmp = serSensor.write(command)
              time.sleep(0.1)
              data = serSensor.read(serSensor.inWaiting())
              print_latest_data(data)
              time.sleep(1)

              """

            response = { 'status' : 200,
                         'result' : { 'hoge' : 100,
                                      'bar' : 'bar' }
                        }
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            responseBody = json.dumps(response)

            self.wfile.write(responseBody.encode('utf-8'))
        except Exception as e:
            print("An error occured")
            print("The information of error is as following")
            print(type(e))
            print(e.args)
            print(e)
            response = { 'status' : 500,
                         'msg' : 'An error occured' }

            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            responseBody = json.dumps(response)

            self.wfile.write(responseBody.encode('utf-8'))

serPato = None

def run(server_class=HTTPServer, handler_class=MyHandler, server_name='localhost', port=8080):
    global serPato
    # Pato Serial
    serPato = serial.Serial("/dev/ttyUSB0", 19200, serial.EIGHTBITS, serial.PARITY_NONE)

    #startSensor()
    server = server_class((server_name, port), handler_class)
    server.serve_forever()

def importargs():
    parser = argparse.ArgumentParser("This is the simple server")

    parser.add_argument('--host', '-H', required=False, default='localhost')
    parser.add_argument('--port', '-P', required=False, type=int, default=8080)

    args = parser.parse_args()

    return args.host, args.port


def main():
    host, port = importargs()
    run(server_name=host, port=port)

if __name__ == '__main__':
    main()