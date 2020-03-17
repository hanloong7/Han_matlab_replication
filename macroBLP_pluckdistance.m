function simdist = macroBLP_pluckdistance()

global dld dpl pc ill macro micro  R T seed prod_DMAyear

rng(seed);
fname = fieldnames(macro);

for d = 1:R    
    for y = 1:T        
        indiv = struct2cell(macro);
        for num = 1:length(indiv)
           temp = indiv{num};
           indiv{num} = temp{d,y};
        end
        indiv = cell2struct(indiv,fname);
        indiv = struct2array(indiv);
        
        loc = macro.locations{d,y};
        indiv = macro.indivchar{d,y};
        %List of products for specific dma-year
        [~,products_index] = ismember(prod_DMAyear{d,y},dpl(:,1));
        
        [~,dealer_index] = ismember(dpl(products_index,2),dld.dn);
        [~,locno_index] = ismember(loc(:,end),dld.ln);
        
        dist = repmat(locno_index,1,length(dealer_index)) ...
            + (repmat(dealer_index',size(locno_index,1),1)-1)*size(dld.ln,1);
        
        final_output = dld.dd(dist);
        di{d,y} = final_output;
        di2{d,y} = final_output.^2;
        ditrav{d,y} = final_output.*indiv(:,2);
        dipopden{d,y} = final_output.*indiv(:,3);
        
       
    end
end

simdist.di = di;
simdist.di2 = di2;
simdist.ditrav = ditrav;
simdist.dipopden = dipopden;
