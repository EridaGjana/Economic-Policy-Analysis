disp('************************************************');
disp('Problem Set #n'); % Initial set up . Start of a new problem set ( Tutorial 5 (Plot_FRED_Data.m))


close all;
clear all; % I clear the environment ( Tutorial 5 (Plot_FRED_Data.m))

% Specify what is to be done ( Tutorial 5 (Plot_FRED_Data.m))
% --------------------------
LoadData     = 1; %Data should be loaded
DefineVars   = 1; % Variables should be defined
PlotOverview = 1; % Show plots
DoSavePlots  = 1; % Save plots
CalcCorr     = 1; % calculate correlation coefficient

% Check for Matlab/Octave
% -----------------------
MyEnv.Octave = exist('OCTAVE_VERSION', 'builtin') ~= 0;% checks for the existence of the Octave version as a built-in function.
MyEnv.Matlab = ~MyEnv.Octave; % sets MyEnv.Matlab to the logical NOT of MyEnv.Octave.( Tutorial 5 (Plot_FRED_Data.m))

% Some useful defintions
% ----------------------
fig_counter = 0; %  keeps track of the number of figures created ( Tutorial 5 (Plot_FRED_Data.m))

% Colorblind barrier-free color pallet ( Tutorial 5 (Plot_FRED_Data.m)). This code defines a series of variables for colors
BfBlack        = [   0,   0,   0 ]/255; % Each variable stores a specific color
BfOrange       = [ 230, 159,   0 ]/255;
BfSkyBlue      = [  86, 180, 233 ]/255;
BfBluishGreen  = [   0, 158, 115 ]/255;
BfYellow       = [ 240, 228,  66 ]/255;
BfBlue         = [   0, 114, 178 ]/255;
BfVermillon    = [ 213,  94,   0 ]/255;
BfRedishPurple = [ 204, 121, 167 ]/255;

% Line Properties
StdLineWidth = 2; % Sets a standard line width for plots to 2

% Load packages (Octave only) % ( Lecture 7 (octxmpl_7_m) )
% ---------------------------
if ~MyEnv.Matlab,
  pkg load io;
  pkg load dataframe; %
end
% Load data from Csv file( Lecture 7 (octxmpl_7_m) )
% ---------------------------------------
if LoadData, % checks if the script should proceed with loading data.
  if MyEnv.Matlab,
    EUROSTAT=readtable('eurostatFile.csv');
  end
  if MyEnv.Octave,
    EUROSTAT=dataframe('eurostatFile.csv'); % it uses the dataframe function to load the  CSV file into a dataframe variable named EUROSTAT.
  end
  FirstYear = 2005; %  indicates the starting year for the data
  Nobs = length(EUROSTAT.GDPnom_CP); % calculates the number of observations=the length of the GDPnom_CP column in EUROSTAT.
  Time = transpose(FirstYear:0.25:(2005+Nobs/4-0.25));% time vector starting from FirstYear calculating observations by quarters
end

% Define Variables from Eurostat data ( Tutorial 5 (Plot_FRED_Data.m))
% -----------------------------------

if DefineVars % checks if the flag DefineVars is true.

  GDPnom = EUROSTAT.GDPnom_CP; % Extracts nominal GDP data from the EUROSTAT dataframe and assigns it to the variable GDPnom.
  GovNom = EUROSTAT.GOVnom_CP; % Extracts nominal government spending data from the EUROSTAT dataframe and assigns it to the variable GovNom.
  GDPDeflator = EUROSTAT.GDPnom_PD10; % Extracts the GDP deflator from the EUROSTAT dataframe and  assign it to GDPDeflator
  GovDeflator = EUROSTAT.GOVnom_PD10;  % extracts the government spending (GOV) deflator from EUROSTAT and assigns it to GOVDeflator
end

% Question 2 (a)( Lecture 7 (octxmpl_7_m) )
% Calculate the real values
GDP_real = (GDPnom ./ GDPDeflator) * 100; % dividing the nominal values  by their corresponding deflators .
GOV_real = (GovNom ./ GovDeflator) * 100; % multiply by 100 = converting an index (deflator) back to a real value

% Question 2b hp filter  ( Lecture 7 (octxmpl_7_m) )
% Calculate the logged real values
log_GDP_real = log(GDP_real);
log_GOV_real = log(GOV_real);

%% Before applying the hp filter I run the hpfilter.m from Lecture 7

% Apply the HP filter to the logged real GDP data
GDP_cycle_real = hpfilter(log_GDP_real, 1600);

% Apply the HP filter to the logged real government spending data
GOV_cycle_real = hpfilter(log_GOV_real, 1600);

% The variables GDP_cycle_real and GOV_cycle_real now contain the cyclical components
% of the logged real GDP and logged real government spending, respectively.

% Question 2c  ( Tutorial 5 (Plot_FRED_Data.m))
% Calculate Correlation Coefficient( Tutorial 5 (Plot_FRED_Data.m))
% ---------------------------------
if CalcCorr %checks if the correlation coefficient calculation is enabled
  Coef_CORR = corr(GDP_cycle_real, GOV_cycle_real); % stores the correlation coefficient value.
end
disp(Coef_CORR); % displays the coefficient.

% QUESTION 2d ( Lecture 7 (octxmpl_7_m) )
% Calculate the public consumption to GDP ratio in percent using nominal values
GOV_GDP_ratio = (GovNom ./ GDPnom) * 100;

% Calculate the average value of the GOV/GDP ratio
avg_GOV_GDP_ratio = mean(GOV_GDP_ratio);

% Display the average value in the command window
disp('Average public consumption to GDP ratio (in percent, using nominal values):');
disp(avg_GOV_GDP_ratio);

%Question 2e ( Lecture 7 (octxmpl_7_m) )
% Assuming the time vector 'Time' corresponds with 'GDP_real' and 'GOV_real' and is in the format YYYY.Q

% Find the index of the year 2010 within the 'Time' vector
index2010 = find(Time >= 2010 & Time < 2011); % ensures that all quarters within 2010 are included.

% Calculate the average values for the year 2010 if there are multiple entries for that year
baseGDP_2010 = mean(GDP_real(index2010));
baseGOV_2010 = mean(GOV_real(index2010));

% Convert the entire series to the 2010 base
GDP_index_2010 = (GDP_real / baseGDP_2010) * 100; % dividing each value by the respective 2010 base value , multiplying by 100
GOV_index_2010 = (GOV_real / baseGOV_2010) * 100;

%%% Question 3 ( Tutorial 5 (Plot_FRED_Data.m))

if PlotOverview % execution of the plotting
  fig_counter = fig_counter + 1; % each new figure opens in a new window
  hf = figure(fig_counter); % hf stores the figure for saving

  subplot(2,1,1); % figure window is divided into 2 rows and 1 column,  this plot is the first item.
  hold on; % allows multiple graphs to be plotted
  plot(Time, GDP_index_2010, 'color', BfOrange, 'LineWidth', StdLineWidth); %  visualizes the GDP_index_2010 series, styles with a predefined color (BfOrange) and line width (StdLineWidth).
  hold off; % concludes the plotting in this subplot
  ylabel('Index (2010=100)');
  xlabel('Time');
  title('Indexed Real GDP');
  xlim([Time(1), Time(end)]);

  subplot(2,1,2); % plotted in the bottom half of the figure
  hold on;
  plot(Time, GOV_index_2010, 'color', BfBlue, 'LineWidth', StdLineWidth);
  hold off;
  ylabel('Index (2010=100)');
  xlabel('Time');
  title('Indexed Real GOV');
  xlim([Time(1), Time(end)]);

   if DoSavePlots
      set(hf, 'paperunits', 'centimeters');
      set(hf, 'papersize', [29, 29/16*9]); % configures the figure's size
      set(hf, 'paperposition',[0, 0, 29 ,29/16*9]); %configures the figure's orientation
      print('Eurostat_GDPandGOV.pdf', '-dpdf'); % saves it as a PDF file named Eurostat_GDPandGOV.pdf
   end
end
% Same procedure as above :
if PlotOverview
  fig_counter = fig_counter + 1;
  hf = figure(fig_counter);

  subplot(2,1,1);
  hold on;
  plot(Time, GOV_GDP_ratio, 'color', BfOrange, 'LineWidth', StdLineWidth);
  hold off;
  ylabel('GOV/GDP Ratio (%)');
  xlabel('Time');
  title('Public Consumption to GDP Ratio');
  xlim([Time(1), Time(end)]);

  subplot(2,1,2);
  hold on;
  plot(Time, avg_GOV_GDP_ratio, 'color', BfBlue, 'LineWidth', StdLineWidth);
  hold off;
  ylabel('Average Ratio (%)');
  xlabel('Time');
  title('Average of Public Consumption to GDP ratio');
  xlim([Time(1), Time(end)]);

   if DoSavePlots
      set(hf, 'paperunits', 'centimeters');
      set(hf, 'papersize', [29, 29/16*9]);
      set(hf, 'paperposition',[0, 0, 29 ,29/16*9]);
      print('Eurostat_GOVGDPratio.pdf', '-dpdf');
   end
end

if PlotOverview
  fig_counter = fig_counter + 1;
  hf = figure(fig_counter);

  subplot(2,1,1);
  hold on;
  plot(Time, GDP_cycle_real, 'color', BfOrange, 'LineWidth', StdLineWidth);
  hold off;
  ylabel('Cyclical Component');
  xlabel('Time');
  title('Cyclical Component of Real GDP');
  xlim([Time(1), Time(end)]);

  subplot(2,1,2);
  hold on;
  plot(Time, GOV_cycle_real, 'color', BfBlue, 'LineWidth', StdLineWidth);
  hold off;
  ylabel('Cyclical Component');
  xlabel('Time');
  title('Cyclical Component of Real GOV');
  xlim([Time(1), Time(end)]);

   if DoSavePlots
      set(hf, 'paperunits', 'centimeters');
      set(hf, 'papersize', [29, 29/16*9]);
      set(hf, 'paperposition',[0, 0, 29 ,29/16*9]);
      print('Eurostat_GDPGOVcyclical.pdf', '-dpdf');
   end

   fig_counter = fig_counter + 1;
   hf = figure(fig_counter);
   scatter(GDP_cycle_real, GOV_cycle_real, 'filled'); %  scatter plot with  (GDP_cycle_real) on the x-axis and (GOV_cycle_real) on the y-axis.  'filled' => filled dots
   ylabel('Cyclical Component of Gov Spending');
   xlabel('Cyclical Component of Real GDP');
   title('Scatter Plot of Cyclical Components');

    if DoSavePlots
      set(hf, 'paperunits', 'centimeters');
      set(hf, 'papersize', [29, 29/16*9]);
      set(hf, 'paperposition',[0, 0, 29 ,29/16*9]);
      print('Scatterplot.pdf', '-dpdf');
   end
end

% Calculating tau in order to put it as a parameter in the dynare script

tau_emp = avg_GOV_GDP_ratio/100 % As suggested in the question 7 , tau should be equal with the average of GOV/GDP ratio

% Divide it by 100 to go back as a proportion

% Question 7

% addpath C:/dynare/6.0/Octave

% Call dynare file run the model
dynare stochmod;











