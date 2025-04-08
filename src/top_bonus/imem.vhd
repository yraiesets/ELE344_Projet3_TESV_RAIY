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

  CONSTANT TAILLE_ROM : positive := 27;  -- taille de la rom (modifier au besoin)
  TYPE romtype IS ARRAY (0 TO TAILLE_ROM) OF std_logic_vector(31 DOWNTO 0);
	
--Mettre à jour la Rom avec le code machine généré avec MARS et validé par le chargé de laboratoire
  CONSTANT Rom : romtype := (
    0  => x"20030001",
    1  => x"2067000b",
    2  => x"00671024",
    3  => x"ac472000",
    4  => x"00432820",
    5  => x"20000000",
    6  => x"8ca21fff",
    7  => x"10430005",
    8  => x"20000000",
    9  => x"20000000",
    10 => x"2063000b",
    11 => x"08000007",
    12 => x"20000000",
    13 => x"00a7202a",
    14 => x"10820003",
    15 => x"20000000",
    16 => x"20000000",
    17 => x"ac851fff",
    18 => x"00e2202a",
    19 => x"00622025",
    20 => x"2067ffff",
    21 => x"00e23822",
    22 => x"8c621ff4",
    23 => x"ac871ff4",
    24 => x"00051820",
    25 => x"10a3ffe6",
    26 => x"20000000",
    27 => x"20000000");
BEGIN
  PROCESS (adresse)
  BEGIN
    data <= Rom(to_integer(unsigned((adresse))));
  END PROCESS;
END imem_arch;

