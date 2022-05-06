function [subjData] = ptr_experiment_script(subjID, runfullversion, doinstr)
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
if nargin < 3
    doinstr = 1; % assume that we do the instructions
end
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
Screen(wind,'Flip',[],1);

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
resp_keys_phase1 = {'f', 'g', 'h', 'j'}; %For $1, $2, $3, $4
resp_key_codes_phase1 = KbName(resp_keys_phase1);
resp_keys_phase2 = {'f','j'}; %for SHARE & KEEP
resp_key_codes_phase2 = KbName(resp_keys_phase2);
space_key_code = KbName('space'); %For participant to advance the screen
esc_key_code = KbName('ESCAPE'); % Abort key
trig_key_code = KbName('Return'); % experimenter advance key

DrawFormattedText(wind,'.', screenwidth*.2, screenheight*.8);
Screen(wind,'Flip',[],1);

% Capture Keypresses & don't affect the editor/console
if runfullversion == 1
    ListenChar(2);
end

% Define trial timing
showpartner_phase1_duration = 2;
showpartner_phase2_duration = 2.5;
max_response_window_duration = 2;
isi_duration = 1;
outcome_duration = 1.5;
iti_duration = 2;

disp('Beginning partner setup')
DrawFormattedText(wind,'..', screenwidth*.2, screenheight*.8);
Screen(wind,'Flip',[],1);

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

DrawFormattedText(wind,'...', screenwidth*.2, screenheight*.8);
Screen(wind,'Flip',[],1);

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
outputpath = ['.' filesep 'output' filesep];

original_image_width = 2444;
original_image_height = 1718;
image_display_ratio = (screenheight/3)/original_image_height;

img_location_rect = [screenwidth*.5 - original_image_width*image_display_ratio*.5
    screenheight*.5 - original_image_height*image_display_ratio*.5
    screenwidth*.5 + original_image_width*image_display_ratio*.5
    screenheight*.5 + original_image_height*image_display_ratio*.5]';

allimages = nan(original_image_height,original_image_width,3,numPartners); % pixels, pixels, RGB, partner

DrawFormattedText(wind,'....', screenwidth*.2, screenheight*.8);
Screen(wind,'Flip',[],1);

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

    allimages(:,:,:,partner) = imread([relative_image_path fnames(partner).name]);

    fnames_for_loading(image_number) = []; % get rid of this image now we've used it. %issue with this line becasue the left and right sides have different number of elements
end

DrawFormattedText(wind,'.....', screenwidth*.2, screenheight*.8);
Screen(wind,'Flip',[],1);


disp('Partner images loaded. Setting up parts 1 & 2.')

% shuffle the partner matrix
shuffle_order = randperm(numPartners);

partner_matrix = partner_matrix(shuffle_order,:);
allimages = allimages(:,:,:,shuffle_order);

% % Number of trials per partner in Phase 1 (first mover)

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

DrawFormattedText(wind,'......', screenwidth*.2, screenheight*.8);
Screen(wind,'Flip',[],1);

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

DrawFormattedText(wind,'.......', screenwidth*.2, screenheight*.8);
Screen(wind,'Flip',[],1);

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
DrawFormattedText(wind,'.......', screenwidth*.2, screenheight*.8);
Screen(wind,'Flip',[],1);

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

DrawFormattedText(wind,'........', screenwidth*.2, screenheight*.8);
Screen(wind,'Flip',[],1);

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
Screen('Flip',wind);

output_filenamepath = sprintf('%sstudy_data_PTR%s_%.4f.mat',outputpath,subjID,now);

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
%%% Instructions: PHASE 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define the task instructions (being displayed to participant)

instructStr{1} = ['As a reminder, in the following task, you will be interacting with 8 hypothetical partners. '...
    'Please treat these partners as if they were real people you are interacting with.'];
instructStr{2} = ['It is well known that faces are particularly important for helping us gather social information. '...
    'For this reason, and to give you a better sense of whom you are interacting with, '...
    'we will provide you with a picture of your partner, along with additional demographic information.'];
instructStr{3} = ['For each interaction, you will see a picture of your partner''s face, like this.'];
instructStr{4} = ['You will then choose how much money you want to share with that partner ($1, $2, $3, or $4) out of $4. You will keep any '...
    'money you don''t send to your partner. \n\n The money that you choose to send will TRIPLE in amount. Your partner will then decide to either '...
    'share half of the money with you or keep all of the money for themselves.'];
instructStr{5} = ['When you''ve made your decision, press the keys f, g, h, or j to send $1, $2, $3, or $4, respectively (e.g., '...
    'to send $3, press the h key). Please keep your fingers on these keys at all times during the study.\n\nYou will have TWO (2) seconds '...
    'to enter your response. If you do not respond within 2 seconds, you will lose all $4 on that trial and your '...
    'partner will receive no money. Please respond in time!!'];
instructStr{6} = ['In an example interaction, you might see the photo of your partner alongside other information, '...
    'and decide to share $3 of your money with them, keeping $1 for yourself. The $3 then triples (becoming $9). '...
    'Your partner then has the chance to share $4.50 with you and keep $4.50 for themselves, or keep all $9.']; %change this last sentence, want to make sure that they remember who they are dealing with%
instructStr{7} = ['After each choice you make, you will see your partner''s decision (to share or keep the money) '...
    'before moving on to the next interaction. In this phase you will complete a total of 80 interactions (10 with each partner).'];

if doinstr
    %for loop for instruction strings
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
                break
            elseif keyIsDown && keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
end

% Check-In
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

% Shorten the task if it's not the full version
% (must be here not above b/c of stimulus creation code that relies
% on 80 trials total per phase)
if runfullversion == 0
    nT_phase1 = 10; 
    nT_phase2 = 10;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% START PART 1: PRACTICE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load practice images, make a texture to load later on 
%Practice Image Path 
numTotalPracticeTrials = 5;
numTotalPracticeStim = 4;
practice_image_fnames = dir([relative_image_path 'practice_stim/*.jpg']);

practice_images = nan(original_image_height,original_image_width,3,numTotalPracticeStim); %pixels, pixels, RGB, practice stim

for img_number = 1:numTotalPracticeTrials
    practice_images(:,:,:,img_number) = imread([relative_image_path practice_image_fnames(img_number).name]);
end

% Creat practice trialText string
practice_response_prompt_text = '$1     $2     $3     $4';

% For practice, order doesn't matter, and can be the same across all
% participants! And b/c we're not saving anything here, we don't need to
% worry about e.g. race & gender. 

practice_partner_order = [1 3 2 4 3];
practice_partner_affiliations = {'Democrat';
    'Republican'
    'Democrat'
    'Republican'};
partner_responses = {'Partner''s decision: SHARE'
    'Partner''s decision: SHARE'
    'Partner''s decision: KEEP'
    'Partner''s decision: SHARE'
    'Partner''s decision: KEEP'};


DrawFormattedText(wind, 'Practice','center',screenheight*.1);
DrawFormattedText(wind, 'Before starting the experiment, you will complete five practice trials.', 'center', 'center', blk, 45, [], [], 1.4);
Screen('Flip',wind,[],1);

WaitSecs(1);

DrawFormattedText (wind, 'To start the practice, simultaneously press and hold all four response keys (f, g, h, and j).', 'center', rect(4)*.9, blk, 50);
Screen('Flip', wind);
while 1
    [keyIsDown,~,keyCode] = KbCheck(-1);
    if keyIsDown
        if keyCode(esc_key_code)
            sca
            error('Experiment aborted by user!');
        elseif all(keyCode(resp_key_codes_phase1))
            break
        end
    end
end

Screen('FillRect', wind, wht);
DrawFormattedText(wind, 'Beginning the practice trials in 5 seconds...', 'center','center');
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

for t = 1:numTotalPracticeTrials

    % Political affiliation & image prep
    affiliation_txt = practice_partner_affiliations{practice_partner_order(t)};
    practice_stim_img = Screen('MakeTexture', wind, practice_images(:,:,:,practice_partner_order(t)));
    
    %%% Part 1: PARTNER DISPLAY
    
    % Display the partner & their affiliation
    Screen('DrawTexture', wind, practice_stim_img,[],img_location_rect);
    DrawFormattedText(wind, affiliation_txt, 'center', screenheight*0.7);
    Screen('Flip', wind, [], 1); % flip w/o clearing buffer
    
    time_trial_start = GetSecs;
    
    while (GetSecs - time_trial_start) < showpartner_phase1_duration
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
    
    DrawFormattedText(wind,practice_response_prompt_text, 'center', screenheight * 0.85);
    Screen('Flip', wind);
    
    practice_time_response_window_start = GetSecs;
    made_practice_offer = 0; 
   
    % Code to collect response
    while GetSecs - practice_time_response_window_start < max_response_window_duration
        [keyIsDown,~,keyCode] = KbCheck(-1); %record keycode
        %if keyIsDown
        if (keyIsDown && size(find(keyCode),2) ==1)
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user'); % allow aborting the study here
            elseif any(keyCode(resp_key_codes_phase1)) % IF the pressed key matches a response key...
                
                made_practice_offer = 1;

                % This is where response encoding would go if we were
                % saving responses. 

                break % change screen as soon as they respond
            end % if response key
        end % if keypress
    end % while
    
       
    %%% Practice: ISI
    
    Screen('DrawTexture', wind, practice_stim_img,[],img_location_rect);
    DrawFormattedText(wind, affiliation_txt, 'center', screenheight*0.7);
    Screen('Flip', wind, [], 1); % flip w/o clearing buffer
    
    time_isi_start = GetSecs;
    
    while (GetSecs - time_isi_start) < isi_duration
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
    
    
    %%% Practice: OUTCOME
    
    if made_practice_offer == 0
        Screen('Flip',wind);
        DrawFormattedText(wind, 'YOU DID NOT RESPOND IN TIME.', 'center', 'center', [255 0 0]);
        Screen('Flip',wind);
    else
        % Create share/keep text (random)
        sharekeep_text = partner_responses{t};
        
        % Add text w/ their share/keep decision
        DrawFormattedText(wind, sharekeep_text, 'center', screenheight*0.8);
        Screen('Flip', wind);
    end
    
    time_outcome_start = GetSecs;
    
    while (GetSecs - time_outcome_start) < outcome_duration
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
    
    
    %Practice ITI
    DrawFormattedText(wind,'+', 'center', 'center',[0 0 0]);
    Screen('Flip', wind);
    time_iti_start = GetSecs;
    
    while (GetSecs - time_iti_start) < iti_duration
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
end % end practice loop for phase 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% END Practice: PHASE 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Screen('FillRect', wind, gry);
DrawFormattedText(wind, 'You''ve completed the practice trials for part 1! Please tell your experimenter whether you have any questions.', 'center', 'center', blk, 45, [], [], 1.4);
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
%%% START PART 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Allow participant to start the task by pressing all 4 response keys.
DrawFormattedText(wind, 'The experiment is ready to begin!','center',screenheight*.1);
DrawFormattedText(wind, 'To start the experiment, simultaneously press and hold all four response keys (f, g, h, and j).', 'center', rect(4)*.9, blk, 50);
Screen('Flip', wind);
while 1
    [keyIsDown,~,keyCode] = KbCheck(-1);
    if keyIsDown
        if keyCode(esc_key_code)
            sca
            error('Experiment aborted by user!');
        elseif all(keyCode(resp_key_codes_phase1))
            break
        end
    end
end

Screen('FillRect', wind, wht);
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


% Creat trialText string
phase1_response_prompt_text = '$1     $2     $3     $4';


%%% PHASE 1 TRIAL LOOP %%%

for t = 1:nT_phase1 % Phase 1 Trial Loop
    % In here, use interactions_matrix_phase1, with columns partner &
    % share/keep (1/0)
    
    % Block break code
    if t == (nT_phase1/2 + 1) % if this trial is the first in the 2nd half
        breaktext = ['You are halfway through this part of today''s study.\n\n'...
            'You can now take a brief break. The task will continue automatically '...
            'in 30 seconds or you can press all four response keys simultaneously '...
            'to continue whenever you are ready.'];
        
        DrawFormattedText(wind, breaktext, 'center', 'center',[],55);
        Screen('Flip', wind);
        
        breakttime_start = GetSecs;
        
        while (GetSecs - breakttime_start) < 30
            [keyIsDown,~,keyCode] = KbCheck(-1);
            if keyIsDown
                if all(keyCode(resp_key_codes_phase1))
                    break
                elseif keyCode(esc_key_code)
                    sca
                    error('Experiment aborted by user!');
                end
            end
        end
        
        DrawFormattedText(wind, 'Beginning the experiment in 5 seconds...', 'center','center');
        pre_block_wait_time = GetSecs;
        Screen('Flip', wind);
        while (GetSecs - pre_block_wait_time) < 5
            [keyIsDown,~,keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(esc_key_code)
                    sca
                    error('Experiment aborted by user!');
                end
            end
        end
    end
    
    % Identify partner number, their affiliation
    tmp_partnerID = interaction_matrix_phase1(t,1);
    if partner_matrix(tmp_partnerID,1) == 1
        affiliation_txt = 'Democrat';
    elseif partner_matrix(tmp_partnerID,1) == 0
        affiliation_txt = 'Republican';
    end
    
    %%% Part 1: PARTNER DISPLAY
    
    % Display the partner & their affiliation
    trial_stim_img = Screen('MakeTexture', wind, allimages(:,:,:,tmp_partnerID));
    Screen('DrawTexture', wind, trial_stim_img,[],img_location_rect);
    DrawFormattedText(wind, affiliation_txt, 'center', screenheight*0.7);
    Screen('Flip', wind, [], 1); % flip w/o clearing buffer
    
    time_trial_start = GetSecs;
    
    while (GetSecs - time_trial_start) < showpartner_phase1_duration
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
    
    
    %%% Part 2: RESPONSE WINDOW
    
    DrawFormattedText(wind,phase1_response_prompt_text, 'center', screenheight * 0.85);
    Screen('Flip', wind);
    
    time_response_window_start = GetSecs;
    
    % Code to collect response
    while GetSecs - time_response_window_start < max_response_window_duration
        [keyIsDown,resp_time,keyCode] = KbCheck(-1); %record keycode
        %if keyIsDown
        if (keyIsDown && size(find(keyCode),2) ==1)
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user'); % allow aborting the study here
            elseif any(keyCode(resp_key_codes_phase1)) % IF the pressed key matches a response key...

                % Record RT
                subjDataPhase1.data.participant_offer_RT(t) = resp_time - time_response_window_start; % record RT

                % Record choice
                if strcmp(KbName(keyCode),'f')
                    tmp_offer = 1;
                elseif strcmp(KbName(keyCode),'g')
                    tmp_offer = 2;
                elseif strcmp(KbName(keyCode),'h')
                    tmp_offer = 3;
                elseif strcmp(KbName(keyCode),'j')
                    tmp_offer = 4; 
                end
                subjDataPhase1.data.participant_offer_choice(t) = tmp_offer;

                % Record their total on this trial (amount kept + returned
                % amount if applicable).
                subjDataPhase1.data.phase1trial_total_received(t) = ...
                    (4-tmp_offer) + tmp_offer * 3 * interaction_matrix_phase1(t,2);
                    % amount kept       tripled offer * share/keep 1/0 variable
                break % change screen as soon as they respond
            end % if response key
        end % if keypress
    end % while
    
    
    %%% Part 3: ISI
    
    Screen('DrawTexture', wind, trial_stim_img,[],img_location_rect);
    DrawFormattedText(wind, affiliation_txt, 'center', screenheight*0.7);
    Screen('Flip', wind, [], 1); % flip w/o clearing buffer
    
    time_isi_start = GetSecs;
    
    while (GetSecs - time_isi_start) < isi_duration
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
    
    
    %%% Part 4: OUTCOME
    
    if isnan(subjDataPhase1.data.participant_offer_RT(t))
        Screen('Flip',wind);
        DrawFormattedText(wind, 'YOU DID NOT RESPOND IN TIME.', 'center', 'center', [255 0 0]);
        Screen('Flip',wind);
    else
        % Create share/keep text
        if interaction_matrix_phase1(t,2) == 1
            sharekeep_text = 'Partner''s decision: SHARE';
        elseif interaction_matrix_phase1(t,2) == 0
            sharekeep_text = 'Partner''s decision: KEEP';
        end
        
        % Add text w/ their share/keep decision
        DrawFormattedText(wind, sharekeep_text, 'center', screenheight*0.8);
        Screen('Flip', wind);
    end
    
    time_outcome_start = GetSecs;
    
    while (GetSecs - time_outcome_start) < outcome_duration
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
    
    
    %%% Part 5: ITI (brief inter-trial break w/ fixation point)
    
    DrawFormattedText(wind,'+', 'center', 'center',[0 0 0]);
    Screen('Flip', wind);
    time_iti_start = GetSecs;
    
    save(output_filenamepath,'subjDataPhase1','subjDataPhase2'); % save out data every trial
    
    while (GetSecs - time_iti_start) < iti_duration
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
end % end trial loop for phase 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% END PHASE 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% show end text
Screen('FillRect', wind, gry);
DrawFormattedText(wind, 'You''ve completed the first part of this task.\n\nPlease ring the bell to inform the experimenter!', 'center', 'center', blk, 45, [], [], 1.4);
Screen('Flip', wind);
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
%%% Instructions: PHASE 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define the task instructions (being displayed to participant)

instructStr = cell(0); % necessary to remove part 1 instructions
instructStr{1} = ['As a reminder, in the next task, you will be interacting with the same 8 partners.'];
instructStr{2} = ['This time, remember that the roles of the interaction are reversed. Your partners '...
    'can offer you $1, $2, $3, or $4 out of a total of $4. The amount they choose to send '...
    'triples in value (so if they send $2, you receive $6.\n\nYOUR choice is now to either '...
    'share 50/50 the money you receive back with them, or keep it all for yourself.'];
instructStr{3} = ['During each interaction, you will be shown your partner''s face, '...
    'some information about them, and their offer. \n\nOnce the response prompt appears on the '...
    'screen, you will have TWO (2) seconds to enter your response (to share or to keep).'];
instructStr{4} = ['If you do not respond in time, you will forfeit all of the money offered '...
    'on that trial. Please be sure to respond during the response window!'];
instructStr{5} = ['Use the ''f'' key to SHARE, and the ''j'' key to KEEP. Please keep your fingers '...
    'on these two keys at all times during the study.'];
instructStr{6} = ['In this phase you will complete a total of 80 interactions (10 with each partner).'];

if doinstr
    %for loop for instruction strings
    for loopCnt = 1:length(instructStr)
        
        DrawFormattedText(wind, 'Reminders: Part 2', 'center', rect(4)*.1, blk); %what is the rect?
        DrawFormattedText(wind, instructStr{loopCnt}, 'center', rect(4)*.2, blk, 55, [], [], 1.4); %not sure what numbers to specify
        Screen('Flip',wind,[],1);
        
        WaitSecs(3);
        
        DrawFormattedText(wind, 'Press the space bar to continue when ready.', 'center', rect(4)*.9, blk);
        Screen('Flip', wind);
        
        while 1
            [keyIsDown,~,keyCode] = KbCheck(-1);
            if keyIsDown && any(keyCode(space_key_code))
                break
            elseif keyIsDown && keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
end

% Check-In
DrawFormattedText(wind, 'This is the end of the reminders for part 2! Please tell your experimenter whether you have any questions.', 'center', 'center', blk, 45, [], [], 1.4);
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
%%% START PART 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Allow participant to start the task by pressing both response keys.
DrawFormattedText(wind, 'The experiment is ready to begin!','center',screenheight*.1);
DrawFormattedText(wind, 'To start the experiment, simultaneously press and hold both response keys (f and j).', 'center', rect(4)*.9, blk, 50);
Screen('Flip', wind);
while 1
    [keyIsDown,~,keyCode] = KbCheck(-1);
    if keyIsDown
        if keyCode(esc_key_code)
            sca
            error('Experiment aborted by user!');
        elseif sum(keyCode(resp_key_codes_phase2))==2 % Only 2 keys being pressed!
            break
        end
    end
end

Screen('FillRect', wind, wht);
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

% Creat trialText string
phase2_response_prompt_text = 'SHARE         or         KEEP';


%%% PHASE 1 TRIAL LOOP %%%

for t = 1:nT_phase2 % Phase 1 Trial Loop
    % In here, use interactions_matrix_phase2, with columns partner &
    % offer ($1, 2, 3, or 4)
    
    % Block break code
    if t == (nT_phase2/2 + 1) % if this trial is the first in the 2nd half
        breaktext = ['You are halfway through this part of today''s study.\n\n'...
            'You can now take a brief break. The task will continue automatically '...
            'in 30 seconds or you can press both response keys simultaneously '...
            'to continue whenever you are ready.'];
        
        DrawFormattedText(wind, breaktext, 'center', 'center',[],55);
        Screen('Flip', wind);
        
        breakttime_start = GetSecs;
        
        while (GetSecs - breakttime_start) < 30
            [keyIsDown,~,keyCode] = KbCheck(-1);
            if keyIsDown
                if sum(keyCode(resp_key_codes_phase2))==2
                    break
                elseif keyCode(esc_key_code)
                    sca
                    error('Experiment aborted by user!');
                end
            end
        end
        
        DrawFormattedText(wind, 'Beginning the experiment in 5 seconds...', 'center','center');
        pre_block_wait_time = GetSecs;
        Screen('Flip', wind);
        while (GetSecs - pre_block_wait_time) < 5
            [keyIsDown,~,keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(esc_key_code)
                    sca
                    error('Experiment aborted by user!');
                end
            end
        end
    end
    
    % Identify partner number, their affiliation
    tmp_partnerID = interaction_matrix_phase2(t,1);
    if partner_matrix(tmp_partnerID,1) == 1
        affiliation_txt = 'Democrat';
    elseif partner_matrix(tmp_partnerID,1) == 0
        affiliation_txt = 'Republican';
    end

    offer_text = sprintf('Offer: $%i. Received: $%i',interaction_matrix_phase2(t,2), interaction_matrix_phase2(t,2)*3);
    
    %%% Part 1: PARTNER DISPLAY
    
    % Display the partner & their affiliation
    trial_stim_img = Screen('MakeTexture', wind, allimages(:,:,:,tmp_partnerID));
    Screen('DrawTexture', wind, trial_stim_img,[],img_location_rect);
    DrawFormattedText(wind, affiliation_txt, 'center', screenheight*0.7);
    DrawFormattedText(wind, offer_text, 'center', screenheight*.8);
    Screen('Flip', wind, [], 1); % flip w/o clearing buffer
    
    time_trial_start = GetSecs;
    
    while (GetSecs - time_trial_start) < showpartner_phase2_duration
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user!');
            end
        end
    end
    
    
    %%% Part 2: RESPONSE WINDOW
    
    DrawFormattedText(wind,phase2_response_prompt_text, 'center', screenheight * 0.9);
    Screen('Flip', wind);
    
    time_response_window_start = GetSecs;
    
    % Code to collect response
    while GetSecs - time_response_window_start < max_response_window_duration
        [keyIsDown,resp_time,keyCode] = KbCheck(-1); %record keycode
        %if keyIsDown
        if (keyIsDown && size(find(keyCode),2) ==1)
            if keyCode(esc_key_code)
                sca
                error('Experiment aborted by user'); % allow aborting the study here
            elseif any(keyCode(resp_key_codes_phase2)) % IF the pressed key matches a response key...

                % Record RT
                subjDataPhase2.data.participant_sharekeep_RT(t) = resp_time - time_response_window_start; % record RT

                % Record choice
                if strcmp(KbName(keyCode),'f')
                    tmp_response= 1;
                elseif strcmp(KbName(keyCode),'j')
                    tmp_response = 0; 
                end
                subjDataPhase2.data.participant_sharekeep_choice(t) = tmp_response;

                % Record their total on this trial (amount kept + returned
                % amount if applicable).
                subjDataPhase2.data.phase2trial_total_received(t) = ...
                    interaction_matrix_phase2(t,2) * 1.5 * tmp_response + ... % if they share, it's 1.5x
                    interaction_matrix_phase2(t,2) * 3 * (1-tmp_response);    % if they keep, it's 3x
                    
                break % change screen as soon as they respond
            end % if response key
        end % if keypress
    end % while
    
    
    %%% Part 3: ITI
    
    if isnan(subjDataPhase2.data.participant_sharekeep_RT(t)) % IF THEY DO NOT RESPOND IN TIME
        % 1. show the red text
        DrawFormattedText(wind, 'YOU DID NOT RESPOND IN TIME.', 'center', 'center', [255 0 0]);

        Screen('Flip', wind);
        time_non_response_start = GetSecs;
        
        save(output_filenamepath,'subjDataPhase1','subjDataPhase2'); % save out data every trial

        while (GetSecs - time_non_response_start) < 1
            [keyIsDown,~,keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(esc_key_code)
                    sca
                    error('Experiment aborted by user!');
                end
            end
        end
           
        % 2. show the normal '+' for the rest of the time
        DrawFormattedText(wind,'+', 'center', 'center', [0 0 0]);
        Screen('Flip', wind);

        while (GetSecs - time_non_response_start) < iti_duration
            [keyIsDown,~,keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(esc_key_code)
                    sca
                    error('Experiment aborted by user!');
                end
            end
        end

    else % BUT IF THEY DID RESPOND IN TIME, DO A NORMAL ITI
        DrawFormattedText(wind,'+', 'center', 'center');
        Screen('Flip', wind);
        time_iti_start = GetSecs;
        
        save(output_filenamepath,'subjDataPhase1','subjDataPhase2'); % save out data every trial

        while (GetSecs - time_iti_start) < iti_duration
            [keyIsDown,~,keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(esc_key_code)
                    sca
                    error('Experiment aborted by user!');
                end
            end
        end
    end
end % end trial loop for phase 2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% END PHASE 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% show end text
Screen('FillRect', wind, gry);
DrawFormattedText(wind, 'You''ve completed the second part of this task.\n\nPlease ring the bell to inform the experimenter!', 'center', 'center', blk, 45, [], [], 1.4);
Screen('Flip', wind);
while 1
    [keyIsDown,~,keyCode] = KbCheck(-1);
    if keyIsDown
        if keyCode(esc_key_code)
            sca
            error('Experiment aborted by user!');
        elseif any(keyCode(trig_key_code))
            sca
            break
        end
    end
end

% CODE HERE FOR SAVING OUT THE DATA TO A FILE!
