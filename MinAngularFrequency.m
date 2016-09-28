% rdemo1:20141202:creative.m:exercise 8.1 of homework 11
% usage: 

%% a
% The problem is from Physics 1 Lab. We drop a pendulum from different
% angles and gather amplitude and angular frequency at each drop, as well
% as their respective uncertainties, from a digital monitor and
% corresponding software that fits the sine curve to determine these
% values. Given a first order Taylor series approximation of sin(x) and an
% associated uncertainty based on the pendulum length (0.834±0.005m), we
% must experimentally determine the angle at which the approximation no
% longer holds. This angle is where the line of best fit for the data meets
% the lower uncertainty value for the theoretical angular frequency based
% on the model.

%% b
filename = 'Demo_G1_Lab9_data.csv';
delimiter = ',';
formatSpec = '%s%s%s%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);

raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));
for col=[1,2,3,4,5,6,7,8]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

Amplituderad = cell2mat(raw(:, 1));Amplituderad(isnan(Amplituderad(:,1)),:)=[];
AUncertaintyrad = cell2mat(raw(:, 2));AUncertaintyrad(isnan(AUncertaintyrad(:,1)),:)=[];
AngularFrequencyExperimental = cell2mat(raw(:, 5));AngularFrequencyExperimental(isnan(AngularFrequencyExperimental(:,1)),:)=[];
OmegaUncertanityExperimental = cell2mat(raw(:, 6));OmegaUncertanityExperimental(isnan(OmegaUncertanityExperimental(:,1)),:)=[];
AngularFrequencyTheoretical = cell2mat(raw(:, 7));AngularFrequencyTheoretical(isnan(AngularFrequencyTheoretical(:,1)),:)=[];
OmegaUncertanityTheoretical = cell2mat(raw(:, 8));OmegaUncertanityTheoretical(isnan(OmegaUncertanityTheoretical(:,1)),:)=[];

%% c
Amplitudedeg = Amplituderad.*180/pi;

pfit=polyfit(Amplitudedeg,AngularFrequencyExperimental,3);
f1=polyval(pfit,Amplitudedeg);

syms x
answer=vpasolve((pfit(1))*x^3+(pfit(2))*x^2+(pfit(3))*x+(pfit(4))==(AngularFrequencyTheoretical(2)-OmegaUncertanityTheoretical(2)),x);

%% d
hold on
scatter(Amplitudedeg,AngularFrequencyExperimental,'b')
errorbar(Amplitudedeg,AngularFrequencyExperimental,OmegaUncertanityExperimental,'Linestyle','none','Marker','s','MarkerEdgeColor','k')
plot(Amplitudedeg,f1,'r--')
calcref=refline(0,AngularFrequencyTheoretical(2))
set(calcref,'Color','g');
bottomref=refline(0,(AngularFrequencyTheoretical(2)-OmegaUncertanityTheoretical(2)))
set(bottomref,'Color','k');
refline(0,(AngularFrequencyTheoretical(2)+OmegaUncertanityTheoretical(2)))
line([double(answer(1)),double(answer(1))],[3.39,(AngularFrequencyTheoretical(2)+OmegaUncertanityTheoretical(2))],'Color','k')
xlabel('Amplitude (Angle) (degrees)')
ylabel('Angular Frequency  (rad/s)')
legend({'Experimental Data' 'Error Bars' 'Polyfit Deg. 3' 'Theoretical Angular Freq.' 'Lower AFreq. Uncertainty' 'Upper AFreq. Uncertainty' 'Intersection'},'Location','NorthEast');
title('Amplitude (deg) vs. Experimental and Theoretical Angular Frequency (rad/s)')
hold off

sprintf('The minimum angular frequency for which the theoretical angular frequency holds is: %s degrees.\n',char(answer(1)))
