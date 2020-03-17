function [G] = Murry_BLP95_moments(theta)

global R T seed macro macro_dist pc GMM ...
     prod_DMAyear delta util theta1 sigma1

rng(seed)
R=4;
T=5;
% theta = [-30.258,0.53036,-0.25364,0.22301,1.2267,-0.31707,0.40996, ...
%    0.32362,-0.49109,0.12635,-0.0047342,-0.47938,-0.44984,0.44616,-0.17891];

%% Define Coeffcients for mu_ijt
gamma = theta(1:4); %distance 
alpha = theta(5:6); %income 
phi = theta(7:8);   %ads
V = diag(theta(9:end)); %acc,size,mpd,domestic

product_util = [0 0];
store = zeros(R,T);
Runtime = 0;
for d = 1:R
    for y = 1: T
        
        %% Define mu_ijt
        % Define parameters
        numK = length(pc.sjt{d,y}); 
        numI = length(macro.weights{d,y}); %num of individuals
        simul = macro.indivchar{d,y}(:,4:end)*V; % random coefficients;
        
        %Trial
%         rcf = macro.indivchar{d,y}(:,4:end)*V; % random coefficients;
%         simul = zeros(numI,7)';
%         k = 1;
%         for idx = 1:2:numI
%            simul(:,idx) = rcf(k,:)';
%            simul(:,idx+1) = -rcf(k,:)';
%            k = k + 1;
%         end
%         clear idx k
%         simul = simul';
        
        %Income
        ALPHA = -exp(alpha(1) + alpha(2)*macro.indivchar{d,y}(:,1)...
            + simul(:,1));
        ALPHA = repmat(ALPHA,1,numK)...
            .*repmat(pc.endo{d,y}(:,1)',numI,1);
        
        %Ads
        Phi1 = phi(1) + repmat(simul(:,6),1,numK);
        Phi1 = Phi1 .* repmat(pc.endo{d,y}(:,2)',numI,1);
        Phi2 = phi(2) + repmat(simul(:,7),1,numK);
        Phi2 = Phi2 .* repmat(pc.endo{d,y}(:,3)',numI,1);

        %Distance
        dd1 = gamma(1)*macro_dist.di{d,y};
        dd2 = gamma(2)*macro_dist.ditrav{d,y};
        dd3 = gamma(3)*macro_dist.dipopden{d,y};
        dd4 = gamma(4)*macro_dist.di2{d,y};
        dd = (dd1 + dd2 + dd3 + dd4)/100;
        
        %Acc, size, mpd, domestic
        acc = repmat(pc.X{d,y}(:,1)',numI,1)...
            .*repmat(simul(:,2),1,numK);
        carsize = repmat(pc.X{d,y}(:,2)',numI,1)...
            .*repmat(simul(:,3),1,numK);
        mpd = repmat(pc.X{d,y}(:,3)',numI,1)...
            .*repmat(simul(:,4),1,numK);
        dom = repmat(pc.X{d,y}(:,4)',numI,1)...
            .*repmat(simul(:,5),1,numK);

        % mui shoudl be numI x numK
        mui = ALPHA + acc + carsize + mpd + dom + dd + Phi1 + Phi2;
        mu{d,y} = mui;
%         m = mean(mui,'all');
%         store(d,y) = m;
        %% Now we do NFP        
        start_delta = pc.logitY{d,y};
        sample_shares = pc.sjt{d,y};
        weights = macro.weights{d,y};
        
        tic;
        delta = Murry_BLP95_NFP(start_delta,mui,...
            weights,sample_shares);
  
        Runtime = Runtime + toc;
        disp("Market " + d + " Year " + y + ", NFP took " + toc + " secs. " )
        
       
        util{d,y} = delta;
        product_util = [product_util;[delta prod_DMAyear{d,y}]];

        
    end
end
disp("Whole NFP took " + Runtime + "sec")
product_util(1,:) = [];
[~,idx] = sort(product_util(:,2));
delta = product_util(idx,:);
delta = delta(:,1);

%OLS on delta to recover theta1
x = [GMM.X GMM.lux GMM.dum];
z = [GMM.X GMM.lux GMM.dum GMM.Z(:,[1:2 end-2:end])];
% x = x(1:length(delta)',:);
% z = x(1:length(delta)',:);
theta1 = (x'*x)\(x'*delta);
xi = delta - x*theta1; %unobserved product quality!! 


sigma1 = mean(xi.^2);
sigma1 = sigma1*inv(x'*x);
sigma1 = sqrt(abs(diag(sigma1)));
macroG = z'*xi;
G = macroG./length(xi);

% % Micro G 
% microG = [0];
% for d = 1:R
%     for y = 1:T
%         
%         %% Calculating mu_ijt for micro moments information
%         numK = size(micro.prod{d,y},1);
%         numI = size(micro.ind{d,y},1);
%         simul = micro.indivchar{d,y}(:,4:end)*V; % random coefficients;
%                 
%         %Income
%         ALPHA = -exp(alpha(1) + alpha(2)*micro.indivchar{d,y}(:,1)...
%             + simul(:,1));
%         ALPHA = repmat(ALPHA,1,numK)...
%             .*repmat(pc.endo{d,y}(:,1)',numI,1);
%         
%         %Ads
%         Phi1 = phi(1) + repmat(simul(:,2),1,numK);
%         Phi1 = Phi1 .* repmat(pc.endo{d,y}(:,2)',numI,1);
%         Phi2 = phi(2) + repmat(simul(:,3),1,numK);
%         Phi2 = Phi2 .* repmat(pc.endo{d,y}(:,3)',numI,1);
% 
%         %Distance
%         dd1 = gamma(1)*micro_dist.di{d,y};
%         dd2 = gamma(2)*micro_dist.di2{d,y};
%         dd3 = gamma(3)*micro_dist.ditrav{d,y};
%         dd4 = gamma(4)*micro_dist.dipopden{d,y};
%         dd = (dd1 + dd2 + dd3 + dd4)/100;
%         
%         %Acc, size, mpd, domestic
%         acc = repmat(pc.X{d,y}(:,1)',numI,1)...
%             .*repmat(simul(:,4),1,numK);
%         carsize = repmat(pc.X{d,y}(:,2)',numI,1)...
%             .*repmat(simul(:,5),1,numK);
%         mpd = repmat(pc.X{d,y}(:,3)',numI,1)...
%             .*repmat(simul(:,6),1,numK);
%         dom = repmat(pc.X{d,y}(:,4)',numI,1)...
%             .*repmat(simul(:,7),1,numK);
%        
%         % mui shoudl be numI x numK
%         mui = ALPHA + acc + carsize + mpd + dom + dd + Phi1 + Phi2;
% 
%         
%         %% Use delta from before to calculate shares
% 
%         
%         delta_micro = repmat(util{d,y}',numI,1);
%         top = exp(delta_micro + mui); %matrix
%         bottom = 1 + sum(top,2); %vector
%         
%         sr_ij = top./bottom; %matrix
%         sr_i0 = 1 - sum(sr_ij,2); %vector
%         srhat_ij = sr_ij ./(1-sr_i0); %matrix
%         
%         %% Form Micro moments
%         first = micro.dec{d,y} - srhat_ij;
%         second = (micro.dec{d,y} - srhat_ij)...
%             .*micro_dist.di{d,y};
%         third = (micro.dec{d,y} - srhat_ij)...
%             .*micro_dist.ditrav{d,y};
%         forth = (micro.dec{d,y} - srhat_ij)...
%             .*micro_dist.dipopden{d,y};
%         
%         first = sum(first,'all')./(numI*numK*10);
%         second = sum(second,'all')./(numI*numK*10);
%         third = sum(third,'all')./(numI*numK*10);
%         forth = sum(forth,'all')./(numI*numK*10);
%         
%         microG = [microG;first;second;third;forth];
%         
%     end
% end
% microG(1) = [];
% G = [macroG;microG];
