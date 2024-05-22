clear variables

SolarData=readtable('SolarData.txt');

eff = 0.225*0.992;
A = 5;
Ein1=0;
Ein2=0;
Ein3=0;
Ein4=0;
Ein5=0;
Ein6=0;

Solar = SolarData{:,:};

for T=100:1:240
    Is1(T)=1050*cosd(Solar(T,1));
    if(Is1(T)<0)
        Is1(T)=0;
    end
    Ein1=Ein1+eff*A*Is1(T)*6*60;
end

for T=1:1:240
    Is2(T)=1050*cosd(Solar(T,2));
    if(Is2(T)<0)
        Is2(T)=0;
    end
    Ein2=Ein2+eff*A*Is2(T)*6*60;
    
    Is3(T)=1050*cosd(Solar(T,3));
    if(Is3(T)<0)
        Is3(T)=0;
    end
    Ein3=Ein3+eff*A*Is3(T)*6*60;
    
    Is4(T)=1050*cosd(Solar(T,4));
    if(Is4(T)<0)
        Is4(T)=0;
    end
    Ein4=Ein4+eff*A*Is4(T)*6*60;
    
    Is5(T)=1050*cosd(Solar(T,5));
    if(Is5(T)<0)
        Is5(T)=0;
    end
    Ein5=Ein5+eff*A*Is5(T)*6*60;
end

for T=1:1:115
    Is6(T)=1050*cosd(Solar(T,6));
    if(Is6(T)<0)
        Is6(T)=0;
    end
    Ein6=Ein6+eff*A*Is6(T)*6*60;
end

