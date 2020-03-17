function [sim_data lateruse] = macroBLP_gensim()

%% define globals
global R T seed

for year=1:T
   
rng(seed+year-1);
%disp(seed+year-1)
%% read in data

addpath('../American Fact Finder');
income_dist = csvread('inc.csv',1,0);
time_dist = csvread('time.csv',1,0);
pop_stats = csvread('pop.csv',1,0);
locno_stats = csvread('locno_tract.csv',1,0);

%cleaning stuff;
pop_stats(:,3) = round(pop_stats(:,3),2);
locno_stats(:,3) = round(locno_stats(:,3),2);
tf = ismember(pop_stats(:,2:3),locno_stats(:,2:3),'rows');
pop_stats((tf(:,1)==0),:) = [];
income_dist((tf(:,1)==0),:) = [];
time_dist((tf(:,1)==0),:) = [];

income_level = 1000*[5 12.5 20 30 42.5 62.5 87.5 125 175 300];
time_level = [5 10 15 20 25 30 35 40 45 60 90 120];
census_tracts = length(income_dist(:,1)); %num of census tracts
pop_stats = [pop_stats (1:census_tracts)'];

pop_stats_unique = pop_stats;
pop_stats = repelem(pop_stats,R*T,1);

%% adding up pmf to get cdf 

income_dist(:,5:end) = cumsum(income_dist(:,5:end),2);
time_dist(:,5:end) = cumsum(time_dist(:,5:end),2);
income_dist(:,5:end) = income_dist(:,5:end)./income_dist(:,end);
time_dist(:,5:end) = time_dist(:,5:end)./time_dist(:,end);

income_dist = repelem(income_dist,R*T,1);
time_dist = repelem(time_dist,R*T,1);

%% invert cdf of income to get bins

r_cdf = rand(R*T*census_tracts,1);

bin_idx(:,1) = (r_cdf < income_dist(:,5));

for i = 1:9
   bin_idx(:,i+1) = (income_dist(:,5+i-1) <=r_cdf) & ...
       (r_cdf < income_dist(:,5+i));
end

income_sim = bin_idx * income_level';
income_sim = log(income_sim);
%income_sim = (income_sim - mean(income_sim))/std(income_sim);

%% invert cdf of time to get bins
clear bin_idx
bin_idx(:,1) = (r_cdf < time_dist(:,5));

for i = 1:11
    bin_idx(:,i+1) = (time_dist(:,5+i-1)<=r_cdf) & ...
        (r_cdf < time_dist(:,5+i));
end

bin_idx = repmat(1:12,R*T*census_tracts,1) .* bin_idx;
bin_idx = sum(bin_idx,2);
bin_idx_t = bin_idx + 1;

time_level = [0 time_level];
time_sim = time_level(bin_idx)' + r_cdf.*(time_level(bin_idx_t)' - time_level(bin_idx)');
time_sim = log(time_sim);
%time_sim = (time_sim - mean(time_sim))/std(time_sim);
%% now drawing individuals endowed with distance

clear bin_idx bin_idx_t 

%[dealerno locno distances] = lon_lat();

pop_stats(:,end+1) = 0;


for i = 1:census_tracts
   
    x = pop_stats_unique(i,2);
    y = pop_stats_unique(i,3);
   %Picks up all the locno
   %associated with the county, census tract
   subset_locno_stats = locno_stats(...
       (locno_stats(:,2) == x) & ...
       (locno_stats(:,3) == y),:);
   

   %generate pmf of locno
   prob = subset_locno_stats(:,end);
   prob = cumsum(prob);
   
   %find the random number for all the 
   %simulated individual
   rand_cdf = r_cdf((i-1)*R*T+1:i*R*T);
   
   %Now find out which bin within the census tract
   %the simulated individual falls into
   
   if length(prob)>1
        bin_idx(:,1) = (rand_cdf < prob(1));
        for j = 2:length(prob)
            bin_idx(:,j) = (prob(j-1)<=rand_cdf) & (rand_cdf<prob(j));
        end
   
   else
       bin_idx = ones(R*T,1);
   end
   
   bin_idx = bin_idx * [1:length(prob)]';
   pop_stats((i-1)*R*T+1:i*R*T,end) = subset_locno_stats(bin_idx,1);
   
end

denom = accumarray(pop_stats_unique(:,1), pop_stats_unique(:,4));
[~,idx] = ismember(pop_stats_unique(:,1),(1:length(denom))');
pop_stats_unique(:,4) = pop_stats_unique(:,4)./denom(idx);
pop_stats(:,4) = repelem(pop_stats_unique(:,4),R*T,1)*(1/(R*T));
clear denom idx bin_idx;

sim_data.DMA = pop_stats(:,1);
sim_data.county = pop_stats(:,2);
sim_data.tract = pop_stats(:,3);
sim_data.popweight = pop_stats(:,4);
sim_data.locno = pop_stats(:,end);
sim_data.income = income_sim;
sim_data.time = time_sim;
%sim_data.densi = pop_stats(:,7); %popdensity
sim_data.densi = pop_stats(:,6); %land area

%7 random coefficient variables for the RE BLP
%unobserved individual random coefficient
% 1-4 is for accel,size,mpd,domestic
% 5 is for prices
% 6-7 are for dealer and manufacturer ad
sim_data.rc1 = randn(size(income_sim,1),1);
sim_data.rc2 = randn(size(income_sim,1),1);
sim_data.rc3 = randn(size(income_sim,1),1);
sim_data.rc4 = randn(size(income_sim,1),1);
sim_data.rc5 = randn(size(income_sim,1),1);
sim_data.rc6 = randn(size(income_sim,1),1);
sim_data.rc7 = randn(size(income_sim,1),1);
lateruse = sim_data;
    for dma=1:R
        macro = sim_data;
        macro = struct2array(macro);
        macro = macro(macro(:,1)==dma,:);
        macro(:,6) = normalize(macro(:,6));
        locations{dma,year} = macro(:,[1:3 5]);
        indivchar{dma,year} = macro(:,[6:end]);
        weights{dma,year} = macro(:,4);
%         l.DMA{dma,year} = macro(:,1);
%         l.county{dma,year} = macro(:,2);
%         l.tract{dma,year} = macro(:,3);
%         l.popweight{dma,year} = macro(:,4);
%         l.locno{dma,year} = macro(:,5);
%         l.income{dma,year} = macro(:,6);
%         l.time{dma,year} = macro(:,7);
%         l.densi{dma,year} = macro(:,8);
%         l.rc1{dma,year} = macro(:,9);
%         l.rc2{dma,year} = macro(:,10);
%         l.rc3{dma,year} = macro(:,11);
%         l.rc4{dma,year} = macro(:,12);
%         l.rc5{dma,year} = macro(:,13);
%         l.rc6{dma,year} = macro(:,14);
%         l.rc7{dma,year} = macro(:,15);
    end
    
  
end
clear sim_data;
sim_data.weights = weights;
sim_data.locations = locations;
sim_data.indivchar = indivchar;

