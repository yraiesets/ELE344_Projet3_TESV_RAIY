--	Controller.VHD
--	Yasser Raies et Vincent Tessier
--	Hiver 2025

LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CONTROLLER IS

	PORT (
		OP, Funct	:	IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		MemtoReg  	:	OUT STD_LOGIC;
		MemWrite  	:	OUT STD_LOGIC;
		MemRead   	:	OUT STD_LOGIC;
		Branch    	:	OUT STD_LOGIC;
		AluSrc    	:	OUT STD_LOGIC;
		RegDst    	:	OUT STD_LOGIC;
		RegWrite  	:	OUT STD_LOGIC;
		Jump      	:	OUT STD_LOGIC;
		AluControl	:	OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);

END CONTROLLER;

ARCHITECTURE rtl OF CONTROLLER IS

	-- Signal Interne pour le AluDecoder
	SIGNAL ALUOp : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN

	MainDecoder : PROCESS (OP)

	BEGIN

		CASE (OP) IS

			WHEN "000000"		=>  -- R-Type
				RegWrite	<= '1';
				RegDst		<= '1';
				AluSrc		<= '0';
				Branch		<= '0';
				MemRead		<= '0';
				MemWrite	<= '0';
				MemtoReg	<= '0';
				ALUOp		<= "10";
				Jump		<= '0';
						-- HexCode => X"304"

			WHEN "100011"		=>  -- Lw
				RegWrite	<= '1';
				RegDst		<= '0';
				AluSrc		<= '1';
				Branch		<= '0';
				MemRead		<= '1';
				MemWrite	<= '0';
				MemtoReg	<= '1';
				ALUOp		<= "00";
				Jump		<= '0';
						-- HexCode => X"2A8"

			WHEN "101011"		=>  -- Sw
				RegWrite	<= '0';
				RegDst		<= '-';
				AluSrc		<= '1';
				Branch		<= '0';
				MemRead		<= '0';
				MemWrite	<= '1';
				MemtoReg	<= '-';
				ALUOp		<= "00";
				Jump		<= '0';
						-- HexCode => X"090"

			WHEN "000100"		=> -- Beq
				RegWrite	<= '0';
				RegDst		<= '-';
				AluSrc		<= '0';
				Branch		<= '1';
				MemRead		<= '0';
				MemWrite	<= '0';
				MemtoReg	<= '-';
				ALUOp		<= "01";
				Jump		<= '0';
						-- HexCode => X"042"

			WHEN "001000"		=> -- Addi
				RegWrite	<= '1';
				RegDst		<= '0';
				AluSrc		<= '1';
				Branch		<= '0';
				MemRead		<= '0';
				MemWrite	<= '0';
				MemtoReg	<= '0';
				ALUOp		<= "00";
				Jump		<= '0';
						-- HexCode => X"280"

			WHEN "000010"		=> -- J
				RegWrite	<= '0';
				RegDst		<= '-';
				AluSrc		<= '-';
				Branch		<= '-';
				MemRead		<= '0';
				MemWrite	<= '0';
				MemtoReg	<= '-';
				ALUOp		<= "--";
				Jump		<= '1';
						-- HexCode => X"001"

			WHEN OTHERS		=>
				RegWrite	<= '-';
				RegDst		<= '-';
				AluSrc		<= '-';
				Branch		<= '-';
				MemRead		<= '-';
				MemWrite	<= '-';
				MemtoReg	<= '-';
				ALUOp		<= "--";
				Jump		<= '-';
						-- HexCode => X"001"

		END CASE;

	END PROCESS;

	ALUDecoder : PROCESS(ALUOp, Funct)

	BEGIN
		
		CASE(ALUOp) IS

			WHEN "00"	=>	AluControl	<=	"0010";
			WHEN "01"	=>	AluControl	<=	"0110";
			WHEN "10"	=>
						CASE(Funct) IS
							WHEN "100000"	=>	AluControl	<=	"0010";
							WHEN "100010"	=>	AluControl	<=	"0110";
							WHEN "100100"	=>	AluControl	<=	"0000";
							WHEN "100101"	=>	AluControl	<=	"0001";
							WHEN "101010"	=>	AluControl	<=	"0111";
							WHEN OTHERS	=>	AluControl	<=	"----";
						END CASE;

			WHEN OTHERS	=>	AluControl	<=	"----";
		END CASE;

	END PROCESS;

END rtl;
