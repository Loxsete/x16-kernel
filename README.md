Оттабулируй все красиво, это реадми
# LoxOS 0.2

LoxOS is a minimal **16-bit real mode operating system** written entirely in **x86 Assembly**. It features a simple command-line interface with built-in commands such as `help`, `clear`, `cpuid`, `info`, and `mem`. This project is designed for **educational purposes**, **hobby OS development**, and demonstrating basic **BIOS-level interactions**.

---

## 🔧 Features

- **Written in pure x86 Assembly**
- **Command-line interface** with input buffer and backspace support
- **CPUID instruction handling** for processor name, vendor, and logical cores
- **Detects available RAM** via BIOS interrupt `0x12`
- **Commands**:
  - `help` – Displays available commands
  - `clear` – Clears the screen
  - `cpuid` – Prints CPU vendor and name
  - `mem` – Prints RAM size
  - `info` – Shows an info table about the OS
- **Custom BIOS bootloader** loads the kernel from disk
- **Text output** using BIOS interrupt `0x10`
- **Graphic mode 0x13** (320x200, 256 colors) initialized but not yet used

---

## 🖥 Requirements

- **x86-based PC** or emulator (e.g., QEMU, Bochs, VirtualBox)
- **NASM assembler**
- **1.44MB floppy image** or bootable USB (if running on real hardware)

---

## 🧱 Build & Run
make clean
make
make run

📁 File Structure
File	Description
bootloader.asm	Loads the kernel from disk into memory and jumps to it
kernel.asm	Main OS with command-line interface and logic
loxos.img	Bootable image (created manually)
📜 License
This project is public domain / MIT – use it however you like. Attribution is appreciated but not required.

✍️ Author
Made by Loxsete

Follow updates and development at: github.com/Loxsete
