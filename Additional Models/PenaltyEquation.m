clear variables

%% Parameters
%----------------------------------
% Initial Score Parameters
%----------------------------------
distance=3020; %Total Distance of Race (lower if end not met)
D=2*distance; %Passenger-km score (2-Seater vehicle)
E=1; %Nominal External Energy (No charge gives large score, but set to 1 to avoid 1/0)
P=1; %Practicality score, assume 1 for calculations, in reality will be less
late=0; %Initially, assume no lateness
d=0; %Assume no penalties
S=0; %Setup
St=0; %Setup
SMax=6020; %Maximum score (provided E=1)
Estart=1/((240*30)/1000); %Value of E to start at max
%----------------------------------
% Charging Parameters
%----------------------------------
sunset_tennant=19.4964; %Sunset time in decimal
sunset_coober=19.5122; %Sunset time in decimal
charge_time=23; %Time the car is allowed to charge until
kWhUsed = 0; %Setup
time=0; %Setup

tennant_time_max=(charge_time-sunset_tennant); %Maximum charging time in Tennant Creek
coober_time_max=(charge_time-sunset_coober); %Maximum charging time in Coober Pedy

%----------------------------------
% Late Parameters
%----------------------------------
max_time_tennant = 90;
max_time_coober = 30;
max_time_adelaide = 150;

%% Charging Penalty
for i=Estart:(tennant_time_max+coober_time_max)/100:tennant_time_max+coober_time_max
    E=((240*30)/1000)*i; %Calculate E in kWh from time(i)
    Snew=(D/E)*P*0.99^(late+d); %Calculate the score
    S=[S (Snew/SMax)*100]; %Give S as a percentage
    kWhUsed=[kWhUsed E];
end

S(:,1)=[];
kWhUsed(:,1)=[];

figure
plot(kWhUsed,S)
xlabel('Charge amount (kWh)');
ylabel('Score Percentage (%)');
title ('Amount of recharge used vs score percentage with no penalties')
grid('on')
xlim([0 50.331318400000000])
ylim([0 100])

%% Late Penalty

%----------------------------------
% Reinitialise Score Parameters
%----------------------------------
distance=3020;
D=2*distance;
E=1;
P=1;
d=0;

for i=1:max_time_tennant+max_time_coober+max_time_adelaide
    Snew=(D/E)*P*0.99^(i+d); %Calculate the score dependent on time
    St=[St (Snew/SMax)*100]; %Give S as a percentage
    time = [time i];
end

time(:,1)=[];
St(:,1)=[];

figure
plot(time,St)
xlabel('Late time (min)');
ylabel('Score Percentage (%)');
title ('Late time vs score percentage with no penalties')
grid('on')
xlim([0 270])