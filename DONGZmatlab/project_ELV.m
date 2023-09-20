clc
clear
yalmip('clear');

%% Simulation Environment
num_elements = 10;  % 이용자 수 설정
num_elevators = 3;  % 엘리베이터 수 설정
min_value = 2;
max_value = 10;

destination = randi([min_value, max_value], 1, num_elements); % 무작위로 목표 층 설정
disp(destination);
%% Variables
x = binvar(num_elements, num_elevators, 'full'); % 이용자가 엘리베이터에 탑승하는지 여부

%% Constraints
Constraints = [];
for i = 1:num_elements
    Constraints = [Constraints, sum(x(i, :)) == 1]; % 각 이용자는 한 대의 엘리베이터에만 탑승
end

for j = 1:num_elevators
    Constraints = [Constraints, sum(x(:, j)) <= floor(num_elements / num_elevators) + 1]; % 엘리베이터 용량 제한
end

%% Objective function (최소화할 목적 함수)
time_objective = 0;
for j = 1:num_elevators
    for i = 1:num_elements
        time_objective = time_objective + destination(i) * x(i, j);
    end
end

%% Solve
options = sdpsettings('solver', 'lpsolve'); 
optimize(Constraints, time_objective, options);

%% 결과 출력
fprintf('엘리베이터 배치 결과: \n');
for j = 1:num_elevators
    passengers = find(value(x(:, j)));
    fprintf('%d번 엘리베이터: 이용자 %s\n', j, num2str(passengers));
end