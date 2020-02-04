currentDirectory = pwd;

% Directory that stores raw files
rawDirectory = strcat(pwd, "/raw/");

% Directory that stores raw files
cleanDirectory = char(strcat(pwd, "/clean/"));

% CSV File
eegFiles = dir(fullfile(rawDirectory,'*.csv'));

% File to assist with source localization (ICA)
elpFile = char(strcat(pwd, "/res/standard-10-5-cap385.elp"));

% Channel Locations
channelLocationFile = char(strcat(pwd, "/res/td_asd_malaia.ced"));

% Sample Rate
sampleRate = 256;

% Number of Channels; 
numChannels = 34

for k = 1:length(eegFiles)
    
    %% Handle File Loading 
    
    % Get file
    currentFile = eegFiles(k).name;
    file = strcat(rawDirectory, currentFile);
    
    % Load EEG Data
    participantEEG = loadFile(file);
    
    %Get Sample Size
    sampleSize = getSampleSize(participantEEG);
    
    %Import file to EEGLAB
    EEG = pop_importdata('dataformat','array','nbchan', numChannels,'data','participantEEG','srate',sampleRate,'pnts', sampleSize,'xmin',0);
    
    % Add Channels
    EEG = pop_chanedit(EEG, 'lookup',elpFile,'load',{channelLocationFile 'filetype' 'autodetect'});
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    %% Begin Preprocessing Pipeline
    
    % Reref Data
    EEG = pop_reref( EEG, []);
    
    %Clean line noise
    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist', [1:34] ,'computepower',1,'linefreqs',60,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',2,'winstep',1);
    
    % Add Hi Pass filter
    EEG = pop_eegfiltnew(EEG, 0.5, 30);
    
    % Remove Channels (Check to see if any channels are noisy)
    %EEG = pop_select( EEG,'nochannel',{'F7' 'VEOG' 'HEOG'});
    
    % Create New Set
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 12,'setname', eegFiles(k).name,'gui','off');
    
    % Save File
    outputFileName = split(currentFile,"."); outputFileName = outputFileName(1);
    outputFileName = char(strcat(outputFileName, "_clean.set"));
    EEG = pop_saveset( EEG, 'filename', outputFileName,'filepath', cleanDirectory);
    
    disp(EEG);
end

eeglab("redraw")

function sampleSize = getSampleSize(EEGDATA)
    columnSize = size(EEGDATA);
    sampleSize = columnSize(2);
end

function EEG = loadFile(filename)
    file = csvread(char(filename), 1, 0);
    EEG = transpose(file);
end