function [outcome] = Murry_BLP95_NFP(start_delta,mui,...
                        weights,sample_shares)

global tolx

iter = 0; 
delta_old = zeros(length(start_delta),1);
delta_new = start_delta;


while ((max(abs(delta_new - delta_old))>tolx) & (iter<100));
   
    %Calculate product market shares;
    top = repmat(delta_new',length(mui),1) + mui;
    top = exp(top);
    bottom = 1 + sum(top,2);
    predicted_shares = (top./bottom);
    predicted_shares = predicted_shares.*weights;
    predicted_shares = sum(predicted_shares,1)';

    % NFP algorithm
    iter = iter + 1; 
    delta_old = delta_new;
    delta_new = delta_new + log(sample_shares) - log(predicted_shares);
    outcome = delta_new;
end
  
    
if sum(isnan(delta_new))>1 
    disp ('ERROR in contraction, no deltas found')
    outcome = zeros(size(start_delta,1),1);
end
disp(iter)