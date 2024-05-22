clear variables
%% Introduction to code

% This model should provide a prediction of the entire race. Everything
% required for the model should be included, with the exception of the
% SolarData.txt and FinalDaySolar.txt files, contained in the SolarData 
% folder. The model includes a lot of extra information that isn't
% needed in the "live" model running on board the ESP32. This includes the
% matrices used in the algorithm, as the algorithm has proven that it is
% best to use more energy, but arrive on time.

%% Advantages / Disadvantages of this model

% Advantages:
%
% •Fast to run code, will be even faster on the live model
%
% •Calculations should cover all forces if they are included in the model
%
% •Model uses time as the dependent variable, which is crucial as the
% vehicle is expected to reach each checkpoint at a specific time
% 
% •Model charges mostly at the first checkpoint, as the following leg is
% the most intensive and also provides flexibility at the next point
%
% •Model calculates the score for every possible outcome, which can be
% cross referenced.
%
% •Model provides variable parameters that should adjust the model to any
% real world changes (such as a different energy usage per day, how much
% extra energy the car can have etc.)
%
% •All required data can be displayed in any format
%
% Disadvantages (and how to improve them):
%
% •It is difficult to predict the wind speed and direction, and so it has
% been assumed to be perpendicular to the car (i.e no effect) as the
% prevailing wind is East to West. Difficult to improve the predicted
% model, but the capability is there for the live model by using live data.
%
% •Slope data is just the angle from point A to B for each leg. This is
% fine for the first and last leg, as they are relatively consistent, but
% for the middle leg, there is a massive increase in slope before a sudden
% descent, and the model may not predict this. To improve, a look-up table
% with slope data can be used (previous slope data was not correct).
% Research into Google Maps/Earth API/Development required.
%
% •Solar Model does not include any cloud cover, which means it always
% assumes ideal conditions. To improve, perhaps average cloud cover can be
% used as a multiplier to get a more accurate result
%
% •Battery model is essentially non-existent (ie. there is no degradation
% or heat effect). Difficult to improve as relevant information is not
% provided, heat model is complicated and will likely make little
% difference. The SoC difference calculation should help to minimise this
% in the real model.

%% Pseudo Code / Overview for predicted model

% Step 1: Initialise the model with fixed and chosen input parameters
%
% Step 2: Calculate the solar energy in for each day
%
% Step 3: Based on the desired ETA, calculate the required average
% velocity, the power required to travel at this speed and the energy used
% for each leg
%
% Step 4: Determine the total amount of energy needed to recharge, charging
% as much as possible at Tennant Creek, so that there is more flexibility
% if the values change
%
% Step 5: Compare the charging and late parameters with the score
% calculation to determine which combination is best for the race
%
% Step 6: Output appropriate measurements

%% Pseudo Code / Overview for real model

%NOTE: The code for the real model will be converted to C, and will be
%edited to remove the large matrices and optimisation. Therefore, this is a
%guide to what is and isn't required
%
% Step 1: Initialise the model with fixed and chosen input parameters
%
% Step 2: Calculate the solar energy in for each day
%
% Step 3: Calculate the average velocity to travel from one destination to
% another to arrive at the desired time (ie no lateness)
%
% Step 4: Calculate the energy required to travel at the average speed
%
% Step 5: Repeat steps 3 and 4 for each leg using updated SoC and extra
% energy values
%
% Step 6: Display relevant information to the display/ output through comms
%% Initialisation

%----------------------------------
% Fixed Parameters
%----------------------------------

m=800; %Mass of car (kg)
a=0; %Acceleration (m/s)
Cd=0.25; %Aero drag coefficient
p=1.18; %Air density (kg/m^3)
vw=0; %Wind velocity (m/s)
alpha=90; %Wind direction relative to forward direction (deg)
Crr=0.006; %Roll coefficient
g=9.81; %Gravity (m/s)

%Slope angles could be more accurate (Task for maybe later)
theta1=0.37; %Slope angle of first leg (deg)
theta2=-0.18; %Slope angle of second leg (deg) 
theta3=-0.17; %Slope angle of third leg (deg)

%----------------------------------
% Variable Parameters
%----------------------------------

%Approximate additional energy to aid in acceleration/differences etc.
%This can be changed after seeing charge after first leg (ie increased or
%decreased depending on extra amount used)
ExtraChargekWh=7.2; %Full charge for 1 hour

%This value is used to slightly increase the average speed for each leg, so
%that there is some leeway (ie the vehicle has time to stop at checkpoints)
%(This value is in km/h)
SpeedIncrease=0.1;

%----------------------------------
% Solar Parameters
%----------------------------------

% Import the solar data for the first 5 days (6-min intervals MAY IMPROVE)
SolarData=readtable('SolarData.txt');
Solar = SolarData{:,:};

% Import table containing Zenith Angle at every minute interval
SolarDataFinal=readtable('FinalDaySolar.txt');
SolarFinal = SolarDataFinal{:,:};

eff = 0.225*0.992; %Efficiency of panel and MPPT
A = 5; %Area of panel (m^2)
Ein1=0; %Initialisation
Ein2=0;
Ein3=0;
Ein4=0;
Ein5=0;
Ein6=0;

%----------------------------------
% Solar Calculations
%----------------------------------

%Calculate energy in for day 1 (10:00-23:54)
for T=100:1:240
    Is1(T)=1050*cosd(Solar(T,1)); %Solar Irradiance Equation
    if(Is1(T)<0) 
        Is1(T)=0; %If the equation is negative, set it to 0 as it does not lose energy
    end
    Ein1=Ein1+eff*A*Is1(T)*6*60; %Calculate the overall energy every 6 mins
end

%Calculate energy in for days 2 to 5 (00:00-23:54)

for T=1:1:240
    Is2(T)=1050*cosd(Solar(T,2)); %Solar Irradiance Equation
    if(Is2(T)<0)
        Is2(T)=0; %If the equation is negative, set it to 0 as it does not lose energy
    end
    Ein2=Ein2+eff*A*Is2(T)*6*60; %Calculate the overall energy every 6 mins
    
    Is3(T)=1050*cosd(Solar(T,3)); %Solar Irradiance Equation
    if(Is3(T)<0)
        Is3(T)=0; %If the equation is negative, set it to 0 as it does not lose energy
    end
    Ein3=Ein3+eff*A*Is3(T)*6*60; %Calculate the overall energy every 6 mins
    
    Is4(T)=1050*cosd(Solar(T,4)); %Solar Irradiance Equation
    if(Is4(T)<0)
        Is4(T)=0; %If the equation is negative, set it to 0 as it does not lose energy
    end
    Ein4=Ein4+eff*A*Is4(T)*6*60; %Calculate the overall energy every 6 mins
    
    Is5(T)=1050*cosd(Solar(T,5)); %Solar Irradiance Equation
    if(Is5(T)<0)
        Is5(T)=0; %If the equation is negative, set it to 0 as it does not lose energy
    end
    Ein5=Ein5+eff*A*Is5(T)*6*60; %Calculate the overall energy every 6 mins
end

% Calculate the day 6 total energy depending on how late the solar car is
% (00:00-11:30->14:00)
for TimeInc=691:841
    Ein=0;
for T=1:1:TimeInc
    Is6(T)=1050*cosd(SolarFinal(T)); %Solar Irradiance Equation
    if(Is6(T)<0)
        Is6(T)=0; %If the equation is negative, set it to 0 as it does not lose energy
    end
    Ein=Ein+eff*A*Is6(T)*60; %Calculate the overall energy minute by minute
end
Ein6(TimeInc-690)=Ein;
end

%----------------------------------
% Time Parameters
%----------------------------------

%tpdh = Time per day hours
%tpds = Time per day seconds

tpdh_full=9; %Full day of driving is from 08:00-17:00
tpds_full=tpdh_full*3600;

tpdh_first=7; %First day is from 10:00-17:00
tpds_first=tpdh_first*3600;

tpdh_last=3.5; %Final day is from 08:00-11:30 (Minimum)
tpds_last=tpdh_last*3600;

battfull=35500*3600; %Full battery energy

%% First Leg

%----------------------------------
% Velocity Calculations
%----------------------------------

tennant_distance=988; % Distance from Adelaide to Tennant Creek

%Calculate the velocity for different ETAs (0 to 90 mins)
for extra=1:91
    hours_to_tennant=tpdh_first+tpdh_full-1.5+((extra-1)/60); % Time from start to expected arrival
    speed_tennant(extra)=SpeedIncrease+tennant_distance/hours_to_tennant; %Average speed required to reach Tennant Creek in time
    v(extra)=speed_tennant(extra)/3.6;
end

%----------------------------------
% Power Calculations
%----------------------------------

%Calculate the power used for each velocity
Pm=v.*(m*a+0.5*Cd*p*(v+vw*cosd(alpha)).^2+Crr*m*g+m*g*sind(theta1)); %Power equation using P=fv
RPM=(v*3.6)/(0.62*pi*60/1000); %RPM of motor at desired velocity
w=((2*pi)/60)*RPM; %RPM to rad/s
effm=(w/(w+0.1765*(Pm/w)))*0.985; %Efficiency of motor at desired velocity
Pout_tennant=Pm/effm; %Power at desired velocity

%----------------------------------
% Energy Calculations
%----------------------------------

%Calculate the total energy used over the first leg (in J)
for i=1:91
SoCTennant(i)=(-Pout_tennant(i))*tpds_first+(-Pout_tennant(i))*(tpds_full-(3600*1.5)+(60*i))+Ein1+Ein2;
end
%% Second Leg

%----------------------------------
% Velocity Calculations
%----------------------------------

coober_distance=2183-tennant_distance; % Distance from Tennant Creek to Coober Pedy

%Calculate the velocity for different ETAs (0 to 30 mins)
for extra=1:31
hours_to_coober=(tpdh_full*2)-0.5+((extra-1)/60); % Time from start to expected arrival
speed_coober(extra)=SpeedIncrease+coober_distance/hours_to_coober; % Average speed required to reach Coober Pedy in time 
v(extra)=speed_coober(extra)/3.6;
end

%----------------------------------
% Power Calculations
%----------------------------------

%Calculate the power used for each velocity
Pm=v.*(m*a+0.5*Cd*p*(v+vw*cosd(alpha)).^2+Crr*m*g+m*g*sind(theta2)); %Power equation using P=fv
RPM=(v*3.6)/(0.62*pi*60/1000); %RPM of motor at desired velocity
w=((2*pi)/60)*RPM; %RPM to rad/s
effm=(w/(w+0.1765*(Pm/w)))*0.985; %Efficiency of motor at desired velocity
Pout_coober=Pm/effm; %Power at desired velocity

%----------------------------------
% Energy Calculations
%----------------------------------

%Calculate the total energy used over the second leg (in J)
for i=1:31
    for j=1:91
        SoCCoober(i,j)=(-Pout_coober(i))*((tpds_full*2)-1800+60*i)+Ein3+Ein4;
    end
end
%% Final Leg

%----------------------------------
% Velocity Calculations
%----------------------------------

adelaide_distance=3020-coober_distance-tennant_distance; % Distance from Coober Pedy to Adelaide

%Calculate the velocity for different ETAs (0 to 150 mins)
for extra=1:151
hours_to_adelaide=tpdh_last+tpdh_full+(extra-1)/60; % Time from start to expected arrival
speed_adelaide(extra)=SpeedIncrease+adelaide_distance/hours_to_adelaide; % Average speed required to reach Adelaide in time
v(extra)=speed_adelaide(extra)/3.6;
end

%----------------------------------
% Power Calculations
%----------------------------------

%Calculate the power used for each velocity
Pm=v.*(m*a+0.5*Cd*p*(v+vw*cosd(alpha)).^2+Crr*m*g+m*g*sind(theta3)); %Power equation using P=fv
RPM=(v*3.6)/(0.62*pi*60/1000); %RPM of motor at desired velocity
w=((2*pi)/60)*RPM; %RPM to rad/s
effm=(w/(w+0.1765*(Pm/w)))*0.985; %Efficiency of motor at desired velocity
Pout_adelaide=Pm/effm; %Power at desired velocity

%----------------------------------
% Energy Calculations
%----------------------------------

%Calculate the total energy used over the final leg (in J)
for i=1:151
    for j=1:31
        for k=1:91
            SoCAdelaide(i,j,k)=(-Pout_adelaide(i))*(tpds_last+60*i)+(-Pout_adelaide(i))*tpds_full+Ein5+Ein6(i);
        end
    end
end
%% Charge Requirements

%----------------------------------
% Charging Parameters
%----------------------------------

sunset_tennant=19.4964; %Sunset time in decimal
sunset_coober=19.5122; %Sunset time in decimal
charge_time=23; %Time the car is allowed to charge until

tennant_time_max=(charge_time-sunset_tennant); %Maximum charging time in Tennant Creek
coober_time_max=(charge_time-sunset_coober); %Maximum charging time in Coober Pedy
tennant_charge_maxkWh = 7.2*tennant_time_max; %Maximum amount of kWh that can be charged per stop
coober_charge_maxkWh = 7.2*coober_time_max;

%----------------------------------
% Predicted Charging Calculations
%----------------------------------

%Calculate the total deficit of energy over the entire race depending on
%lateness
for i=1:151
    for j=1:31
        for k=1:91
            TotalChargeNeededkWh(i,j,k)=(battfull+(SoCTennant(k)+SoCCoober(j,k)+SoCAdelaide(i,j,k)))*-(1/1000)*(1/3600)+ExtraChargekWh; 
        end
    end
end

%Calculate the total amount of charge required at Tennant Creek (note: the
%model aims to charge as much as possible at the first stop, so that there
%is more flexibility at the next stop

for i=1:151
    for j=1:31
        for k=1:91
            if TotalChargeNeededkWh(i,j,k)>tennant_charge_maxkWh 
                TennantChargekWh(i,j,k)=tennant_charge_maxkWh; %If more charge is required for the whole trip, charge for the maximum amount possible
            else
                TennantChargekWh(i,j,k)=TotalChargeNeededkWh(i,j,k);
            end
        end
    end
end

%Calculate the total amount of charge required at Coober Pedy
for i=1:151
    for j=1:31
        for k=1:91
            if TotalChargeNeededkWh(i,j,k)>tennant_charge_maxkWh
                CooberChargekWh(i,j,k)=TotalChargeNeededkWh(i,j,k)-tennant_charge_maxkWh; %Charge whatever is remaining at the second stop
            else
                CooberChargekWh(i,j,k)=0; %If the maximum amount was already charged, no charging needed here
            end
        end
    end
end

%Calculate the SoC Percent after the first run
SoCTennantPercentBefore=((battfull+SoCTennant)/battfull)*100; 

%Calculate the SoC Percent after the first run and charging
for i=1:151
    for j=1:31
        for k=1:91
            SoCTennantPercentAfter(i,j,k)=(((battfull+SoCTennant(k))+(TennantChargekWh(i,j,k)*3600*1000))/battfull)*100;
        end
    end
end

%Calculate the SoC Percent after the second run
for i=1:151
    for j=1:31
        for k=1:91
            SoCCooberPercentBefore(i,j,k)=((((SoCTennantPercentAfter(i,j,k)/100)*battfull)+SoCCoober(j,k))/battfull)*100;
        end
    end
end

%Calculate the SoC Percent after the second run and charging
for i=1:151
    for j=1:31
        for k=1:91
            SoCCooberPercentAfter(i,j,k)=(((((SoCTennantPercentAfter(i,j,k)/100)*battfull)+SoCCoober(j,k))+(CooberChargekWh(i,j,k)*3600*1000))/battfull)*100;
        end
    end
end

%----------------------------------
% Real Charging Calculations
%----------------------------------

%This code is not necessarily useful for the pre-race prediction, but can
%be used in the actual race, so that discrepancies between the predicted
%and real values can be included in the model. Replace the RealSoC values
%with the percent of the car at the end of each leg, so that the difference
%in energy is monitored. This is so that the car does not charge more or
%less than it has to in real time

%User Input Values
RealSoCTennant=SoCTennantPercentBefore(1,1,1);
RealSoCCoober=SoCCooberPercentBefore(1,1,1);

%Calculate the difference between predicted and real
SoCDiffTennant=battfull*(SoCTennantPercentBefore(1,1,1)-RealSoCTennant)/100;
SoCDiffCoober=battfull*(SoCCooberPercentBefore(1,1,1)-RealSoCCoober)/100;
%Calculate the average difference in SoC and add on the amount to the final
%charge
SoCAddAdelaide=(SoCDiffTennant+SoCDiffCoober)/2;

%Same equation as before but with the changes included
TotalChargeNeededkWhRealTennant=(battfull+(SoCTennant(1)+SoCCoober(1,1)+SoCAdelaide(1,1,1)+SoCDiffTennant+SoCDiffCoober+SoCAddAdelaide))*-(1/1000)*(1/3600)+ExtraChargekWh; 

%% Score Algorithm
%----------------------------------
% Initial Score Parameters
%----------------------------------
distance=3020; %Total Distance of Race (lower if end not met)
D=2*distance; %Passenger-km score (2-Seater vehicle)
P=1; %Practicality score, assume 1 for calculations, in reality will be less
d=0; %Assume no penalties

%----------------------------------
% Score Calculations
%----------------------------------

%Calculate the total score for all possibilities (more charging, less time;
%less charging, more time)

%Note that this does not need to be included in the hardware solution as
%the first solution (ie no lateness) gives the highest score, so no need to
%waste calculation time
for i=1:151
    for j=1:31
        for k=1:91
            Score(i,j,k)=(D/TotalChargeNeededkWh(i,j,k))*P*0.99^(i+j+k+d);
        end
    end
end

%Calculate the max score out of all scores, and its index
[MaxScore,I] = max(Score,[],"all","linear");
[TimeAdelaide, TimeTennant, TimeCoober] = ind2sub(size(Score),I); %Find the late times for the max score

%----------------------------------
% Output
%----------------------------------

fprintf('The most score efficient method is as follows:\n');
fprintf('The vehicle must arrive at Tennant Creek %d minutes late, Coober Pedy %d minutes late and Adelaide %d minutes late\n\n',TimeTennant-1,TimeCoober-1,TimeAdelaide-1);
fprintf('Between Darwin and Tennant Creek, the solar car must travel at an average speed of %.2fkm/h\n\n',speed_tennant(TimeTennant));
fprintf('To travel an average speed of %.2fkm/h between Tennant Creek and Coober Pedy, the car will need to charge %.2fkWh (for %.2f hours) at Tennant Creek\n\n',speed_coober(TimeCoober), TennantChargekWh(TimeTennant,TimeCoober),TennantChargekWh(TimeTennant,TimeCoober)/((30*240)/1000));
fprintf('The SoC will go from %.2f%% before charging to %.2f%% after charging in Tennant Creek\n\n',SoCTennantPercentBefore(TimeTennant),SoCTennantPercentAfter(TimeTennant,TimeCoober,TimeAdelaide));
fprintf('To travel an average speed of %.2fkm/h between Coober Pedy and Adelaide, the car will need to charge %.2fkWh (for %.2f hours) at Coober Pedy\n\n',speed_adelaide(TimeAdelaide), CooberChargekWh(TimeTennant,TimeCoober,TimeAdelaide),CooberChargekWh(TimeTennant,TimeCoober,TimeAdelaide)/((30*240)/1000));
fprintf('The SoC will go from %.2f%% before charging to %.2f%% after charging in Coober Pedy\n\n',SoCCooberPercentBefore(TimeTennant),SoCCooberPercentAfter(TimeTennant,TimeCoober,TimeAdelaide));
fprintf('Total Charge will be %.2fkWh, giving a final score of %.2f\n',TotalChargeNeededkWh(TimeTennant,TimeCoober,TimeAdelaide),MaxScore);
