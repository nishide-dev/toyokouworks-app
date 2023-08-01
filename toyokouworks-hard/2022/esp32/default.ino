#include <Adafruit_INA260.h>

#include <WiFiClientSecure.h>
#include <WiFiMulti.h>

#include <TinyGPS++.h>
//#include <LiquidCrystal_I2C.h>
#include <time.h>
#define JST     3600* 9
#include <math.h>
 
WiFiMulti wifiMulti;
WiFiClientSecure client;
Adafruit_INA260 ina260 = Adafruit_INA260();
TinyGPSPlus gps;

int year, month, day, hour, minute, second, second_old;
float lat, lng, alt, speed;

const char* machine_name = "esp32-001";
String table_name = "20220822-test";
float current;
float voltage;
float power;
float initial_battery;

//String latitude, longitude, machine_speed

int counter = 0;

const char* host = "";

String url = ""
String operation_type = "SCAN";

unsigned long zeroMillis = 0;

String get_now_table() {
  String table_name = "20220822-test";
  return table_name;
}

float read_current() {
  while (1) {
    float current = 0;
    for (int i=0; i<20; i++) {
      current += ina260.readCurrent();
      Serial.println(current);
    }
    current /= 20;
    if (current>=1 && current<15000) {
      return current;
      break;
    }
  }
}

float read_voltage() {
  while (1) {
    float voltage = 0;
    for (int i=0; i<20; i++) {
      voltage += ina260.readBusVoltage();
    }
    voltage /= 20;
    if (voltage>=0 && voltage<100000) {
      return voltage;
      break;
    }
  }
}

float read_power() {
  while (1) {
    float power = 0;
    for (int i=0; i<20; i++) {
      power += ina260.readPower();
    }
    power /= 20;
    if (power>=0 && power<200000) {
      return power;
      break;
    }
  }
}

float calc_initial_battery(float voltage) {
  double multiplier = pow(double(5.42), double((log(2)/500)*(voltage-26300)));
  float initial_battery = 195.01*log(float(voltage))-1884-float(multiplier)-1;
  return initial_battery;
}

int wifi_connect_multi(int counter) {
  if (counter % 10 != 0) {
    return 0;
  }
  if (wifiMulti.run() == WL_CONNECTED) {
    return 0;
  }
  WiFiServer server(80);
  const char* ssid = "ssid1";
  const char* password = "password1";
  wifiMulti.addAP(ssid, password);
  const char* ssid2 = "ssid2";
  const char* password2 = "password2";
  wifiMulti.addAP(ssid2, password2);
  Serial.print("Attempting to connect WiFi...");

  int count = 0;
  while (wifiMulti.run() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
    count++;
    if (count >= 10){
      Serial.print("couldn't connect WiFi...");
      return 0;
      break;
    }
  }
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
  server.begin();
  return 1;
}

void post_api(String current, String voltage, String power, String latitude, String longitude, String machine_speed, String time_d) {
  WiFiClientSecure client;
  client.setInsecure();
  if (!client.connect(host, 443)) {
    Serial.println("connection failed");
    return;
  }
  
//  String json_to_send = "{\"OperationType\":\"TEST\"}";
  String json_to_send = "{\"OperationType\": \"UPDATE_LAST\", \"Keys\": {\"TableName\": \"" + table_name + "\", \"machine_name\": \"" + String(machine_name) + "\", \"current\": \"" + current + "\", \"voltage\": \"" + voltage + "\", \"power\": \"" + power + "\", \"lat\": \"" + latitude + "\", \"lng\": \"" + longitude + "\", \"speed\": \"" + machine_speed + "\", \"time_d\": \"" + time_d + "\"}}";
  client.println("POST " + url + " HTTP/1.1");
  client.println("Content-Length: "+ String(json_to_send.length()));
  client.println("Content-Type: application/json");
  client.println("HOST: " + String(host));
  client.println("Accept: */*");
  client.println("Connection: close");
  client.println();
  client.println(json_to_send);
  
  unsigned long timeout = millis();
  while (client.available() == 0) {
    if (millis() - timeout > 60000) {
      Serial.println(">>> Client Timeout !");
      client.stop();
      return;
    }
  }
  while (client.connected()) {
    String line = client.readStringUntil('\n');
    if (line == "\r") {
      break;
    }
  }
  String line = client.readStringUntil('\n');
  Serial.print(line);
  Serial.println("closing connection");
//  delay(30000);
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
//  Serial2.begin(9600);
  Serial.println("Start!!");
  
//  Serial2.begin(9600);
  
  table_name = get_now_table();
  
  if (!ina260.begin()) {
    Serial.println("Couldn't find INA260 chip");
    while (1) {
      Serial.println("Checking...");
      delay(1000);
      if (ina260.begin()) {
        break;
      }
    }
  }
  current = read_current();
  voltage = read_voltage();
  power = read_power();
  initial_battery = calc_initial_battery(voltage);
  Serial.print("initial_battery: ");
  Serial.print(initial_battery);

//  while (!Serial2.available()) {
//    Serial.println("Couldn't find INA260 chip");
//    delay(3000);
//  }
  
  wifi_connect_multi(counter);
  

  configTime( JST, 0, "ntp.nict.jp", "ntp.jst.mfeed.ad.jp");
}

void loop() {
  // put your main code here, to run repeatedly:
  while (ina260.begin()) {
    wifi_connect_multi(counter);
    unsigned long previousMillis = millis();
    current = read_current();
    voltage = read_voltage();
    power = read_power();
//    current = ina260.readCurrent();
//    voltage = ina260.readBusVoltage();
//    power = ina260.readPower();

//    int gps_counter = 0;
//    while (Serial2.available()>0) {
//      Serial.println("GPS Loading...");
//      if (gps.encode(Serial2.read())) {
//        Serial.println("GPS Success!");
//        lat = gps.location.lat();
//        lng = gps.location.lng();
//        speed = gps.speed.kmph();
//        alt = gps.altitude.meters();
//        break;
//      }
//      gps_counter++;
//      delay(10);
//      if (gps_counter>10) {
//        break;
//      }
//    }
    
    unsigned long currentMillis = millis();
    float time_d = float((currentMillis - previousMillis)/3); // average
    
  
    Serial.println(current);
    Serial.println(time_d);

    if (wifiMulti.run() == WL_CONNECTED) {
      post_api(String(current), String(voltage), String(power), "0", "0", "0",String(time_d));
    }

    counter += 1;
    delay(1000);
  }
  Serial.println("Couldn't find INA260 chip");
  delay(1000);
}
