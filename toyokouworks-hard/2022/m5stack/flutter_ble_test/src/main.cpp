#include <M5Core2.h>
#include <TinyGPS++.h>
#include <Adafruit_INA260.h>
#include <math.h>

#define HALL 36
float hall_thresh = 100.0;
float pi = M_PI;
float d = 0.18; // 半径[m]


// A sample NMEA stream.
const char *gpsStream =
    "$GPRMC,045103.000,A,3014.1984,N,09749.2872,W,0.67,161.46,030913,,,A*"
    "7C\r\n";

// The TinyGPS++ object
TinyGPSPlus gps;
Adafruit_INA260 ina260 = Adafruit_INA260();

String table_name = "20220822-test";
float current;
float voltage;
float power;

static void smartDelay(unsigned long ms) {
    unsigned long start = millis();
    do {
        while (Serial2.available() > 0) gps.encode(Serial2.read());
    } while (millis() - start < ms);
    M5.Lcd.clear();
}

void displayInfo(float current_value) {
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
    M5.Lcd.print(F("CURRENT: "));
    M5.Lcd.print(current_value);
}

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
    if (current>=0 && current<5000) {
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

void setup() {
    M5.begin(true, true, true, false, kMBusModeInput);

    Serial2.begin(9600, SERIAL_8N1, 13, 14);
    M5.Lcd.setTextColor(GREEN,  BLACK);

    //  while (*gpsStream)
    //    if (gps.encode(*gpsStream++))
    //      displayInfo();

    table_name = get_now_table();
  
    // if (!ina260.begin()) {
    //     Serial.println("Couldn't find INA260 chip");
    //     M5.Lcd.println("Couldn't find INA260 chip");
    //     while (1) {
    //         Serial.println("Checking...");
    //         delay(1000);
    //         if (ina260.begin()) {
    //             break;
    //         }
    //     }
    // }
    // current = read_current();
    // voltage = read_voltage();
    // power = read_power();
  M5.Lcd.print("     HALL Sensor");
  pinMode(HALL, INPUT);
}

void loop() {
  while (ina260.begin()) {
      current = read_current();
      voltage = read_voltage();
      power = read_power();
      float current = 0;
      displayInfo(current);
  }
  bool status = digitalRead(HALL);
  M5.Lcd.printf("Hall status : %d", status);

  float hall_count = 1.0;
  float start = micros();
  bool on_state = false;
  // counting number of times the hall sensor is tripped
  // but without double counting during the same trip
  while(true){
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
  float rpm_val = (hall_count/time_passed)*60.0;
  Serial.print(rpm_val);
  Serial.println(" RPM");
  float kmph = 0.12 * rpm_val * pi * d;
  Serial.print(kmph);
  Serial.println(" KMPH");
  delay(1);

  float current = 0;
  displayInfo(current);
  smartDelay(1000);
}