function fval = Murry_BLP95_GMM(theta)


global G W iter

iter = iter + 1;

G = Murry_BLP95_moments(theta);
W = eye(length(G(:,1)));
fval = G'*W*G;

csvwrite('theta2.csv',theta);