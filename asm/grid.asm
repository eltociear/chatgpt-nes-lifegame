.segment "CODE"

.include "nes.inc"

; グリッドのサイズ
GRID_WIDTH  = 16
GRID_HEIGHT = 15
GRID_SIZE   = GRID_WIDTH * GRID_HEIGHT

; メモリ上のグリッドの位置
GRID_ADDR   = $0300
TEMP_GRID_ADDR = $0400

; グリッドの初期化サブルーチン
.export InitGrid
InitGrid:
  LDX #$00

InitGridLoop:
  LDA #$00
  STA GRID_ADDR, X
  INX
  CPX #GRID_SIZE
  BNE InitGridLoop

  RTS

; グリッドの更新サブルーチン
.export UpdateGrid
UpdateGrid:
  LDX #$00

UpdateGridLoop:
  ; グリッドの現在の状態を読み込み
  LDA GRID_ADDR, X
  STA TEMP_GRID_ADDR, X
  
  ; 現在のセルの位置を計算
  TXA
  STA $00
  TYA
  STA $01
  
  ; 周囲の生きたセルの数を数える
  JSR CountNeighbors

  ; ライフゲームのルールを適用
  ; 生きたセルは2または3つの生きた隣接セルがあれば生存、それ以外は死滅
  ; 死んだセルは3つの生きた隣接セルがあれば誕生
  LDA GRID_ADDR, X
  CMP #$01
  BEQ CheckLiveCell

CheckDeadCell:
  LDA TEMP_GRID_ADDR, X
  CMP #$03
  BEQ SetLiveCell
  JMP NextCell

CheckLiveCell:
  LDA TEMP_GRID_ADDR, X
  CMP #$02
  BEQ NextCell
  CMP #$03
  BEQ NextCell
  JMP SetDeadCell

SetLiveCell:
  LDA #$01
  STA TEMP_GRID_ADDR, X
  JMP NextCell

SetDeadCell:
  LDA #$00
  STA TEMP_GRID_ADDR, X

NextCell:
  INX
  CPX #GRID_SIZE
  BNE UpdateGridLoop

  ; グリッドの更新を反映
  LDX #$00
CopyGridLoop:
  LDA TEMP_GRID_ADDR, X
  STA GRID_ADDR, X
  INX
  CPX #GRID_SIZE
  BNE CopyGridLoop

  RTS

; 周囲の生きたセルの数を数えるサブルーチン
CountNeighbors:
  LDA #$00
  STA $02

  ; 8つの隣接セルを確認
  ; (x-1, y-1), (x, y-1), (x+1, y-1)
  ; (x-1, y),   (x+1, y)
  ; (x-1, y+1), (x, y+1), (x+1, y+1)
  JSR CheckNeighborLeftUp
  JSR CheckNeighborUp
  JSR CheckNeighborRightUp
  JSR CheckNeighborLeft
  JSR CheckNeighborRight
  JSR CheckNeighborLeftDown
  JSR CheckNeighborDown
  JSR CheckNeighborRightDown

  RTS

CheckNeighborLeftUp:
  LDA $00
  SEC
  SBC #1
  BCS CheckNeighborCommon
  RTS

CheckNeighborUp:
  LDA $01
  SEC
  SBC #1
  BCS CheckNeighborCommon
  RTS

CheckNeighborRightUp:
  LDA $00
  CLC
  ADC #1
  CMP #GRID_WIDTH
  BCC CheckNeighborCommon
  RTS

CheckNeighborLeft:
  LDA $00
  SEC
  SBC #1
  BCS CheckNeighborCommon
  RTS

CheckNeighborRight:
  LDA $00
  CLC
  ADC #1
  CMP #GRID_WIDTH
  BCC CheckNeighborCommon
  RTS

CheckNeighborLeftDown:
  LDA $00
  SEC
  SBC #1
  BCS CheckNeighborCommon
  RTS

CheckNeighborDown:
  LDA $01
  CLC
  ADC #1
  CMP #GRID_HEIGHT
  BCC CheckNeighborCommon
  RTS

CheckNeighborRightDown:
  LDA $00
  CLC
  ADC #1
  CMP #GRID_WIDTH
  BCC CheckNeighborCommon
  RTS

CheckNeighborCommon:
  TAX
  LDA $01
  CMP #GRID_HEIGHT
  BCC CheckNeighborFinal
  RTS

CheckNeighborFinal:
  LDA $03
  CLC
  ADC $01
  TAX
  LDA GRID_ADDR, X
  CMP #$01
  BNE NeighborCheckEnd
  INC $02

NeighborCheckEnd:
  RTS
