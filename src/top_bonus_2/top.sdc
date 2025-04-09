# Spécifications de contraintes pour diriger la synthèse logique du design
 
create_clock -name {CLK} -period 13.500 -waveform { 0.000 6.750 } [get_ports {clk}]

# Calcul de l'incertitude d'horloge automatique
derive_clock_uncertainty