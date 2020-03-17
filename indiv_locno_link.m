function output = indiv_locno_link()

output = csvread('Murry_microBLP_indiv.csv',1,0);
output = output(:,end-1:end);