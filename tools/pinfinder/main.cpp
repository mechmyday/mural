// Pin finder for the MKS DLC32 MAX.
// Drives one candidate GPIO high at a time (all others low) for a few seconds and
// prints which one. Put a multimeter between GND and a pin (e.g. the STEP/DIR holes of the
// empty Z and A driver sockets): it reads ~3.3V only while that pin's GPIO is printed.
//
// The list covers the pins Mural uses for the OLED and servo plus the spare header GPIOs.
// It skips pins the board uses for flash, steppers, SD and UART0.
#include <Arduino.h>

static const int candidates[] = {2, 4, 5, 19, 20, 35, 36, 37, 38, 39, 40, 41, 48};
static const int count = sizeof(candidates) / sizeof(candidates[0]);
static const int holdMs = 4000;

void setup() {
    Serial.begin(115200);
    delay(500);
    for (int i = 0; i < count; i++) {
        pinMode(candidates[i], OUTPUT);
        digitalWrite(candidates[i], LOW);
    }
    Serial.println("pinfinder: cycling GPIOs");
}

void loop() {
    for (int i = 0; i < count; i++) {
        int pin = candidates[i];
        digitalWrite(pin, HIGH);
        Serial.printf("GPIO %d HIGH\n", pin);
        delay(holdMs);
        digitalWrite(pin, LOW);
    }
}
