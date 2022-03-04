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
if runfullversion == 0
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
rand_order_gender_race_index = randperm(4);

% put them in the partner matrix
partner_matrix(1:2,3:4) = gender_race_matrix(:,:,rand_order_gender_race_index(1));
partner_matrix(3:4,3:4) = gender_race_matrix(:,:,rand_order_gender_race_index(2));
partner_matrix(5:6,3:4) = gender_race_matrix(:,:,rand_order_gender_race_index(3));
partner_matrix(7:8,3:4) = gender_race_matrix(:,:,rand_order_gender_race_index(4));

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

% alternative take (NOT USED)
% 1 0 female white
% 0 1 male black

% 0 1 male black
% 1 0 female white

% 1 1 female black
% 0 0 male white

% 0 0 male white
% 1 1 female black
%}

% LOAD PARTNER IMAGES

% column 1: political affiliation (0 = Republican, 1 = Democrat)
% column 2: reciprocation rate (from 0-1)
% column 3: Gender (1 = F, 0 = M)
% column 4: Race (1 = Black, 0 = White)


% relative path to images
relative_image_path = '../stimuli/';
fnames = dir([relative_image_path '*.jpg']);
fnames_for_loading = fnames;
outputpath = ['output' filesep];

allimages = nan(1718,2444,3,numPartners); % pixels, pixels, RGB, partner

for partner = 1:numPartners
    if partner_matrix(partner,3) == 1
        tmp_gender = 'F';
    elseif partner_matrix(partner,3) == 0
        tmp_gender = 'M';
    end
    
    if partner_matrix(partner,4) == 1
        tmp_race = 'B';
    elseif partner_matrix(partner,4) == 0
        tmp_race = 'W';
    end
    
    imgtxt = [tmp_race tmp_gender];
    
    for image_number = 1:length(fnames_for_loading)
        if strcmp(imgtxt,fnames_for_loading(image_number).name(5:6))
            break
        end
    end
    
    fnames(partner) = fnames_for_loading(image_number);
    
    allimages(:,:,:,partner) = imread([relative_image_path fnames(image_number).name]);
    
    fnames_for_loading(image_number) = []; % get rid of this image now we've used it. 
end

% shuffle the partner matrix
shuffle_order = randperm(numPartners);

partner_matrix = partner_matrix(shuffle_order,:);
allimages = allimages(:,:,:,shuffle_order);

% Number of trials per partner in Phase 1 (first mover)
if runfullversion == 1
    nT_per_partner = 10;
else
    nT_per_partner = 2;
end 

nT_phase1 = numPartners * nT_per_partner;
nT_phase2 = nT_phase1;

% Create Interactions Matrix
% (Rows = trials, columns = partner number, share/keep)



%Create variables for variable columns for data table 
trialNum = nan(nT,1);
cumTrialNum = nan(nT,1);
image = cell(nT,1);
shared = nan(nT,1);
partnerChoice = nan(nT,1);
received = nan(nT,1);

%Create Data Table 
subjData.data = table(trialNum, cumTrialNum, image, shared, partnerChoice, received);

% Capture Keypresses & don't affect the editor/console 
if runfullversion == 1
    ListenChar(2);
end

% Path to the file disk

WaitSecs(2)
sca
