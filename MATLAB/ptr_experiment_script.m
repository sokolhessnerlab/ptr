function [subjData] = ptr_experiment_script(subjID, runfullversion)
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
	runfullversion = 0; % assume that we run the short version of the study
end
if nargin < 1
	subjID = '000'; % assume default subjID 000
end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% PREPARATION & GLOBAL VARS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create Experiment Window 
if runfullversion == 1
	rect=[1600 0 2400 600];
	[wind, rect] = Screen('OpenWindow', max(Screen('Screens')),[], rect); % If it test mode, do not hide cursor 
else
	[wind, rect] = Screen('OpenWindow', max(Screen('Screens')));
end

% Define Experiment Window
blk = BlackIndex(wind);
wht = WhiteIndex(wind);
gry = GrayIndex(wind, 0.8);
Screen('TextFont', wind, 'default');

% Show Loading Screen
DrawFormattedText(wind, 'Setting up...', 'center', 'center', blk);
Screen(wind,'Flip');

% Set Random Number Generator
rng('shuffle');

%File path set-up
if ismac
    homepath = [filesep 'Volumes' filesep 'research' filesep 'AHSS Psychology' filesep 'shlab' filesep 'Projects' filesep 'PTR' filesep 'task' filesep];
end
        
% if IsWin
%     homepath = ['S:' filesep 'Projects' filesep 'PTR' filesep 'task' filesep];
% end

imgpath_blackfemale = ['stimuli' filesep 'blackfemaleFaces'];
imgpath_blackmale = ['stimuli' filesep 'blackmaleFaces'];
imgpath_whitefemale = ['stimuli' filesep 'whitefemaleFaces'];
imgpath_whitemale = ['stimuli' filesep 'whitemaleFaces'];
outputpath = ['output' filesep];

% relative path to images
relative_image_path = '../stimuli/';
fnames = dir([relative_image_path '*.jpg']);

% Basic Keyboard Stuff
KbName('UnifyKeyNames'); %for OS X

%Define Response Keys
resp_keys = {'f', 'g', 'h', 'j'}; %For $1, $2, $3, $4
resp_key_codes = KbName(resp_keys);
esc_key_code = KbName('ESCAPE'); % Abort key
trig_key_code = KbName('Return'); % experimenter advance key

% Number of Partners to interact with
numPartners = 8; % interact with 8 partners

% Partner information
partner_matrix = nan(numPartners,4); % political aff, reciprocity rate, gender, race

% Affiliation
partner_matrix(1:4,1) = 0; % Republican = 0
partner_matrix(5:8,1) = 1; % Democrat = 1

% Reciprocity rate
partner_matrix([1:2 5:6],2) = 0.7; % good partner (high reprocity)
partner_matrix([3:4 7:8],2) = 0.3; % bad partner (low reprocity)


% Prep gender/race matrix
% column 3: Gender (1 = F, 0 = M)
% column 4: Race (1 = Black, 0 = White)
gender_race_matrix = nan(2,2,4);
gender_race_matrix(:,:,1) = [1 1; 1 0];
gender_race_matrix(:,:,2) = [0 0; 1 0];
gender_race_matrix(:,:,3) = [1 0; 1 1];
gender_race_matrix(:,:,4) = [1 0; 0 0];

% randomly pick out these pairs
rand_order_gender_race_matrix = randperm(4);

% put them in the partner matrix
partner_matrix(1:2,3:4) = gender_race_matrix(:,:,rand_order_gender_race_matrix(1));
partner_matrix(3:4,3:4) = gender_race_matrix(:,:,rand_order_gender_race_matrix(2));
partner_matrix(5:6,3:4) = gender_race_matrix(:,:,rand_order_gender_race_matrix(3));
partner_matrix(7:8,3:4) = gender_race_matrix(:,:,rand_order_gender_race_matrix(4));

% shuffle the partner matrix
partner_matrix = partner_matrix(randperm(numPartners),:);

%{
% All possible combos of gender/race that ensure at least one differs
% within pairs:
% G R
% 1 1
% 1 0

% 0 1
% 0 0

% 1 1
% 0 1

% 1 0
% 0 0

% alternative take
% 1 0 female white
% 0 1 male black

% 0 1 male black
% 1 0 female white

% 1 1 female black
% 0 0 male white

% 0 0 male white
% 1 1 female black
%}

% NEXT STEP: load partner images given partner matrix content
for partner = 1:numPartners
    % need to identify who we're looking for in each row
    % load an image (and then not repeat that image loading again later)
end


% Number of trials per partner in Phase 1 (first mover)
if runfullversion == 1
    nT_per_partner = 10;
else
    nT_per_partner = 2;
end 

nT_phase1 = numPartners * nT_per_partner;
nT_phase2 = nT_phase1;

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
if runfullversion == 1
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
