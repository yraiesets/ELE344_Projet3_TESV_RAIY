--========================= imem.vhd ============================
-- ELE-343 Conception des systèmes ordinés
-- HIVER 2017, Ecole de technologie supérieure
-- Auteur : Chakib Tadj, Vincent Trudel-Lapierre, Yves Blaquière
-- Update: Hachem Bensalem, Janvier 2025
-- =============================================================
-- Description: imem avec NOp      
-- =============================================================

LIBRARY ieee;
LIBRARY std;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY imem IS -- Memoire d'instructions
  PORT (adresse : IN  std_logic_vector(7 DOWNTO 0); -- Ce signal corresponds au signal PC(9 DOWNTO 2)
                                                    
        data : OUT std_logic_vector(31 DOWNTO 0));
END; 

ARCHITECTURE imem_arch OF imem IS

  CONSTANT TAILLE_ROM : positive := 26;  -- taille de la rom (modifier au besoin)
  TYPE romtype IS ARRAY (0 TO TAILLE_ROM) OF std_logic_vector(31 DOWNTO 0);
	
--Mettre à jour la Rom avec le code machine généré avec MARS et validé par le chargé de laboratoire
CONSTANT Rom : romtype := (
  0  => x"20030001",  -- addi $3, $0, 1
  1  => x"2067000b",  -- addi $7, $3, 11
  2  => x"00671024",  -- and $2, $3, $7
  3  => x"ac472000",  -- sw $7, 8192($2)
  4  => x"00432820",  -- add $5, $2, $3
  5  => x"8ca21fff",  -- lw $2, 8191($5)
  6  => x"10430005",  -- beq $2, $3, next
  7  => x"20000000",  -- NOP (BEQ delay slot 1)
  8  => x"20000000",  -- NOP (BEQ delay slot 2)
  9  => x"2063000b",  -- addi $3, $3, 11
  10 => x"08000006",  -- j To (nouvelle adresse : saute à ligne 6 maintenant)
  11 => x"20000000",  -- NOP (J delay slot)
  12 => x"00a7202a",  -- slt $4, $5, $7
  13 => x"10820003",  -- beq $4, $2, around
  14 => x"20000000",  -- NOP (BEQ delay slot 1)
  15 => x"20000000",  -- NOP (BEQ delay slot 2)
  16 => x"ac851fff",  -- sw $5, 8191($4)
  17 => x"00e2202a",  -- slt $4, $7, $2
  18 => x"00622025",  -- or $4, $3, $2
  19 => x"2067ffff",  -- addi $7, $3, -1
  20 => x"00e23822",  -- sub $7, $7, $2
  21 => x"8c621ff4",  -- lw $2, 8180($3)
  22 => x"ac871ff4",  -- sw $7, 8180($4)
  23 => x"00051820",  -- add $3, $0, $5
  24 => x"10a3ffe7",  -- beq $5, $3, main (ajusté pour revenir à ligne 0)
  25 => x"20000000",  -- NOP (BEQ delay slot 1)
  26 => x"20000000"   -- NOP (BEQ delay slot 2)
);
BEGIN
  PROCESS (adresse)
  BEGIN
    data <= Rom(to_integer(unsigned((adresse))));
  END PROCESS;
END imem_arch;

