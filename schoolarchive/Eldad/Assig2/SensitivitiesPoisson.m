%3D Poisson Driver
clear all
close all

%% Set constants

nn =  8;
L = 1;

n1 = nn; % Number of cells in x1 direction
n2 = nn; % Number of cells in x2 direction
n3 = nn; % Number of cells in x3 direction

h1 = L/n1; % cell length in x1 direction
h2 = L/n2;
h3 = L/n3;

Lx1 = n1*h1;
Lx2 = n2*h2;
Lx3 = n3*h3;

%% Set up cells, mesh, Operators %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MESH
[x,y,z] = ndgrid(0:h1:Lx1,0:h2:Lx2,0:h3:Lx3); % Cell nodes
[xc,yc,zc] = ndgrid(h1/2:h1:Lx1-h1/2, h2/2:h2:Lx2-h2/2, h3/2:h3:Lx3-h3/2); % Cell centres
[xdx,ydx,zdx] = ndgrid(0:h1:Lx1, h2/2:h2:Lx2-h2/2, h3/2:h3:Lx3-h3/2); %Staggered in x1 cell wall x2 x3
[xdy,ydy,zdy] = ndgrid(h1/2:h1:Lx1-h1/2, 0:h2:Lx2, h3/2:h3:Lx3-h3/2); %Staggered in x2 cell wall x1 x3
[xdz,ydz,zdz] = ndgrid(h1/2:h1:Lx1-h1/2, h2/2:h2:Lx2-h2/2, 0:h3:Lx3); %Staggered in x3 cell wall x1 x2

%%%%%%%%%%%%%%%%%% OPERATORS

% derivatives on walls (going from centre to nodes) <GRAD>
ddxn = @(m,k) 1/k*spdiags([-ones(m+1,1) ones(m+1,1)],[-1,0],m+1,m); 
% derivative function (calculating from nodes to centre) <DIV>
ddxc = @(m,k) 1/k*spdiags([-ones(m+1,1) ones(m+1,1)],[0,1],m,m+1); 
% Average function (Go from centres to walls (will also need ghost))
av = @(m) 0.5*spdiags([ones(m,1) ones(m,1)],[-1,0],m+1,m); 
%%%%%%% 

I1   = speye(n1);     % Create Identities of Appropriate size
I2   = speye(n2);     % Create Identities of Appropriate size
I3   = speye(n3);     % Create Identities of Appropriate size

Dn1  = ddxn(n1,h1);  % Create 1D Operators 
Dn2  = ddxn(n2,h2);  % Create 1D Operators 
Dn3  = ddxn(n3,h3);  % Create 1D Operators 

Dc1  = ddxc(n1,h1);  % Create 1D Operators 
Dc2  = ddxc(n2,h2);  % Create 1D Operators 
Dc3  = ddxc(n3,h3);  % Create 1D Operators 

Av1  = av(n1);
Av2  = av(n2);
Av3  = av(n3);

Av1([1,end]) = 2*[1,1];
Av2([1,end]) = 2*[1,1];
Av3([1,end]) = 2*[1,1];

%%% Ramp up to 2D then to 3D
%% 3D
DN1 = kron(I3,kron(I2,Dn1));
DN2 = kron(I3,kron(Dn2,I1));
DN3 = kron(Dn3,kron(I2,I1));

DC1 = kron(I3,kron(I2,Dc1));
DC2 = kron(I3,kron(Dc2,I1));
DC3 = kron(Dc3,kron(I2,I1));

A1 = kron(I3,kron(I2,Av1));
A2 = kron(I3,kron(Av2,I1));
A3 = kron(Av3,kron(I2,I1));
AV = [A1;A2;A3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DIV  = [DC1,DC2,DC3];

U = sin(pi*xc).*sin(pi*yc).*sin(pi*zc);
u = U(:);
m = ones(size(u));
v = randn(size(m));


a1 = A1*(1./m);
a2 = A2*(1./m);
a3 = A3*(1./m);

Am1   = spdiags(a1,0,size(A1,1),size(A1,1));
Am2   = spdiags(a2,0,size(A2,1),size(A2,1));
Am3   = spdiags(a3,0,size(A3,1),size(A3,1));
Ainv1 = spdiags(1./a1,0,size(A1,1),size(A1,1));
Ainv2 = spdiags(1./a2,0,size(A2,1),size(A2,1));
Ainv3 = spdiags(1./a3,0,size(A3,1),size(A3,1));
A2inv1 = spdiags(1./a1.^2,0,size(A1,1),size(A1,1));
A2inv2 = spdiags(1./a2.^2,0,size(A2,1),size(A2,1));
A2inv3 = spdiags(1./a3.^2,0,size(A3,1),size(A3,1));

Sinv = blkdiag(Ainv1,Ainv2,Ainv3);
S2inv=  blkdiag(A2inv1,A2inv2,A2inv3);

dCdu = @(u,m)(DIV*Sinv*DIV');
dCdm = @(u,m)(DIV*diag(DIV'*u)*S2inv*AV*diag(1./m.^2));

%%  Sensitivities
J = -dCdu(u,m)\dCdm(u,m);
[P,S,V] = svd(J);
s = diag(S);

%{
V = reshape(V(:,5),n1,n2,n3);
J = reshape(J(:,4*nn^2 + 5*nn),n1,n2,n3);

%% Plot
a = squeeze(xc(:,1,1));
[X, Y , Z] = meshgrid(a);

third = round(nn/3);
half =  round(nn/2);

% For plotting u
figure(1)
    xslice = [ a(half) a(2*third) a(end) ];
    yslice = [ a(end) ];
    zslice = [ a(1) a(half) ];
    slice(X,Y,Z,U,xslice,yslice,zslice)
    colorbar;
    title('f(x,y,z) = sin(pi*x)*sin(pi*y)*sin(pi*z)')
figure(2)
    xslice = [ a(1)];
    yslice = [ a(end) ];
    zslice = [ a(1), a(half - 1)  ];
    slice(X,Y,Z,J,xslice,yslice,zslice)
    %caxis([-0.4 0])
    colorbar;
    title('Sensitivity near surface of domain')
figure(3)
    xslice = [ a(half) a(2*third) a(end) ];
    yslice = [ a(end) ];
    zslice = [ a(1) a(half) ];
    slice(X,Y,Z,V,xslice,yslice,zslice)
    colorbar;
    title('Principal Vector V_{end}')
%}
figure(9)
semilogy(1:length(s),s,'.')
title('semilogy plot of eigenvalues')
xaxis('Eigenvalue number')
yaxis('log Eigen value')
%}
% Singular Value Explorer

%
a = squeeze(xc(:,1,1));
[X, Y , Z] = meshgrid(a);

for ii = 1:10
    
Vv = reshape(V(:,ii),n1,n2,n3);
figure(3)
    for jj = 1:length(a)
    xslice = [ a(jj), a(end) ];
    yslice = [ a(end) ];
    zslice = [ a(1)];
    slice(X,Y,Z,Vv,xslice,yslice,zslice)
    colorbar;
    title(sprintf('Principal Vector V_{%i}',ii))
    pause(1)
    end
end
%}
