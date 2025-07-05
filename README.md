# Assembly Expression Parser

This project is a mathematical expression evaluator written in MIPS assembly. It reads an infix expression (e.g. `1+2*3-4/2+10`), handles multi-digit integers, and computes the result using integer arithmetic with correct operator precedence (PEMDAS).

## Features
- Supports `+`, `-`, `*`, `/` operators
- Evaluates expressions using the **Shunting Yard Algorithm**
- Implements two stack structures for values and operators
- Parses ASCII character input and simulates realistic computation flow

## Tech Stack
- MIPS Assembly (tested in SPIM/MARS simulator)
- Stack-based memory management via `.space` and register tracking

## How to Run
1. Load `assembly_project.asm` into MARS or QtSPIM.
2. Run the program — result is stored in `$v1` after execution.
