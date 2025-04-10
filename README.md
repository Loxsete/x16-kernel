

---

# Test OS - Mini Kernel

This is a simple 16-bit operating system kernel written in assembly language (NASM). The project includes a bootloader and a kernel, together forming a minimal OS with basic command-line functionality.

Author: Loxsete  
Date: April 2025

## Overview

The project consists of two main components:
1. **Bootloader** (`boot.asm`) — responsible for loading the kernel from disk into memory and transferring control.
2. **Kernel** (`kernel.asm`) — provides a basic command-line interface with support for several commands.

The kernel is loaded at address `0x1000` and operates in real mode. It supports command input from the keyboard and text output to the screen using BIOS interrupts.

## Features

### Supported Commands:
- `clear` — clears the screen.
- `cpuid` — displays processor information (vendor ID).
- `help` — shows a list of available commands.
- `info` — displays OS information.

### Functionality:
- Displays a welcome message on boot.
- Supports command input with key handling (including backspace).
- Shows an info table about the OS.
- Handles errors for unknown commands.

## Requirements

- **Build Tool**: NASM (Netwide Assembler).
- **Emulator**: QEMU (for testing, optional).
- **Build OS**: Any OS supporting NASM and Make (e.g., Linux, Windows with WSL or Cygwin).

## Build and Run

1. Ensure `nasm` and (optionally) `qemu-system-x86_64` are installed.
2. Clone or download the repository.
3. Run the following commands in the terminal:
   ```bash
   make          # Build the OS image (os_image.bin)
   make run      # Run in QEMU (if installed)
   make clean    # Remove generated files
   ```

The `os_image.bin` file is the final image, ready to be written to a floppy disk or used in an emulator.

## Project Structure

- `boot.asm` — bootloader code (loaded at `0x7c00`).
- `kernel.asm` — kernel code (loaded at `0x1000`).
- `Makefile` — script for build automation.
- `os_image.bin` — final binary OS image.

## Example Output

Upon booting, you’ll see:
```
System Booted
+------------+
| Test OS    |
| By Loxsete |
+------------+
> 
```
Enter a command like `help`, and you’ll get:
```
Commands: clear, cpuid, help, info
> 
```

## Limitations

- Operates only in real mode (16-bit).
- Maximum command length is 31 characters.
- Limited functionality as this is a test version.

## Future Plans

- Transition to protected mode (32-bit).
- Add more commands and features.
- Implement filesystem support.

## License

This project is distributed "as is" without any warranties. You are free to use and modify the code.

---

If you have questions or suggestions, feel free to contact the author (Loxsete)!
