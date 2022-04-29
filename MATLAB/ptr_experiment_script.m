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
	rect=[0 0 800 600];
	[wind, rect] = Screen('OpenWindow', max(Screen('Screens')),[], rect); % If it test mode, do not hide cursor 
else
	[wind, rect] = Screen('OpenWindow', max(Screen('Screens')));
end

screenheight = rect(4);
screenwidth = rect(3); 

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
space_key_code = KbName('space'); %For participant to advance the screen
esc_key_code = KbName('ESCAPE'); % Abort key
trig_key_code = KbName('Return'); % experimenter advance key

% Capture Keypresses & don't affect the editor/console 
if runfullversion == 1
    ListenChar(2);
end

disp('Beginning partner setup')

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

disp('Partner setup complete. Loading images.')

% relative path to images
relative_image_path = '../stimuli/';
fnames = dir([relative_image_path '*.jpg']);
fnames_for_loading = fnames;
outputpath = ['output' filesep];

original_image_width = 2444;
original_image_height = 1718;
image_display_ratio = (screenheight/3)/original_image_height;

img_location_rect = [screenwidth*.5 - original_image_width*image_display_ratio*.5
    screenheight*.5 - original_image_height*image_display_ratio*.5
    screenwidth*.5 + original_image_width*image_display_ratio*.5
    screenheight*.5 + original_image_height*image_display_ratio*.5]';

allimages = nan(original_image_height,original_image_width,3,numPartners); % pixels, pixels, RGB, partner

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
    
    fnames_for_loading(image_number) = []; % get rid of this image now we've used it. %issue with this line becasue the left and right sides have different number of elements 
end

disp('Partner images loaded. Setting up part 2.')

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
interaction_matrix_phase1_part1 = repmat(1:numPartners,[1,3])'; % 24 trials, 3 interactions w/ each partner
interaction_matrix_phase1_part2 = repmat(1:numPartners,[1,4])'; % 36 trials, 4 interactions w/ each partner
interaction_matrix_phase1_part3 = repmat(1:numPartners,[1,3])'; % 24 trials, 3 interactions w/ each partner

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
                         
% Phase 2 matrices made up of 2 matrices (offer patterns)
interaction_matrix_phase2_part1 = repmat(1:numPartners,[1,5])'; % 40 trials, Rows 1 through 8, 5 offers within interaction
interactions_matrix_phase2_part2 = repmat(1:numPartners,[1,5])'; % 40 trials, Rows 1 through 8, 5 offers within interaction 

% Placeholders for offers [$1=1, $2=2, $3=3, $4=4,]
interaction_matrix_phase2_part1(:,2) = nan;
interactions_matrix_phase2_part2(:,2) = nan;

% Fill in their actions (all actions are the same)
for partner = 1:numPartners
    %what rows are for each partners in each matrix [partner = 1:8]
    index_phase2_part1 = find(interaction_matrix_phase2_part1(:,1) == partner);
    index_phase2_part2 = find(interactions_matrix_phase2_part2(:,1) == partner);
    
    %fill in actions for offers 
    interaction_matrix_phase2_part1(index_phase2_part1,2) = [1 2 2 3 4];
    interactions_matrix_phase2_part2(index_phase2_part2,2) = [1 2 3 3 4];
end

interaction_matrix_phase2_part1 = interaction_matrix_phase2_part1(randperm(size(interaction_matrix_phase2_part1,1)),:);
interactions_matrix_phase2_part2 = interactions_matrix_phase2_part2(randperm(size(interactions_matrix_phase2_part2,1)),:);

%Combine two parts (partner number + offers)
interaction_matrix_phase2 = [interaction_matrix_phase2_part1; interactions_matrix_phase2_part2];

% Set-up file to path disk 

disp('Part 2 setup complete. Creating placeholders for data.')

%%% Create variables to store participants' responses, RTs, and outcomes

%Create variables for variable columns for data table: Phase 1
participant_offer_choice = nan(nT_phase1,1);
participant_offer_RT = nan(nT_phase1,1);
phase1trial_total_received = nan(nT_phase1,1);

%Create Data Table 
subjDataPhase1.data = table(participant_offer_choice, participant_offer_RT, phase1trial_total_received);

%Create variables for variable columns for data table: Phase 2
participant_sharekeep_choice = nan(nT_phase2,1);
participant_sharekeep_RT = nan(nT_phase2,1);
phase2trial_total_received = nan(nT_phase2,1);

%Create Data Table 
subjDataPhase2.data = table(participant_sharekeep_choice, participant_sharekeep_RT, phase2trial_total_received);

%%% Save out stimuli & setup variables
study_parameters = struct();
study_parameters.numPartners = numPartners;
study_parameters.goodrate = goodrate;
study_parameters.badrate = badrate;
study_parameters.partner_matrix = partner_matrix;
study_parameters.shuffle_order = shuffle_order;
study_parameters.allimages = allimages; % This might make this object large?
study_parameters.fnames = fnames;
study_parameters.nT_per_partner = nT_per_partner;
study_parameters.nT_phase1 = nT_phase1;
study_parameters.nT_phase2 = nT_phase2;
study_parameters.interaction_matrix_phase1 = interaction_matrix_phase1;
study_parameters.interaction_matrix_phase2 = interaction_matrix_phase2;

save(sprintf('study_parameters_PTR%s_%.4f.mat',subjID,now),'study_parameters')

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
            sca
            error('Experiment aborted by user!');
        elseif any(keyCode(trig_key_code))
            break
        end
    end
end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Instructions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define the task instructions (being displayed to participant)

instructStr{1} = ['As a reminder, in the following task, you will be interacting with 8 hypothetical partners. '...
    'However, please treat these partners as if they were real people you are interacting with.'];
instructStr{2} = ['It is well known that faces are particularly important for helping us gather social information. '...
    'For this reason, and to give you a better sense of whom you are interacting with, '...
    'we will provide you with a picture of your partner, along with additional demographic information.'];
instructStr{3} = ['For each interaction, you will see a picture of your partner''s face '...
    'and then choose how much money you want to share with that partner ($1, $2, $3, or $4).'];
instructStr{4} = ['The money that you choose to send will TRIPLE in amount. Your partner will then decide to either '...
    'share half of the money with you or keep all of the money for themselves.'];
instructStr{5} = ['When you''ve made your decision, press the keys f, g, h, or j to send $1, $2, $3, or $4, respectively (e.g., '...
    'to send $3, press the h key). Please keep your fingers on these keys at all times during the study. Then if you want to advance to your next interaction press the space bar.'];
instructStr{6} = ['Here is an example of an interaction: You see the photo of your partner alongside other attribute information, '...
    'and decide to share $2 of your money with them. This money then triples (becoming $6). '...
    'Your partner then has the chance to share $3 with you and keep $3 for themselves, or keep all $6.']; %change this last sentence, want to make sure that they remember who they are dealing with%
instructStr{7} = ['In this phase you will complete a total of 80 interactions (10 with each partner).'];

%for loop for these strings
for loopCnt = 1:length(instructStr)
    
    DrawFormattedText(wind, 'Reminders: Part 1', 'center', rect(4)*.1, blk); %what is the rect? 
    DrawFormattedText(wind, instructStr{loopCnt}, 'center', rect(4)*.2, blk, 55, [], [], 1.4); %not sure what numbers to specify 
    %Want to link an example stimuli image to string 3 that the participant
    %can reference%
    if loopCnt == 3
        path_to_instruction_image = [relative_image_path 'instruction_stim/CFD-BF-030-002-N.jpg'];
        stim_image = imread(path_to_instruction_image);
        stim_image_txt = Screen('MakeTexture', wind, stim_image); % make texture for image 
        Screen('DrawTexture', wind, stim_image_txt,[],img_location_rect);
    end
    Screen('Flip',wind,[],1); 
      
    WaitSecs(3);
      
    DrawFormattedText(wind, 'Press the space bar to continue when ready.', 'center', rect(4)*.9, blk);
    Screen('Flip', wind);
    
     while 1
       [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown && any(keyCode(space_key_code))
%             DrawFormattedText(wind, 'Reminders: Part 1', 'center', rect(4)*.1, blk);
%             Screen('Flip', wind);
            break
        elseif keyIsDown && keyCode(esc_key_code)
            sca
            error('Experiment aborted by user!');
        end
     end
end

%Check-In
Screen('FillRect', wind, gry);
DrawFormattedText(wind, 'This is the end of the instructions! Please tell your experimenter whether you have any questions.', 'center', 'center', blk, 45, [], [], 1.4);
Screen(wind,'Flip');
while 1
     [keyIsDown,~,keyCode] = KbCheck(-1);
     if keyIsDown
         if keyCode(esc_key_code)
             sca
             error('Experiment aborted by user!');
         elseif any(keyCode(trig_key_code))
             break
         end
     end
end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% START EXPERIMENT
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creat trialText string
trialText = 'How much money would you like to share? \n\n $1     $2     $3     $4';
%Need to add political affiliation text + age
    % Allow participant to start the task by pressing all 4 response keys.
    DrawFormattedText(wind, 'The experiment is ready to begin!','center',screenheight*.1);
    DrawFormattedText(wind, 'To start the experiment, simultaneously press and hold all four response keys (f, g, h, or j).', 'center', rect(4)*.9, blk, 50);
    Screen('Flip', wind);
    while 1
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            elseif all(keyCode(resp_key_codes))
                break
            end
        end
    end
    
    DrawFormattedText(wind, 'Beginning the experiment in 5 seconds...', 'center','center');
    pre_study_wait_time = GetSecs;
    Screen('Flip', wind);
    while (GetSecs - pre_study_wait_time) < 5
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
         

    subjData.ts.studystart = GetSecs; %log the study start time if it's the first trial
    for t = 1:nT_phase1 % Trial Loop
        %make background white
        % change the background to white to match the stimuli
        Screen('FillRect', wind, wht);
        DrawFormattedText(wind, 'Starting...', 'center', 'center', blk);
        Screen('Flip', wind);
        WaitSecs(1);
        
        
        %go through each stimuli and add in an image + make texture 
        for loopCnt = 1:numPartners
            %make texture, go through each stimuli and add in an image
            trial_stim = allimages(:,:,:,partner);
            trial_stim_text = Screen('MakeTexture', wind, trial_stim); %getting an error with this because it "doesn't correspond to an open window"
            %display the image, I FEEL LIKE IM CLOSE? 
            Screen('DrawTexture', wind, trial_stim_text,[],img_location_rect);
            DrawFormattedText(wind,trialText, 'center', rect(4) * 0.65);
            
            %put it together with interactions matrix, use partner number
            %to access all images per trial
            
            Screen('Flip', wind);
            
            %while loop for key responses 
            
            %endTime stamp
            
            %locations for saving (get this)
            
            %participant offer choice (dollar amount)
            subjDataPhase1.data.participant_offer_choice
            
            %participant_off_RT (in ms)
            subjDataPhase1.data.participant_offer_RT
            
            %phase1trial_total_recieved (not-offered + shared)
            subjDataPhase1.data.phase1trial_total_received
       
        end
        
        % In here, use interactions_matrix_phase1, with columns partner &
        % share/keep (1/0)
        % Use partner number to access allimages(:,:,:,N) per trial.
        % Save data in...
        % subjDataPhase1.data.participant_offer_choice (dollar amount)
        % subjDataPhase1.data.participant_offer_RT (in ms)
        % subjDataPhase1.data.phase1trial_total_received (not-offered +
        % shared)
        %make texture for images 
        %Interactions_matrix_phase1 use partner number to access allimages
        %per trial
 
    end
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% END PHASE 1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %show end text
        Screen('FillRect', wind, gry);
        DrawFormattedText(wind, 'You''ve completed the first phase of this task.\nPlease ring the bell to inform the experimenter!', 'center', 'center', blk, 45, [], [], 1.4);
        Screen('Flip', wind);
        while 1
            [keyIsDown,~,keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(esc_key_code)
                    error('Experiment aborted by user!');
                elseif any(keyCode(trig_key_code))
                    break
                end
            end
        end
        
        %OPENING INSTRUCTIONS/SCREENS FOR PHASE 2 
            

sca
