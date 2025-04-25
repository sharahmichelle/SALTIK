#include <Wire.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <DFRobot_ESP_EC.h>

// WiFi Credentials
const char* WIFI_SSID = "gumamela_wifi";        // Replace with your Wi-Fi SSID
const char* WIFI_PASSWORD = "ro$3ma2Low"; // Replace with your Wi-Fi password

// IF THE WIFI DOES NOT HAVE A PASSWORD!
//const char* WIFI_SSID = "UPVMIAGAO";
//const char* WIFI_PASSWORD = "";  // Leave it empty for open networks

// Firebase Credentials
const char* FIREBASE_HOST = "saltik-198-default-rtdb.firebaseio.com";
const char* FIREBASE_AUTH = "KYlTeJtRRligdZvqT0oSpjllKcDG6yZhWED52lup";

// Firebase objects
FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;

// Pin configurations
#define ONE_WIRE_BUS 4  // GPIO pin for DS18B20
#define EC_SENSOR_PIN 35 // GPIO pin for EC sensor

// Initialize the OneWire and DallasTemperature objects
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// Initialize the EC sensor
DFRobot_ESP_EC ec;

// Initialize the OLED display
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_ADDR 0x3C
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire);

// Temperature coefficient for EC
#define ALPHA 0.022
#define K 0.8  // Calibration constant for salinity

void setup() {
  Serial.begin(115200);

  // Connect to Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected!");

  // Configure Firebase
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Initialize DS18B20
  sensors.begin();
  
  // Initialize EC sensor
  ec.begin();

  // Initialize OLED display
  if (!display.begin(SSD1306_SWITCHCAPVCC, OLED_ADDR)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;);
  }

  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.println(F("Temp & EC Sensors"));
  display.display();
  delay(2000);
}

void loop() {
  // Read temperature
  sensors.requestTemperatures();
  float temperatureC = sensors.getTempCByIndex(0);

  // Read EC sensor voltage
  float voltage = analogRead(EC_SENSOR_PIN);

  // Convert voltage to EC value
  float ecValue25 = ec.readEC(voltage, temperatureC);
  
  // Apply temperature compensation
  float ecValue = ecValue25 * (1 + ALPHA * (temperatureC - 25));

  // Calculate salinity
  float salinity = ecValue / K;

  // Print to Serial Monitor
  Serial.print("Temperature: ");
  Serial.print(temperatureC);
  Serial.println(" °C");

  Serial.print("EC Value: ");
  Serial.print(ecValue, 2);
  Serial.println(" mS/cm");

  Serial.print("Salinity: ");
  Serial.print(salinity, 2);
  Serial.println(" ppt");

  // Display on OLED
  display.clearDisplay();
  display.setCursor(0, 0);
  display.println(F("Temp:"));
  display.print(temperatureC);
  display.print(F(" C"));

  display.setCursor(0, 16);
  display.println(F("EC:"));
  display.print(ecValue, 2);
  display.print(F(" mS/cm"));

  display.setCursor(0, 32);
  display.println(F("Salinity:"));
  display.print(salinity, 2);
  display.print(F(" ppt"));

  display.display();

  // **Send Data to Firebase**
  if (Firebase.setFloat(firebaseData, "/sensor/temperature", floor(temperatureC * 10) / 10)) {
    Serial.println("Temperature updated in Firebase");
  } else {
    Serial.println("Failed to update temperature");
    Serial.println(firebaseData.errorReason());
  }

  if (Firebase.setFloat(firebaseData, "/sensor/ec_value", ecValue)) {
    Serial.println("EC updated in Firebase");
  } else {
    Serial.println("Failed to update EC");
    Serial.println(firebaseData.errorReason());
  }

  if (Firebase.setFloat(firebaseData, "/sensor/salinity", round(salinity))) {
    Serial.println("Salinity updated in Firebase");
  } else {
    Serial.println("Failed to update salinity");
    Serial.println(firebaseData.errorReason());
  }

  delay(5000);  // Send data every 5 seconds
}
