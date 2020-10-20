
// Example for library:
// https://github.com/Bodmer/TJpg_Decoder

// This example is for an ESP8266 or ESP32, it renders all Jpeg files
// found in SPIFFS. The test images are in the sketch "data" folder
// (press Ctrl+K to see it). You can add more images of your own to
// the Data folder.

// You must upload the images to SPIFFS using the ESP8266 or ESP32
// Arduino IDE Sketch Data Upload menu option.

// Include the jpeg decoder library
#include <TJpg_Decoder.h>
#include <Adafruit_GFX.h>    // Core graphics library
#include <Adafruit_ST7789.h> // Hardware-specific library for ST7789
#include <esp_pm.h>

// Bluetooth
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// Include SPIFFS
#define FS_NO_GLOBALS
#include <FS.h>
#ifdef ESP32
#include "SPIFFS.h" // ESP32 only
#endif
#include <SPI.h>

#define SERVICE_UUID "BC0DAFB6-3EE7-4D77-9012-FAC1DA5ADE15"
#define CHARACTERISTIC_EMOJI_UUID "bc0dafb6-3ee7-4d77-9012-fac1da5a0001"
#define CHARACTERISTIC_IMAGE_UUID "bc0dafb6-3ee7-4d77-9012-fac1da5a0002"
static char apName[] = "MyMaskMoji-xxxxxxxxxxxx";

#define TFT_CS         5
  #define TFT_RST        23
  #define TFT_DC         16
  #define TFT_MOSI 19
  #define TFT_SCLK 18
  #define BACKLIGHT 4
  Adafruit_ST7789 tft = Adafruit_ST7789(TFT_CS, TFT_DC, TFT_MOSI, TFT_SCLK, TFT_RST);


// Support function prototypes.
bool tft_output(int16_t x, int16_t y, uint16_t w, uint16_t h, uint16_t* bitmap);
void loadFile(const char *name);
void displayJpeg(const uint8_t *jpegData, uint32_t dataSize);

uint32_t sleepTime = 0;

class Callbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        std::string value = pCharacteristic->getValue();
        std::string uuid = pCharacteristic->getUUID().toString();
        Serial.print("characteristic uuid "); Serial.println(uuid.c_str());
        if (uuid == CHARACTERISTIC_EMOJI_UUID) {
          std::string filename = "/" + value + ".jpg";
          Serial.print("file "); Serial.println(value.c_str());
          loadFile(filename.c_str());
        } else if (uuid == CHARACTERISTIC_IMAGE_UUID) {
          Serial.print("received "); Serial.print(value.size()); Serial.println(" bytes of image data");
          displayJpeg((const uint8_t *)value.data(),(uint32_t)value.size());
        }
    }
};

//====================================================================================
//                                    Setup
//====================================================================================
void setup()
{
  Serial.begin(115200);
  Serial.println("\n\n Testing TJpg_Decoder library");

  // Initialise SPIFFS
  if (!SPIFFS.begin()) {
    Serial.println("SPIFFS initialisation failed!");
    while (1) yield(); // Stay here twiddling thumbs waiting
  }
  Serial.println("\r\nInitialisation done.");

  // Initialise the TFT
  tft.init(135,240);
  tft.setTextColor(0xFFFF, 0x0000);
  tft.fillScreen(ST77XX_BLACK);
  tft.setSPISpeed(40000000);
  
  pinMode(BACKLIGHT, OUTPUT);

  // The jpeg image can be scaled by a factor of 1, 2, 4, or 8
  TJpgDec.setJpgScale(1);

  // The byte order can be swapped (set true for TFT_eSPI)
  TJpgDec.setSwapBytes(false);

  // The decoder must be given the exact name of the rendering function above
  TJpgDec.setCallback(tft_output);

  initBLE();

  sleepTime = 1;
  pinMode(35, INPUT);

   esp_pm_config_esp32_t config;
    config.max_freq_mhz= 80;
    config.min_freq_mhz = 10;
    config.light_sleep_enable = true;
  esp_pm_configure(&config);
}

/**
 * Create unique device name from MAC address
 **/
void createName(char *result) {
  uint8_t baseMac[6];
  // Get MAC address for WiFi station
  esp_read_mac(baseMac, ESP_MAC_WIFI_STA);
  // Write unique name into apName
  sprintf(result, "MyMaskMoji-%02X%02X%02X%02X%02X%02X", baseMac[0], baseMac[1], baseMac[2], baseMac[3], baseMac[4], baseMac[5]);
}

void initBLE() {
  createName(apName);
  BLEDevice::init(apName);
  BLEServer *pServer = BLEDevice::createServer();

  BLEService *pService = pServer->createService(SERVICE_UUID);

  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_EMOJI_UUID,
                                         BLECharacteristic::PROPERTY_WRITE
                                       );

  pCharacteristic->setCallbacks(new Callbacks());

  pService->start();

  BLEAdvertising *pAdvertising = pServer->getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

//====================================================================================
//                                    Loop
//====================================================================================
//#if defined(ESP32)
//void loop()
//{
//  File root = SPIFFS.open("/");
//  while (File file = root.openNextFile()) {
//    String strname = file.name();
//    // If it is not a directory and filename ends in .jpg then load it
//    if (!file.isDirectory() && strname.endsWith(".jpg")) {
//      loadFile(strname.c_str());
//    }
//  }
//}
//#else   // ESP8266 has different SPIFFS methods
//void loop()
//{
//  fs::Dir directory = SPIFFS.openDir("/");
//  while (directory.next()) {
//    String strname = directory.fileName();
//    // If filename ends in .jpg then load it
//    if (strname.endsWith(".jpg")) {
//      loadFile(strname.c_str());
//    }
//  }
//}
//#endif
void loop() {
  if (sleepTime > 0 && millis() >= sleepTime) {
    Serial.println("back to sleep");
    sleepTime = 0;
    digitalWrite(BACKLIGHT, LOW);
    tft.enableSleep(true);
  }
  if (sleepTime == 0 && !digitalRead(35)) {
    sleepTime = millis() + 10000;
    digitalWrite(BACKLIGHT, HIGH);
    tft.enableSleep(false);
    tft.setRotation(1);
    tft.setCursor(10, tft.height()/2);
    tft.fillScreen(0x03 << 11 | 0x03 << 5 | 0x3);
    tft.setTextSize(2);
    tft.print(apName);
  }
}

//====================================================================================
//                                    tft_output
//====================================================================================
// This next function will be called during decoding of the jpeg file to
// render each block to the TFT.  If you use a different TFT library
// you will need to adapt this function to suit.
bool tft_output(int16_t x, int16_t y, uint16_t w, uint16_t h, uint16_t* bitmap)
{
  // Stop further decoding as image is running off bottom of screen
  if ( y >= tft.height() ) return 0;

  sleepTime = millis() + 10000;
  digitalWrite(BACKLIGHT, HIGH);
  tft.enableSleep(false);

  // This function will clip the image block rendering automatically at the TFT boundaries
  //tft.pushImage(x, y, w, h, bitmap);
  
  // This might work instead if you adapt the sketch to use the Adafruit_GFX library
   tft.drawRGBBitmap(x, y, bitmap, w, h);

  // Return 1 to decode next block
  return 1;
}

//====================================================================================
//                                    load_file
//====================================================================================

void loadFile(const char *name)
{
  tft.setRotation(0);
  tft.fillScreen(0x03 << 11 | 0x03 << 5 | 0x3);

  // Time recorded for test purposes
  uint32_t t = millis();

  // Get the width and height in pixels of the jpeg if you wish
  uint16_t w = 0, h = 0, scale;
  JRESULT result = TJpgDec.getFsJpgSize(&w, &h, name); // Note name preceded with "/"
  tft.setRotation(w > h ? 1 : 0);

  for (scale = 1; scale <= 8; scale <<= 1) {
    if (w <= tft.width() * scale && h <= tft.height() * scale) break;
  }
  TJpgDec.setJpgScale(scale);
  uint16_t x = (tft.width() - w) >> 1;
  uint16_t y = (tft.height() - h) >> 1;

  // Draw the image, top left at 0,0
  TJpgDec.drawFsJpg(x, y, name);

  // How much time did rendering take
  t = millis() - t;

  char buf[100];
  tft.setTextSize(1);
  sprintf(buf, "%s %dx%d 1:%d %u ms result %d", name, w, h, scale, t, result);
  tft.setCursor(0, tft.height() - 8);
  tft.print(buf);
  Serial.println(buf);
  delay(500);
}

void displayJpeg(const uint8_t *jpegData, uint32_t dataSize)
{
  tft.setRotation(0);
  tft.fillScreen(0x03 << 11 | 0x03 << 5 | 0x3);

  // Time recorded for test purposes
  uint32_t t = millis();

  // Get the width and height in pixels of the jpeg if you wish
  uint16_t w = 0, h = 0, scale;
  JRESULT result = TJpgDec.getJpgSize(&w, &h, jpegData, dataSize);
  tft.setRotation(w > h ? 1 : 0);

  for (scale = 1; scale <= 8; scale <<= 1) {
    if (w <= tft.width() * scale && h <= tft.height() * scale) break;
  }
  TJpgDec.setJpgScale(scale);
  uint16_t x = (tft.width() - w) >> 1;
  uint16_t y = (tft.height() - h) >> 1;

  // Draw the image, top left at 0,0
  TJpgDec.drawJpg(x, y, jpegData, dataSize);

  // How much time did rendering take
  t = millis() - t;

  char buf[100];
  tft.setTextSize(1);
  sprintf(buf, "bt buffer %dx%d 1:%d %u ms result %d", w, h, scale, t, result);
  tft.setCursor(0, tft.height() - 8);
  tft.print(buf);
  Serial.println(buf);
  delay(500);
}
