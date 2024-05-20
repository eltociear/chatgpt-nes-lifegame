.segment "CODE"

.include "nes.inc"

; グリッドのサイズ
GRID_WIDTH  = 16
GRID_HEIGHT = 15
GRID_SIZE   = GRID_WIDTH * GRID_HEIGHT

; メモリ上のグリッドの位置
GRID_ADDR   = $0300

PALETTE:
  .incbin "../graphics/palette.pal"

; グリッドの描画サブルーチン
.export DrawGrid
DrawGrid:
  ; PPUアドレスを設定
  LDA #$20       ; PPUのネームテーブルアドレスの上位バイト
  STA $2006
  LDA #$00       ; PPUのネームテーブルアドレスの下位バイト
  STA $2006

  ; グリッドの描画ループ
  LDY #$00       ; Yレジスタを0にリセット

DrawGridLoop:
  LDX #$00       ; Xレジスタを0にリセット

DrawGridRow:
  ; グリッドのセルの状態を読み込み
  LDA GRID_ADDR, X
  CMP #$01
  BEQ DrawLiveCell
  JMP DrawDeadCell

DrawLiveCell:
  ; 生きたセルのタイルインデックスを設定
  LDA #$01       ; 生きたセルのタイルインデックス（例：1）
  JMP WriteTile

DrawDeadCell:
  ; 死んだセルのタイルインデックスを設定
  LDA #$00       ; 死んだセルのタイルインデックス（例：0）

WriteTile:
  JSR WriteTileData

  INX
  CPX #GRID_WIDTH
  BNE DrawGridRow

  INY
  CPY #GRID_HEIGHT
  BNE DrawGridLoop

  RTS

; ヘルパー関数: PPUにタイルデータを書き込む
WriteTileData:
  STA $2007      ; PPUデータレジスタにタイルインデックスを書き込む
  RTS
