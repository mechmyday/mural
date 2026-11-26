// I2C check for the OLED on the expansion header.
// Every 3 s: reads the idle level of IO17/IO18 (the OLED's pull-ups should make both HIGH),
// then scans the bus with SDA/SCL both ways round.
#include <Arduino.h>
#include <Wire.h>

static void scan(int sda, int scl) {
    Wire.begin(sda, scl, 100000);
    Serial.printf("  scan SDA=%d SCL=%d:", sda, scl);
    int found = 0;
    for (uint8_t a = 1; a < 127; a++) {
        Wire.beginTransmission(a);
        if (Wire.endTransmission() == 0) { Serial.printf(" 0x%02X", a); found++; }
    }
    Serial.println(found ? "" : " nothing");
    Wire.end();
}

void setup() {
    Serial.begin(115200);
    delay(500);
}

void loop() {
    pinMode(17, INPUT);
    pinMode(18, INPUT);
    delay(5);
    Serial.printf("idle: IO17=%d IO18=%d\n", digitalRead(17), digitalRead(18));
    scan(17, 18);
    scan(18, 17);
    delay(3000);
}
