function simdist = microBLP_pluckdistance()

global dld dpl macro micro pc R T seed
rng(seed)
for d= 1:R
    for y = 1:T
        [~,indivindex] = ismember(micro.ind_b4sim{d,y},micro.locno(:,1));
        locno = micro.locno(indivindex,3);
        [~,locindex] = ismember(locno,dld.ln);
        
        [~,prodindex] = ismember(micro.prod{d,y},dpl(:,1));
        dealer = dpl(prodindex,2);
        [~,dealerindex] = ismember(dealer,dld.dn);
        
        finalindex = repmat(locindex,1,size(dealerindex,1)) ...
            + (repmat(dealerindex',size(locindex,1),1)-1)*size(dld.dd,1);
        
        finaloutput = dld.dd(finalindex);
        indivchar = micro.indivchar{d,y};
        di{d,y} = finaloutput;
        di2{d,y} = finaloutput.^2;
        ditrav{d,y} = finaloutput...
            .*indivchar(:,2);
        dipopden{d,y} = finaloutput...
            .*indivchar(:,3);                        
    end
end

simdist.di = di;
simdist.di2 = di2;
simdist.ditrav = ditrav;
simdist.dipopden = dipopden;