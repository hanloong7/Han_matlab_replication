function [microsim indivchar]= microBLP_gensim()

global micro macrotemp seed R T
rng(seed)
locno_stats = csvread('locno_tract.csv',1,0);
locno_stats(:,3) = round(locno_stats(:,3),2);

locno = micro.locno(:,3);
sim = micro.locno(:,4);

%We identify the census tract of each locno 
%Can be repeated
[~,idx] = ismember(locno,locno_stats(:,1));
census_tract = [locno_stats(idx,2:3)];
macrocensus = [macrotemp.county macrotemp.tract];

macro_temp = macrotemp;
fname = fieldnames(macro_temp);
macro_temp = struct2cell(macro_temp);
for num = 1:length(macro_temp)
   macro_temp{num} = reshape(macro_temp{num},R*T,length(macro_temp{num})/(R*T))';
end
macro_temp = cell2struct(macro_temp,fname);

macrocensus = macrocensus([1:R*T:end],:);
[tf,idx] = ismember(census_tract,macrocensus,'rows');
tf = idx + size(macrocensus,1).*(sim-1);
microsim = [macro_temp.income(tf) macro_temp.time(tf) macro_temp.densi(tf)...
        macro_temp.rc1(tf) macro_temp.rc2(tf) macro_temp.rc3(tf) macro_temp.rc4(tf)...
        macro_temp.rc5(tf) macro_temp.rc6(tf) macro_temp.rc7(tf)];
    
for d = 1:R
    for y = 1:T
        [~,indivindex] = ismember(micro.ind{d,y},micro.locno(:,5));
        indivchar{d,y} = microsim(indivindex,:);
    end
end