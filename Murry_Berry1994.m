function Berry1994 = Murry_Berry1994()

addpath('../data')

%global dld dpl macro micro pc R T seed macro_big
global pc seed GMM
rng(seed)

%% First Stage
x = [GMM.Z GMM.X GMM.lux GMM.dum];
endo = [GMM.endo];

for num = 1:size(endo,2)
    y = endo(:,num);
   beta(:,num) = inv(x'*x)*x'*y; 
end

keep = size(beta,1) - size(GMM.dum,2);
colNames = {'Avgprice','Dealer Ad','Manufacturer Ad'};
rowNames = {'Acc_nei','size_nei','mpd_nei','domestic_nei',...
    'Acc_sty','size_sty','mpd_sty','domestic_sty',...
    'pd5mile','Adprice', 'AdUS_Brand',...
    'Acc','size','mpd','domestic','constant','lux'};
sTable = array2table(beta(1:keep,:),'RowNames',rowNames,'VariableNames',colNames);
%writetable(sTable,'Berry1994_FS.csv');

%% Berry IV regression

x = [GMM.X GMM.lux GMM.endo GMM.dum];
z = [GMM.X GMM.lux GMM.Z GMM.dum];
y = [GMM.logitY];

beta2 = inv(x'*z*inv(z'*z)*z'*x)*x'*z*inv(z'*z)*z'*y;
keep = size(beta2,1) - size(GMM.dum,2);
colNames = {'Logit Regression'};
rowNames = {'Acc','size','mpd','domestic','constant','lux',...
    'avg_price','AdDealer','AdMan'};
sTable2 = array2table(beta2(1:keep,:),'RowNames',rowNames,'VariableNames',colNames);
%writetable(sTable2,'Berry1994_IV');

Berry1994.coef = beta2;
Berry1994.delta = x*beta2;
Berry1994.IVTab = sTable2;
Berry1994.FSTab = sTable;
