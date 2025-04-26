
# LoxOS 0.3

LoxOS is a minimal **16-bit real mode operating system** written entirely in **x86 Assembly**. It features a simple command-line interface with built-in commands such as `help`, `clear`, `cpuid`, `info`,`disks`, and `mem`. This project is designed for **educational purposes**, **hobby OS development**, and demonstrating basic **BIOS-level interactions**.

**Documentation**:
 **https://beautiful-heliotrope-cb59e0.netlify.app**

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

![image](https://github.com/user-attachments/assets/faf8ff6d-4814-4e33-96bb-a8f27ed82f6e)

![image](https://github.com/user-attachments/assets/b4c7a67c-416d-4d3a-ab59-f3c0ca8a964d)


---

## 🖥 Requirements

- **x86-based PC** or emulator (e.g., QEMU, Bochs, VirtualBox)
- **NASM assembler**
- **1.44MB floppy image** or bootable USB (if running on real hardware)

---

## 🧱 Build & Run
- **chmod +x build.sh**
- **./build.sh all**
- **./build.sh run-usb**

## 📁 File Structure
File	Description
- **boot.asm**
- **kernel.asm**
- **Makefile**

## 📜 License
This project is public domain / MIT – use it however you like. Attribution is appreciated but not required.

## ✍️ Author
**Made by Loxsete**

