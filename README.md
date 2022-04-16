# ECSE_425_Final :trollface:

## Welcome to the repository of Group06 ECSE425 Final Project - Pipelined Processor

### How to run our program?:partying_face:
----
#### Unit Tests:
| Unit under | Testing Directory | File required  |  Runtime
| ----------- | ----------- |  ----------- | ----------- |
|Fetch_stage |unit test fetch| stage fetch_stage.vhd + fetchStage_tb.vhd	| 15ns|
|Decode_stage| unit test decode stage |decode_stage.vhd + decodeStage_tb.vhd + register_file.vhd|20ns|
|Register_file|component test register file|register_file.vhd + register_file_tb.vhd |20ns|
|Execute_stage|unit test execute stage|execute_stage.vhd + executeStage_tb.vhd + TWOMUX.vhd + ADD.vhd + FIVEMUX.vhd + ALU.vhd|16ns|
|ALU |component test ALU|ALU.vhd	+ ALUUnit.vhd |10ns|
|Memory_stage|unit test memory stage|memory_stage.vhd + memoryStage_tb.vhd + TWOMUX.vhd |20ns|
|Writeback_stage|unit test write back stage|writeback_stage.vhd + writebackStage_tb.vhd| 6ns|
|Memory|component test memory|memory.vhd + memory_tb.vhd|15ns|


----
#### Benchmark1 -- Entry point
1. Go to the benchmark1 directory
2. Use Modelsim to open the project file: benchmark1.mpf  
3. Make sure all files needed to run are included:
![image](https://user-images.githubusercontent.com/54852475/163653747-6d7b24a7-cc53-441f-a9f8-3112c6aeb199.png)  
4. Run the command: `source benchmark1_tb.tcl` in the console   
5. **The console may report error:**  
![image](https://user-images.githubusercontent.com/54852475/163653827-138fe6f7-932e-48f0-8e14-951a002f7da8.png)  
6. Ignore the error and goto wave window
7. Make sure the time to run is 6.5ns for testbench1
8. Show the result:
![image](https://user-images.githubusercontent.com/54852475/163653939-7dec9551-260a-4491-9c82-e786ab60a8b1.png)


----
#### Benchmark2 -- Fibonacci :u6709:
__Note: In this project, we assume that the end of program is not an infinite loop instruction. Our CPU will determine when is the end of the instruction by itself since when loading the instructions from "program.txt", we assigned the rest of instruction memory as undefined.__

1. Go to the benchmark2 directory
2. Use Modelsim to open the project file: processor.mpf
3. Make sure all files needed to run are included:  
![image](https://user-images.githubusercontent.com/54852475/163636158-4a811603-194b-4c20-b5ef-81a1dcc61e77.png)
4. Run the command: `source final_tb.tcl` in the console   
5. **The console may report error:**  ![image](https://user-images.githubusercontent.com/54852475/163636274-dbd16117-acce-4ed7-a036-7e6e1d73ddbb.png)
6. Ignore the error and goto wave window
7. Make sure the time to run is 55ns for testbench2
8. Show the result:   
![image](https://user-images.githubusercontent.com/54852475/163637826-acf55b04-f692-4183-880e-2bdb1efdc395.png)
