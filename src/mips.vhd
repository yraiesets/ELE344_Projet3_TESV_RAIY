--	Controller.VHD
--	Yasser Raies et Vincent Tessier
--	Hiver 2025

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MIPS IS
    PORT (
        Instruction : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        ReadData    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Reset       : IN  STD_LOGIC;
        Clock       : IN  STD_LOGIC;

        MemRead     : OUT STD_LOGIC;
        MemWrite    : OUT STD_LOGIC;
        PC          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        WriteData   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        AluResult   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY MIPS;

ARCHITECTURE rtl OF MIPS IS

	-- Signaux internes entre le controleur et le datapath
	SIGNAL MemtoRegI, MemWriteI, MemReadI	:	STD_LOGIC;
	SIGNAL BranchI, AluSrcI, RegDstI	:	STD_LOGIC;
	SIGNAL RegWriteI, JumpI			:	STD_LOGIC;
	SIGNAL AluControlI			:	STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL IF_ID_InstructionI		:	STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN

	-- Instanciation du controleur
	CONTROLLER_INST : ENTITY work.CONTROLLER(rtl)
		PORT MAP (
			OP		=>	IF_ID_InstructionI(31 DOWNTO 26),
			Funct		=>	IF_ID_InstructionI(5 DOWNTO 0),
			MemtoReg	=>	MemtoRegI,
			MemWrite	=>	MemWriteI,
			MemRead		=>	MemReadI,
			Branch		=>	BranchI,
			AluSrc		=>	AluSrcI,
			RegDst		=>	RegDstI,
			RegWrite	=>	RegWriteI,
			Jump		=>	JumpI,
			AluControl	=>	AluControlI
		);

	-- Instanciation du datapath
	DATAPATH_INST : ENTITY work.DATAPATH(rtl)
		PORT MAP (
			Clk		=>	Clock,
			Reset		=>	Reset,
			MemtoReg	=>	MemtoRegI,
			Branch		=>	BranchI,
			AluSrc		=>	AluSrcI,
			RegDst		=>	RegDstI,
			RegWrite	=>	RegWriteI,
			Jump		=>	JumpI,
			MemReadIn	=>	MemReadI,
			MemWriteIn	=>	MemWriteI,
			AluControl	=>	AluControlI,
			Instruction	=>	Instruction,
			ReadData	=>	ReadData,
			MemReadOut	=>	MemRead,
			MemWriteOut	=>	MemWrite,
			PC		=>	PC,
			WriteData	=>	WriteData,
 			AluResult	=>	AluResult,
			IF_ID_InstructionOut	=> IF_ID_InstructionI
		);

END ARCHITECTURE rtl;

