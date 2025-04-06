# Spécifications de contraintes pour diriger la synthèse logique du design
#

# Contrainte de la période maximum de l'horloge à 20 ns (Fmin=50MHz). 
# Cette contrainte concerne les chemins combinatoires entre les bascules. 
create_clock -name {CLK} -period 14.000 -waveform { 0.000 7.000 } [get_ports {clk}]

# Calcul de l'incertitude d'horloge automatique
derive_clock_uncertainty