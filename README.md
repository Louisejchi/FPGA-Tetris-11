# FPGA-Tetris-11th
## Authors: 110321026 110321059 110321068
### Input/Output unit:
* 8x8 LED 矩陣 : 遊戲畫面(包含開始、方塊狀態、結束)

* 7-seg 顯示器 : 紀錄得分

* BEEP 蜂鳴器 : 發出音樂聲

### Function description:
1. 等待遊戲開始時，會有 TETRIS 動畫出現。
2. 當方塊掉落時，透過左右移動以及旋轉調整位置。
3. 任一行擺滿方塊時，會將其消除，並得分(每消除一次，得一分)。
4. 可停止畫面。
5. 任一方塊碰到頂端時，遊戲結束，蜂鳴器會開始播音樂。

### Program module description:
* Tetris.v
> 主程式
```verilog!
module Tetris(
              input start, // 開始
                    left, right, rotation, // 操作方塊 : 左移、右移、旋轉
                    pause, // 暫停
                    CLK, // 時脈
              output reg [0:7] LED_R, LED_G, LED_B, // 控制亮燈 : 紅燈、綠燈、藍燈
              output reg [6:0] seg7, // 7-seg : 顯示數字
              output reg [3:0] COMM, COM, // 控制亮燈 : 8x8 LED 排數、7-seg 位數
              output beep // 控制音樂
);
```

* divcreq.sv
> 顯示畫面用的除頻器，不包含開始前的動畫
```verilog!
module divfreqForDisplay (
                          input CLK // 輸入的時脈, 
                          output reg CLK_div // 除頻後的時脈
                         );
```
> 方塊降落的除頻器
```verilog!
module divfreqForDrop (
                       input CLK,// 輸入的時脈,
                       output reg CLK_div // 除頻後的時脈
);
```
> 方塊左右、旋轉的除頻器
```verilog!
module divfreqForMove (
                       input CLK,// 輸入的時脈,
                       output reg CLK_div // 除頻後的時脈
);
```
> 遊戲開始前動畫用的除頻器
```verilog!
module divfreqForStart (
                       input CLK,// 輸入的時脈,
                       output reg CLK_div // 除頻後的時脈
);
```

* ScoreUse7seg.sv
> 得分
```verilog!
module score( 	
             input enable, // 控制是否得分
             input [13:0] count, // 得分
             input CLK, // 時脈
             output reg [6:0] seg7, // 7-seq 顯示分數
             output reg [3:0] COM // 7-seq 可亮位數
); 
```
> 得分用的除頻器
```verilog!
module divfreq (
                input CLK,// 輸入的時脈,
                output reg CLK_div // 除頻後的時脈
);
```
* getBlock.v
> 取得隨機方塊
```verilog!
module getBlock(	
                input enable, // 控制方塊掉落
                      CLK, // 時脈
                output [2:0] num // 選擇第幾種方塊掉落
);
```
:::success
123
:::

