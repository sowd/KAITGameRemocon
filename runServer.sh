#!/usr/bin/python3
# -*- coding:utf-8 -*-


#PAT_SERIAL_ID="/dev/ttyUSB1"
PAT_SERIAL_ID='/dev/serial/by-id/usb-PATLITE_USB_FTDI_PATLITE-if00-port0'


#OMRON_SERIAL_ID="/dev/ttyUSB0"
OMRON_SERIAL_ID="/dev/serial/by-id/usb-OMRON_2JCIE-BU01_MY2SD5OO-if00-port0"
#OMRON_SERIAL_ID=''


DEFAULT_HOST_NAME='localhost'
PORT_NUM=8081


import argparse
import json
from http.server import BaseHTTPRequestHandler, HTTPServer

from urllib.parse import urlparse
from urllib.parse import parse_qs

# for IRemocon
import socket


# for Omron sensor
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


serSensor = None

def startSensor():
    global serSensor
    serSensor = serial.Serial(OMRON_SERIAL_ID, 115200, serial.EIGHTBITS, serial.PARITY_NONE)

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



def getSensorData(data):
    """
    print measured latest value.
    """
    time_measured = datetime.now().strftime("%Y/%m/%d %H:%M:%S")
    temperature = str(int(hex(data[9]) + '{:02x}'.format(data[8], 'x'), 16) / 100)
    relative_humidity = str(int(hex(data[11]) + '{:02x}'.format(data[10], 'x'), 16) / 100)
    ambient_light = str(int(hex(data[13]) + '{:02x}'.format(data[12], 'x'), 16))
    barometric_pressure = str(int(hex(data[17]) + '{:02x}'.format(data[16], 'x')
                                  + '{:02x}'.format(data[15], 'x') + '{:02x}'.format(data[14], 'x'), 16)
 / 1000)
    sound_noise = str(int(hex(data[19]) + '{:02x}'.format(data[18], 'x'), 16) / 100)
    eTVOC = str(int(hex(data[21]) + '{:02x}'.format(data[20], 'x'), 16))
    eCO2 = str(int(hex(data[23]) + '{:02x}'.format(data[22], 'x'), 16))
    discomfort_index = str(int(hex(data[25]) + '{:02x}'.format(data[24], 'x'), 16) / 100)
    heat_stroke = str(int(hex(data[27]) + '{:02x}'.format(data[26], 'x'), 16) / 100)
    vibration_information = str(int(hex(data[28]), 16))
    si_value = str(int(hex(data[30]) + '{:02x}'.format(data[29], 'x'), 16) / 10)
    pga = str(int(hex(data[32]) + '{:02x}'.format(data[31], 'x'), 16) / 10)
    seismic_intensity = str(int(hex(data[34]) + '{:02x}'.format(data[33], 'x'), 16) / 1000)
    temperature_flag = str(int(hex(data[36]) + '{:02x}'.format(data[35], 'x'), 16))
    relative_humidity_flag = str(int(hex(data[38]) + '{:02x}'.format(data[37], 'x'), 16))
    ambient_light_flag = str(int(hex(data[40]) + '{:02x}'.format(data[39], 'x'), 16))
    barometric_pressure_flag = str(int(hex(data[42]) + '{:02x}'.format(data[41], 'x'), 16))
    sound_noise_flag = str(int(hex(data[44]) + '{:02x}'.format(data[43], 'x'), 16))
    etvoc_flag = str(int(hex(data[46]) + '{:02x}'.format(data[45], 'x'), 16))
    eco2_flag = str(int(hex(data[48]) + '{:02x}'.format(data[47], 'x'), 16))
    discomfort_index_flag = str(int(hex(data[50]) + '{:02x}'.format(data[49], 'x'), 16))
    heat_stroke_flag = str(int(hex(data[52]) + '{:02x}'.format(data[51], 'x'), 16))
    si_value_flag = str(int(hex(data[53]), 16))
    pga_flag = str(int(hex(data[54]), 16))
    seismic_intensity_flag = str(int(hex(data[55]), 16))

    return {
	 "time_measured":time_measured
	,"temperature":temperature
	,"relative_humidity":relative_humidity
	,"ambient_light":ambient_light
	,"barometric_pressure":barometric_pressure
	,"sound_noise":sound_noise
	,"eTVOC":eTVOC
	,"eCO2":eCO2
	,"discomfort_index":discomfort_index
	,"heat_stroke":heat_stroke
	,"vibration_information":vibration_information
	,"si_value":si_value
	,"pga":pga
	,"seismic_intensity":seismic_intensity
	,"temperature_flag":temperature_flag
	,"relative_humidity_flag":relative_humidity_flag
	,"ambient_light_flag":ambient_light_flag
	,"barometric_pressure_flag":barometric_pressure_flag
	,"sound_noise_flag":sound_noise_flag
	,"etvoc_flag":etvoc_flag
	,"eco2_flag":eco2_flag
	,"discomfort_index_flag":discomfort_index_flag
	,"heat_stroke_flag":heat_stroke_flag
	,"si_value_flag":si_value_flag
	,"pga_flag":pga_flag
	,"seismic_intensity_flag":seismic_intensity_flag
    }

def sendIRemocon(params):
  ps = params.split(',')
  cmd = ps[0]
  iRemoconAddr = ps[1]

  print(iRemoconAddr+'<'+cmd)

  #with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
  with socket.socket() as s:
    s.settimeout(10)
    s.connect((iRemoconAddr, 51013))
    s.send( (cmd+"\r\n").encode())

    ret = s.recv(1024).decode()

    return ret

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

            ret = ''

            if OMRON_SERIAL_ID != '' and parsed.query.startswith("callback="):
              print('Accessing the sensor.')
              # Get Latest data Long.
              command = bytearray([0x52, 0x42, 0x05, 0x00, 0x01, 0x21, 0x50])
              command = command + calc_crc(command, len(command))
              tmp = serSensor.write(command)
              time.sleep(0.1)
              data = serSensor.read(serSensor.inWaiting())
              sensorData = getSensorData(data)

              # Respond by JSONP
              self.send_response(200)
              self.send_header('Content-type', 'application/x-javascript')
              self.end_headers()
              responseBody = parsed.query[9:]+'('+json.dumps(sensorData)+')'

              self.wfile.write(responseBody.encode('utf-8'))

              return

            elif parsed.query.startswith("*"):
              print('Accessing IRemocon.')
              ret = sendIRemocon(parsed.query)

            elif PAT_SERIAL_ID != '' and parsed.query.isalpha() and serPato.isOpen():
              print('Accessing lamp.')
              serPato.write(str.encode(parsed.query))

            response = {
              'result':ret
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
            response = {}
            #response = { 'status' : 500,
            #             'msg' : 'An error occured' }

            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            responseBody = json.dumps(response)

            self.wfile.write(responseBody.encode('utf-8'))

serPato = None

def run(server_class=HTTPServer, handler_class=MyHandler, server_name=DEFAULT_HOST_NAME, port=PORT_NUM):
    print('Patlite serial ID: '+PAT_SERIAL_ID);
    print('Omron sensor serial ID: '+OMRON_SERIAL_ID);
    print('===========');
    print('Starting API server at '+server_name+':'+str(port));
    print(' (No other host name can be used for REST access)');
    print('Changing host name: -H [host name]');
    print('Changing port #: -P [port num]');

    ## Pato Serial
    global serPato
    if PAT_SERIAL_ID != '':
        serPato = serial.Serial(PAT_SERIAL_ID, 19200, serial.EIGHTBITS, serial.PARITY_NONE)

    # start omron sensor
    if OMRON_SERIAL_ID != '':
        startSensor()

    server = server_class((server_name, port), handler_class)

    server.serve_forever()

def importargs():
    parser = argparse.ArgumentParser("This is the simple server")

    parser.add_argument('--host', '-H', required=False, default=DEFAULT_HOST_NAME)
    parser.add_argument('--port', '-P', required=False, type=int, default=PORT_NUM)

    args = parser.parse_args()

    return args.host, args.port


def main():
    host, port = importargs()

    run(server_name=host, port=port)

if __name__ == '__main__':
    main()
