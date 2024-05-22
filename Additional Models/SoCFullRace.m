clear variables
%% Parameters
%----------------------------------
% Car body fixed
%----------------------------------
m=800; %Mass of car (kg)
Cd=0.25; %Aero drag coefficient
a=0; %Acceleration (m/s)
p=1.18; %Air density (kg/m^3)
Crr=0.006; %Roll coefficient
g=9.81; %Gravity (m/s)
%----------------------------------
% Car body variable
%----------------------------------
vw=0; %Wind velocity (m/s)
alpha=90; %Wind direction relative to forward direction (deg)
theta=0; %Slope angle (deg)
vel=0;
%----------------------------------
% Solar and Battery fixed
%----------------------------------
battfull=35500*3600;
SoC = 0;
per = 0;
%----------------------------------
% Race parameters
%----------------------------------
 tpdh_full=9; % Time per day hours (tpdh) of full day (08:00-17:00)
tpds_full=tpdh_full*3600; % Time per day seconds (tpds) of full day (08:00-17:00)

tpdh_first=7; % Time per day hours (tpdh) of first day (10:00-17:00)
tpds_first=tpdh_first*3600; % Time per day seconds (tpds) of first day (10:00-17:00)

tpdh_last=3.5; % Time per day hours (tpdh) of last day (08:00-11:30)
tpds_last=tpdh_last*3600; % Time per day seconds (tpds) of last day (08:00-11:30)

coober_distance=2183; % Distance from Darwin to Coober Pedy
hours_to_coober=tpdh_first+tpdh_full*3-0.5; % Time from start to expected arrival

speed_coober=coober_distance/hours_to_coober % Average speed required to reach Coober Pedy in time 

adelaide_distance=3020; % Distance from Darwin to Adelaide
hours_to_adelaide=tpdh_first+tpdh_last+tpdh_full*4; % Time from start to expected arrival

speed_adelaide=adelaide_distance/hours_to_adelaide % Average speed required to reach Adelaide in time

%% Speed vs SoC
for v=1:0.1:30.5
%----------------------------------
% Body Power Calculation
%----------------------------------
Pm=v*(m*a+0.5*Cd*p*(v+vw*cosd(alpha))^2+Crr*m*g+m*g*sind(theta));
RPM=(v*3.6)/(0.62*pi*60/1000);
w=((2*pi)/60)*RPM;
effm=(w/(w+0.1765*(Pm/w)))*0.985; %Both motor and inverter efficiency
Pout=Pm/effm;
%----------------------------------
% Solar power averages
%----------------------------------
Pin_full=903.5394; %Average power for full day (08:00-17:00) (Alice Springs as solar reference)
Pin_first=945.8257; %Average power for first day (10:00-17:00) (Darwin as solar reference)
Pin_last=875.5226; %Average power for last day (08:00-11:30) (Adelaide as solar reference)

SoCnew=battfull+(Pin_first-Pout)*tpds_first+(Pin_full-Pout)*tpds_full*4+(Pin_last-Pout)*tpds_last; %SoC calculation for all days
SoCper=(SoCnew/battfull)*100; %SoC as a percent
if SoCper>100
    SoCper=100;
elseif SoCper<0
    SoCper=0;
end

SoC=[SoC SoCnew];
per=[per SoCper];
vel=[vel v];

end

SoC(:,1) = [];
per(:,1) = [];
vel(:,1) = [];
vel=vel*3.6;
figure
plot(vel,per)
xlabel('Speed (km/h)');
ylabel('State-of-Charge (%)');
title ('Constant Speed vs State-of-Charge for the whole race')
xlim([0 110])
grid('on')