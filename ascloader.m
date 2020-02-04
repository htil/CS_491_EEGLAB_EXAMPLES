currentDirectory = pwd;
ALLEEG = [];
CURRENTSET = 1;
runICA = 0;

%% Directory that stores raw files
rawDirectory = strcat(pwd, "/raw/");

%% Directory that stores raw files
cleanDirectory = char(strcat(pwd, "/clean/"));

%% CSV File
eegFiles = dir(fullfile(rawDirectory,'*.csv'));

%% File to assist with source localization (ICA)
elpFile = char(strcat(pwd, "/res/standard-10-5-cap385.elp"));

%% Channel Locations
channelLocationFile = char(strcat(pwd, "/res/td_asd_malaia.ced"));

%% Sample Rate
sampleRate = 512;

%% Number of Channels; 
numChannels = 34;

%eeglab("redraw")

file = strcat(rawDirectory, "A100_raw_256Hz.csv");

%% Load EEG Data
%participantEEG = loadASCFile(file);

%disp(participantEEG)
%disp(participantEEG)
EEG = readtable(file, 'Delimiter','\t','ReadVariableNames',false);
EEG = transpose(table2cell(EEG));

function EEG = loadASCFile(filename)
    EEG = readmatrix(char(filename));
    %EEG = csvread(char(filename), 1, 0);
    %fileID = fopen(filename, 'rt');
    %if fileID == -1, error('Cannot open file: %s', FileName); end
    %EEG = fscanf(fileID, '%s\t%s\t', [35 Inf]).';
    %disp(EEG)
    %fclose(fileID);
    %EEG = transpose(EEG);
    %EEG  = textread(filename,'%s', 'delimiter', '\t');
    %disp(EEG)
    %EEG = cell2mat(out);
end

function EEG = loadFile(filename)
    file = csvread(char(filename), 1, 0);
    EEG = transpose(file);
end