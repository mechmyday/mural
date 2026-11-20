#ifndef Board_h
#define Board_h

// Pin map for the MKS DLC32 MAX (ESP32-S3).
// Source: "MKS DLC32 MAX V1.0_002 PIN.pdf" from github.com/makerbase-mks/MKS-DLC32.

// Steppers. Drivers are plug-in TMC2209 modules in standalone mode (no UART on this board).
// X socket drives the left motor, Y socket drives the right motor (Y1 and Y2 connectors are the same driver).
constexpr int LEFT_STEP_PIN = 16;   // X STEP
constexpr int LEFT_DIR_PIN = 15;    // X DIR
constexpr int RIGHT_STEP_PIN = 7;   // Y STEP
constexpr int RIGHT_DIR_PIN = 6;    // Y DIR
constexpr int MOTOR_ENABLE_PIN = 8; // Shared EN for all sockets, active LOW

// TF card slot. Wired for SDMMC, driven here in SPI mode:
// CLK -> SCK, D0 -> MISO, CMD -> MOSI, D3 -> CS.
constexpr int SD_SCK_PIN = 13;
constexpr int SD_MISO_PIN = 12;
constexpr int SD_MOSI_PIN = 14;
constexpr int SD_CS_PIN = 21;

// The Z and A driver sockets stay empty, so their STEP/DIR holes are plain GPIOs with
// VDD (3.3V logic) and GND holes in the same socket. Never plug a driver into Z or A.
//   Z socket: STEP = IO5, DIR = IO4      A socket: STEP = IO20, DIR = IO19
// IO19/IO20 are the S3's native USB pins. They're free here because the board's USB port
// goes through a CH340 on UART0 (ARDUINO_USB_CDC_ON_BOOT=0).

// Pen servo signal on the A socket STEP hole. Power the servo from 5V/GND on an endstop header.
#ifndef SERVO_PIN
#define SERVO_PIN 20
#endif

// 0.91" SSD1306 OLED on the Z socket: SDA -> DIR hole, SCL -> STEP hole, VCC -> VDD, GND -> GND.
#ifndef OLED_SDA_PIN
#define OLED_SDA_PIN 4
#endif
#ifndef OLED_SCL_PIN
#define OLED_SCL_PIN 5
#endif

#endif
