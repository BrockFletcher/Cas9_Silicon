%%Electrostatic Calculator
%%Kappa=1/Debye length
format long eng
z=1;%valence of symetry electrolyte
e=1.6022E-19; %Charge on a proton [C]
epzero=8.8542E-12; %Permittivity of a vacuum [C^2/(N*m^2)]
eprwater=78; %relative permittivity of water at 20 degC
k=1.38065E-23; %[J/K] Boltzmann's constant
avo=6.022E23;
T=293.15; %Temp in Kelvin
Cdiwater= 1E-7; %mol/m3, concentration of ions in solution
cion=[1E-3, 5E-3, 1E-2, 2E-2, 5E-2, 1E-1, 1.5E-1];
Psizero=25; %milivolts
a=125; % radius of particle in nm
r=[125:1:1000]';
kappasq=((2*z^2*e^2*(cion))/(epzero*eprwater*k*T));
debye=1E9*((1000*avo*(kappasq)).^(-0.5)); %in [nm]
kappa1=(debye.^(-1));
Psi=Psizero.*(a./r).*exp(-kappa1.*(r-a));
DebyeChart=[cion,debye];
DebyeLabels=['Ion Conc. [M]','Debye Length [nm]'];

%array2table(cion, 'debye length')


%%Charge in Pore
L=20; %in [nm]
x=[-L/2:(0.001*L):-0.1,0.1:(0.001*L):L/2]';

PsiPore=((((((Psizero.*(exp(kappa1.*(L/2))))-(Psizero.*(exp(kappa1.*(-L/2))))))./((exp(kappa1.*(L)))-(exp((-kappa1).*(L)))))).*(((exp(kappa1.*(x))))))...
   +((((((Psizero.*(exp(kappa1.*(L/2))))-(Psizero.*(exp(-(kappa1.*(L/2)))))))./((exp(kappa1.*(L)))-(exp((-kappa1).*(L)))))).*(((exp(kappa1.*(-x))))));

PsiPore2=Psizero.*((cosh(x./debye))./(cosh(L./debye)));

PsiPoreCircle=((L/2)./(abs(x))).*PsiPore;
%RhoPore=(epzero*eprwater*Psizero)*((1-exp(-L.*kappa1))/(1+exp(-L.*kappa1)))
test=colormap(winter(length(cion)));
colororder(test)

figure(1)
plot(cion,debye,'o-');
title('debye length vs. NaCl concentration')
xlabel('Salt conc. [Molarity]')
ylabel('debye length [nm]')
axis([0 0.15 0 10])
a=cion'; b=num2str(a); c=cellstr(b);
text(cion,debye,c);

figure(2)
plot(Psi)
title('Electric Field vs. distance from particle vs. Molarity')
xlabel('Distance (nm)')
xlim([0 20])
ylabel('Charge (mV)')
ylim([0 30])
a=cion'; b=num2str(a);
leg=legend(b);
title(leg,'Ion Conc. [M]')

figure(3)
p=plot(x,PsiPore,'LineWidth',4);
set(gca,'fontsize',18,'fontweight','bold')
axis([-L/2 L/2 0 Psizero+0.1*Psizero]);
title('Electric Field Within Pore')
ylabel('Charge (mV)')
xlabel('Distance from center (nm)')
a=1000.*cion'; b=num2str(a);
leg=legend(b,'Location','Northeastoutside');
title(leg,'NaCl [mM]')



figure(4)
plot(x,PsiPoreCircle)
axis([-L/2 L/2 0 Psizero+0.1*Psizero]);
title('Electric Field within Cylindrical Pore')
ylabel('Charge(mV')
xlabel('Distance from center (nm)')
a=cion'; b=num2str(a);
leg=legend(b);
title(leg,'Ion Conc. [M]')

