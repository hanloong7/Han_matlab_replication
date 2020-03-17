function prod_DMAyear = product_DMAyear_link()

global R T

prod = csvread('Murry_prod_yearDMA.csv',1,0);

for d = 1:R
    for y = 1:T
        prod_DMAyear{d,y} = prod((prod(:,2)==y) & (prod(:,3)==d));
    end
end