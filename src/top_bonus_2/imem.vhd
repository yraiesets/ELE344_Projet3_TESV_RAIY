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

  CONSTANT TAILLE_ROM : positive := 23;  -- taille de la rom (modifier au besoin)
  TYPE romtype IS ARRAY (0 TO TAILLE_ROM) OF std_logic_vector(31 DOWNTO 0);
	
--Mettre à jour la Rom avec le code machine généré avec MARS et validé par le chargé de laboratoire
CONSTANT Rom : romtype := (
  0  => x"20030001",
  1  => x"2067000b",
  2  => x"00671024",
  3  => x"ac472000",
  4  => x"00432820",
  5  => x"8ca21fff",
  6  => x"10430004",
  7  => x"20000000",
  8  => x"2063000b",
  9  => x"08000006",
  10 => x"20000000",
  11 => x"00a7202a",
  12 => x"10820002",
  13 => x"20000000",
  14 => x"ac851fff",
  15 => x"00e2202a",
  16 => x"00622025",
  17 => x"2067ffff",
  18 => x"00e23822",
  19 => x"8c621ff4",
  20 => x"ac871ff4", 
  21 => x"00051820",
  22 =>	x"10a3ffe9",
  23 => x"20000000");
BEGIN
  PROCESS (adresse)
  BEGIN
    data <= Rom(to_integer(unsigned((adresse))));
  END PROCESS;
END imem_arch;

