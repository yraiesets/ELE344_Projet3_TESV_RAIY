--	Controller.VHD
--	Yasser Raies et Vincent Tessier
--	Hiver 2025

LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY DATAPATH IS

    GENERIC(N   :   INTEGER :=  32);

    PORT(

        Clk         :   IN  STD_LOGIC;
        Reset       :   IN  STD_LOGIC;
        MemtoReg    :   IN  STD_LOGIC;
        Branch      :   IN  STD_LOGIC;
        AluSrc      :   IN  STD_LOGIC;
        RegDst      :   IN  STD_LOGIC;
        RegWrite    :   IN  STD_LOGIC;
        Jump        :   IN  STD_LOGIC;
        MemReadIn   :   IN  STD_LOGIC;
        MemWriteIn  :   IN  STD_LOGIC;
        AluControl  :   IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        Instruction :   IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        ReadData    :   IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);

        MemReadOut  :   OUT STD_LOGIC;
        MemWriteOut :   OUT STD_LOGIC;
        PC          :   OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        AluResult   :   OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        WriteData   :   OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)

    );

END ENTITY DATAPATH;

ARCHITECTURE rtl OF DATAPATH IS

	-- Signaux internes pour le banc de registres
	SIGNAL WriteReg                    					:   	STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL Result, SignImm, rd1, rd2   					:   	STD_LOGIC_VECTOR(N-1 DOWNTO 0);

	-- Signaux internes pour l'ALU
	SIGNAL SrcB, AluResultIntern						:	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL Zero								:	STD_LOGIC;

	-- Signaux internes pour le PC
	SIGNAL PCIntern, PCNext, PCPlus4					:	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL PCBranch, PCJump, PCNextBr					:	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL SignImmSh							:	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL PCSrc								:	STD_LOGIC;
	

	-- Signaux de pipelines

	SIGNAL IF_PCNextBr          : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL IF_PCNext            : STD_LOGIC_VECTOR(31 DOWNTO 0);  
	SIGNAL IF_PC                : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL IF_PCPlus4           : STD_LOGIC_VECTOR(31 DOWNTO 0); 
	SIGNAL IF_ID_PCPlus4        : STD_LOGIC_VECTOR(31 DOWNTO 0);  
	SIGNAL IF_ID_Instruction    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_PCJump            : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_SignImm           : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_rs                : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL ID_rt                : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL ID_rd                : STD_LOGIC_VECTOR(4 DOWNTO 0); 
	SIGNAL ID_rd1               : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_rd2               : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_Jump              : STD_LOGIC;
	SIGNAL ID_MemtoReg          : STD_LOGIC;
	SIGNAL ID_MemWrite          : STD_LOGIC;
	SIGNAL ID_MemRead           : STD_LOGIC;
	SIGNAL ID_Branch            : STD_LOGIC;
	SIGNAL ID_AluSrc            : STD_LOGIC;
	SIGNAL ID_RegDst            : STD_LOGIC;
	SIGNAL ID_RegWrite          : STD_LOGIC;
	SIGNAL ID_AluControl        : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL EX_PCBranch          : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EX_PCSrc             : STD_LOGIC;
	SIGNAL EX_SignImmSh         : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EX_ForwardA          : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL EX_ForwardB          : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL EX_preSrcB           : std_Logic_vector(31 DOWNTO 0);
	SIGNAL EX_SrcB              : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EX_SrcA              : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EX_AluResult         : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EX_Zero              : STD_LOGIC;
	SIGNAL ID_EX_AluSrc         : STD_LOGIC;
	SIGNAL ID_EX_RegDst         : STD_LOGIC;
	SIGNAL ID_EX_AluControl     : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL EX_WriteReg          : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL ID_EX_rt             : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL ID_EX_rs             : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL ID_EX_rd1            : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_EX_Branch         : STD_LOGIC;
	SIGNAL EX_cout              : STD_LOGIC;
	SIGNAL ID_EX_MemWrite       : STD_LOGIC;
	SIGNAL ID_EX_MemRead        : STD_LOGIC;
	SIGNAL ID_EX_RegWrite       : STD_LOGIC;
	SIGNAL ID_EX_MemtoReg       : STD_LOGIC;
	SIGNAL ID_EX_SignImm        : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_EX_rd             : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL ID_EX_rd2            : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_EX_PCPlus4        : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ID_EX_instruction    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EX_MEM_AluResult     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EX_MEM_MemWrite      : STD_LOGIC;
	SIGNAL EX_MEM_MemRead       : STD_LOGIC;
	SIGNAL EX_MEM_MemtoReg      : STD_LOGIC;
	SIGNAL EX_MEM_RegWrite      : STD_LOGIC;
	SIGNAL EX_MEM_preSrcB       : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EX_MEM_WriteReg      : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL EX_MEM_instruction   : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WB_Result            : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MEM_WB_WriteReg      : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL MEM_WB_MemtoReg      : STD_LOGIC;
	SIGNAL MEM_WB_RegWrite      : STD_LOGIC;
	SIGNAL MEM_WB_AluResult     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MEM_WB_readdata      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MEM_WB_instruction   : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

	-------------------------------------------------------------------------------------
	--			Etage Pipeline Instruction Fetch (IF)			   --
	-------------------------------------------------------------------------------------

	-- Mul2-to-1 pour determiner IF_PCNextBr
	IF_PCNextBr <= EX_PCBranch WHEN EX_PCSrc = '1' ELSE IF_PCPlus4;

	-- Mul2-to-1 pour determiner IF_PCNext
	IF_PCNext <= ID_PCJump WHEN ID_Jump = '1' ELSE IF_PCNextBr;

	-- Bascule D Synchrone avec remise a zero asynchrone (clear).
	PROCESS(Clk, Reset) IS
		BEGIN
			IF Reset = '1' THEN
				IF_PC <= (OTHERS => '0');
			ELSIF RISING_EDGE(Clk) THEN
				IF_PC <= IF_PCNext;
			END IF;
	END PROCESS;

	IF_PCPlus4 	<=	STD_LOGIC_VECTOR(UNSIGNED(IF_PC) + TO_UNSIGNED(4, N));


	-------------------------------------------------------------------------------------
	--				Etage Registre IF/ID		   	           --
	-------------------------------------------------------------------------------------


	PROCESS(Clk) BEGIN
		IF RISING_EDGE(Clk) THEN
			IF_ID_Instruction	<=	Instruction;
			IF_ID_PCPlus4		<=	IF_PCPlus4;
		END IF;	
	END PROCESS;

	-------------------------------------------------------------------------------------
	--			Etage Pipeline Instruction Decode (ID)			   --
	-------------------------------------------------------------------------------------
	
	ID_MemtoReg	<=	MemtoReg;
	ID_MemWrite	<=	MemWriteIn;
	ID_MemRead	<=	MemReadIn;
	ID_Branch	<=	Branch;
	ID_AluSrc	<=	AluSrc;
	ID_RegDst	<=	RegDst
	ID_RegWrite	<=	RegWrite;
	ID_AluControl	<=	AluControl;

	ID_PCJump	<=	IF_ID_PCPlus4(31 DOWNTO 28) & IF_ID_Instruction(25 DOWNTO 0) & "00"; -- Concatenation pour obtenir l'adresse de saut complete

	ID_rs	<= IF_ID_Instruction(25 DOWNTO 21);
	ID_rt	<= IF_ID_Instruction(20 DOWNTO 16);
	
	-- Banc de registres
    	REGISTER_FILE	:	ENTITY work.RegFile(RegFile_arch)
        	PORT MAP(
            		clk	=>	Clk,
            		we	=>	MEM_WB_RegWrite,
            		ra1	=>	ID_rs,
            		ra2	=>	ID_rt,
            		wa	=>	MEM_WB_WriteReg,
            		wd	=>	WB_Result,
            		rd1	=>	ID_rd1,
            		rd2	=>	ID_rd2
        	);

	ID_rd	<= IF_ID_Instruction(15 DOWNTO 11);

    	-- Extension de signe (SignExtend)
	ID_SignImm <= STD_LOGIC_VECTOR(RESIZE(SIGNED(IF_ID_Instruction(15 DOWNTO 0)), N));

	-------------------------------------------------------------------------------------
	--				Etage Registre ID/EX		   	           --
	-------------------------------------------------------------------------------------

	PROCESS(Clk) BEGIN
		IF RISING_EDGE(Clk) THEN
			ID_EX_PCPlus4 	<= IF_ID_PCPlus4;
			ID_EX_rd1 	<= ID_rd1;
			ID_EX_rd2	<= ID_rd2;
			ID_EX_SignImm	<= ID_SignImm;
			ID_EX_rs	<= ID_rs;
			ID_EX_rt	<= ID_rt;
			ID_EX_rd  	<= ID_rd;
			ID_EX_RegWrite 	<= ID_RegWrite;
			ID_EX_MemtoReg	<= ID_MemtoReg;
			ID_EX_MemWrite	<= ID_MemWrite;
			ID_EX_MemRead 	<= ID_MemRead;
			ID_EX_Branch	<= ID_Branch;
		END IF;
	END PROCESS;

	-------------------------------------------------------------------------------------
	--			Etage Pipeline Execute (EX)			           --
	-------------------------------------------------------------------------------------

	-- Determiner si on doit effectuer un branchement
	EX_PCSrc	<=	ID_EX_Branch AND EX_Zero;

	EX_SignImmSh	<=	STD_LOGIC_VECTOR(SHIFT_LEFT(SIGNED(ID_EX_SignImm), 2));

	EX_PCBranch	<=	STD_LOGIC_VECTOR(SIGNED(ID_EX_PCPlus4) + SIGNED(EX_SignImmSh));

    	-- UAL
	UAL		:	ENTITY work.UAL(rtl)
		PORT MAP(
			ualControl	=>	AluControl,
			srcA		=>	rd1,
			srcB		=>	SrcB,
			result		=>	AluResultIntern,
			cout		=>	OPEN,
			zero		=>	EX_Zero
		);

	-- Forwading Unit

    	-- Mul2-to-1 pour determine l'addresse d'ecriture
	WriteReg <= Instruction(20 DOWNTO 16) WHEN RegDst = '0' ELSE Instruction(15 DOWNTO 11);

   	 -- Mul2-to-1 pour determine les donnees d'ecriture
	Result <= ReadData WHEN MemtoReg = '1' ELSE AluResultIntern;


	-- Mul2-to-1 pour determine la SrcB de l'ALU
	SrcB <= SignImm WHEN AluSrc = '1' ELSE rd2;
	

	-- Assignation des Sorties
	MemReadOut	<=	MemReadIn;
	MemWriteOut	<=	MemWriteIn;
	PC		<=	IF_PC;
	AluResult	<=	AluResultIntern;
	WriteData	<=	rd2;
	
END ARCHITECTURE rtl;