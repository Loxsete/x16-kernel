LoxOS 0.2
LoxOS is a lightweight, 16-bit real mode operating system crafted entirely in x86 Assembly. Designed for educational purposes, hobby OS development, and showcasing BIOS-level interactions, it offers a minimal yet functional command-line interface with essential commands like help, clear, cpuid, info, and mem.

🔧 Features
Pure x86 Assembly: Built from the ground up for low-level control.
Command-Line Interface: Supports input buffering and backspace functionality.
CPUID Handling: Retrieves processor name, vendor, and logical core count.
RAM Detection: Uses BIOS interrupt 0x12 to report available memory.
Built-in Commands:
help: Lists all available commands.
clear: Clears the screen for a fresh view.
cpuid: Displays CPU vendor and name.
mem: Shows available RAM size.
info: Presents an OS information table.
Custom BIOS Bootloader: Loads the kernel directly from disk.
Text Output: Leverages BIOS interrupt 0x10 for display.
Graphic Mode: Initializes 320x200, 256-color mode (0x13), ready for future use.
🖥 System Requirements
Hardware: x86-based PC or emulator (e.g., QEMU, Bochs, VirtualBox).
Assembler: NASM (Netwide Assembler).
Storage: 1.44MB floppy disk image or bootable USB for real hardware.
🛠 Build & Run
1️⃣ Assemble the Code
Run the following commands to build and launch LoxOS:

bash

Копировать
make clean    # Clears previous build artifacts
make          # Assembles the bootloader and kernel
make run      # Launches the OS in an emulator
2️⃣ File Structure
File	Description
bootloader.asm	Loads the kernel from disk into memory and executes it
kernel.asm	Core OS with command-line interface and logic
loxos.img	Bootable floppy disk image (manually created)
📜 License
Public Domain / MIT License

LoxOS is free to use, modify, and distribute. Attribution to the author is appreciated but not required.

✍️ Author
Created by Loxsete

Follow the project for updates and development:

📍 github.com/Loxsete
