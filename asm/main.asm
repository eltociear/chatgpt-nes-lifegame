.segment "HEADER"
.byte "N", "E", "S", $1A   ; 4 bytes: NESファイル識別子
.byte $02                  ; 1 byte: PRG-ROMページ数（16KB単位）
.byte $01                  ; 1 byte: CHR-ROMページ数（8KB単位）
.byte $00                  ; 1 byte: フラグ6
.byte $00                  ; 1 byte: フラグ7
.byte $00                  ; 1 byte: PRG-RAMサイズ
.byte $00                  ; 1 byte: フラグ9
.byte $00                  ; 1 byte: フラグ10
.byte $00, $00, $00, $00, $00, $00 ; 6 bytes: パディング

.segment "STARTUP"
.org $8000
.include "nes.inc"

.import InitGrid
.import UpdateGrid
.import DrawGrid

RESET:
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX $2000
  STX $2001

  JSR InitPPU
  JSR InitGrid

MainLoop:
  JSR UpdateGrid
  JSR DrawGrid

  JMP MainLoop

InitPPU:
  LDA #%10000000
  STA $2000
  LDA #%00011110
  STA $2001
  RTS

NMI:
  RTI

.segment "VECTORS"
.org $FFFA
.word NMI
.word RESET
.word 0
