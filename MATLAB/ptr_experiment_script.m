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
goodrate = 0.7;
badrate = 0.3;

partner_matrix([1:2 5:6],2) = goodrate; % good partner (high reprocity)
partner_matrix([3:4 7:8],2) = badrate; % bad partner (low reprocity)


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

% % Number of trials per partner in Phase 1 (first mover)
% if runfullversion == 1
%     nT_per_partner = 10;
% else
%     nT_per_partner = 2;
% end 

nT_per_partner = 10;


nT_phase1 = numPartners * nT_per_partner;
nT_phase2 = nT_phase1;

% Create Interactions Matrix
% This matrix will be made up of three matrices
interaction_matrix_phase1_part1 = repmat(1:8,[1,3])'; % 24 trials, 3 interactions w/ each partner
interaction_matrix_phase1_part2 = repmat(1:8,[1,4])'; % 36 trials, 4 interactions w/ each partner
interaction_matrix_phase1_part3 = repmat(1:8,[1,3])'; % 24 trials, 3 interactions w/ each partner

% Placeholder for the share/keep decisions [1 = share, 0 = keep]
interaction_matrix_phase1_part1(:,2) = nan;
interaction_matrix_phase1_part2(:,2) = nan;
interaction_matrix_phase1_part3(:,2) = nan;

% Using the partner rate from the partner matrix, fill in their actions
for partner = 1:numPartners
    % first identify which rows are this partner's in each of the matrices
    index_part1 = find(interaction_matrix_phase1_part1(:,1) == partner);
    index_part2 = find(interaction_matrix_phase1_part2(:,1) == partner);
    index_part3 = find(interaction_matrix_phase1_part3(:,1) == partner);
    
    % Then, using their rate, fill in their actions in the 3 matrices
    if partner_matrix(partner,2) == goodrate
        interaction_matrix_phase1_part1(index_part1,2) = [1 1 0];
        interaction_matrix_phase1_part2(index_part2,2) = [1 1 1 0];
        interaction_matrix_phase1_part3(index_part3,2) = [1 1 0];
    elseif partner_matrix(partner,2) == badrate
        interaction_matrix_phase1_part1(index_part1,2) = [0 0 1];
        interaction_matrix_phase1_part2(index_part2,2) = [0 0 0 1];
        interaction_matrix_phase1_part3(index_part3,2) = [0 0 1];
    end
end

% randomly sort each of the component matrices
interaction_matrix_phase1_part1 = interaction_matrix_phase1_part1(randperm(length(interaction_matrix_phase1_part1)),:);
interaction_matrix_phase1_part2 = interaction_matrix_phase1_part2(randperm(length(interaction_matrix_phase1_part2)),:);
interaction_matrix_phase1_part3 = interaction_matrix_phase1_part3(randperm(length(interaction_matrix_phase1_part3)),:);

% Assemble the final matrix: partner number, share [1]/keep [0] decision
interaction_matrix_phase1 = [interaction_matrix_phase1_part1; 
                             interaction_matrix_phase1_part2;
                             interaction_matrix_phase1_part3];
                         
%Phase 2 matrices made up of 2 matrices (offer patterns)
interactions_matrix_phase2_part1 = repmat(1:8,[1,5])'; % 40 trials, Rows 1 through 8, 5 offers within interaction
interactions_matrix_phase2_part2 = repmat(1:8,[1,5])'; % 40 trials, Rows 1 through 8, 5 offers within interaction 

%Placeholders for offers [$1=1, $2=2, $3=3, $4=4,]
interactions_matrix_phase2_part1(:,2) = nan;
interactions_matrix_phase2_part2(:,2) = nan;

%Using the partner matrix, fill in their actions
for partner = 1:numPartners
    %what rows are for each partners in each matrix [partner = 1:8]
    index_phase2_part1 = find(interactions_matrix_phase2_part1(:,1) == partner);
    index_phase2_part2 = find(interactions_matrix_phase2_part2(:,1) == partner);
    %fill in actions for offers 
    interactions_matrix_phase2_part1(index_phase2_part1,2) = [1 2 2 3 4];
    interactions_matrix_phase2_part2(index_phase2_part2,2) = [1 2 3 3 4];
    %Now have the offers occur a certain amount of times per partner ($1x2,
    %$2x3, $3x3, $4x2) - there is an issue with the left side being 1 by 1
    %and right side being 1 by 5, think I am on the right track
    interactions_matrix_phase2_part1 = repelem([1 2 2 3 4],[1 1 1 1 1]);
    interactions_matrix_phase2_part2 = repelem([1 2 3 3 4],[1 1 1 1 1]);
end

%Combine two parts (partner number + offers)
interactions_matrix_phase2 = [interactions_matrix_phase2_part1; interactions_matrix_phase2_part2];

% Set-up file to path disk 

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

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Waiting for Experimenter Screen
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Text display
Screen('FillRect', wind, gry);
DrawFormattedText(wind, 'Waiting for experimenter...', 'center', 'center', blk);
Screen(wind, 'Flip');
while 1
    [keyIsDown,~,keyCode] = KbCheck(-1);
    if keyIsDown
        if keyCode(esc_key_code)
            error('Experiment aborted by user!');
        elseif any (keyCode(trig_key_code))
            break
        end
    end
end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Instructions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define the task instructions (being displayed to participant)

instructStr{1} = ['As a reminder, in the following task, you will be interacting with 8 hypothetical partners. '...
    'However, please treat these partners as if they were real people you were interacting with.'];
instructStr{2} = ['It is well known that faces are particularly important for helping us gather social information. '...
    'For this reason, and to give you a better sense of whom you are interacting with, '...
    'we will provide you with a picture of your partner, along with additional demographic information.'];
instructStr{3} = ['In the following task, for each interaction, you will see a picture of your partners face '...
    'and then choose how much money you want to share with that partner. For each of the partners, you may choose to share $1, $2, $3, or $4.'];
instructStr{4} = ['The money that you choose to send will TRIPLE in amount. Your partner will then decide to either,'...
    'share part, all, or none of the money that they recieved back with you.'];
instructStr{5} = ['Here is an example of an interaction: You see the photo of your partner alongside other attribute information, '...
    'and decide to share $2 of your money with them. This money will then be tripled (becoming $6). '...
    'Your partner then has the chance to share $3 with you and keep $3 for themsevles, or keep all $6 for themselves.']; %change this last sentence, want to make sure that they remember who they are dealing with%
instructStr{6} = ['In this phase you will complete a total of 80 interactions 10 with each partner.'];

%for loop for these strings - also drawformattedtext

for loopCnt = 1:length(instructStr)
    DrawFormattedText(wind, 'Instructions: Economic Interactions Task', 'center', rect[], blk); %what is the rect? 
    DrawFormattedText(wind, instructStr{loopCnt}, 'center', rect[], blk, , , , ); %not sure what numbers to specify 
    % if end statement connecting images to loop
end
    Screen('Flip', wind, [],1);
    
    WaitSecs(3);
    
    DrawFormattedText(wind, 'Press the space bar to continue when ready.', 'center', rect [], blk); %what is the rect? 
    Screen('Flip', wind);
    
    %while loop for aborting 
    
WaitSecs(2)
sca
