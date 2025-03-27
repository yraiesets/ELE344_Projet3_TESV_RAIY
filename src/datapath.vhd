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
    	-- Mul2-to-1 pour determine l'addresse d'ecriture
	WriteReg <= Instruction(20 DOWNTO 16) WHEN RegDst = '0' ELSE Instruction(15 DOWNTO 11);

   	 -- Mul2-to-1 pour determine les donnees d'ecriture
	Result <= ReadData WHEN MemtoReg = '1' ELSE AluResultIntern;

    	-- Extension de signe (SignExtend)
	SignImm <= STD_LOGIC_VECTOR(RESIZE(SIGNED(Instruction(15 DOWNTO 0)), N));

    	-- Banc de registres
    	REGISTER_FILE	:	ENTITY work.RegFile(RegFile_arch)
        	PORT MAP(
            		clk	=>	Clk,
            		we	=>	RegWrite,
            		ra1	=>	Instruction(25 DOWNTO 21),
            		ra2	=>	Instruction(20 DOWNTO 16),
            		wa	=>	WriteReg,
            		wd	=>	Result,
            		rd1	=>	rd1,
            		rd2	=>	rd2
        	);

	-- Mul2-to-1 pour determine la SrcB de l'ALU
	SrcB <= SignImm WHEN AluSrc = '1' ELSE rd2;
	
	-- UAL
	UAL		:	ENTITY work.UAL(rtl)
		PORT MAP(
			ualControl	=>	AluControl,
			srcA		=>	rd1,
			srcB		=>	SrcB,
			result		=>	AluResultIntern,
			cout		=>	OPEN,
			zero		=>	Zero
		);

	-- Determiner si on doit effectuer un branchement
	PCSrc		<=	Branch AND Zero;
	
	-- Calcul des signaux utilises dans la logique du PC :
	PCPlus4 	<=	STD_LOGIC_VECTOR(UNSIGNED(PCIntern) + TO_UNSIGNED(4, N));
	PCJump		<=	PCPlus4(31 DOWNTO 28) & Instruction(25 DOWNTO 0) & "00"; -- Concatenation pour obtenir l'adresse de saut complete
	SignImmSh	<=	STD_LOGIC_VECTOR(SHIFT_LEFT(SIGNED(SignImm), 2));
	PCBranch	<=	STD_LOGIC_VECTOR(SIGNED(PCPlus4) + SIGNED(SignImmSh));

	-- Mul2-to-1 pour determiner PCNextBr
	PCNextBr <= PCBranch WHEN PCSrc = '1' ELSE PCPlus4;


	-- Mul2-to-1 pour determiner PCNext
	PCNext <= PCJump WHEN Jump = '1' ELSE PCNextBr;

	-- Bascule D Synchrone avec remise a zero asynchrone (clear).
	PROCESS(Clk, Reset) IS
		BEGIN
			IF Reset = '1' THEN
				PCIntern <= (OTHERS => '0');
			ELSIF RISING_EDGE(Clk) THEN
				PCIntern <= PCNext;
			END IF;
	END PROCESS;

	-- Assignation des Sorties
	MemReadOut	<=	MemReadIn;
	MemWriteOut	<=	MemWriteIn;
	PC		<=	PCIntern;
	AluResult	<=	AluResultIntern;
	WriteData	<=	rd2;
	
END ARCHITECTURE rtl;