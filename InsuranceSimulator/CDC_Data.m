%% Data Integration

% This is the CDC data for incidence and mortality rates of heart disease across
% a population

% Source: National Vital Statistics Report, Vol 64 No 2

% Where disease of the heart were the cause of death:
% columns were:
% 1: all ages]
% 2: under 1 year
% 3: 1-4
% 4: 5-14
% 5: 15-24
% 6: 25-34
% 7: 35-44
% 8: 45-54
% 9: 55-64
% 10: 65-74
% 11: 75-84
% 12: 85 + 
% 13: age adjusted rate
% note that these were rates with respect to populations of 100,000 people

% sick_data:
data13 = [193.3 7.8 1.1 0.4 2.1 7.6 25.6 80.3 184.6 390.3 1095.1 4013.9 169.8];
data12 = [191.0 8.5 1.0 0.4 2.2 7.6 25.9 79.7 184.6 388.3 1103.7 4046.1 170.5];
data11 = [191.5 7.7 1.0 0.5 2.3 7.9 26.2 80.7 183.2 399.0 1134.7 4111.6 173.7];

data = [data13; data12; data11];
data = mean(data)./100000; % normalize accordingly

death1_4 = ones(4,1)*data(3);
death5_14= ones(10,1)*data(4);
death15_24=ones(10,1)*data(5);
death25_34=ones(10,1)*data(6);
death35_44=ones(10,1)*data(7);
death45_54=ones(10,1)*data(8);
death55_64=ones(10,1)*data(9);
death65_74=ones(10,1)*data(10);
death75_84=ones(10,1)*data(11);
death85_119=ones(120-85,1)*data(12);

death_heart_disease = [death1_4;death5_14;death15_24;death25_34;death35_44;death45_54;death55_64;death65_74;death75_84;death85_119];

% Heart Disease Frequency - from CDC
% 18-44: .038
% 45-64: .121
% 65-74: .244
% 75+  : .369

% assume 0 incidence under the age of 18

freq1_17 = ones(17,1)*0;
freq18_44 = ones(45-18,1)*.038;
freq45_64 = ones(65-45,1)*.121;
freq65_74 = ones(10,1)*.244;
freq75_119 = ones(120-75,1)*.369;

heart_disease_frequency = [freq1_17;freq18_44;freq45_64;freq65_74;freq75_119];


