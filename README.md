# Personnel Management System in NASM Assembly

A small command-line personnel registry written in **x86 (32-bit) NASM assembly for Linux**. It uses an interactive menu to register people (name and age), list them, delete them, and compute simple statistics, with no C library, only raw Linux system calls.

University project, March 2026.

## Authors

- Lahcen Mokhtar AMROUNE
- Mohammed Rami BENSMICHA

## Features

| # | Option | Description |
|---|--------|-------------|
| 1 | Register a person | Enter a name and an age (e.g. `Bob 25`), with input validation |
| 2 | List people | Numbered list of all registered people |
| 3 | Delete a person | Delete by number; the following entries shift up automatically |
| 4 | Oldest and youngest | Shows the person with the highest and lowest age |
| 5 | Average age | Arithmetic mean of all ages, shown with the list of ages used |
| 6 | Quit | Clean exit via `sys_exit` |

## Requirements

- **NASM** (Netwide Assembler)
- **binutils** (`ld`)
- A 32-bit Linux system, or a 64-bit Linux system with 32-bit support

On Debian/Ubuntu:

```bash
sudo apt install nasm binutils
```

## Build and Run

```bash
# Assemble
nasm -f elf32 -o projet.o projet.asm

# Link
ld -m elf_i386 -o projet projet.o

# Run
./projet
```

Replace `projet.asm` with the name of your source file (e.g. `Code_projet_Assembleur_NASM.asm`).

## Example Session

```
1. Enregistrer du personnel
2. Lister des personnes enregistrees
3. Supprimer une personne specifique
4. Afficher la personne la plus agee et la plus jeune
5. Afficher l'age moyen
6. Quitter le programme
Votre choix: 1
Entrez le nom et l'age (ex: Bob 25): Alice 30
Personne enregistree!

Votre choix: 2
Liste des personnes:
1 Alice 30
2 Bob 25
3 Charlie 35

Votre choix: 5
Age en moyenne:
30 (30 25 35)
```

The interface is in French.

## How It Works

### Program structure

- **`_start`** is the entry point and calls `display_menu`.
- **`display_menu`** clears the number buffer, prints the menu with `sys_write`, reads the choice with `sys_read`, and jumps to the matching routine.
- **`parse_input`** finds the space between name and age, checks the name length, copies the name into the array, converts the age with `convert_age`, and validates it.
- **`list_people`, `delete_person`, `show_extremes`, `show_average`** implement the other menu options.
- **`print_number`** converts an integer to text so it can be printed.

### Linux system calls used

| Call | `eax` | Purpose |
|------|-------|---------|
| `sys_exit` | 1 | Quit the program |
| `sys_read` | 3 | Read user input from stdin |
| `sys_write` | 4 | Print text to stdout |

All calls go through `int 0x80`.

### Data structures

| Name | Size | Description |
|------|------|-------------|
| `personnes` | 10 × 64 bytes | Names, zero-terminated strings |
| `ages` | 10 × 4 bytes | Ages, 32-bit integers |
| `count` | 4 bytes | Number of people currently stored |
| `input` | 256 bytes | Keyboard input buffer |
| `input_length` | 4 bytes | Length of the last input read |
| `num_buffer` | 11 bytes | Buffer for number-to-text conversion |

Deleting a person shifts all following names and ages up by one slot and decrements `count`.

## Input Validation

| Rule | Detail |
|------|--------|
| Menu choice | Exactly one digit from 1 to 6 |
| Name | Not empty, fewer than 20 characters |
| Age | Between 1 and 120 inclusive |
| Format | Name and age separated by a space |
| Capacity | Maximum of 10 people |
| Deletion | The number must match an existing person |

Invalid input prints an explicit error message, for example `Entree invalide! (Nom < 20 char, 0 < age <= 120)`.

## Tests

| Test | Input | Expected result |
|------|-------|-----------------|
| Normal registration | `Bob 25` | Success |
| Name too long | `ABCDEFGHIJKLMNOPQRSTU 30` | Error |
| Invalid age | `Bob 150` | Error |
| Non-numeric age | `Bob abc` | Error |
| Valid deletion | `2` | Success |
| Invalid deletion | `99` | Error |
| Empty list | none | Appropriate message |
| Maximum of 10 people | 11th entry | Error |

## Challenges

- **String handling:** there are no built-in string functions, so copying, searching, and zero-termination are all written by hand.
- **String to integer conversion:** `convert_age` multiplies by 10 and rejects non-digit characters.
- **Memory shifting on delete:** shifting the following entries without corrupting data was the hardest part.
- **Register management:** registers had to be saved on the stack around critical operations so important values were not overwritten.

## Possible Improvements

- Search by name, edit an entry, and sort by name or age
- Save and load data from a file, and export to CSV
- More statistics (median, standard deviation)
- Macros for frequent system calls, for example:

  ```nasm
  %macro PRINT 2
      mov eax, 4
      mov ebx, 1
      mov ecx, %1
      mov edx, %2
      int 0x80
  %endmacro

  ; Usage: PRINT menu, menu_len
  ```

- Dynamic memory allocation to remove the 10-person limit
- A friendlier interface with `ncurses`

## Repository Contents

| File | Description |
|------|-------------|
| `projet.asm` | NASM source code (about 700 lines) |
| `Rapport_projet_Assembleur_NASM.pdf` | Full project report (in French) |
| `README.md` | This file |
