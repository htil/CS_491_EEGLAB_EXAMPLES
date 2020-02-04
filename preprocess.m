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

eeglab("redraw")
for k = 1:length(eegFiles)
    
    %% Handle File Loading 
    
    %% Get file
    currentFile = eegFiles(k).name;
    outputFileName = split(currentFile,"."); outputFileName = outputFileName(1);
    file = strcat(rawDirectory, currentFile);
    
    %% Load EEG Data
    participantEEG = loadFile(file);
    
    %% Get Sample Size
    sampleSize = getSampleSize(participantEEG);
    
    %% Import file to EEGLAB
    EEG = pop_importdata('dataformat','array','nbchan', numChannels,'data','participantEEG','srate',sampleRate,'pnts', sampleSize,'xmin',0);
    
    %% Add Channels
    EEG = pop_chanedit(EEG, 'lookup',elpFile,'load',{channelLocationFile 'filetype' 'autodetect'});
    
    %% Begin Preprocessing Pipeline
    
    %% Reref Data
    EEG = pop_reref( EEG, []);
    
    %% Clean line noise
    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist', [1:30] ,'computepower',1,'linefreqs',60,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',2,'winstep',1);
    
    %% Add Hi Pass filter
    EEG = pop_eegfiltnew(EEG, 0.5, 30);
    
    %% Remove Channels (Check to see if any channels are noisy)
    %EEG = pop_select( EEG,'nochannel',{'F7' 'VEOG' 'HEOG'});
    
    %% Create New Set
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 12,'setname', eegFiles(k).name,'gui','off');

    %% Import Events
    eventFileName = char(strcat(rawDirectory, outputFileName,  ".txt"));
    disp(eventFileName)
    EEG = pop_importevent( EEG, 'event', eventFileName, 'fields', {'latency' 'type' 'position'},'skipline',1,'timeunit',1);
   
    % Run ICA
    if runICA == 1
        EEG = pop_runica(EEG, 'extended',1,'interupt','on');
    end
    
    %% Save File
    outputFileName = char(strcat(outputFileName, "_clean.set"));
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = pop_saveset( EEG, 'filename', outputFileName,'filepath', cleanDirectory);
    
    %% Refresh GUI
    eeglab("redraw")
end

function sampleSize = getSampleSize(EEGDATA)
    columnSize = size(EEGDATA);
    sampleSize = columnSize(2);
end

function EEG = loadFile(filename)
    file = csvread(char(filename), 1, 0);
    EEG = transpose(file);
end

function EEG = loadASCFiles(filename)
    EEG = readtable(filename, 'Delimiter','\t','ReadVariableNames',false);
    EEG = transpose(table2cell(EEG));
end

