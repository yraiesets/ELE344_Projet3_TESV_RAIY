--========================= imem.vhd ============================
-- ELE-343 Conception des systemes ordines
-- HIVER 2017, Ecole de technologie superieure
-- Auteur : Chakib Tadj, Vincent Trudel-Lapierre, Yves Blaquiere
-- Update: Hachem Bensalem, Janvier 2025
-- =============================================================
-- Description: imem        
-- =============================================================

LIBRARY ieee;
LIBRARY std;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY imem IS -- Memoire d'instructions
  PORT (adresse : IN  std_logic_vector(7 DOWNTO 0); -- Ce signal corresponds au signal PC(9 DOWNTO 2)
                                                    
        data : OUT std_logic_vector(31 DOWNTO 0));
END;  -- imem;

ARCHITECTURE imem_arch OF imem IS

  CONSTANT TAILLE_ROM : positive := 19;  -- taille de la rom (modifier au besoin)
  TYPE romtype IS ARRAY (0 TO TAILLE_ROM) OF std_logic_vector(31 DOWNTO 0);
	
	--Mettre a jour la Rom avec le code machine genere avec MARS et valide par le charge de laboratoire
  CONSTANT Rom : romtype := (
	0  => x"20030001",
	1  => x"2067000b",
	2  => x"00671024",
	3  => x"ac472000",
	4  => x"00432820",
	5  => x"8ca21fff",
	6  => x"10430002",
	7  => x"2063000b",
	8  => x"08000006",
	9  => x"00a7202a",
	10 => x"10820001",
	11 => x"ac851fff",
	12 => x"00e2202a",
	13 => x"00622025",
	14 => x"2067ffff",
	15 => x"00e23822",
	16 => x"8c621ff4",
	17 => x"ac871ff4",
	18 => x"00051820",
	19 => x"10a3ffec");

BEGIN
  PROCESS (adresse)
  BEGIN
    data <= Rom(to_integer(unsigned((adresse))));
  END PROCESS;
END imem_arch;

