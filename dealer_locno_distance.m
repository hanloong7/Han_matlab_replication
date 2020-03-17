function ll = dealer_locno_distance()

% Calculate distance for all unique customer lat lon
% across all dealers
dealer = csvread('Murry_dealerno_latlon.csv',1,0);
cust = csvread('Murry_locno_latlon.csv',1,0);

d = repmat(dealer,size(cust,1),1);
c = repelem(cust,size(dealer,1),1);

ll.dn = dealer(:,1); %dealerno
ll.ln = cust(:,1); %locno
dd = distance(d(:,2),d(:,3),c(:,2),c(:,3),6371000)./1609.344;
ll.dd = reshape(dd,size(dealer,1),size(cust,1))';



