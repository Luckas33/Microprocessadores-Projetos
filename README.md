# Projetos de Microprocessadores

## Projeto 1 - Desenvolvimento de um Processador
### Objetivo
Criar um processador simples, incluindo Unidade Lógica e Aritmética (ULA) e outros componentes necessários para a execução de instruções.

### Componentes
- **ULA (Unidade Lógica e Aritmética)**: Responsável por operações matemáticas e lógicas.
- **Banco de registradores**: Armazena valores temporários para execução das instruções.
- **Decodificador de instruções**: Interpreta os códigos de operação.
- **Memória**: Armazena instruções e dados.
- **Clock**: Garante a sincronização entre os componentes.

### Funcionalidades
- Suporte a operações básicas como soma, subtração, AND, OR, XOR e deslocamento.
- Arquitetura baseada em um conjunto de instruções simples.
- Implementação em VHDL/Verilog e simulação em FPGA.

---

## Projeto 2 - Bootloader e Nano Kernel
### Objetivo
Criar um bootloader e um nano kernel de um sistema operacional minimalista.


### Estrutura do Código
#### Bootloader
- **print_string**: Exibe mensagens na tela.
- **load_kernel**: Carrega o kernel para a memória.
- **disk_error**: Trata erros de leitura do disco.

#### Kernel
- Prompt de comando para interação com o usuário.
- Suporte aos comandos `cls`, `reboot`, `exit`, `help` e `edit` (em desenvolvimento).
- Funções auxiliares como `print_string`, `get_string` e `clear_screen`.

---
##Projeto 3 - Microprocessadores

###Sistema de Controle com Microprocessador Intel 8086

###Descrição

Este projeto consiste no desenvolvimento de um sistema de controle utilizando o microprocessador Intel 8086. O foco está na integração de periféricos como o CI 8255A, além do uso de circuitos lógicos para endereçamento e controle.

###Funcionalidades

📟 Leitura de sinais digitais a partir de um teclado matricial.

🔌 Controle de entradas e saídas digitais via CI 8255A.

🏷️ Decodificação de endereços utilizando o CI 74LS138.

##Como Executar

Configure o hardware conectando o 8086 aos periféricos.

Compile e grave o código no sistema.

Teste a interação via teclado matricial.

##Tecnologias Utilizadas

Processador: Intel 8086

Circuitos Integrados: CI 8255A, 74273 e 74LS138

Linguagem: Assembly
