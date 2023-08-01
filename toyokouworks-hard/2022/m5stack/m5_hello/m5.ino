#include <M5Core2.h>
#include <TinyGPS++.h>
#include <Adafruit_INA260.h>
#include <math.h>
#include <WiFiClientSecure.h>
#include <WiFiMulti.h>
#include <time.h>
#define JST 3600* 9

#define HALL 36
float hall_thresh = 10;
float pi = M_PI;
float d = 0.17; // 半径[m]
float kmph = 0;


// A sample NMEA stream.
const char *gpsStream =
    "$GPRMC,045103.000,A,3014.1984,N,09749.2872,W,0.67,161.46,030913,,,A*"
    "7C\r\n";

// The TinyGPS++ object
TinyGPSPlus gps;

WiFiMulti wifiMulti;
WiFiClientSecure client;
int year, month, day, hour, minute, second, second_old;
float lat, lng, alt, speed;
float rpm_val;

int counter = 0;

const char* host = "";
String url = "";
String operation_type = "SCAN";
unsigned long zeroMillis = 0;

String get_now_table() {
  String table_name = "20220925-test";
  return table_name;
}

const char* machine_name = "esp32-001";
String table_name = "20220925-test";
float current;
float voltage;
float power;

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

void post_api(String current, String voltage, String power, String latitude, String longitude, String machine_speed, String rpm, String hall_speed) {
  WiFiClientSecure client;
  client.setInsecure();
  if (!client.connect(host, 443)) {
    Serial.println("connection failed");
    return;
  }
  
//  String json_to_send = "{\"OperationType\":\"TEST\"}";
  String json_to_send = "{\"OperationType\": \"UPDATE_GPS\", \"Keys\": {\"TableName\": \"" + table_name + "\", \"machine_name\": \"" + String(machine_name) + "\", \"current\": \"" + current + "\", \"voltage\": \"" + voltage + "\", \"power\": \"" + power + "\", \"lat\": \"" + latitude + "\", \"lng\": \"" + longitude + "\", \"speed\": \"" + machine_speed + "\", \"DataType\": \"" + "GPS" + "\", \"RPM\": \"" + rpm + "\", \"HALL_SPEED\": \"" + hall_speed + "\"}}";
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

static void smartDelay(unsigned long ms) {
    unsigned long start = millis();
    do {
        while (Serial2.available() > 0) gps.encode(Serial2.read());
    } while (millis() - start < ms);
    M5.Lcd.clear();
}

void displayInfo(float kmph, float rpm) {
    // Date and Time (UTC)
    M5.Lcd.setCursor(0, 0, 4);
    M5.Lcd.print(F("UTC: "));
    if (gps.date.isValid() && gps.time.isValid()) {
        // Date
        M5.Lcd.print(gps.date.month());
        M5.Lcd.print(F("/"));
        M5.Lcd.print(gps.date.day());
        M5.Lcd.print(F("/"));
        M5.Lcd.print(gps.date.year());
        // Time
        M5.Lcd.print(F(" "));
        if (gps.time.hour() < 10) M5.Lcd.print(F("0"));
        M5.Lcd.print(gps.time.hour());
        M5.Lcd.print(F(":"));
        if (gps.time.minute() < 10) M5.Lcd.print(F("0"));
        M5.Lcd.print(gps.time.minute());
        M5.Lcd.print(F(":"));
        if (gps.time.second() < 10) M5.Lcd.print(F("0"));
        M5.Lcd.print(gps.time.second());
        M5.Lcd.print(F("."));
        if (gps.time.centisecond() < 10) M5.Lcd.print(F("0"));
        M5.Lcd.print(gps.time.centisecond());
    } else {
        M5.Lcd.print(F("INVALID"));
    }

    // Position
    M5.Lcd.println();
    M5.Lcd.print(F("LAT: "));
    if (gps.location.isValid()) {
        M5.Lcd.print(gps.location.lat(), 6);
    } else {
        M5.Lcd.print(F("INVALID"));
    }
    M5.Lcd.println();
    M5.Lcd.print(F("LNG: "));
    if (gps.location.isValid()) {
        M5.Lcd.print(gps.location.lng(), 6);
    } else {
        M5.Lcd.print(F("INVALID"));
    }

    // Altitude
    M5.Lcd.println();
    M5.Lcd.print(F("ALT: "));
    if (gps.altitude.isValid()) {
        M5.Lcd.print(gps.altitude.meters());
    } else {
        M5.Lcd.print(F("INVALID"));
    }

    // Speed in kilometers per hour (double)
    // Course in degrees (double)
    M5.Lcd.println();
    M5.Lcd.print(F("S&C: "));
    M5.Lcd.print(gps.speed.mps());
    M5.Lcd.print(F(", "));
    M5.Lcd.print(gps.course.deg());

    // Number of satellites in use
    M5.Lcd.println();
    M5.Lcd.print(F("SAT: "));
    if (gps.satellites.isValid()) {
        M5.Lcd.print(gps.satellites.value());
    } else {
        M5.Lcd.print(F("INVALID"));
    }

    M5.Lcd.println();
    M5.Lcd.print(F("KMPH: "));
    M5.Lcd.print(kmph);

    M5.Lcd.println();
    M5.Lcd.print(F("RPM: "));
    M5.Lcd.print(rpm);
}



void setup() {
  M5.begin(true, true, true, false, kMBusModeInput);

  Serial2.begin(9600, SERIAL_8N1, 13, 14);
  M5.Lcd.setTextColor(GREEN,  BLACK);

  pinMode(HALL, INPUT);

  wifi_connect_multi(counter);
  
  configTime( JST, 0, "ntp.nict.jp", "ntp.jst.mfeed.ad.jp");
}

void loop() {
  wifi_connect_multi(counter);
  unsigned long previousMillis = millis()/1000;
  bool status = digitalRead(HALL);
  // M5.Lcd.printf("Hall status : %d", status);

  float hall_count = 1.0;
  float start = micros();
  bool on_state = false;
  // counting number of times the hall sensor is tripped
  // but without double counting during the same trip
  while(true){
    float mid = micros();
    if (((mid-start)/1000000.0) > 5.0) {
      break;
    }
    if (digitalRead(HALL)==0){
      if (on_state==false){
        on_state = true;
        hall_count+=1.0;
      }
    } else{
      on_state = false;
    }
    
    if (hall_count>=hall_thresh){
      Serial.print(hall_count);
      break;
    }

  }

  // print information about Time and RPM
  float end_time = micros();
  float time_passed = ((end_time-start)/1000000.0);
  Serial.print("Time Passed: ");
  Serial.print(time_passed);
  Serial.println("s");
  rpm_val = (hall_count/time_passed)*60.0;
  Serial.print(rpm_val);
  Serial.println(" RPM");
  kmph = 0.12 * rpm_val * pi * d;
  Serial.print(kmph);
  Serial.println(" KMPH");
  delay(1);

  int gps_counter = 0;
  while (Serial2.available()>0) {
    Serial.println("GPS Loading...");
    if (gps.encode(Serial2.read())) {
      Serial.println("GPS Success!");
      lat = gps.location.lat();
      lng = gps.location.lng();
      speed = gps.speed.kmph();
      alt = gps.altitude.meters();
      break;
    }
    gps_counter++;
    delay(10);
    if (gps_counter>10) {
      break;
    }
  
    unsigned long currentMillis = millis()/1000;
    float time_d = float((currentMillis - previousMillis)/3); // average
    if (wifiMulti.run() == WL_CONNECTED) {
      post_api(String(current), String(voltage), String(power), String(lat), String(lng), String(speed), String(rpm_val), String(kmph));
    }
    counter += 1;
    delay(100);
  }

  displayInfo(kmph, rpm_val);
  smartDelay(200);
}
