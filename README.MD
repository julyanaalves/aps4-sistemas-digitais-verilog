APS4 – Mini Computador de 8 bits (Verilog)

## Visão geral

Este repositório implementa um computador simples de 8 bits em Verilog, com CPU, ALU, unidade de controle, caminho de dados e memória (ROM, RAM e portas de I/O mapeadas em memória). Há testbenches para validar módulos individuais e o sistema integrado.

Principais objetivos:
- Executar um pequeno programa armazenado na ROM (0x00–0x7F).
- Manipular dados em RAM (0x80–0xDF).
- Interagir com I/O via mapeamento de memória (entradas 0xF0–0xFF, saídas 0xE0–0xEF).

## Estrutura do projeto

```
APS4/
	computer/
		alu.v                # ALU e portas lógicas básicas
		control_unit.v       # Unidade de controle (FSM) – gera sinais de controle
		cpu.v                # Integra control_unit e data_path
		data_path.v          # Registradores, barramentos e conexão com ALU/memória
		memory.v             # ROM + RAM + I/O mapeado em memória
		rom_128x8_sync.v     # Programa de exemplo gravado na ROM
		computer.v           # Topo do sistema: CPU + memória
	tb/
		tb_alu.v             # Teste da ALU
		tb_computer.v        # Teste do computador completo
		... outros testbenches
```

## Arquitetura resumida

- Registradores: PC, MAR, A, B, IR, CCR (flags NZVC).
- Barramentos internos:
	- Bus1_Sel: 00=PC, 01=A, 10=B
	- Bus2_Sel: 00=ALU_Result, 01=Bus1, 10=from_memory
- ALU (8 bits): ADD, INC, SUB, DEC, AND, OR, XOR, NOT, com flags N Z V C.
- Unidade de Controle (FSM): ciclos de fetch → decode → execute para cada instrução.
- Memória:
	- ROM 0x00–0x7F (programa)
	- RAM 0x80–0xDF (dados)
	- I/O: saída 0xE0–0xEF (port_out_00..15), entrada 0xF0–0xFF (port_in_00..15)

## Conjunto de instruções (opcodes)

Os opcodes estão definidos em `computer/rom_128x8_sync.v` como parâmetros. Tamanho das instruções:
- Sem operando: 1 byte (apenas opcode)
- Com operando: 2 bytes (opcode + operando)

Grupo de Load/Store:
- LDA_IMM, byte  → A ← imediato
- LDB_IMM, byte  → B ← imediato
- LDA_DIR, addr  → A ← MEM[addr] (RAM/I/O)
- LDB_DIR, addr  → B ← MEM[addr]
- STA_DIR, addr  → MEM[addr] ← A (RAM/I/O)
- STB_DIR, addr  → MEM[addr] ← B

Grupo ALU (resultado normalmente em A, salvo instruções explícitas):
- ADD_AB      → A ← A + B
- SUB_AB      → A ← A − B
- SUB_BA      → B ← B − A
- AND_AB      → A ← A & B
- OR_AB       → A ← A | B
- XOR_AB      → A ← A ^ B
- NOTA        → A ← ~A
- NOTB        → B ← ~B
- INCA/INCB   → ++A / ++B
- DECA/DECB   → --A / --B

Branches (2 bytes, com destino absoluto na ROM):
- BRA, addr   → salta sempre para addr
- BMI, addr   → salta se N=1
- BPL, addr   → salta se N=0
- BEQ, addr   → salta se Z=1
- BNE, addr   → salta se Z=0
- BVS, addr   → salta se V=1
- BVC, addr   → salta se V=0
- BCS, addr   → salta se C=1
- BCC, addr   → salta se C=0

## Programando a ROM

Edite o bloco `initial` em `computer/rom_128x8_sync.v` (label `PROGRAM_CODE`) e escreva seu programa preenchendo `ROM[i]` com opcodes e operandos.

Exemplo (já incluso):
```
ROM[0] = LDA_IMM; ROM[1] = 8'h0F;   // A <- 15
ROM[2] = LDB_IMM; ROM[3] = 8'h02;   // B <- 2
ROM[4] = ADD_AB;                    // A <- A + B
ROM[5] = STA_DIR; ROM[6] = 8'hE0;   // port_out_00 <- A (17)
```

Exemplo (ler entrada, incrementar e escrever saída):
```
ROM[0] = LDA_DIR; ROM[1] = 8'hF0;   // A <- port_in_00
ROM[2] = INCA;                      // A <- A + 1
ROM[3] = STA_DIR; ROM[4] = 8'hE1;   // port_out_01 <- A
ROM[5] = BRA;    ROM[6] = 8'h05;    // loop simples
```

Observações:
- Use RAM 0x80–0xDF para variáveis.
- Para “parar”, use um `BRA` apontando para si mesmo (não há HALT).
- Endereços de branch são absolutos na faixa da ROM (0x00–0x7F).

## Como simular (Windows)

Você pode usar Icarus Verilog (iverilog + vvp) ou ModelSim/Questa. Abaixo, sugestões para PowerShell.

1) Testar a ALU
- Arquivos: `computer/alu.v` e `tb/tb_alu.v`.

2) Testar o computador completo
- Arquivos: todos em `computer/` e `tb/tb_computer.v`.

Comandos (Icarus Verilog) – exemplo opcional:

```powershell
# ALU
iverilog -o .\build\alu_tb.exe .\computer\alu.v .\tb\tb_alu.v
vvp .\build\alu_tb.exe

# Computer
iverilog -o .\build\computer_tb.exe .\computer\*.v .\tb\tb_computer.v
vvp .\build\computer_tb.exe
```

Saída esperada do exemplo padrão (`tb_computer.v`):
- A = 15, B = 2, A+B = 17, gravado em `port_out_00` (endereço 0xE0).

## Dicas de depuração
- Confira o mapeamento de endereços ao usar RAM vs I/O.
- Verifique `NZVC` para branches condicionais.
- Use `$monitor/$display` nos testbenches para inspecionar sinais.

## Próximos passos
- Adicionar novas instruções (ex.: deslocamentos, comparação, HALT).
- Escrever programas maiores na ROM.
- Criar scripts `.ps1` para build/run.

---

Feito com Verilog puro para fins didáticos em arquiteturas e sistemas digitais.

