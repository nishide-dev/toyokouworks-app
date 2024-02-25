#include <Arduino.h>
#include <Adafruit_INA260.h>
#include <WiFiClientSecure.h>
#include <WiFiMulti.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "credentials.h"

Adafruit_INA260 ina260 = Adafruit_INA260();
WiFiMulti wifiMulti;

// put function declarations here:
void postCurrentData(float current, float voltage) {
  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;

  // ArduinoJsonを使用して、JSONを簡単に生成
  StaticJsonDocument<200> doc;
  doc["current"] = current;
  doc["voltage"] = voltage;
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

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  delay(100);

  while (!Serial) { delay(10); }

  Serial.println("Adafruit INA260 Test");

  WiFi.begin(SSID, PASSWORD);

  while(WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
  }

  configTime(9 * 60 * 60, 0, "ntp.jst.mfeed.ad.jp", "ntp.nict.jp", "time.google.com");

  Serial.println();
  Serial.print("Connected to ");
  Serial.println(SSID);
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  Serial.print("MAC Address: ");
  Serial.println(WiFi.macAddress());

  delay(3000);

  if (!ina260.begin()) {
    Serial.println("Couldn't find INA260 chip");
    while (1);
  }
  Serial.println("Found INA260 chip");
}

void loop() {
  // put your main code here, to run repeatedly:
  delay(500);
  float current = ina260.readCurrent();
  Serial.print("Current: ");
  Serial.print(current);
  Serial.println(" mA");
  float voltage = ina260.readBusVoltage();
  Serial.print("Bus Voltage: ");
  Serial.print(voltage);
  Serial.println(" V");

  postCurrentData(current, voltage);
}

// put function definitions here:
int myFunction(int x, int y) {
  return x + y;
}