// Basic demo for accelerometer readings from Adafruit MPU6050

#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include "BluetoothSerial.h"


Adafruit_MPU6050 mpu;
float energyAccl = 0;
BluetoothSerial SerialBT;


void setup(void) {
  Serial.begin(9600);
  SerialBT.begin("ESP32_pbu2"); //Start the Bluetooth Communication and name your own device with your NetID ESP32_NETID
  Serial.println("Adafruit MPU6050 test!");

  // Try to initialize!
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }
  Serial.println("MPU6050 Found!");

  mpu.setAccelerometerRange(MPU6050_RANGE_8_G); // +- 8G /s
  mpu.setGyroRange(MPU6050_RANGE_500_DEG); // +- 500 Degree/s
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ); // Low Pass Filter 
  delay(10);
}

void loop() {

  /* Get new sensor events with the readings */
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  /* Print out the values to USB port */
  Serial.print(a.acceleration.x);
  Serial.print(",");
  Serial.print(a.acceleration.y);
  Serial.print(",");
  Serial.print(a.acceleration.z);
  Serial.print(",");
  Serial.print(g.gyro.x);
  Serial.print(",");
  Serial.print(g.gyro.y);
  Serial.print(",");
  Serial.println(g.gyro.z);

  //  /* Print out the values to Bluetooth port */
  // SerialBT.print(a.acceleration.x);
  // SerialBT.print(",");
  // SerialBT.print(a.acceleration.y);
  // SerialBT.print(",");
  // SerialBT.print(a.acceleration.z);
  // SerialBT.print(",");
  // SerialBT.print(g.gyro.x);
  // SerialBT.print(",");
  // SerialBT.print(g.gyro.y);
  // SerialBT.print(",");
  // SerialBT.println(g.gyro.z);
  
  delay(10);
}
