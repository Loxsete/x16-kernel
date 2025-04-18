
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
- **Graphic mode 0x13** (320x200, 256 colors)
- ![2025-04-17T20_27_59,732378334+03_00](https://github.com/user-attachments/assets/bf0e7485-de39-4941-a743-a179f4a95d42)

![2025-04-17T20_20_41,873831067+03_00](https://github.com/user-attachments/assets/960b9b51-1032-4e87-8255-3c72e3e2a720)

---

## 🖥 Requirements

- **x86-based PC** or emulator (e.g., QEMU, Bochs, VirtualBox)
- **NASM assembler**
- **1.44MB floppy image** or bootable USB (if running on real hardware)

---

## 🧱 Build & Run
- **make clean**
- **make**
- **make run-usb** or **make run-hd**

## 📁 File Structure
File	Description
- **boot.asm**
- **kernel.asm**
- **Makefile**

## 📜 License
This project is public domain / MIT – use it however you like. Attribution is appreciated but not required.

## ✍️ Author
**Made by Loxsete**

