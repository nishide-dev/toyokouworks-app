#include <Arduino.h>
#include <M5Core2.h>
#include <Adafruit_INA260.h>
#include <WiFiClientSecure.h>
#include <WiFiMulti.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "credentials.h"
#include <TinyGPS++.h>
#include <time.h>
#include <math.h>
#include "TCA9548.h"

#define PIN_YELLOW 32
#define PIN_GREEN 33
#define INA260_CHANNEL 3
#define JST 3600* 9

// TCA9548 MP(0x70);

Adafruit_INA260 ina260 = Adafruit_INA260();
WiFiMulti wifiMulti;
String raceTimestamp;
// A sample NMEA stream.
const char *gpsStream =
    "$GPRMC,045103.000,A,3014.1984,N,09749.2872,W,0.67,161.46,030913,,,A*"
    "7C\r\n";
// The TinyGPS++ object
TinyGPSPlus gps;
float current, voltage, power;
float lat, lng, gpsSpeed, newGpsSpeed, alt;
float integratedCurrent = 0;
unsigned long currentMillis;
unsigned long previousMillis;
unsigned long diffTime = 0;

// put function declarations here:
void M5Begin();
void SerialBegin();
// void WireBegin();
// void MPBegin();
void WiFiBegin();
void INA260Begin();
void GPSBegin();
void postData(float current, float voltage, float power, float integratedCurrent, float lat, float lng, float gpsSpeed);
float readCurrent();
float readVoltage();
float readPower();

void setup() {
  // put your setup code here, to run once:
  M5Begin();
  SerialBegin();
  // WireBegin();
  // MPBegin();
  WiFiBegin();

  Serial.println("Adafruit INA260 Test");

  INA260Begin();
  GPSBegin();
  M5.Lcd.setCursor(0, 0);
  M5.Lcd.print("              ");

  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Failed to obtain time");
    return;
  }

  currentMillis = millis();
  previousMillis = currentMillis;

  // 分までの時間を取得
  char buffer[20];
  sprintf(buffer, "%04d%02d%02d%02d%02d", timeinfo.tm_year + 1900, timeinfo.tm_mon + 1, timeinfo.tm_mday, timeinfo.tm_hour, timeinfo.tm_min);
  raceTimestamp = buffer;
}

void loop() {
  // put your main code here, to run repeatedly:
  current = readCurrent();
  Serial.print("Current: ");
  Serial.print(current);
  Serial.println(" mA");

  voltage = readVoltage();
  Serial.print("Bus Voltage: ");
  Serial.print(voltage);
  Serial.println(" mV");

  power = readPower();

  const unsigned long GPS_TIMEOUT = 1000;
  unsigned long gpsStartTime = millis();

  while (Serial2.available() > 0 && (millis() - gpsStartTime) < GPS_TIMEOUT) {
    char c = Serial2.read();
    if (gps.encode(c)) {
      Serial.println("GPS Data Received");
      lat = gps.location.lat();
      lng = gps.location.lng();
      newGpsSpeed = gps.speed.kmph();
      if (gpsSpeed != newGpsSpeed) {
        gpsSpeed = newGpsSpeed;
        Serial.print("GPS Speed: ");
        Serial.print(gpsSpeed);
        Serial.println(" km/h");
      } else {
        continue;
      }
      break;
    }
  }

  if (gps.location.isValid()) {
    lat = gps.location.lat();
    lng = gps.location.lng();
    gpsSpeed = gps.speed.kmph();
    Serial.println("GPS Success!");
  } else {
    Serial.println("GPS Data Invalid or No Data Received");
    // ここで緯度や経度にデフォルトの値を設定することも考えられます。
    // lat = DEFAULT_LAT;
    // lng = DEFAULT_LNG;
  }

  currentMillis = millis();
  diffTime = currentMillis - previousMillis;
  previousMillis = currentMillis;

  // integratedCurrentはmA*hで計算
  integratedCurrent += current * float(diffTime) / 1000 / 60 / 60;
  Serial.print("integratedCurrent: ");
  Serial.println(integratedCurrent);

  // wifiが切れていたら再接続
  if (wifiMulti.run() != WL_CONNECTED) {
    WiFiBegin();
  } else {
    postData(current, voltage, power, integratedCurrent, lat, lng, gpsSpeed);
  }
  delay(100);
}

// put function definitions here:
void M5Begin() {
  M5.begin(true, true, true, true);
  M5.Lcd.setTextSize(3);
  M5.Lcd.print("Hello World");
}

void SerialBegin() {
  Serial.begin(115200);
  delay(100);
  while (!Serial) { M5.Lcd.print("Failed to connect Serial"); delay(10); }
}

// void WireBegin() {
//   Wire.begin();
//   delay(100);
// }

// void MPBegin() {
//   if (MP.begin() == false)
//   {
//     Serial.println("Could not connect to TCA9548 multiplexer.");
//   }
//   else
//   {
//     Serial.println("\nScan the channels of the multiplexer for searchAddress.\n");
//     MP.selectChannel(INA260_CHANNEL); 
//   }
// }

void WiFiBegin() {
  wifiMulti.addAP(SSID1, PASSWORD1);
  wifiMulti.addAP(SSID2, PASSWORD2);

  while (wifiMulti.run() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
  }

  configTime(9 * 60 * 60, 0, "ntp.jst.mfeed.ad.jp", "ntp.nict.jp", "time.google.com");

  Serial.println();
  Serial.println("Connected to WiFi");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  Serial.print("MAC Address: ");
  Serial.println(WiFi.macAddress());
}

void INA260Begin() {
  if (!ina260.begin()) {
    Serial.println("Couldn't find INA260 chip");
    while (1);
  }
  Serial.println("Found INA260 chip");
}

void GPSBegin() {
  Serial2.begin(9600, SERIAL_8N1, 13, 14);
  delay(100);
}

void postData(float current, float voltage, float power, float integratedCurrent, float lat, float lng, float gpsSpeed) {
  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;

  // ArduinoJsonを使用して、JSONを簡単に生成
  StaticJsonDocument<200> doc;
  doc["current"] = current;
  doc["voltage"] = voltage;
  // doc["power"] = power;
  doc["integratedCurrent"] = integratedCurrent;
  doc["lat"] = lat;
  doc["lng"] = lng;
  doc["gpsSpeed"] = gpsSpeed;
  doc["race"] = raceTimestamp.c_str();
  String payload;
  serializeJson(doc, payload);

  http.begin(client, API_URL);
  http.addHeader("Content-Type", "application/json");

  int httpResponseCode = http.POST(payload);

  if(httpResponseCode > 0) {
    String response = http.getString();
    Serial.println(httpResponseCode);
    Serial.println(response);
  } else {
    Serial.print("Error on sending POST: ");
    Serial.println(httpResponseCode);
  }
  http.end();
}

float readCurrent() {
  while (1) {
    float current = 0;
    for (int i=0; i<3; i++) {
      current += ina260.readCurrent();
    }
    current /= 3;
    if (current>=-5 && current<15000) {
      return current;
      break;
    }
  }
}

float readVoltage() {
  while (1) {
    float voltage = 0;
    for (int i=0; i<3; i++) {
      voltage += ina260.readBusVoltage();
    }
    voltage /= 3;
    if (voltage>=-5 && voltage<100000) {
      return voltage;
      break;
    }
  }
}

float readPower() {
  while (1) {
    float power = 0;
    for (int i=0; i<3; i++) {
      power += ina260.readPower();
    }
    power /= 3;
    if (power>=-5 && power<200000) {
      return power;
      break;
    }
  }
}
