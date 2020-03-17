function micro= microBLP_decision()

% This file creates the decision of all simulated individuals
% the y matrix for BLP micro moments 
% output is:
% 1. Simulated individual's decision in each market-year
% 2. Simulated individual's index in each market-year
% 3. Simulated individual's product choice in each market-year
% 4. Simulated individual's locno

global numindiv seed
rng(seed)

indiv = csvread('Murry_microBLP_indiv.csv',1,0);
prod = csvread('Murry_prod_yearDMA.csv',1,0);
randp = randperm(size(indiv,1),numindiv)';
randp = sort(randp);
randp = repelem(randp,10,1);
indiv = indiv(randp,:);

%indiv product_id locno
simindivtract = indiv(:,[end-1 1 end]);
%Forth columns is the 20th macro simulated individual's data
simindivtract = [simindivtract randi([1 20],size(simindivtract,1),1)];
indiv = indiv(:,1:end-1);
indiv(:,end+1) = (1:size(indiv,1))';
simindivtract = [simindivtract indiv(:,end)];

%1st col is prod_id
%2nd col is year, 3rd col is dma, 4th is individual id
for d = 1:4
    for y = 1:5
        %Individuals after simulation in dma year
        i = indiv(indiv(:,2) == y & indiv(:,3)==d,end);
        %Individuals before simulation in dmayear
        i_b4sim = indiv(indiv(:,2)==y & indiv(:,3)==d,end-1);
        %Product purchased by individual
        i_p = indiv(indiv(:,2)==y & indiv(:,3)==d,1);
        %Products available in dma year
        p = prod((prod(:,2) == y) & (prod(:,3)==d));
        
        [~, idx] = ismember(i_p,p);
        indivindx = [1:1:size(idx)]';
        a = zeros(size(i_p,1),size(p,1));
        for num = 1:size(i_p,1)
            a(indivindx(num),idx(num)) = 1;
        end
        
        simindivdec{d,y} = a;
        simindiv{d,y} = i;
        simindiv_b4sim{d,y} = i_b4sim;
        simprod{d,y} = p;
    end
end

clearvars -except simindivdec simindiv simprod simindivtract simindiv_b4sim
micro.dec = simindivdec;
micro.ind = simindiv;
micro.ind_b4sim = simindiv_b4sim;
micro.prod = simprod;
micro.locno = simindivtract;




