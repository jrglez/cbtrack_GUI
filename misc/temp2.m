% Calculates te values of d an V on the lower mantle so there is jump of an
% order of magnitude between the upper and the lower mantle dn the lower
% mantle's viscosity si constant.

%%% Viscosity structure using  Billen's coeficients %%%
clear 
close all
d=[1e4, 0, 4e4]; p=[3,0,3]; A0=[0.285,2.57e-20,0.285]; Coh=[1000,1000,1000]; r=[1,1.2,1]; F2=[0.33333,0.30079,0.33333];n=[1,3.5,1]; A=F2.*(d.^p./(A0.*Coh.^r)).^(1./n); 

e2=1e-15;
E=[335000,520000,335000];
V=[4e-6,11e-6,1.5e-6];
R=8.3145;

% Dislocation and diffusion creep BG viscosity (at 250 km)
eta_df_250=2e20;
eta_ds_250=2e20;

%Pressure (Using Turcotte's aproximation)
z=(0:1000:1.5e6)';
rho0=3400;
g=9.81;
B=4.3e-12;

P=-(1/B)*log(1-rho0*g*B.*z);

% Calculate the temperature
temp_mod=input('1) HSCM, 2) GDH1: ');
if temp_mod==1 %Half Space Temperature
    Tm=1400+273; T0=273; k=1e-6; t=150e6*365*24*3600;
    T=(Tm-T0)*erf(z./(2*sqrt(k*t)))+T0+z*3e-4;

else %     T(T>Tm-1)=T(T>Tm-1)+(z(T>Tm-1)-z(T>Tm-1)))*3e-4;
    % Temperature (plate like + adiabatic)  
    TL=1450; L=9.5e4; Cp=1300; k=3.2; alfa=3.7e-5; t=60e6*365*24*3600;
    T=zeros(size(z));
    T(1:95)=TL*z(1:95)/L;
    for i=1:10
        T(1:95)=T(1:95)+(TL*2/(i*pi))*sin(i*pi*z(1:95)/L)*exp(-i^2*pi^2*k*t/(rho0*Cp*L^2));    
    end

    T(96:end)=TL*exp(g*alfa*(z(96:end)-L)/Cp);
    T=T+273;
end

% Calculate the whater content to obtain the desired dislocation viscosity
% at 250 km
Coh(:)=((F2(2)^n(2)/(A0(2)*eta_ds_250^n(2)))*e2^(1-n(2))*exp((E(2)+P(251)*V(2))/(R*T(251))))^(1/r(2));

% Calculate the grain size to obtain the desired diffusion viscosity at
% 250 km
d(1)=((eta_df_250*A0(1)*Coh(1)/F2(1))*exp(-(E(1)+P(251)*V(1))/(R*T(251))))^(1/p(1));

% Recalculate the Preexponential coeficient.
A=F2.*(d.^p./(A0.*Coh.^r)).^(1./n);

    % Viscosity. 1 is linear for the upper mantle, 2 is non-linear for the
% upper mantle and 3 y linear for the lower mantel
for i=1:3
eta(:,i)=A(i)*e2^((1-n(i))/n(i))*exp((E(i)+P*V(i))./(n(i)*R*T));
end

eta_comp=eta(:,1).*eta(:,2)./(eta(:,1)+eta(:,2)); % Composite viscosity for the upper mantle
eta_lm=eta(:,3)/2; % Compostite of two linear viscosities for the upper mantle 

% m, b, m_p and b_p are used to aproximate pressure and temperature to
% linear functions from T(671) to T(end) and from P(671) to T(end)
m=(T(end)-T(671))/530000;
b=T(671)-m*z(671);
m_p=(P(end)-P(671))/530000;
b_p=P(671)-m_p*z(671);

V(3)=m*E(3)/(b*m_p-m*b_p);
    
    % Same as above but assuming linerar functions from Taylor expanssion
    % at the surface (eta_lm is almos constant)
    %V(3)=E(3)*alfa/(rho0*Cp*(1-(g*alfa*L/Cp)));

% Lower mantle's NEW preexponential factor son there is a viscosity jump on
% the U-L mantle boundary
eta(:,3)=A(3)*e2^((1-n(3))/n(3))*exp((E(3)+P*V(3))./(n(3)*R*T));
eta_lm=eta(:,3)/2; % Compostite of two linear viscosities for the upper mantle 

A_lm=A(3)*10*eta_comp(671)/eta_lm(671);
d_lm=(A_lm*A0(3)*Coh(3)^r(3)/F2(3))^(1/p(3)); %Corresponding grain size.
d(3)=d_lm; A(3)=A_lm; 

eta(:,3)=A(3)*e2^((1-n(3))/n(3))*exp((E(3)+P*V(3))./(n(3)*R*T));
eta_lm=eta(:,3)/2;

eta_def=eta_comp;
eta_def(671:end)=eta_lm(671:end);

plotyy(z(eta_def<1e25),log10(eta_def(eta_def<1e25)),z,T)

