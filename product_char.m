function [pc GMM]= product_char()

global R T seed prod_DMAyear dpl
rng(seed)

X = csvread('Murry_macroBLP_X.csv',1,0);
logitY = csvread('Murry_macroBLP_Y.csv',1,0);
sjt = csvread('Murry_macroBLP_sjt.csv',1,0);
dum = csvread('Murry_macroBLP_dummy.csv',1,0);
endo = csvread('Murry_macroBLP_endo.csv',1,0);
Z = csvread('Murry_macroBLP_Z.csv',1,0);
lux = csvread('Murry_macroBLP_lux.csv',1,0);
ads = csvread('Murry_macroBLP_ad.csv',1,0);
whole = csvread('Murry_macroBLP_wholesale.csv',1,0);

for d = 1:R
    for y = 1:T
       [~,index] = ismember(prod_DMAyear{d,y},dpl(:,1));
       pc.X{d,y} = X(index,:);
       pc.logitY{d,y} = logitY(index,:);
       pc.sjt{d,y} = sjt(index,:);
       pc.dum{d,y} = dum(index,:);
       pc.endo{d,y} = endo(index,:);
       pc.Z{d,y} = Z(index,:);
       pc.lux{d,y} = lux(index,:);
       pc.ads{d,y} = ads(index,:);
       pc.whole{d,y} = whole(index,:);
    end
end

GMM.X = X;
GMM.logitY = logitY;
GMM.sjt = sjt;
GMM.dum = dum;
GMM.endo = endo;
GMM.Z = Z;
GMM.lux = lux;
GMM.ads = ads;
GMM.whole = whole;