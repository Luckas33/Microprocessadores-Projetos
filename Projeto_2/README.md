# Projeto 2 - Microprocessadores

## Sistema Operacional

## Descrição

Este projeto tem como objetivo a criação de um mini sistema operacional que inclui:

* Um **bootloader** capaz de inicializar o sistema;
* Um **kernel** responsável pelo gerenciamento básico de hardware e execução de aplicações;
* Um **editor de texto** simples para testar o funcionamento do sistema.

### Estrutura do Projeto

O projeto é dividido em três partes principais:

1. **Bootloader**:
   * Carrega o kernel na memória;
   * Inicializa os registradores e prepara o ambiente de execução;
   * Passa o controle para o kernel.
2. **Kernel**:
   * Configuração de interrupções;
   * Gerenciamento de memória;
   * Manipulação básica de entrada e saída (I/O);
   * Suporte a chamadas de sistema básicas.
3. **Editor de Texto**:
   * Interface simples baseada em texto;
   * Suporte a entrada e saída via teclado e tela;
   * Possibilidade de salvar e carregar arquivos.

### Tecnologias Utilizadas

* Linguagem Assembly para o bootloader
* Linguagem C para o kernel e editor de texto
* Ferramentas:
  * **NASM** para montagem do bootloader
  * **GCC** para compilar o kernel e o editor
  * **QEMU** para testes e emulação

### Como Executar

1. **Compilar o bootloader**:
   ```
   nasm -f bin boot.asm -o bootloader.bin
   ```
2. **Compilar o kernel**:
   ```
   nasm -ffreestanding -m32 -c kernel.asm -o kernel.bin
   ld -m elf_i386 -T linker.ld -o kernel.bin kernel.bin
   ```
3. **Criar a imagem do sistema**:
   ```
   cat bootloader.bin kernel.bin > os.img
   ```
4. **Rodar no QEMU**:
   ```
   qemu-system-i386 -drive format=raw,file=os.img
   ```

### Autores

* [Seu Nome]
* [Outros Colaboradores]
