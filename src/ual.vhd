--================ alu.vhd =================================
-- ELE344 Conception et architecture de processeurs
-- HIVER 2025, Ecole de technologie superieure
-- ***** Raies, Yasser ************
-- ***** RAIY07099301 ************
-- =============================================================
-- Description: 
--              Architecture RTL du UAL (Unite Arithmetique et Logique)
--              de N bits (par defaut 32 bits).
--              Il prend deux entrees et applique une operation logique
--              ou arithmetique definie par `ualControl`.
-- =============================================================

LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY UAL IS

  GENERIC (N : INTEGER := 32);

  PORT (
		ualControl : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        	srcA, srcB : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        	result     : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        	cout, zero : OUT STD_LOGIC
	);
	
END UAL;

ARCHITECTURE rtl OF UAL IS

  SIGNAL operation                    : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL op1, op2                     : STD_LOGIC;
  SIGNAL somme, srcAMux, srcBMux, res : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
  SIGNAL retenueSomme                 : UNSIGNED(N DOWNTO 0);

BEGIN
	-- Extraction des bits de contrele depuis `ualControl`
	operation <= ualControl(1 DOWNTO 0);
  	op1       <= ualControl(3);
  	op2       <= ualControl(2);
	
	-- Selection des entrees en fonction des bits de contrele
  	srcAMux   <= srcA WHEN op1 = '0' ELSE NOT(srcA);
  	srcBMux   <= srcB WHEN op2 = '0' ELSE NOT(srcB);
	
	-- Additionneur (utilise pour ADD/SUB)
	retenueSomme <= RESIZE(UNSIGNED(srcAMux), srcAMux'LENGTH+1) + UNSIGNED(srcBMux) + UNSIGNED'("" & op2);
	somme <= STD_LOGIC_VECTOR(retenueSomme(N-1 DOWNTO 0));

  -- Multiplexeur 4-a-1 pour generer le signal res
  PROCESS (operation, srcAMux, srcBMux, somme) IS
  BEGIN

	CASE operation IS
		WHEN "00" => res <= srcAMux AND srcBMux;
		WHEN "01" => res <= srcAMux OR srcBMux;
		WHEN "10" => res <= somme;
		WHEN OTHERS => res <= (0 => somme(N-1), OTHERS => '0');
	END CASE;

  END PROCESS;

  -- Assignation des sorties
  	zero 	<= '1' WHEN UNSIGNED(res) = 0 ELSE '0';
  	result	<= res;
  	cout	<= retenueSomme(N);
END rtl;
