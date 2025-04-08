-- Controller.VHD
-- Yasser Raies et Vincent Tessier
-- Hiver 2025

LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY TOP IS

	PORT (
		Clk       	: IN  STD_LOGIC;
		Reset     	: IN  STD_LOGIC;

		PC        	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		WriteData 	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		DataAddress 	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);

END ENTITY TOP;

ARCHITECTURE rtl OF TOP IS

	SIGNAL Instruction, ReadDataIntern                      	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MemWriteIntern                          			: STD_LOGIC;
	SIGNAL PCIntern, WriteDataIntern, AluResultIntern		: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

	-- Instanciation de la memoire d'instructions
	IMEM_INST : ENTITY work.IMEM(imem_arch)
		PORT MAP (
			adresse		=>	PCIntern(9 DOWNTO 2),
			data		=>	Instruction
		);

	-- Instanciation du processeur MIPS
	MIPS_INST : ENTITY work.MIPS(rtl)
		PORT MAP (
			Instruction	=>	Instruction,		
			ReadData	=>	ReadDataIntern,
			Reset		=>	Reset,
			Clock		=>	Clk,
			MemRead		=>	OPEN,
			MemWrite	=>	MemWriteIntern,
			PC		=>	PCIntern,
			WriteData	=>	WriteDataIntern,
			AluResult	=>	AluResultIntern
		);

	-- Instanciation de la memoire de donnees
	DMEM_INST : ENTITY work.DMEM(dmem_arch)
		PORT MAP (
			clk		=>	Clk,
			MemWrite	=>	MemWriteIntern,
			adresse		=>	AluResultIntern,
			WriteData	=>	WriteDataIntern,
			ReadData	=>	ReadDataIntern
		);

	PC <= PCIntern;
	WriteData <= WriteDataIntern;
	DataAddress <= AluResultIntern;

END ARCHITECTURE rtl;
