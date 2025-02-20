# Documentação do Projeto 2

Este projeto tem como foco a compreensão da inicialização de sistemas operacionais e a interação com hardware em baixo nível. Ele pode ser expandido no futuro para suportar mais funcionalidades.

## Equipe:

* Lucas de Oliveira Sobral - 556944
* Mateus Andrade Maia - 552593
* Caio Vinícius Pessoa Freires - 558169
* Carlos Vinícius dos Santos Mesquita - 558171
* Matheus Simão Sales - 555851
* Herik Mario Muniz Rocha - 558167

## Objetivo

Criar um bootloader e um nano kernel de um sistema operacional minimalista.

## Requisitos

* Bootloader
* Deve implementar um sistema de arquivos com alocação contínua.
* Ser monousuário.
* Ser monotarefa.
* Sem interface gráfica (somente linha de comando).
* Capaz de reiniciar o computador.
* Capaz de carregar uma aplicação de teste.

## Estrutura do Código:

### Bootloader (boot.asm)

O bootloader é responsável por carregar o kernel para a memória e transferir o controle para ele.

#### Principais Funções:

* **print_string**: Exibe uma string na tela.
* **load_kernel**: Carrega o kernel do disco para a memória.
* **disk_error**: Exibe uma mensagem de erro caso ocorra uma falha ao ler o disco.

### Kernel (kernel.asm)

O kernel fornece uma interface de linha de comando para interagir com o sistema.

#### Funcionalidades:

* Exibição de mensagens de boas-vindas.
* Prompt de comando para entrada do usuário.
* Reconhecimento de comandos:
  * `<span>cls</span>`: Limpa a tela.
  * `<span>reboot</span>`: Reinicia o computador.
  * `<span>exit</span>`: Entra em modo de espera (halt).
  * `<span>help</span>`: Exibe os comandos disponíveis.
  * `<span>edit</span>`: (Em desenvolvimento) Chamaria um editor de texto.

#### Principais Funções:

* **print_string**: Exibe uma string na tela.
* **get_string**: Captura a entrada do usuário.
* **clear_screen**: Limpa a tela.

## Como executar

Para compilar e rodar o sistema operacional, siga os passos abaixo:

1. **Instalar o NASM**: O NASM (“Netwide Assembler”) é necessário para compilar os arquivos Assembly.

   ```
   sudo apt install nasm
   ```
2. **Compilar os arquivos**: usando nasm

   ```
   nasm -f bin boot.asm -o boot.bin
   nasm -f bin kernel.asm -o kernel.bin
   ```
3. **Criar a imagem do sistema**: No Linux, podemos usar o seguinte comando para criar a imagem final:

   ```
   dd if=/dev/zero of=system.img bs=512 count=2880
   dd if=bootloader.bin of=system.img conv=notrunc
   dd if=kernel.bin of=system.img seek=1 conv=notrunc
   ```
4. **Executar a imagem**: em um terminal normal no diretório da pasta

   ```
   qemu-system-x86_64 -drive format=raw,file=system.img
   ```
