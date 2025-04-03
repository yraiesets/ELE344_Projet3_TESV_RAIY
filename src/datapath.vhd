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

	-- Nouveau signaux interne

	SIGNAL IF_PCNextBr          : std_logic_vector(31 DOWNTO 0);
	SIGNAL IF_PCNext            : std_logic_vector(31 DOWNTO 0);  
	SIGNAL IF_PC                : std_logic_vector(31 DOWNTO 0);
	SIGNAL IF_PCPlus4           : std_logic_vector(31 DOWNTO 0); 
	SIGNAL IF_ID_PCPlus4        : std_logic_vector(31 DOWNTO 0);  
	SIGNAL IF_ID_Instruction    : std_logic_vector(31 DOWNTO 0);
	SIGNAL ID_PCJump            : std_logic_vector(31 DOWNTO 0);
	SIGNAL ID_SignImm           : std_logic_vector(31 DOWNTO 0);
	SIGNAL ID_rs                : std_logic_vector(4 DOWNTO 0);
	SIGNAL ID_rt                : std_logic_vector(4 DOWNTO 0);
	SIGNAL ID_rd                : std_logic_vector(4 DOWNTO 0); 
	SIGNAL ID_rd1               : std_logic_vector(31 DOWNTO 0);
	SIGNAL ID_rd2               : std_logic_vector(31 DOWNTO 0);
	SIGNAL ID_Jump              : std_logic;
	SIGNAL ID_MemtoReg          : std_logic;
	SIGNAL ID_MemWrite          : std_logic;
	SIGNAL ID_MemRead           : std_logic;
	SIGNAL ID_Branch            : std_logic;
	SIGNAL ID_AluSrc            : std_logic;
	SIGNAL ID_RegDst            : std_logic;
	SIGNAL ID_RegWrite          : std_logic;
	SIGNAL ID_AluControl        : std_logic_vector(3 DOWNTO 0);
	SIGNAL EX_PCBranch          : std_logic_vector(31 DOWNTO 0);
	SIGNAL EX_PCSrc             : std_logic;
	SIGNAL EX_SignImmSh         : std_logic_vector(31 DOWNTO 0);
	SIGNAL EX_ForwardA          : std_logic_vector(1 DOWNTO 0);
	SIGNAL EX_ForwardB          : std_logic_vector(1 DOWNTO 0);
	SIGNAL EX_preSrcB           : std_Logic_vector(31 DOWNTO 0);
	SIGNAL EX_SrcB              : std_logic_vector(31 DOWNTO 0);
	SIGNAL EX_SrcA              : std_logic_vector(31 DOWNTO 0);
	SIGNAL EX_AluResult         : std_logic_vector(31 DOWNTO 0);
	SIGNAL EX_Zero              : std_logic;
	SIGNAL ID_EX_AluSrc         : std_logic;
	SIGNAL ID_EX_RegDst         : std_logic;
	SIGNAL ID_EX_AluControl     : std_logic_vector(3 DOWNTO 0);
	SIGNAL EX_WriteReg          : std_logic_vector(4 DOWNTO 0);
	SIGNAL ID_EX_rt             : std_logic_vector(4 DOWNTO 0);
	SIGNAL ID_EX_rs             : std_logic_vector(4 DOWNTO 0);
	SIGNAL ID_EX_rd1            : std_logic_vector(31 DOWNTO 0);
	SIGNAL ID_EX_Branch         : std_logic;
	SIGNAL EX_cout              : std_logic;
	SIGNAL ID_EX_MemWrite       : std_logic;
	SIGNAL ID_EX_MemRead        : std_logic;
	SIGNAL ID_EX_RegWrite       : std_logic;
	SIGNAL ID_EX_MemtoReg       : std_logic
	SIGNAL ID_EX_SignImm        : std_logic_vector(31 DOWNTO 0);
	SIGNAL ID_EX_rd             : std_logic_vector(4 DOWNTO 0);
	SIGNAL ID_EX_rd2            : std_logic_vector(31 DOWNTO 0);
	SIGNAL ID_EX_PCPlus4        : std_logic_vector(31 DOWNTO 0);
	SIGNAL ID_EX_instruction    : std_logic_vector(31 DOWNTO 0);
	SIGNAL EX_MEM_AluResult     : std_logic_vector(31 DOWNTO 0);
	SIGNAL EX_MEM_MemWrite      : std_logic;
	SIGNAL EX_MEM_MemRead       : std_logic;
	SIGNAL EX_MEM_MemtoReg      : std_logic;
	SIGNAL EX_MEM_RegWrite      : std_logic;
	SIGNAL EX_MEM_preSrcB       : std_logic_vector(31 DOWNTO 0);
	SIGNAL EX_MEM_WriteReg      : std_logic_vector(4 DOWNTO 0);
	SIGNAL EX_MEM_instruction   : std_logic_vector(31 DOWNTO 0);
	SIGNAL WB_Result            : std_logic_vector(31 DOWNTO 0);
	SIGNAL MEM_WB_WriteReg      : std_logic_vector(4 DOWNTO 0);
	SIGNAL MEM_WB_MemtoReg      : std_logic;
	SIGNAL MEM_WB_RegWrite      : std_logic;
	SIGNAL MEM_WB_AluResult     : std_logic_vector(31 DOWNTO 0);
	SIGNAL MEM_WB_ReadData      : std_logic_vector(31 DOWNTO 0);
	SIGNAL MEM_WB_instruction   : std_logic_vector(31 DOWNTO 0);

	

        ID_MemtoReg	<= MemtoReg;
       	ID_Branch	<= Branch;      
        ID_AluSrc	<= AluSrc;   
        ID_RegDst	<= RegDst;         
        ID_RegWrite	<= RegWrite;    
        ID_Jump		<= Jump;
        ID_MemRead	<= MemReadIn;
        ID_MemWrite	<= MemWriteIn;
        ID_AluControl	<= AluControl;
       

BEGIN
    	-- Mul2-to-1 pour determine l'addresse d'ecriture
	EX_WriteReg <= ID_EX_Instruction(20 DOWNTO 16) WHEN EX_RegDst = '0' ELSE ID_EX_Instruction(15 DOWNTO 11);

   	 -- Mul2-to-1 pour determine les donnees d'ecriture
	WB_Result <= MEM_WB_ReadData WHEN EX_MEM_MemtoReg = '1' ELSE EX_MEM_AluResultIntern;

    	-- Extension de signe (SignExtend)
	ID_SignImm <= STD_LOGIC_VECTOR(RESIZE(SIGNED(Instruction(15 DOWNTO 0)), N));

    	-- Banc de registres
    	REGISTER_FILE	:	ENTITY work.RegFile(RegFile_arch)
        	PORT MAP(
            		clk	=>	Clk,
            		we	=>	MEM_WB_WriteReg,
            		ra1	=>	IF_ID_Instruction(25 DOWNTO 21),
            		ra2	=>	IF_ID_Instruction(20 DOWNTO 16),
            		wa	=>	MEM_WB_WriteReg,
            		wd	=>	WB_Result,
            		rd1	=>	ID_rd1,
            		rd2	=>	ID_rd2
        	);

	-- Mul2-to-1 pour determine la SrcB de l'ALU
	EX_SrcB <= SignImm WHEN ID_EX_AluSrc = '1' ELSE ID_rd2;
	
	-- UAL
	UAL		:	ENTITY work.UAL(rtl)
		PORT MAP(
			ualControl	=>	ID_EX_AluControl,
			srcA		=>	EX_SrcA,
			srcB		=>	EX_SrcB,
			result		=>	EX_AluResult,
			cout		=>	OPEN,
			zero		=>	EX_Zero
		);

	-- Determiner si on doit effectuer un branchement
	EX_PCSrc		<=	EX_Branch AND EX_Zero;
	
	-- Calcul des signaux utilises dans la logique du PC :
	IF_PCPlus4 	<=	STD_LOGIC_VECTOR(UNSIGNED(IF_PC) + TO_UNSIGNED(4, N));
	ID_PCJump		<=	ID_PCPlus4(31 DOWNTO 28) & IF_ID_Instruction(25 DOWNTO 0) & "00"; -- Concatenation pour obtenir l'adresse de saut complete
	EX_SignImmSh	<=	STD_LOGIC_VECTOR(SHIFT_LEFT(SIGNED(EX_SignImm), 2));
	EX_PCBranch	<=	STD_LOGIC_VECTOR(SIGNED(EX_PCPlus4) + SIGNED(EX_SignImmSh)); -- Maj

	-- Mul2-to-1 pour determiner PCNextBr
	IF_PCNextBr <= EX_PCBranch WHEN EX_PCSrc = '1' ELSE IF_PCPlus4;


	-- Mul2-to-1 pour determiner PCNext
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


	-- Process pour la partie Forwarding Unit
	ForwardUnit PROCESS(EX_rd1,EX_rd2,WB_Result, EX_MEM_AluResult) IS
		BEGIN
			IF(EX_MEM_RegWrite AND (MEM_WB_WriteReg NOT ZEROS) AND (MEM_WB_WriteReg = ID_EX_rs)) 
			THEN EX_ForwardA = 10 -- Condition pour EX Forward A 
			END IF 

			IF(MEM_WB_RegWrite AND (MEM_WB_WriteReg NOT ZEROS) AND (MEM_WB_WriteReg = ID_EX_rs)) 
			THEN EX_ForwardA = 01 -- Condition pour MEM Forward A 
			END IF

			IF(EX_MEM_RegWrite AND (MEM_WB_WriteReg NOT ZEROS) AND (MEM_WB_WriteReg = ID_EX_rt)) 
			THEN EX_ForwardB = 10 -- Condition pour EX Forward B
			END IF 

			IF(MEM_WB_RegWrite AND (MEM_WB_WriteReg NOT ZEROS) AND (MEM_WB_WriteReg = ID_EX_rt)) 
			THEN EX_ForwardB = 01 -- Condition pour MEM Forward B 
			END IF
	
		CASE (EX_ForwardA) IS

			WHEN "10"		=>  -- EX/MEM
			EX_preSrcB => EX_MEM_AluResult
		
			WHEN "01"		=>  -- MEM/WB
			EX_preSrcB => WB_Result
			
			WHEN OTHERS		=> -- ID/EX
			EX_preSrcB => ID_EX_rd1

		END CASE;

		CASE (EX_ForwardB) IS

			WHEN "10"		=>  -- EX/MEM
			EX_preSrcB => EX_MEM_AluResult

			WHEN "01"		=>  -- MEM/WB
			EX_preSrcB => WB_Result
			
			WHEN OTHERS		=> -- ID/EX
			EX_preSrcB => ID_EX_rd2

		END CASE;
			
 
	END ForwardUnit;


	-- Banc de regirstres pour le passage de l'étage IF_ID.
	IF_ID PROCESS(Clk) IS
	
		BEGIN
			IF RISING_EDGE(Clk) THEN
				IF_PCPlus4 		=> IF_ID_PCPlus4;  -- Signal 2 vers Signal 13 
				INSTRUCTION		=> IF_ID_INSTRUCTION ; -- Instruction vers Signal 31 (Init Instruction)
			END IF;
	END IF_ID;
	

	-- Banc de regirstres pour le passage de l'étage ID_EX.
	ID_EX PROCESS(Clk) IS
		BEGIN
			IF RISING_EDGE(Clk) THEN
				ID_MemtoReg	=> ID_EX_MemtoReg;
       				ID_Branch	=> ID_EX_Branch;      
        			ID_AluSrc	=> ID_EX_AluSrc;   
        			ID_RegDst	=> ID_EX_RegDst;         
        			ID_RegWrite	=> ID_EX_RegWrite;    
        			ID_Jump		=> ID_EX_Jump;
        			ID_MemRead	=> ID_EX_MemRead;
        			ID_MemWrite	=> ID_EX_MemWrite;
       				ID_AluControl	=> ID_EX_AluControl;

				ID_PCPlus4	=> ID_EX_PCPlus4;

				ID_rd1 		=> ID_EX_rd1;
				ID_rd2 		=> ID_EX_rd2;

				ID_SignImm 	=> ID_EX_SignImm;
				ID_rs 		=> ID_EX_rs;
				ID_rt 		=> ID_EX_rt;
				ID_rd 		=> ID_EX_rd;
			END IF;
	END ID_EX;
	
	
	-- Banc de regirstres pour le passage de l'étage EX_MEM.
	EX_MEM PROCESS(Clk) IS
		BEGIN
			IF RISING_EDGE(Clk) THEN
				
				ID_EX_MemtoReg	=> EX_MEM_MemtoReg;
        			ID_EX_RegWrite	=> EX_MEM_RegWrite; 
        			ID_EX_MemRead	=> EX_MEM_MemRead;
        			ID_EX_MemWrite	=> EX_MEM_MemWrite;

				EX_AluResult 	=> EX_MEM_AluResult; 
       				EX_PreSrcB	=> EX_MEM_PreSrcB;
				EX_WriteReg	=> EX_MEM_WriteReg;
			END IF;
	END EX_MEM;

-- Banc de regirstres pour le passage de l'étage MEM_WB.
	MEM_WB PROCESS(Clk) IS
		BEGIN
			IF RISING_EDGE(Clk) THEN
				
				EX_MEM_MemtoReg		=> MEM_WB_MemtoReg;
        			EX_MEM_RegWrite		=> MEM_WB_RegWrite; 


				ReadData		=> MEM_WB_ReadData
				EX_MEM_AluResult	=> MEM_WB_AluResult;
				EX_MEM_WriteReg 	=> MEM_WB_WriteReg;
			

       				
			END IF;
	END MEM_WB;
	

	-- Assignation des Sorties
	MemReadOut	<=	MemReadIn;
	MemWriteOut	<=	MemWriteIn;
	PC		<=	PCIntern;
	AluResult	<=	AluResultIntern;
	WriteData	<=	rd2;
	
END ARCHITECTURE rtl;