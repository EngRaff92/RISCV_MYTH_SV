RISC-V Processor - Introduction
Welcome on board to getting started learning about processor designing using RISC-V. These set of tutorials are written to help you get started with RISC-V along with covering practical aspects of designing a processor. On completing all these tutorials you would gain knowledge about the famous open-source architecture and would have designed your own simplified RISC-V processor from scratch. So without wasting any time further, let's dive right into it. Happy learning!
Introduction
What is an Instruction Set Architecture(ISA)?
To put it simply, an ISA is a specification which describes the way in which the software talks to the underlying hardware (processor in this case). This means that the ISA contains the specifications of how different instructions should be fetched from memory, decoded and finally executed. You can think of these specifications as golden rules and which the underlying processor based on the ISA must follow. These ISAs usually define and contain the data format and size (32-bit/64-bit) and the instructions along with their binary encodings. RISC-V is an open source Instruction Set Architecture (ISA) like ARM or x86 ISA but it is open source. This means that it is freely available to the public to develop their own processors using it.
In these set of tutorials, we would be covering the RISC-V ISA basics i.e. how are various instructions as specified by the ISA are fetched, decoded and executed. Along side all this, we would also be developing various sub-units which would fit together in the end to complete our own version of a RISC-V based processor.
The tutorials are divided into various sections starting from creating the instruction memory to finally putting all the sub-units together to complete our processor. Each of these tutorials would introduce you to a concept needed for designing a RISC-V based processor. However, we know that going through these concepts can sometimes get boring hence for every tutorial you'd also have to design and test your sub-units as you go along.
ISA Basics
Through these tutorial you would be able to understand how a processor executes intructions and will be able to practically create one using the labs. In order to fully understand the process, this section covers few basic terminology used across the tutorials. Don't worry if you don't fully understand these yet as each of these would be covered in the tutorials.
* Instruction Length: The length of the instructions. It would be 32-bit for our processor
* Architectural Registers: These are the registers which the ISA defines. There would be 32 of these registers starting from X0 to X31
* Program Counter: An additional register which holds the address of the current instruction
* Instruction Formats: The RISC-V ISA defines 5 different instruction formats (or instruction classes). The later tutorial will cover more on these formats
Design Problem
Since this is an introductory post, there isn't a design problem associated with a concept. However, there is a design problem kept to help you get familiarised with the platform. The problem is to design a small adder and simulate it using the platform. Please do look at the simulation output shown in waves to gain better understanding.

-------------------------------

RISC-V Processor - Fetch
This tutorial would cover one of the basic building block of the RISC-V processor i.e. the Instruction Memory. But before jumping into the details, here is a quick recap of the previous tutorial. The last tutorial touched upon what an Instruction Set Architecture means and how it defines the various instructions as specified by the architecture. The processors are supposed to fetch, decode and execute those instructions keeping all the rules intact as defined by the ISA. This tutorial would cover the first aspect of the process that is fetching the instructions!
Instruction Fetch
Before the processor can decode or execute an instruction, it needs to fetch (or simply get) the instruction from the memory. The binary encodings of the instructions are stored in the memory and the processor uses the program counter (an address to memory in other words) to read those instructions.
The processor would fetch a new instruction whenever it needs to. The modern processors usually fetch multiple instructions in one clock cycle for better performance. However, in this tutorial our processor would request for one instruction only whenever it has completely processed the last instruction. Now, that we know the first part of building the processor is to fetch an instruction, let's get straight into designing it.
Design Requirements
In order to keep things simple, the RISC-V processor would fetch a new instruction every cycle. Since the processor is single-cycle, this means that the instructions would be executed in one cycle and hence the processor can easily fetch a new instruction at the beginning of the next cycle. The design of the instruction memory should be able to read out the instruction stored at the given address every cycle. We don't need to worry about writing to the instruction memory and can assume it would be preloaded with instructions to be executed. The above design requirements should be good to begin designing our processor.
Interface Definition
The instruction fetch would have the following interface definition:
* imem_addr_i : Memory address from where the instruction would be fetched.
* read_instr_o: The instruction (or the data) present at the given address
Both the above input and outputs would be 32-bit wide. The 32-bit RISC-V processor would support instructions which are 32-bit wide and hence the output is 32-bit long. The input is kept at 32-bit length to keep things simple. It can be reduced based on the size of the memory, however 32-bit should work for now.
That's what is needed to get the instruction memory to work. In later tutorials the input and output would be connected with other sub-units to complete our processor. In those tutorials we would realise how the input address to the memory is nothing but the program counter and how the read instruction output from the memory is used by the decode stage to process instructions encoding as per the RISC-V ISA.

-------------------------------

RISC-V Processor Design
The last tutorial covered how the processor fetches an instruction. Fetching the instruction is the first part and now the processor needs to understand how to decode and execute that instruction. The decode stage is quite important as it where the instruction encodings would be decoded based on the RISC-V ISA. Decoding an instruction involves a couple of parts and this tutorial would cover those step-by-step. Before going ahead, please download the latest RISC-V ISA from this link as the tutorial would be referencing the ISA for the instruction encodings.
Instruction Decode
Every ISA defines the following for an instruction:
* The length of the instruction (in our RISC-V processor every instruction is 32-bit wide)
* The number of architectural registers instruction accesses. These could be either source registers (which specify the data which the instruction would process) or the destination register (where the result of the operation would be stored)
* The operation which the instruction should perform. Add, subtract, shifting, multiplication are different example of these operations
* Few other sideband signals - these would be used to allow the processor to decode these instructions easily All the above information is usually contained within the instruction (this is what the 32-bits of the instruction covers).
The RISC-V ISA broadly defines 6 instruction formats, namely:
* R-type
* I-type
* S-type
* B-type
* U-type
* J-type
Each of the above formats further have various instructions defined within. For example R-type contains instructions like ADD, AND, OR, etc. These formats have their own way of encoding the various information (source and destination registers, immediate values (if any) and sideband signals). Here's a snippet of the various instruction encodings from the RISC-V ISA: 
￼
A quick description of what these encodings mean:
* opcode : This is the sideband signal which is used to decide one of the instruction format
* rd : One of the X1-X31 reigsters used as the destination where the result of the instruction would be stored
* rs1 : One of the X1-X31 registers used as one of data sources for the instruction
* rs2 : One of the X1-X31 registers used as the other data source for the instruction
* funct3/funct7 : Sideband signals used for further decoding instruction within one of the instruction formats
* imm : This contains the immediate value to be processed by the instruction. Should be 0 for R-type
With this we can now start looking at the design of a decode engine for our RISC-V processor. This unit would get the input from the instruction fetch unit, decode it and send various information about the instruction to rest of the parts of the processor.
Design Requirements
The design requirements for the decode unit is similar to the instruction fetch. It would take the instruction as an input and give all of the above information as we discussed as output.
Interface Definition
The decode unit would have the following interface definition:
* instr_i : 32-bit instruction to be encoded
* rs1_o : 5-bit value giving the first source register
* rs2_o : 5-bit value giving the second source register
* rd_o : 5-bit value giving the destination register
* op_o : 7-bit signal for the instruction opcode
* funct3_o : The 3-bits instruction function
* funct7_o : The 7-bits instruction function
* r_type_instr_o : Current instruction is an R-type instruction
* i_type_instr_o : Current instruction is an I-type instruction
* s_type_instr_o : Current instruction is an S-type instruction
* b_type_instr_o : Current instruction is an B-type instruction
* u_type_instr_o : Current instruction is an U-type instruction
* j_type_instr_o : Current instruction is an J-type instruction
* illegal_instr_o : Current instruction is an illegal instruction
* instr_imm_o : A 20-bit signal for the immediate value within the instruction
As you can see the decode unit would provide all the necessary information about the instruction. In fact, it even contains some extra information which tells the current instruction format. In the later tutorials all this information would be used by different blocks to simplify their design. For now let's get started designing the decode unit.

-------------------------------

RISC-V Processor - Register File
This tutorial would cover the register file for our processor. The previous tutorials talked about the RISC-V ISA and the instruction memory from where our processor would fetch the instruction and use the decode block to decode the 32-bit fetched instruction as per the encodings given in the ISA. Out of those components, almost every instruction had an encoding for the registers specified by the ISA. Those were decoded as either the source registers (rs1, rs2) or the destination register (rd). Both the source registers and destination registers refer to one of 32 available architectural (i.e. as specified by the RISC-V ISA) registers. This tutorial would cover how the processor maintains each of these registers and how these can be read to obtain the value stored in the source registers or to written to store a value into the destination register.
Register File
As discussed above the register file is used to read the value stored into one of the architectural registers and even to write the value to one of the architecture register. Here is the quick recap of the six instruction types as defined by the RISC-V ISA and the way those encode the source or destination registers:
Instruction Type	Source Register 1 (RS1)	Source Register 2 (RS2)	Destination Register (RD)
R-type	instr[19:15]	instr[24:20]	instr[11:7]
I-type	instr[19:15]	-	instr[11:7]
S-type	instr[19:15]	instr[24:20]	-
B-type	instr[19:15]	instr[24:20]	-
U-type	-	-	instr[11:7]
J-type	-	-	instr[11:7]
There are few instruction types which either don't read any source registers (U and J type) or don't write to the destination register (S and B type). The R-type instructions read the values from both the source register and write the result of the instruction to the destination register. The I-type instructions on the other hand just read the source register 1. The later tutorials would cover in-depth as to how these instruction compute their result. Other than the source and destination register it is also imperative to understand the length for each of the registers that would be implemented in the register file. The RISC-V ISA uses the term XLEN to denote the length of architectural registers present in the processor. For our processor the XLEN would be equal to 32, which means there are 32 registers, each of those would be 32-bit wide. Also, the RISC-V ISA mandates that the register 0 (X0) should be hardwired to 0 i.e. the register would always keep the value 0. Even if the instruction wants to write another value to X0, this value would be ignored and register X0 would continue to give the value 0. For more information, please refer to section "2.1 Programmers’ Model for Base Integer ISA" of the RISC-V ISA.
Design Requirements
The register file should allow reading the values of two register and writing to one register and as from the above encodings it is clear that the register needs to support ports to allow reading two source registers and writing to one of the register. The design for the register file would be very similar to the instruction memory, with just that the register file will support 2 ports for allowing two registers to be read and one port for wrtiting. The instruction encodings above would serve as the addresses from where the data would be read/written to. The register file should ensure that the register X0 is hardwired to 0.
Since the processor is single-cycle, it should be fine to allow write to take a cycle but the read data should be given on the same cycle which would be later used to during the execute phase.
Interface Definition
The register file would have the following interface definition:
* clk : Input clock signal (this is same as the processor clock)
* rs1_addr_i : 5-bit input address for the RS1 source register
* rs2_addr_i : 5-bit input address for the RS2 source register
* rd_addr_i : 5-bit input address for the RD destination register
* wr_en_i : 1-bit write enable signal input
* wr_data_i : 32-bit write data input
* rs1_data_o : 32-bit output data corresponding to RS1 register
* rs2_data_o : 32-bit output data corresponding to RS2 register
That's what is needed to get the instruction memory to work. In later tutorials the input and output would be connected with other sub-units to complete our processor. In those tutorials we would realise how the input address to the memory is nothing but the program counter and how the read instruction output from the memory is used by the decode stage to process instructions encoding as per the RISC-V ISA.

-------------------------------

RISC-V Processor - ALU
The previous tutorials have covered instruction memory unit responsible for storing the instructions which the processor would execute. The instruction decode unit which would get the instruction word from the memory and break it into the encodings specified by the RISC-V ISA. Then the tutorials covered the register file which implements the architecture registers (i.e. the registers specified by the RISC-V ISA) and allows the processor to read two registers and write one of them. This tutorial would focus on one of the important computational unit in the processor: ALU. The following block diagram shows the current design components of the RISC-V Processor along with the ALU unit: 
￼
Don't worry about the muxes shown in the block diagram. Those would be added when all the components are connected together. The block diagram is a good way to visualise the current state of the microarchitecture of our RISC-V processor.
ALU
The arithmetic logical unit is responsible for executing the function specified by the instruction. Looking into the RISC-V ISA, one could define the following operations which would be sufficient to execute most of the instructions as per the RV32I implementation. The table below list the various ALU operations and the corresponding RISC-V instructions from the RV32I Base Instruction Set:
ALU Operation	Instructions
Addition (+)	ADD, ADDI, LW, SW, JALR, AUIPC, JAL
	
Subtraction (-)	SUB
	
Shift left (<<)	SLL, SLLI
	
Logical Shift right (>>)	SRL, SRLI
	
Arithmetic Shift right(>>>)	SRA, SRAI
	
Logical OR (|)	OR, ORI
	
Logical AND (&)	AND, ANDI
	
Logical XOR (^)	XOR, XORI
	
Equal to (==)	BEQ, BNE, BLT
	
Less than (<)	BLTU, SLTU, SLTIU
	
Greater than (>)	BGEU
	
Signed Less than (<)	BLT, SLT, SLTI
	
Signed Greater than (>)	BGEU
From the above table it is clear that the ALU would need to perform operations on two operands and drive the result as the output. The ALU would take in the two operands which could either be values read from the register file or the immediate value specified from within the instruction opcode. It would also take in the type of operation to be performed on those two operands before giving the result. This would be a good time to dig into the RISC-V ISA and learn more about the operation of the instructions listed above. To gain more familiarity please refer to section "2.4 Integer Computational Instructions" of the RISC-V ISA. The describes the operation for the instructions listed above.
Design Requirements
The ALU would be a pure combinational unit and would give out result in the same cycle. The ALU design should be straightforward with just a bit of care for the logic around the signed and unsigned operations. Look at the interface requirements and the logic on the right window pane.
Interface Definition
The arithmetic unit would have the following interface definition:
* opr_a_i : 32-bit input. This is the first operand
* opr_b_i : 32-bit input. This is the second operand
* op_sel_i : 4-bit input signal to select ALU operation
* alu_res_o : 32-bit ALU result output
The operation select signal needs to be only 4-bit wide as the ALU can only get upto 13 various combinations of functions.

-------------------------------

RISC-V Processor - Data Memory
The next building block for our RISC-V processor is the data memory. Just like the instruction memory was used for fetching the RISC-V instructions, the data memory would be used for storing and retrieving data. Our RISC-V processor is based upon Harvard architecture as the processor uses different paths for instructions and data.
Data Memory
Not all the RISC-V instructions need to access memory. Particularly, the load store class of instructions would need to access the data memory. These instructions would either get data from the memory to be processed further or write data to the memory for storing it. The following table lists the RV32I set of instructions which would need an access to data memory:
Instruction	Description
LB	Loads a byte from data memory
LH	Loads a half-word (16-bits) from data memory
LW	Loads entire word (32-bits) from data memory
LBU	Loads a byte and zero-extends it to 32-bits
LHU	Loads a half-word and zero-extends it to 32-bits
SB	Stores a byte to data memory
SH	Stores a half-word to data memory
SW	Stores the entire word to data memory
As can be seen from the table above, there exists various flavours of the load/store class of instructions depending on the data which needs to be accessed ranging from a byte (8-bits) to a word (32-bits). In order to keep things simple, the RISC-V processor would support only the word accesses to the data memory. This implies that the data memory would always return a word of read data and would also write a word of data into the memory. The data memory is the main memory for our RISC-V processor and is the only level of memory available. In production grade CPUs, the entire memory side of thigs are quite vast and usually consists of multiple hierarchies of caches along with support for address translation. The aim of this tutorial is to introduce to the concept of data memory and help understand how to design a simple memory for the RISC-V processor.
Design Requirements
The data memory should return read data in the same cycle. The write data should be processed in one cycle. The memory would be either used for reading data or writing data to it. Since the processor executes single instruction per cycle, there is no need to support both read and write simulataneously.
Interface Definition
The instruction fetch would have the following interface definition:
clk            : CPU Clock
dmem_addr_i    : Memory address to either read or write data to the memory
dmem_wr_i      : Data should be written to the memory
dmem_wr_data_i : Write data to written into the memory
dmem_data_o    : Read data from the memory
The dmem_addr_i, dmem_wr_data_i and dmem_data_o are all 32-bit wide. As discussed earlier, our RISC-V CPU would support full word accesses. The address bits can be further reduced depending on the size of the memory however it is kept at 32-bit for simplicity. Complete the logic on the right to design the data memory for your RISC-V processor.