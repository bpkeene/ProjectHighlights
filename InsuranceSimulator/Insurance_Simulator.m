%% Brian, Andrew, Jiatai, Kevin, Stephen, Jeffrey
% MMFE Group 6 Project - Why is Warren Buffet So Rich?
%
% MATLAB author: Brian Keene
clc
%% Set up the array of living people.

n = 1000; % the size of our population

% create the distribution of ages
% We will simulate 1,000,000 New Yorkers between the ages of 30-65.
% A population pyramid can be found at 
% https://www.census.gov/population/projections/data/statepyramid.html
% {30-34: 6.5;
% 35-39: 6.4;
% 40-44: 7.1;
% 45-49: 7.6;
% 50-54: 7.3;
% 55-59: 6.2;
% 60-64: 5.4}
percents = [.065 .064 .071 .076 .073 .062 .054]; %
normal_percent = percents./(sum(percents)); % normalize to 100%

% create n random numbers distributed uniformly across the range
% [0, n] and this will be our random population
randpop = (n*rand(n,1)); % n random numbers
x_np_ind = length(normal_percent);
x_np_data = zeros(size(normal_percent)); % initialize data storage

% make the age ranges cumulative distributions so that the randpop can be
% indexed - the cumulative normal percents will form data points fit to a
% spline, allowing for more detailed analysis of age brackets
for i = 1:x_np_ind
    x_np_data(i) = sum(normal_percent(1:i));
end
% Interpolate the age ranges to further divide the age brackets in to
% integer values by implementing cubic splines
x_np_data = [0 x_np_data] * n; % insert 0 for the spline starting point
x = linspace(30,65,8); % age range (30:64.99999....)
cubic_spline = spline(x,[x_np_data]);

n_begin = 30; %starting age
n_end = 65; % end age + 1
n_int = 36; % number of integer values across age range
xplot = linspace(n_begin,n_end,n_int) ;

figure(1)
plot(x,x_np_data,'o',xplot,ppval(cubic_spline,xplot),'-')
title('Cumulative Age Distribution for 1,000,000 Men in New York')
xlabel('Age (years)')
ylabel('Cumulative Number of People Age 30:x')
legend('Census Data Points','Fitted Spline','Location','SouthEast')

age_ind_segments = ppval(cubic_spline,xplot);

ordered_pop = sort(randpop); % sort in ascending order
index_cutoff = zeros(size(35,1)); %
for i = 1:(length(age_ind_segments)-1)
    index_cutoff(i) = find(ordered_pop <= age_ind_segments(i+1),1,'last');
end

% Extract the number of people in the age group
n_people_each_age = zeros(size(index_cutoff));
for i = 1:(length(index_cutoff))
    if i == 1
      n_people_each_age(i) = index_cutoff(i);
    elseif i>1
      n_people_each_age(i) = index_cutoff(i)-index_cutoff(i-1);
    end
end
n_people_each_age; % matrix of number of people at each age

figure(2)
plot(xplot(1:35),n_people_each_age,'xb')
title('Number of People at Each Age - Initial Data')
xlabel('Age (years)')
ylabel('Number of People')
axis([n_begin n_end-1 0 1.1*max(n_people_each_age)])
legend('Number of People')

% create the individual people
age_matrix = zeros(size(randpop));  %initialize
for k = 1:length(index_cutoff)
    if k == 1
        age_matrix(1:index_cutoff(1)) = xplot(1);
    elseif k>1
        age_matrix(index_cutoff(k-1):((index_cutoff(k))))=xplot(k);
    end
end

% import data from Social Security administration to interpolate a rate of 
% death as a function of age
% which may be found at http://www.ssa.gov/oact/STATS/table4c6.html
load('SSI_data.mat')

% let's correct the indices:
exact_age = exact_age(2:end);
life_expectancy = life_expectancy(2:end);
number_of_lives = number_of_lives(2:end);
pdeath_each_age = pdeath_each_age(2:end);

% SSI_data.mat contains the following data:
% column 1: integer age values ('exact_age')
% column 2: probability of death in the next year at current age
% ('pdeath_each_age')
% column 3: population remaining, out of 100000 ('number_of_lives')
% column 4: average remaining number of years expected prior to death for a
% person at that exact age ('life_expectancy')
figure(3)
plot(exact_age,pdeath_each_age,'k')
title('Social Security Data - Probability of Death vs Age')
xlabel('Age (years)')
ylabel('Probability of Death')

%% Setting up the Simulation

% we can start with an initial fund of ~ $10 billion dollars (or something
% comparable - 'law of large numbers'
tfinal = 500; % the length of the simulation, t_0 = 1
tlength = tfinal - 1;
% An array that denotes the state of the person
AliveState = ones(n,1);
% AliveState Key:
% 0 : dead
% 1 : Alive & Healthy
% 2 : removed by screening (old age or sickness at years_in_sim = 10)
% 3 : Sick, but not identified (allowed to continue in simulation)

% Functions for Sickness
% Data was obtained from cdc.gov
% http://www.cdc.gov/nchs/fastats/heart-disease.htm
% All sickness was attributed to heart disease
% probability of getting sick vs age
% CDC Data provided the morbidity data - see 'CDC_Data.m'
load('CDC_Data_Workspace.mat')
% variables we need are:
% heart_disease_frequency
% death_heart_disease

psick_function = heart_disease_frequency;

risk_factor = 5; % sick people are 5 times as likely to die as healthy in 
% the next year (completely arbitrary)

% probability of dying if sick
psick_death = min(risk_factor*(pdeath_each_age),1); %probability of dying cannot exceed 1

psick_each_age = psick_function(exact_age);
phealthy_each_age = 1-psick_each_age;
% now, find the probability of death for healthy people by subtracting the
% probability of being sick multiplied by the probability of dying to find
% the adjusted risk of dying as a healthy person.
adjusted_pdeath_healthy = pdeath_each_age-(psick_each_age.*psick_death);

% these are the random numbers associated with the dying
random_death_store = zeros(n,tfinal-1);

% now, initialize storage for the probability of dying - this is the
% probability at each age of dying according to SSI data
pdeath_simulation = zeros(n,tfinal-1);
pdeath_this_year = zeros(n,1);
death_by_person = zeros(n,1);
death_by_person_simulation = zeros(n,tfinal-1);
death_count = zeros(tfinal,1);
payout = -500000; % 500,000 payout

% Completely Arbitrary:
p_ID_Sick = .50; % probability of screening a sick person out at beginning

years_in_sim_store = zeros(n,tlength);
screen_counter_store = zeros(tfinal,1);
each_year_people_count = zeros(tfinal,1);
age_matrix_store = zeros(n,tfinal);
% initialize the year counter
t = 1; % this is t_0
years_in_sim = zeros(n,1);
%round(0+9*rand(n,1)); % initialize for the first iteration

% birth function for age given a random number
f1 = ppval(cubic_spline,xplot)./n; % the population distribution normalized
% such that its interval is [0 1] with different sized 'bins' for each
% integer age

age = @(x) find(x-f1<=0,1,'first') + 28; % index mismatch
% above function will be used when creating people during the simulation to
% keep the number of people at the beginning of the year at 1M

% First, we need to curate the initial AliveState Matrix - introduce sick
% people, check if we find them, and then replace those who we found with
% healthy people of the same age.

initial_p_sick = rand(n,1); % a number denoting whether they are sick or not
initial_find_sick = rand(n,1); % do we screen them out?

p_sick = initial_p_sick - psick_function(age_matrix);

% determine the number of sick people in the initial population
for i = 1:n;
    if p_sick(i)<=0;
        if p_ID_Sick - initial_find_sick(i)<=0
            AliveState(i) = 3; % sick person enters the simulation
        else
            AliveState(i) = 1; % the person is healthy (false positive)
        end
    end
end

AliveStateNew = AliveState;

%% Simulation

while t<tfinal,
    AliveState = AliveStateNew; % AliveState denotes the beginning AliveState of
    % each person at each year in the simulation. AliveStateNew will be
    % altered during each iteration of the 'while' loop
    
    % move the counter for years_in_sim forward by 1 for every person
    years_in_sim = years_in_sim + ones(n,1); 
    
    % assorted random numbers for various procedures
    random_death = rand(n,1); % coin flip deciding if they die or not
    random_birth = rand(n,1); % for creation of new people
    random_sick  = rand(n,1); % for determination of sickness
    random_find  = rand(n,1); % do we identify whether the person is sick or not?
    
    counter = 0; % count the deaths - resets each iteration of t
    screen_counter = 0; % unique people removed and replaced via screening
    
    % we need to replace the dead people
    dead_people = find(AliveState == 0);
    for i = 1:length(dead_people)
        k = dead_people(i); % the index from 1:n assigned to that person
        % we need to assign them a new age
        age_matrix(k) = age(random_birth(k));
        
        % determine if they are sick or not
        probability_sick = random_sick(k) - psick_function(age_matrix(k));
           if probability_sick<=0;
               if p_ID_Sick - random_find(k) <= 0 ;
                 AliveStateNew(k) = 3; % sick person enters the simulation
               else
                 AliveStateNew(k) = 1; % the person is healthy (false positive)
               end
           else
               AliveStateNew(k) = 1;
           end
        years_in_sim(k) = 1; % reset the years in simulation
    end
    
    % At this point in the iteration, everyone is alive - but some people
    % have completed 10 years in simulation and must be screened for re-entry.
    % Evaluate the age of policyholders at years_in_sim(i) = 11.  Those deemed
    % too old or found to be sick will be rejected.
    too_old_screen = find(years_in_sim == 11);
    
    % screen for old age / sickness at years_in_sim = 10
    % if neither, allow them to re up for insurance at the new rate
    for k = 1:(length(too_old_screen));
        if age_matrix(too_old_screen(k))>=65; % are they too old?
            AliveStateNew(too_old_screen(k)) = 2;
            screen_counter = screen_counter + 1;
        elseif AliveState(too_old_screen(k)) == 3 % if they are sick, do we screen them out?
            if p_ID_Sick - random_find(too_old_screen(k)) <= 0
                % we found them - denote that they have been kicked out
                AliveStateNew(too_old_screen(k)) = 2;
                screen_counter = screen_counter + 1;
            end
        end
        % in any event, the years_in_sim now goes back to 1
        years_in_sim(too_old_screen(k)) = 1; % reset to 1 - the person's premium
        % will now rise according to their current age at the beginning of
        % the 10 year period
    end
    
    % We have now assigned AliveState = 2 to those who were screened out,
    % and no one is dead at this point in the iteration.  We can therefore
    % find all AliveState = 2, and craft new people from the population
    % distribution to replace them.  
    % For consideration: assign an age, healthy/sick, and reset
    % years_in_sim at that index to 1; assign the new age to age_matrix at
    % that index;
    % for this we can copy & paste the code from above
    people_screened_out = find(AliveStateNew == 2);
    for i = 1:length(people_screened_out);
        k = people_screened_out(i); % to shorten things up
        age_matrix(k) = age(random_birth(k)); % assign an age to new person
        % now, we must determine if they are sick or healthy
        probability_sick = random_sick(k) - psick_function(age_matrix(k));
           if probability_sick - random_find(k)<=0
              AliveStateNew(k) = 3; % sick person enters the simulation
           else
              AliveStateNew(k) = 1; % the person is healthy
           end
        years_in_sim(k) = 1;
    end
    
    % At this point, we have a fully curated population of 1M people.  Now,
    % it is time to see what happens in the next year.
    % but let's check:
    jkl = find(AliveStateNew == 1);
    hij = find(AliveStateNew == 3);
    how_many_people = length(jkl) + length(hij);
    % storing during simulation, the above should yield a matrix of length
    % tfinal with value n at each index
    
    for i = 1:n; % examine every person
        if AliveStateNew(i) == 1; % if they are healthy, then...
            pdeath_this_year(i,1) = adjusted_pdeath_healthy(age_matrix(i));
            death_by_person(i) = pdeath_this_year(i)-random_death(i);
            if death_by_person(i) > 0; %if they died,
                AliveStateNew(i) = 0;
                counter = counter + 1;
            else
                continue
            end
        elseif AliveState(i) == 3; % if they are sick, then...
            pdeath_this_year(i,1) = psick_death(age_matrix(i));
            death_by_person(i) = pdeath_this_year(i,1)-random_death(i);
            if death_by_person(i) > 0;
                AliveStateNew(i) = 0;
                counter = counter + 1;
            else
                continue
            end
        end
    end
    
    death_count(t) = counter;
    pdeath_simulation(:,t) = pdeath_this_year(:,1);
    death_by_person_simulation(:,t) = death_by_person(:,1);
    age_matrix = age_matrix + ones(n,1);
    screen_counter_store(t,1) = screen_counter;
    years_in_sim_store(:,t) = years_in_sim(:,1);
    age_matrix_store(:,t) = age_matrix(:,1);
    each_year_people_count(t,1) = how_many_people;
    t = t+1;
end


%% Data Analysis and Computation of the Base Rate Multiplier

expected_yearly_losses = payout.*death_count;
normalized_EYL = expected_yearly_losses./n; % a preliminary estimate of 
% how much the pay out costs per person involved in the policy per year

worst_year = min(normalized_EYL);
tplot=1:(length(death_count));
% Let's plot the deaths by year
figure(4)
plot(tplot,death_count')
title('Simulation Results - Deaths over Time')
xlabel('Year')
ylabel('Deaths')
axis([0 length(tplot) .8*min(death_count) 1.2*max(death_count)])

% when did the simulation reach an equilibrium? 
% Let's define equilibrium as a (relatively) constant number of people being removed
% from the simulation by the screening process - since at t = 1, everyone
% had the same years_in_sim = 1, this represents an unstable initial
% condition.  A graph should show whether this fixed itself over time:
tplot = 1:tfinal;
figure(5)
plot(tplot',screen_counter_store)
title('Equilibrium Dynamics of the Screening Process')
xlabel('Year')
ylabel('People Removed by Screening Process')
axis([0 tlength 0 1.2*max(screen_counter_store)])

% we'll use the data from t = 401:430 - at this point, the simulation
% appeared to have reached equilibrium as indicated by the graph of the
% screening process vs time
years_in_sim_short = years_in_sim_store(:,(401:430));
age_matrix_short = age_matrix_store(:,(401:430));
screen_counter_short = screen_counter_store(401:430);
each_year_people_count_short = each_year_people_count(401:430);
death_by_person_simulation_short = death_by_person_simulation(:,(401:430));
expected_yearly_losses_short = -expected_yearly_losses(401:430,1);

% now, let's assign premium coefficients. If years_in_sim(i,j) =
% years_in_sim(i,j-1) + 1, then it is the same person, and therefore they are
% eligible for a constant premium - so let them have it!
% Special consideration must be held for the first index - this will not be
% the first year in simulation for some people, and so we must backtrack to
% find their initial age and therefore the correct premium price
premium_coeffs = zeros(n,30);
base_rate_multiplier = 1.08; % an 8% increase in price per year beyond 30 at time of entry
premium_coeff_func = @(age) base_rate_multiplier.^(age-30); % at age = 30, premium coeff = 1

for i = 1:n; % for each person
    for j = 1:30 % at each time t
        if j == 1;
            if years_in_sim_short(i,j) ~= 1;
                backtrack = 1-years_in_sim_short(i,j);
                age_at_entry = age_matrix_short(i,j) + backtrack;
                premium_coeffs(i,j) = premium_coeff_func(age_at_entry);
            else
                age_at_entry = age_matrix_short(i,j);
                premium_coeffs(i,j) = premium_coeff_func(age_at_entry);
            end
        else
            if years_in_sim_short(i,j) == years_in_sim_short(i,j-1) + 1;
                premium_coeffs(i,j) = premium_coeffs(i,j-1);
            else
                age_at_entry = age_matrix_short(i,j);
                premium_coeffs(i,j) = premium_coeff_func(age_at_entry);
            end
        end
    end
end

yearly_premium_income = sum(premium_coeffs);

tplot = 1:30;
figure(6)
plot(tplot,yearly_premium_income)
title('Expected Yearly Premium Income - Cumulative Base Rate Multiplier')
xlabel('Year')
ylabel('Income from Premiums')


% % We now have the yearly losses for the 30 year period stored in 
% % expected_yearly_losses_short, and the yearly income stored in
% % yearly_premium_income
% 
% % we now need to solve for the base rate multiplier of the premiums and
% % that will complete the problem.
% initial_funds_matrix = [initial_funds; zeros(29,1)];
% 
% data_for_examination = [yearly_premium_income; expected_yearly_losses_short'; initial_funds_matrix'];
% 
% 
% % we will assume a rate of return of 3% on all cash: premiums + initial
% % funds (or, if t>1, funds left over from last year)
initial_guess = 1000; % guess a base rate of $1000
% solve_base_rate = fsolve('Premium_Base_Rate',data_for_examination,initial_guess);

%% Solving for the Premium Base Rate

%PREMIUM_BASE_RATE 

% sp = sum_of_premiums is a vector of dimensions (30,1) that is a sum of the
% base rate multipliers that, when multiplied by an unknown constant, will
% yield the total income of premium payments for that year

% yc (yearly_costs) is a vector of dimensions (30,1) that is the total losses
% due to deaths for each year of examination for the insurance company

% initial_funds is a scalar value of the initial funds at t=0 ; for matrix
% dimensions consistency, we append zeros in indices (2:end,1) and ignore
% them
RoR= 1.03; % arbitrary; the assumed rate of Rate of Return (RoR)
% Our constraint is a 10% profit margin at T = 30; The equations are
% coupled such that it is actually one equation - the lifetime profit over
% the course of 30 years - and one unknown - the base rate of the premium.
% Unfortunately, MATLAB does not support iterative creation of implicit
% anonymous functions, so we'll have to type them all out by hand...

% our initial funds at the beginning of each sequential year is given by
% the leftover funds from the previous year
sp = yearly_premium_income; % some shorthand
yc = expected_yearly_losses_short; % more shorthand
initial_funds = 1000000000; % our initial funds in dollars ($1B)
% compute the revenue streams as functions of x
income_y1 = @(x) (sp(1)*x + initial_funds(1))*RoR - yc(1);
income_y2 = @(x) (sp(2)*x + income_y1(x))*RoR - yc(2);
income_y3 = @(x) (sp(3)*x + income_y2(x))*RoR - yc(3);
income_y4 = @(x) (sp(4)*x + income_y3(x))*RoR - yc(4);
income_y5 = @(x) (sp(5)*x + income_y4(x))*RoR - yc(5);
income_y6 = @(x) (sp(6)*x + income_y5(x))*RoR - yc(6);
income_y7 = @(x) (sp(7)*x + income_y6(x))*RoR - yc(7);
income_y8 = @(x) (sp(8)*x + income_y7(x))*RoR - yc(8);
income_y9 = @(x) (sp(9)*x + income_y8(x))*RoR - yc(9);
income_y10 = @(x) (sp(10)*x + income_y9(x))*RoR - yc(10);
income_y11 = @(x) (sp(11)*x + income_y10(x))*RoR - yc(11);
income_y12 = @(x) (sp(12)*x + income_y11(x))*RoR - yc(12);
income_y13 = @(x) (sp(13)*x + income_y12(x))*RoR - yc(13);
income_y14 = @(x) (sp(14)*x + income_y13(x))*RoR - yc(14);
income_y15 = @(x) (sp(15)*x + income_y14(x))*RoR - yc(15);
income_y16 = @(x) (sp(16)*x + income_y15(x))*RoR - yc(16);
income_y17 = @(x) (sp(17)*x + income_y16(x))*RoR - yc(17);
income_y18 = @(x) (sp(18)*x + income_y17(x))*RoR - yc(18);
income_y19 = @(x) (sp(19)*x + income_y18(x))*RoR - yc(19);
income_y20 = @(x) (sp(20)*x + income_y19(x))*RoR - yc(20);
income_y21 = @(x) (sp(21)*x + income_y20(x))*RoR - yc(21);
income_y22 = @(x) (sp(22)*x + income_y21(x))*RoR - yc(22);
income_y23 = @(x) (sp(23)*x + income_y22(x))*RoR - yc(23);
income_y24 = @(x) (sp(24)*x + income_y23(x))*RoR - yc(24);
income_y25 = @(x) (sp(25)*x + income_y24(x))*RoR - yc(25);
income_y26 = @(x) (sp(26)*x + income_y25(x))*RoR - yc(26);
income_y27 = @(x) (sp(27)*x + income_y26(x))*RoR - yc(27);
income_y28 = @(x) (sp(28)*x + income_y27(x))*RoR - yc(28);
income_y29 = @(x) (sp(29)*x + income_y28(x))*RoR - yc(29);
income_y30 = @(x) (sp(30)*x + income_y29(x))*RoR - yc(30);

% the constraint is 10% profit at t = 30:
constraint = @(x) income_y30(x) - initial_funds(1) - 1.1*sum(yc);
rate = fzero(@(x) constraint(x),initial_guess)

% END