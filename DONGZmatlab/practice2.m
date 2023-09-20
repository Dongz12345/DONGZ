clc
clear
yalmip('clear');

%% Simulation Environment
Nunits = 4;
Horizon = 24;
a = [0.12 0.17 0.15 0.19];
b = [14.8 16.57 15.55 16.21];
c = [89 83 100 70];
d = [1.2 2.3 1.1 1.1];
e = [-5 -4.24 -2.15 -3.99];
f = [3 6.09 5.69 6.2];
RU = [40 30 30 50];
RD = [40 30 30 50];

Demand = [510 530 516 510 515 544 646 686 741 734 748 760 754 700 686 720 714 761 727 714 618 584 578 544];
pmin = [28 20 30 20];
pmax = [200 290 190 260];

%% Variables
p = sdpvar(Nunits, Horizon);

%% Constraints1
Constraints = [];
for i=1:Horizon
    for j=1:Nunits
    Constraints=[Constraints, pmin(j)<=p(j,i)<= pmax(j)];
    end
end
%% Constraints2
for i=1:Horizon
    for j=1:Nunits
        Constraints=[Constraints, Demand(i)==sum(p(:,i))];
    end
end
%% Constraints3
for i = 1:Horizon-1
    for j=1:Nunits
        if i < Horizon
            Constraints = [Constraints, p(j,i+1)-p(j,i)<=RU(j)];
            Constraints = [Constraints, p(j,i+1)-p(j,i)>=-RD(j)];
        end
    end
end

%% Objective function
objective=0;
for i=1:Nunits
    for j=1:Horizon
    objective = objective+a(i)*p(i,j)^2+b(i)*p(i,j)+c(i);
    end
end
%% Solve
sol = optimize(Constraints, objective);

%% Display Results
p=value(p);
disp(value(p));


