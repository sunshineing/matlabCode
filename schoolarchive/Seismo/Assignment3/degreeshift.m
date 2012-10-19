function [npar nperp ts tn] = degreeshift(tor)

degree = 0:10:80;
for ii = 1:length(degree);
npar(:,ii) = [tand(degree(ii));1]./sqrt( tand(degree(ii))^2 +1);
nperp(:,ii) = [npar(2,ii);-npar(1,ii)];
t(:,ii) = tor*nperp(:,ii);
ts(ii)  = t(:,ii)'*npar(:,ii);
tn(ii) =  t(:,ii)'*nperp(:,ii);
end

npar(:,10) = [1;0];
nperp(:,10)=[0;-1];
t(:,10) = tor*nperp(:,10);
ts(10)  = t(:,10)'*npar(:,10);
tn(10) =  t(:,10)'*nperp(:,10);

for ii = length(degree) +2 : 2*length(degree)
npar(:,ii) = npar(:,20-ii).*[1;-1];
nperp(:,ii) = [npar(2,ii);-npar(1,ii)];
t(:,ii) = tor*nperp(:,ii);
ts(ii)  = t(:,ii)'*npar(:,ii);
tn(ii) =  t(:,ii)'*nperp(:,ii);
end




end