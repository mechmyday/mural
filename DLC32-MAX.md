# Mural on the MKS DLC32 MAX

This fork runs Mural on an [MKS DLC32 MAX](https://github.com/makerbase-mks/MKS-DLC32/tree/main/MKS--DLC32-MAX-main) instead of the stock FluidNC Pen/Laser board. Everything else (motors, belts, pen, web UI) stays the same.

What's different from stock Mural:

| | Stock | This fork |
|---|---|---|
| MCU | ESP32, 4MB | ESP32-S3, 8MB |
| Drivers | TMC2209 on UART | Plug-in TMC2209 modules, standalone mode |
| Power in | 12–24V | 12–24V, 2.1mm DC barrel jack |
| Board size | 70 × 70 mm | 100 × 70 mm (holes 92 × 62) |
| Printed parts | stock | remixed `bottom` and `cover` (see below) |

## Wiring

Pin source: [MKS DLC32 MAX V1.0_002 PIN.pdf](https://github.com/makerbase-mks/MKS-DLC32/blob/main/MKS--DLC32-MAX-main/firmware/MKS%20DLC32%20MAX%20V1.0_002%20PIN.pdf) and the [manual](https://github.com/makerbase-mks/MKS-DLC32/blob/main/MKS--DLC32-MAX-main/tool/MKS%20DLC32%20MAX%20Manual.pdf).

| What | Where on the board | GPIO |
|---|---|---|
| Left motor | **X** driver socket, X-Motor connector | STEP 16, DIR 15 |
| Right motor | **Y** driver socket, Y1-Motor connector | STEP 7, DIR 6 |
| Driver enable | shared | 8 |
| OLED SDA | **Expansion header**, the pin on IO18 | 18 |
| OLED SCL | **Expansion header**, the pin on IO17 | 17 |
| OLED VCC / GND | Expansion header VCC / GND (see note below) | |
| Servo signal | **A socket, STEP hole** | 20 |
| Servo 5V / GND | 5V / GND pins of any endstop header (X-, Y-, Z-, Door…) | |
| SD card | TF slot (SPI mode over the SDMMC wiring) | SCK 13, MISO 12, MOSI 14, CS 21 |

- **Only plug drivers into the X and Y sockets.** The A socket's STEP hole is used as a plain GPIO for the servo, so a driver there would fight it. The Z socket is unused, so leave it empty as well.
- The OLED uses the expansion header, which FluidNC sets up as UART1 (TXD1 = IO17, RXD1 = IO18). Mural doesn't use that UART, so the two pins act as I2C. On the test board SDA turned out to be IO18 and SCL IO17, the opposite of what the TX/RX labels suggest. If the screen stays blank, run the `i2cscan` env, which scans with SDA/SCL both ways round and shows which one finds the OLED (0x3C). If the header only has **5V**, check that your OLED module's SDA/SCL pull-ups go to its own 3.3V regulator, not to VCC. The ESP32-S3 pins aren't 5V tolerant. Most 0.91" modules are fine. If the header has 3.3V, use that.
- Use plain male-female dupont wires into the socket holes. Socket layout follows the StepStick standard: the logic side has EN, MS1, MS2, MS3, RST, SLP, **STEP**, **DIR**, and the power side has VMOT, GND, 2B, 2A, 1A, 1B, **VDD**, **GND**. Check the silkscreen.
- The servo pulls a few hundred mA when it stalls. If the board resets when the pen moves, power the servo from the PD trigger output through a small 5V buck instead of the endstop 5V pin.
- All pins live in [`include/board.h`](include/board.h). Run the `pinfinder` env (below) if anything doesn't respond.

### Power

Keep the stock USB-C PD trigger. Set it to **20V** and wire its output to a **2.1 × 5.5 mm barrel plug** (center positive). The plug goes through the notch in the top wall of the cover into the board's DC jack.

## Driver setup (standalone TMC2209)

The DLC32 MAX has no UART line to the driver sockets, so the firmware can't set current or microsteps. Set them on the hardware instead:

1. **Microsteps:** set all three DIP switches (M0/M1/M2) under the X and Y sockets to **OFF**. On a TMC2209, MS1 = MS2 = low gives **1/8 step**, which the firmware expects (`stepsPerRotation = 200 * 8`). Leave M2 off. On many TMC2209 modules that pin is PDN_UART.
2. **Current:** set **Vref ≈ 1.0 V** on each driver's pot. That's ~0.7 A RMS, the same as stock (`rms_current(707)`). For the usual 0.11 Ω sense resistors, `I_rms ≈ Vref × 0.71`. Check your module's datasheet, because some use a different formula. Measure between the pot and GND with the board powered and the motors unplugged.
3. Quick check: one jog of 1600 steps should turn the motor exactly one revolution. If it turns 2×, 4× or 8× too little, the DIP switches are wrong.

The drivers boot in stealthChop, which is quiet, and that's fine at these speeds.

## Flashing

```bash
pio run -e dlc32max -t upload        # builds the UI/worker too (needs Node/npm)
pio run -e dlc32max -t uploadfs      # web UI to LittleFS
pio device monitor -e dlc32max       # 9600 baud
```

Flashing the board wipes the default MKS laser firmware. The USB port goes through a CH340, so install its driver if your OS (Windows or MacOS) doesn't have it. The board needs 12–24V connected even for flashing, because USB alone doesn't power it.

Before the first build, run `npm install --ignore-scripts` in `worker/` (and `npm install` in `ui/` if it has no `node_modules`). `--ignore-scripts` skips building the `canvas` native module, which fails on newer Node versions. The worker bundle doesn't use canvas (it's a webpack external). Without the worker installed, `uploadfs` still succeeds but leaves the drawing worker out of the web UI.

On first boot with a blank card the firmware formats it (about 10 s) and then starts the **Mural** WiFi access point at 192.168.4.1.

`pio run -e dlc32max -t mergebin` produces a single 8MB `firmware-merged.bin` to flash at `0x0`.

### pinfinder

This is a simple diagnostic tool to find out which pins are mapped on the board.  The [FluidNC Wiki](http://wiki.fluidnc.com/en/hardware/3rd-party/MKS-DCL32-MAX) does not contain a complete pinout, so you can use this tool to check which pins map to the ESP32.
`pio run -e pinfinder -t upload && pio device monitor -e pinfinder` cycles the GPIOs Mural uses (2, 4, 5, 17, 18, 19, 20 and the spare header pins), holding each high for 4 s and printing which one. Put a multimeter on a socket hole or header pin to confirm what's behind it. Reflash `dlc32max` afterwards.

## Printed parts

Print the two remixed parts from [`STLs/dlc32max/`](STLs/dlc32max/). Print everything else from the stock `STLs/*.3mf` files.

| Part | Change |
|---|---|
| `bottom_dlc32max.stl` | Board plate widened to 110 mm and lengthened 6 mm. Old bosses and ribs removed. New heat-set bosses on the 92 × 62 board pattern, each tied to the nearest cover boss with a 2 mm rib. Upper cover bosses moved out. The center block (cover tongue and motor carrier inserts) is stock height, so the stock motor carriers fit. |
| `cover_dlc32max.stl` | 16 mm wider and 6 mm taller above the lower corners. Middle band of the lid raised 8 mm, with the outer bands kept at stock height so the belts can't rub. The screw tongue stays at stock height, with a step up to the raised lid. Old side block removed. One opening in the top wall for the DC jack and USB, plus a notch for the SD card (no RJ11 opening). OLED window and screen-holder bosses moved 21 mm toward the PD-trigger pocket so the OLED header clears the driver heatsinks. Motor-cable notches at the motor end moved 5 mm inward, 4 mm wider (10 mm) and 2.5 mm deeper. PD-trigger pocket kept. |

Both are oriented for printing: bottom on its back plate, cover lid-down. Use the same settings as the stock parts. The cover's screw tongue sits 8 mm above the bed in that orientation, so enable supports ("touching build plate" or paint-on supports are enough). Hardware is the same as stock: M3 heat-set inserts (M3x4x5) in all eight bosses of the board area, and M3 screws.

**Height budget above the top of the board PCB.** Check your driver + heatsink height against these:

- Under the raised middle band: ~33 mm (~28 mm under the OLED holder, ~26 mm under the PD-trigger pocket)
- Under the outer bands (outer ~6 mm each side): ~25 mm

### Editing the parts

The remix is OpenSCAD in [`cad/`](cad/). It imports the stock meshes (`cad/src/`, pulled out of the 3MF files with `cad/tools/3mf2stl.py`) and stretches, cuts and adds to them.

- `cad/params.scad`: every number that matters (stretch amounts, board placement, post positions).
- `cad/dlc32max_board.scad`: board keep-out model for fit checks. Component heights are estimates.
- `cad/bottom_dlc32max.scad`, `cad/cover_dlc32max.scad`: the remixes.
- `cad/print_*.scad`: print orientation. Export with `openscad -o out.stl cad/print_cover.scad`.
- `cad/lib/stretch.scad`: the mesh stretch helpers.


