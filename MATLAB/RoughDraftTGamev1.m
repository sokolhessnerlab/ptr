
function [subjData] = TGamev1(subjID, testMode)
%
% subjID must be a 3-character string (e.g. '003')
% testMode must be either 0 (do the fully study) or 1 (do not do the study)
%
% DATA:
%
% 
% POLITICAL ORIENTATION DATA: 
% 'Democrat' = 0
% 'Republican' = 1
%
% AGE DATA: 
% 'Age' = 
	% '19' 
	% '20'
	% '21'
%
% Partner Choice: 
% $1 = 'f'
% $2= 'g'
% $3 = 'h'
% $4 = 'j'
%
% set up defaults 
Screen('Preference', 'SkipSyncTests', 1); %skips sync tests for monitor relay timing (for use during testing w/ dual monitor)
if nargin < 2
	testMode = 1; % assume full mode of study 
end
if nargin < 1
	subjID = '000'; % assume default subjID 000
end

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% PREPARATION & GLOBAL VARS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Experiment Window 
if testMode == 1
	rect=[1600 0 2400 600];
	[wind, rect] = Screen('OpenWindow', max(Screen('Screens')),[], rect); % If it test mode, do not hide cursor 
else
	[wind, rect] = Screen('OpenWindow', max(Screen('Screens')));
end

% Define Experiment Window
% Screen('BlendFunction', wind, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
blk = BlackIndex(wind);
wht = WhiteIndex(wind);
gry = GrayIndex(wind, 0.8);
Screen('TextFont', wind, 'default');

% Show Loading Screen
DrawFormattedText(wind, 'Setting up...', 'center', 'center', blk);
Screen(wind,'Flip');

% Random Number Generator
rng('shuffle');

%File path set-up
if ismac
    homepath = [filesep 'Volumes' filesep 'research' filesep 'AHSS Psychology' filesep 'shlab' filesep 'Projects' filesep 'PTR' filesep 'task' filesep];
end
        
if IsWin
    homepath = ['S:' filesep 'Projects' filesep 'PTR' filesep 'task' filesep];
end

imgpath_blackfemale = ['stimuli' filesep 'blackfemaleFaces'];
imgpath_blackmale = ['stimuli' filesep 'blackmaleFaces'];
imgpath_whitefemale = ['stimuli' filesep 'whitefemaleFaces'];
imgpath_whitemale = ['stimuli' filesep 'whitemaleFaces'];
outputpath = ['output' filesep];


% Basic Keyboard Stuff
KbName('UnifyKeyNames'); %for OS X

%Define Response Keys
resp_keys = {'f', 'g', 'h', 'j'}; %For $1, $2, $3, $4
resp_key_codes = KbName(resp_keys);
esc_key_code = KbName('ESCAPE');
trig_key_code = KbName('Return'); %experimenter advance key
%Abort key
[~, ~, keyCode] = KbCheck;
if keyCode(KbName('~')) == 1
    break
end

% Number of Stimuli to Choose From
numTotalStim = 8;

% Number of Stimuli (per groups)
% Number of stimuli groups = 2 (R/D)? 
if testMode == 1
    numTGameStim = [];
    numTGameBlocks = [];
else
    numTGameStim = [];
    numTGameBlocks = [];
    HideCursor;
end

nT = numTGameBlocks*numTGameStim;

% # of trials in the task during testmode
if testMode == 1
    nT = 80;
else
    nT =[];
end 

% set up trial order 

%Create variables for partner matrix 
blockNum = nan(nT,1);
trialNum = nan(nT,1);
cumTrialNum = nan(nT,1);
stimulus = cell(nT,1);
stimulusRace = nan(nT,1);
stimulusGender = nan(nT,1);
stimulusPA = nan(nT,1);

%Create Data Table 

% Capture Keypresses & don't affect the editor/console 
if testMode == 1
    ListenChar(2);
end

%Load Faces

%Blocks are (R/D) = 1, (good/bad) = 2, (R/Good & R/bad) = 3, (D/Good &
%D/bad) = 4, (R/black & R/white) = 5, (D/black & D/white) = 6, (R/female &
%R/male) = 7, (D/female & D/male) = 8
%SWITCH ASSOC?

% Path to the file disk

WaitSecs(2)
sca
