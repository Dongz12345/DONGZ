clc
clear
%% Simulation Environment
count7 =0;
count8 =0;
a7 = [repmat(1, 1, 19), repmat(2, 1, 30), repmat(3, 1, 35), repmat(4, 1, 15), repmat(5, 1, 1)];
fprintf('\n');
a8 = [repmat(1, 1, 16), repmat(2, 1, 20), repmat(3, 1, 35), repmat(4, 1, 25), repmat(5, 1, 4)];
b = [13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13];

if exist('count_list.mat', 'file') ==2
    load('count_list.m');
else
    count_list7 = [];
    count_list8 = [];
end

for i = 1:20
    
    fprintf('-----------------------\n');
    fprintf('7-level re-roll: %d\n', i);
    fprintf('-----------------------\n');
      
    for j = 1:5
        randomIndex = randi(length(a7)); % 무작위 인덱스 생성
        random_a7 = a7(randomIndex); % 무작위 요소 선택
    
        disp(random_a7); % 무작위로 선택된 요소 출력
        
        fourCount7 = sum(random_a7 == 4); % 4의 개수
        if fourCount7 >= 1
            count7 = count7+1;
            randomIndex_b7 = randi(length(b)); % 랜덤한 인덱스 선택
            b(randomIndex_b7) = b(randomIndex_b7) - fourCount7; % 선택된 인덱스의 값을 1 감소
       
        end
        if sum(b<=10) == 2
            fprintf('two 2-star 4cost unit selled\n')
            break;
        end
    end 
end

b = [13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13];
for i = 1:20
    fprintf('-----------------------\n');
    fprintf('8-level re-roll: %d\n', i);
    fprintf('-----------------------\n');
      
    for j = 1:5
        randomIndex = randi(length(a8)); % 무작위 인덱스 생성
        random_a8 = a8(randomIndex); % 무작위 요소 선택
    
        disp(random_a8); % 무작위로 선택된 요소 출력
        
        fourCount8 = sum(random_a8 == 4); % 4의 개수
        if fourCount8 >= 1
            count8 = count8+1;
            randomIndex_b8 = randi(length(b)); % 랜덤한 인덱스 선택
            b(randomIndex_b8) = b(randomIndex_b8) - fourCount8; % 선택된 인덱스의 값을 1 감소
        end
        if sum(b<=10) == 2
            fprintf('two 2-star 4cost unit selled\n')
            break;
        end
    end 
end

count_list7 = [count_list7, count7]; % count를 저장
count_list8 = [count_list8, count8]; % count를 저장
save('count_list.m', 'count_list7');
save('count_list.m', 'count_list8');

disp(b);
fprintf('7-level re-roll count : %d\n', count7);
fprintf('8-level re-roll count : %d\n', count8);
avg_count7 = mean(count_list7);

%% Parameters


%% Variables
x = sdpvar(2,1);


%% Constraints
Constraints = [];
Constraints = [Constraints, x(1)>=0];
Constraints = [Constraints, x(2)>=0];




%% Objective function


%% Solves

%% Results


