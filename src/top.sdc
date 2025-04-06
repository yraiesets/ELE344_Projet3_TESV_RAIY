# Spécifications de contraintes pour diriger la synthèse logique du design
 
create_clock -name {CLK} -period 13.000 -waveform { 0.000 6.500 } [get_ports {clk}]

# Calcul de l'incertitude d'horloge automatique
derive_clock_uncertainty