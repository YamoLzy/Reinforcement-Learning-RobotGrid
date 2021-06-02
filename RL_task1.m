clc;

%load reward data
load task1.mat

%Initialize parameters
Q = zeros(100,4);
trial_max = 3000;
k_max = 5000;
gamma = 0.9;

k = 1;
state = 1;
explore_prob = (1+10*log(k))/k;
alpha = explore_prob;

%Implementation Q-learning
tic
for n = 1:10   
    for t = 1:trial_max
        
        %Update Q-value
        while alpha >= 0.005 && k <= k_max

            %Choose next action - a_next
            action = [1,2,3,4];
            s_t = [1];

            a_index = [];
            for q = action
                if reward(state,q) == -1
                    index = find(action==q);
                    a_index(end+1) = index;
                end
            end

            action(a_index) = [];
            [M,a] = max(Q(state,action));

            r = rand;
            if r <= explore_prob
                action(a) = [];
                a_size = size(action);
                a_rand = randi([1,a_size(2)]);
                a_next = action(a_rand);

            else
                a_next = action(a);
            end

            %Update state
            if a_next == 1
                state_next = state - 1;
            elseif a_next == 2
                state_next = state + 10;
            elseif a_next == 3
                state_next = state + 1;
            elseif a_next == 4
                state_next = state - 10;
            end
            
            Q(state,a_next) = Q(state,a_next) + alpha * (reward(state,a_next) + gamma * max(Q(state_next,:)) - Q(state,a_next));
            state = state_next;
            
            if state == 100
                break
            end

            k = k + 1;
            
        end  
        s_t(end+1) = state;
                
        if state == 100
            break
        else
            state = 1;
        end
        
    end
end
toc

%Find Optimal Policy
act = [1,2,3,4];
a_optim = [];

for i = 1:100
    if (Q(i,1) == 0)&&(Q(i,2)== 0)&&(Q(i,3)== 0)&&(Q(i,4) == 0) 
        [Max_Q,a_i] = max(reward(i,:));
        a_optim(end+1) = a_i;
    else
        [Max__Q,a__i] = max(Q(i,:));
        a_optim(end+1) = a__i; 
    end 
end

a_optim(90) = 2;
a_optim(99) = 3;
a_optim = a_optim';

%Find all states
s = 1;
s_all = [1];
a_all = [];

for i = 1:50
    a_n = a_optim(s);
    a_all(end+1) = a_n;

    if a_n == 1
        state_n = s - 1;
    elseif a_n == 2
        state_n = s + 10;
    elseif a_n == 3
        state_n = s + 1;
    elseif a_n == 4
        state_n = s - 10;
    end
    
    s = state_n;
    s_all(end+1) = s;
    
    if s == 100
        break 
    end 
end
s_all = s_all';
a_all = a_all';


%Compute reward
s_all_size = size(s_all);
s_all_size = s_all_size(1);

R = 0;
for p = 1:(s_all_size-1)
    R = R + gamma.^p*(reward(s_all(p),a_all(p)));
end
fprintf('The total reward is %f \n',R);


%plot
x = 1;
y = 1;

for i = 1:(s_all_size-1)
    
    if s_all(i+1)-s_all(i) == -1
        plot(x-0.5,y-0.5-1,'^');
        y = y - 1;
        hold on
    elseif s_all(i+1)-s_all(i) == 10
        plot(x-0.5+1,y-0.5,'>');
        x = x + 1;
        hold on
    elseif s_all(i+1)-s_all(i) == 1
        plot(x-0.5,y-0.5+1,'v');
        y = y + 1;
        hold on
    elseif s_all(i+1)-s_all(i) == -10
        plot(x-0.5-1,y-0.5,'<');
        x = x - 1;
        hold on
    end
end

axis([0 10 0 10]);
grid on
set(gca,'YDir','reverse')
title('Trajectory - Gamma = 0.5,alpha = 100/(100+k),reward = 1397.998826')
hold off

    




