function [subjData] = IATv6(subjID, day, testMode, wind, blk, wht, gry, rect)
    %% 
    % subjID must be a 3-character string (e.g. '003')
    % day is a 1-character string - '1' or '2'
    % testMode must be either 0 (do the full study) or 1 (do an abbreviated study)
    % 
    % DATA:
    %
    % Stimulus Data:
    % 'White' = 0
    % 'Black' = 1
    % 'Pleasant' = 1
    % 'Unpleasant' = 0
    %
    % set up defaults
%    Screen('Preference', 'SkipSyncTests', 1);   % skips sync tests for monitor relay timing (*ideally don't use this, mostly for use during testing w/ dual monitor setup)
    if nargin < 3
        testMode = 1; % assume test mode (unless otherwise specified)
    end
    if nargin < 1
        subjID = '000'; % assume default subjid 000 (unless otherwise specified)
    end  

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% DESCRIPTION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
            YYYY.MM.DD - UPDATES
            2018.11.20 - Cleaned Master Copy      
            2019.05.08 - Added lines so that only 1 keypress is recorded.
                         If 2 keys pressed simultaneously, no response
                         registered.
            2020.02.13 - Fixed a bug in the previous edit (2019) so that
                         if 2 keys are pressed simultaneously, no response
                         is registered.
        %}

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% PREPARATION & GLOBAL VARS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Create Experiment Window
%    if testMode == 1
%        rect=[1600 0 2400 600];
%        [wind, rect] = Screen('OpenWindow', max(Screen('Screens')) , 200, rect);
%    else
%        [wind, rect] = Screen('OpenWindow', max(Screen('Screens')));
%    end
%     
%     % Define Experiment Window
%     Screen('BlendFunction', wind, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);   % turn on aliasing to allow line to be smooth
%     blk = BlackIndex(wind);
%     wht = WhiteIndex(wind);
%     gry = GrayIndex(wind, 0.8);
%     Screen('TextFont',wind,'default');

% Create a screen that waits for the experimenter to intentionally start the next task/script (for the BST wrapper)
%DrawFormattedText(wind, 'Waiting for experimenter to initialize the next task...', 'center', 'center');
%Screen(wind, 'Flip');
%while 1
%    [keyIsDown,~,keyCode] = KbCheck(-1);
%    if keyIsDown
%        if keyCode(KbName('ESCAPE'))
%            error('Experiment aborted by user!');
%        elseif any(keyCode(KbName('Return')))
%            break
%        end
%    end
%end

% set up file paths
if ismac %If the computer is a mac
    homepath = [filesep 'Volumes' filesep 'Research' filesep 'AHSS Psychology' filesep 'shlab' filesep 'Projects' filesep 'BST' filesep 'task' filesep];
end

if IsWin %If the computer is a windows
    homepath = ['S:' filesep 'Projects' filesep 'BST' filesep 'task' filesep];
end

imgpath_black = ['images' filesep 'IAT' filesep 'blackFaces'];
imgpath_white = ['images' filesep 'IAT' filesep 'whiteFaces'];
outputpath = ['output' filesep];

rng('shuffle');
t=clock; 

iti=0.25;
noRespTime=.2;
correctionOffset=.005; 

% basic keyboard prep
KbName('UnifyKeyNames');    % for OS X

% Define Response Keys % Work on updating code to match these response
% keys.
resp_keys = {'e', 'i'};
resp_key_codes = KbName(resp_keys);
space_key_code = KbName('space');
esc_key_code = KbName('ESCAPE');
trig_key_code = KbName('Return');

screenWidthPix = rect(RectRight);
screenHeightPix = rect(RectBottom);
yCenter=screenHeightPix/2;
labelVPos1=round(.05*screenHeightPix); %in percentage of screen height
labelVPos2=round(.1*screenHeightPix); %in percentage of screen height
labelVPos3=round(.15*screenHeightPix); %in percentage of screen height
labelHPos=round(.15*screenWidthPix); %in percentage of screen width
wordHPos=yCenter-10;

% Determine total number of trials in the task based on whether it's in testMode
if testMode == 1
    nT = 60;
else
    nT = 200;
end

% set up trial Order
switchAssoc=0; % Incongruent first for all participants. (1 = congruent first, 0 = incongruent first)

%Create structure to hold data in
subjData = struct;
subjData.params.ID = subjID;
subjData.params.condition = switchAssoc;

%Create variables for data table
blockNum = nan(nT,1);
trialNum = nan(nT,1);
cumTrialNum = nan(nT, 1);
stimulus = cell(nT,1);
stimulusValence = nan(nT ,1);
stimulusRace = nan(nT, 1);
response = nan(nT, 1);
correct = nan(nT,1);
correctionStart = nan(nT,1);
correctionTime = nan(nT,1);
RT = nan(nT,1);
startTime = nan(nT, 1);
trialtype = cell(nT,1);
cattype = cell(nT,1);

%Create data table
subjData.data = table(blockNum, trialNum, cumTrialNum, stimulus, stimulusRace, stimulusValence, response, correct, correctionTime, RT, startTime, correctionStart,trialtype,cattype);

outfName = 'testFile_01';
[outfName,errmsg] = sprintf('%s_%s_%d.%02.0f.%02.0f_%02.0f.%02.0f.%02.0f', subjID, mfilename, t);
%OPEN OUTPUT FILES FOR IMAGE ORDER AND nBACK RESPONSE

% set up the path to the file on disk
subjFile = fopen([homepath outputpath 'tmp_iattask_subj' subjID '_day' day '_' num2str(now) '.txt'],'w');
fprintf(subjFile,'SUBJECT ID\tCONDITION\tBLOCK\tTRIAL NUM\tCUMULATIVE TRIAL NUM\tSTIM\tSTIM VALENCE\tSTIM RACE\tRESPONSE\tCORRECT\tRT\tSTART TIME\tCORRECTION TIME\tCORRECTION START\n');

% capture keypresses so that they don't affect the editor or console
% use cmd-c to re-allow keys should execution fail before code sets flag back
if testMode == 1
    ListenChar(2);
end

    %% Establish Try
    %{
    the majority of the script is established in this try section. if anything contained within the try statement fails the catch section executes allowing the script to break gracefully rather than throwing an error & locking the user out of the screen
    %} 
    try
%%
% Load Faces 
blackDir = imgpath_black;
whiteDir= imgpath_white;
homeDir= homepath;

cd(blackDir); %load the black faces
fnames=dir('*.jpg');
fnames=struct2cell(fnames);
fnames=fnames(1,:);
for ind=1:length(fnames)
    black(ind).name=fnames{ind};
    black(ind).image=double(imread(black(ind).name));
end
numBlackFaces=length(black);
cd(homeDir);

cd(whiteDir); %load the white faces
fnames=dir('*.jpg');
fnames=struct2cell(fnames);
fnames=fnames(1,:);
for ind=1:length(fnames)
    white(ind).name=fnames{ind};
    white(ind).image=double(imread(white(ind).name));
end    
cd(homeDir);
numWhiteFaces=length(white);


goodWords={'Great', 'Terrific', 'Wonderful', 'Fabulous', 'Superb', 'Nice', 'Fantastic', 'Lovely'};
badWords={'Awful', 'Terrible', 'Horrible', 'Disgusting', 'Horrid', 'Foul', 'Revolting', 'Nasty'};
numGoodWords=length(goodWords);
numBadWords=length(badWords);
flowers={'Carnation', 'Daisy', 'Lily', 'Orchid', 'Poppy', 'Rose', 'Sunflower', 'Tulip'};
insects={'Beetle', 'Centipede', 'Cockroach', 'Flea', 'Mosquito', 'Scorpion', 'Spider', 'Tick'};
numFlowers=length(flowers);
numInsects=length(insects);


% Display parameters
fixColor=[0];
textcolor=[0];
flowerInsectColor=[255 255 255];
%blackWhiteColor=[255 255 255];
blackWhiteColor = [128 128 128];
%goodBadColor=[255 255 0];
goodBadColor=[255 140 0];


% Note that the following IF statement always evaluates to true, given that
% switchAssoc is set earlier in this script to be 0. (INCONGRUENT FIRST)

% Blocks are 1 (pleasant/unpleasant), 2 (black/white), 3 (Black/pleasant & White/unpleasant), 4 (Black/Unpleasant & White/pleasant), 5-7 insects & flowers, 8 is unpleasant/pleasant
if switchAssoc % Sets up blocks so it's bad/good (OR good/bad), b/w, and then incongruent x2, good/bad, and congruentx2 OR congruent x2, bad/good, incongruentx2
            % Also makes block length vary (20, 20, 20, 40, 40, 20, 40)
    blockOrder = [ones(20,1)*8;ones(20,1)*2;ones(20,1)*4;ones(40,1)*4;ones(40,1);ones(20,1)*3;ones(40,1)*3]; % 8 2 4 4 1 3 3 (CONGRUENT FIRST)
else
    blockOrder = [ones(20,1);ones(20,1)*2;ones(20,1)*3;ones(40,1)*3;ones(40,1)*8;ones(20,1)*4;ones(40,1)*4]; % 1 2 3 3 8 4 4 (INCONGRUENT FIRST)
end
blockNum = [ones(20,1);ones(20,1)*2;ones(20,1)*3;ones(40,1)*4;ones(40,1)*5;ones(20,1)*6;ones(40,1)*7];
            % 20 ones     20 twos     20 threes     40 fours    40 fives     20 sixes   40 sevens
            %         20         40           60           100         140          160        200 
            %                           PRAC         TEST        PRAC           PRAC      TEST 

subjData.params.blockOrder = blockOrder;
subjData.params.blockNum = blockNum;
            
practest = cell(length(blockNum),1);
for i = 1:length(blockNum)
    if ((i > 60) && (i <= 100)) || (i > 160)
        practest{i} = 'TEST';
    else 
        practest{i} = 'PRAC';
    end
end

            
trialOrderB1 = (mod(randperm(20),2)+3)'; 
trialOrderB2 = (mod(randperm(20),2)+1)';

trialOrderB3 = zeros(20,1);
tmp1 = (mod(randperm(10),2)+1)';
tmp2 = (mod(randperm(10),2)+3)';
if round(rand)
    trialOrderB3(1:2:end)=tmp1;
    trialOrderB3(2:2:end)=tmp2;
else
    trialOrderB3(1:2:end)=tmp2;
    trialOrderB3(2:2:end)=tmp1;
end

trialOrderB4 = zeros(40,1);
tmp1 = (mod(randperm(20),2)+1)';
tmp2 = (mod(randperm(20),2)+3)';
if round(rand)
    trialOrderB4(1:2:end)=tmp1;
    trialOrderB4(2:2:end)=tmp2;
else
    trialOrderB4(1:2:end)=tmp2;
    trialOrderB4(2:2:end)=tmp1;
end

trialOrderB5 = (mod(randperm(40),2)+3)';

trialOrderB6 = zeros(20,1);
tmp1 = (mod(randperm(10),2)+1)';
tmp2 = (mod(randperm(10),2)+3)';
if round(rand)
    trialOrderB6(1:2:end)=tmp1;
    trialOrderB6(2:2:end)=tmp2;
else
    trialOrderB6(1:2:end)=tmp2;
    trialOrderB6(2:2:end)=tmp1;
end

trialOrderB7 = zeros(40,1);
tmp1 = (mod(randperm(20),2)+1)';
tmp2 = (mod(randperm(20),2)+3)';
if round(rand)
    trialOrderB7(1:2:end)=tmp1;
    trialOrderB7(2:2:end)=tmp2;
else
    trialOrderB7(1:2:end)=tmp2;
    trialOrderB7(2:2:end)=tmp1;
end

%Insert testmode condition so that you don't have to go through the entire task every time
if testMode == 1
    trialOrder = [trialOrderB1; trialOrderB2; trialOrderB3];
else
    trialOrder=[trialOrderB1; trialOrderB2; trialOrderB3; trialOrderB4; trialOrderB5; trialOrderB6; trialOrderB7];
end

subjData.params.trialOrder = trialOrder;

%Set up Blocks
%have a selector for black/white side and blackgood/bad order
switchSide=round(rand);

% Practice Good/Bad
block(1).name = 'goodbad';
block(1).sortLabels = {'Pleasant', 'Unpleasant'};
if switchSide block(1).sortLabels = block(1).sortLabels(:,[2 1]); end
block(1).leftLabel = block(1).sortLabels(:,1);
block(1).rightLabel = block(1).sortLabels(:,2);
block(1).hiTextColor = goodBadColor;
block(1).type = 'SINGLE';

block(2).name = 'blackwhite';
block(2).sortLabels = {'Black', 'White'};
if switchSide block(2).sortLabels = block(2).sortLabels(:,[2 1]); end
block(2).leftLabel = block(2).sortLabels(:,1);
block(2).rightLabel = block(2).sortLabels(:,2);
block(2).hiTextColor = blackWhiteColor;
block(2).type = 'SINGLE';

block(3).name = 'blackgood';
block(3).sortLabels = {'Black', 'White'; ...
                       'Pleasant', 'Unpleasant'};
if switchSide block(3).sortLabels = block(3).sortLabels(:,[2 1]); end
block(3).leftLabel = block(3).sortLabels(:,1);
block(3).rightLabel = block(3).sortLabels(:,2);
block(3).hiTextColor = blackWhiteColor;
block(3).loTextColor = goodBadColor;
block(3).type = 'INCONGRUENT';

block(4).name = 'blackbad';
block(4).sortLabels = {'Black', 'White'; ...
                       'Unpleasant', 'Pleasant'};
if switchSide block(4).sortLabels = block(4).sortLabels(:,[2 1]); end
block(4).leftLabel = block(4).sortLabels(:,1);
block(4).rightLabel = block(4).sortLabels(:,2);
block(4).hiTextColor = blackWhiteColor;
block(4).loTextColor = goodBadColor;
block(4).type = 'CONGRUENT';

block(5).name = 'flowersinsects';
block(5).sortLabels = {'Flowers', 'Insects'};
if switchSide block(5).sortLabels = block(5).sortLabels(:,[2 1]); end
block(5).leftLabel = block(5).sortLabels(:,1);
block(5).rightLabel = block(5).sortLabels(:,2);
block(5).hiTextColor = flowerInsectColor;
block(5).type = 'SINGLE';

block(6).name = 'flowersgood';
block(6).sortLabels = {'Flowers', 'Insects'; ...
                       'Pleasant', 'Unpleasant'};
if switchSide block(6).sortLabels = block(6).sortLabels(:,[2 1]); end
block(6).leftLabel = block(6).sortLabels(:,1);
block(6).rightLabel = block(6).sortLabels(:,2);
block(6).hiTextColor = flowerInsectColor;
block(6).loTextColor = goodBadColor;
block(6).type = 'CONGRUENT';

block(7).name = 'flowersbad';
block(7).sortLabels = {'Flowers', 'Insects'; ...
                       'Unpleasant', 'Pleasant'};
if switchSide block(7).sortLabels = block(7).sortLabels(:,[2 1]); end
block(7).leftLabel = block(7).sortLabels(:,1);
block(7).rightLabel = block(7).sortLabels(:,2);
block(7).hiTextColor = flowerInsectColor;
block(7).loTextColor = goodBadColor;
block(7).type = 'INCONGRUENT';

block(8).name = 'badgood';
block(8).sortLabels = {'Unpleasant', 'Pleasant'};
if switchSide block(8).sortLabels = block(8).sortLabels(:,[2 1]); end
block(8).leftLabel = block(8).sortLabels(:,1);
block(8).rightLabel = block(8).sortLabels(:,2);
block(8).hiTextColor = goodBadColor;
block(8).type = 'SINGLE';

subjData.params.block = block;

%Create variables for storing stimuli info
stimName = cell(nT, 1);
stimStr = cell(nT, 1);
corrans = cell(nT, 1);

for ind=1:length(trialOrder)
    switch trialOrder(ind)
        case 1
            stimSel=round(rand*(numBlackFaces-1))+1;
            stimName{ind}=black(stimSel).name;
            stimStr{ind} = sprintf('Screen(''PutImage'', wind, black(%d).image);', stimSel);
            corrans{ind}='Black';
        case 2
            stimSel=round(rand*(numWhiteFaces-1))+1;
            stimName{ind}=white(stimSel).name;
            stimStr{ind} = sprintf('Screen(''PutImage'', wind, white(%d).image);', stimSel);
            corrans{ind}='White';
        case 3
            stimSel=round(rand*(numGoodWords-1))+1;
            stimName{ind}=goodWords{stimSel};
            stimStr{ind} = sprintf('DrawFormattedText(wind,goodWords{%d},''center'',''center'',goodBadColor);', stimSel);
            corrans{ind}='Pleasant';
        case 4
            stimSel=round(rand*(numBadWords-1))+1;
            stimName{ind}=badWords{stimSel};
            stimStr{ind} = sprintf('DrawFormattedText(wind,badWords{%d},''center'',''center'',goodBadColor);', stimSel);
            corrans{ind}='Unpleasant';
        case 5
            stimSel=round(rand*(numFlowers-1))+1;
            stimName{ind}=flowers{stimSel};
            stimStr{ind} = sprintf('DrawFormattedText(wind,flowers{%d},''center'',''center'',flowerInsectColor);', stimSel);
            stimStr{ind} = sprintf('DrawFormattedText(wind,flowers{%d},''center'',wordHPos,flowerInsectColor);', stimSel);
%             stimStr{ind} = sprintf('DrawFormattedText(w,%s,''center'',wordHPos ,goodBadColor);', flowers{stimSel});
            corrans{ind}='Flowers';
        case 6
            stimSel=round(rand*(numInsects-1))+1;
%             insectCtr=insectCtr+1;
            stimName{ind}=insects{stimSel};
            stimStr{ind} = sprintf('DrawFormattedText(wind,insects{%d},''center'',''center'',flowerInsectColor);', stimSel);
            stimStr{ind} = sprintf('DrawFormattedText(wind,insects{%d},''center'',wordHPos,flowerInsectColor);', stimSel);
%             stimStr{ind} = sprintf('DrawFormattedText(w,%s,''center'',wordHPos ,goodBadColor);', insects{stimSel});
            corrans{ind}='Insects';
        otherwise
            Screen('CloseAll');
            errordlg('creating trials broke');
    end
end

    AssertOpenGL
    KbName('UnifyKeyNames');
	  
    % set priority - also set after Screen init
    priorityLevel=MaxPriority(wind);
    Priority(priorityLevel);
    HideCursor;
      
    for ind=1:length(block)
        for jnd=1:size(block(ind).sortLabels,1)
            bbox=Screen('TextBounds', wind, block(ind).leftLabel{jnd});
            block(ind).leftTextStartX(jnd)=labelHPos-round(bbox(3)/2);
            bbox=Screen('TextBounds', wind, block(ind).rightLabel{jnd});
            block(ind).rightTextStartX(jnd)=screenWidthPix-labelHPos-round(bbox(3)/2);
        end
    end
    orText='or';
    bbox=Screen('TextBounds', wind, orText);
    leftOrStartX=labelHPos-round(bbox(3)/2);
	rightOrStartX=screenWidthPix-labelHPos-round(bbox(3)/2);

    
%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% 'WAITING FOR EXPERIMENTER' SCREEN
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Display Text
            Screen('FillRect', wind, gry);
            DrawFormattedText(wind, 'Waiting for experimenter...', 'center', 'center', blk);
            Screen(wind,'Flip');
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
%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% INSTRUCTIONS SCREENS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%Create instruction strings
    
    instructStr{1} = ['In this task, you will be presented with a set of words or images to classify into groups. ' ... 
        'This task requires that you classify items as quickly as you can while making as few mistakes as possible. ' ...
        'Going too slow or making too many mistakes will result in an uninterpretable score.'];
    
    instructStr{2} = ['The following is a list of category labels and the items that belong to each of those categories. \n\n' ...
            'Category Items \n\n' ...
            'GOOD: Great, Terrific, Wonderful, Fabulous, Superb, Nice, Fantastic, Lovely. \n' ...
            'BAD: Awful, Terrible, Horrible, Disgusting, Horrid, Foul, Revolting, Nasty. \n' ...
            'BLACK:  Faces of Black American people \n' ...
            'WHITE:  Faces of White American people'];
    
    instructStr{3} = ['The two labels at the top will tell you which words or images go with each key. ' ...  
        'Every so often the labels at the top will change, switching which words or images go with each key. ' ...
        'Before such a switch, there will be a short break and you will be told to look at the categories.'];
    
    instructStr{4} = ['Things to keep in mind: \n\n' ...
        '- Keep your index fingers on the ''e'' and ''i'' keys to enable rapid response.\n' ...
        '- Each word or image has a correct classification. Most of these are easy.\n' ...
        '- The test gives no results if you go slow -- Please try to go as fast as possible.\n' ...
        '- Expect to make a few mistakes because of going fast. That is OK.\n' ...
        '- If you make a mistake, a red X will appear. You should then correct your response as quickly as possible.'];
    
            for loopCnt = 1:length(instructStr)

                DrawFormattedText(wind, 'Instructions', 'center', rect(4)*.2, blk);
                DrawFormattedText(wind, instructStr{loopCnt}, 'center', 'center', blk, 60, [], [], 1.4);
                Screen('Flip',wind,[],1);
                
                if (testMode == 1)
                    WaitSecs(1);
                else
                    WaitSecs(3);
                end

                DrawFormattedText(wind, 'Press the space bar to continue when ready.', 'center', rect(4)*.9, blk);
                Screen('Flip', wind);

                while 1
                    [keyIsDown,~,keyCode] = KbCheck(-1);
                    if keyIsDown && any(keyCode(space_key_code))
                        break
                    elseif keyIsDown && keyCode(esc_key_code)
                        error('Experiment aborted by user!');
                    end
                end
                
            end     % end for loop
    
               
%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Instructions Check-In
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
            DrawFormattedText(wind, 'This is the end of the instructions. Please tell your experimenter whether or not you have any questions.', 'center', 'center', blk, 45, [], [], 1.4);
            Screen(wind,'Flip');
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
            
%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% BEGINNING OF TASK MESSAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    beginningStr{1} = ['You are about to begin the experiment. In some rounds, there will be one category on each side ' ...
        'and on others there will be two categories on either side. ' ...
        'Please pay close attention to the categories and try to move as quickly and accurately as you can. '...
        'It is alright if you make mistakes, but please try to correct them as quickly as possible.'];
           
    DrawFormattedText(wind, 'Instruction', 'center', rect(4)*.1, blk);
    DrawFormattedText(wind, beginningStr{1} , 'center', 'center', blk, 45, [], [], 1.4);
    Screen('Flip',wind,[],1);
    
    WaitSecs(2);
    
    DrawFormattedText(wind, 'Press the E or I key to continue when you are ready to begin the task.', 'center', rect(4)*.9, blk);
    Screen('Flip', wind);
    
    while 1
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                error('Experiment aborted by user!');
            elseif any(keyCode(resp_key_codes))
                break
            end
        end
    end
    
    % capture keypresses so that they don't affect the editor or console
    % use cmd-c to re-allow keys should execution fail before code sets flag back
    if testMode == 1
        ListenChar(2);
    end
%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% START OF TASK
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('FillRect', wind, wht);
    DrawFormattedText(wind,'+','center','center',fixColor);
    [tmp, beginScan] = Screen('Flip', wind); %begins initial fixation
    elapsedTrialTime=0;

currBlock = 0;
blockCtr = 0;
trialLoop = 1;

% initialize some variables
trialCorrect = nan(nT,1);
trialCorrectionTime = nan(nT, 1);
trialCorrectionStart = nan(nT, 1);
responseTime = nan(nT, 1);
keyResponse = nan(nT, 1);


for ind=1:length(trialOrder)
    trialLoop = trialLoop + 1;
    
    if blockNum(ind) ~= blockCtr  %Tests whether you've looped through all the trials in the block so that it can decide to throw
        % instructions up on the screen again.
        
        trialLoop = 1;
%         instruxStart=GetSecs;
        
        currBlock=(blockOrder(ind));
        blockCtr=blockCtr+1;
        DrawFormattedText(wind,'+','center','center',fixColor);
        [tmp, beginScan] = Screen('Flip', wind); %begins initial fixation
        
        WaitSecs(2);
        
        Screen('FillRect', wind, wht);
        
        if length(block(currBlock).leftLabel)>1
            DrawFormattedText(wind,block(currBlock).leftLabel{1},block(currBlock).leftTextStartX(1),labelVPos1,block(currBlock).hiTextColor);
            DrawFormattedText(wind,block(currBlock).rightLabel{1},block(currBlock).rightTextStartX(1),labelVPos1,block(currBlock).hiTextColor);
            DrawFormattedText(wind,orText,leftOrStartX,labelVPos2,textcolor);
            DrawFormattedText(wind,orText,rightOrStartX,labelVPos2,textcolor);
            DrawFormattedText(wind,block(currBlock).leftLabel{2},block(currBlock).leftTextStartX(2),labelVPos3,block(currBlock).loTextColor);
            DrawFormattedText(wind,block(currBlock).rightLabel{2},block(currBlock).rightTextStartX(2),labelVPos3,block(currBlock).loTextColor);
        else
            DrawFormattedText(wind,block(currBlock).leftLabel{1},block(currBlock).leftTextStartX(1),labelVPos1,block(currBlock).hiTextColor);
            DrawFormattedText(wind,block(currBlock).rightLabel{1},block(currBlock).rightTextStartX(1),labelVPos1,block(currBlock).hiTextColor);
        end
        
        DrawFormattedText(wind,'Look at the categories\n \nPress the E or I key to continue','center','center',textcolor);
        Screen('Flip', wind);
        WaitSecs(2);
        while 1
            [keyIsDown,~,keyCode] = KbCheck(-1);
            if keyIsDown
                if any(keyCode(resp_key_codes))
                    break
                elseif keyCode(esc_key_code)
                    error('Experiment aborted by user!');
                end
            end
        end
        Screen('FillRect', wind, wht);
        if length(block(currBlock).leftLabel)>1
            DrawFormattedText(wind,block(currBlock).leftLabel{1},block(currBlock).leftTextStartX(1),labelVPos1,block(currBlock).hiTextColor);
            DrawFormattedText(wind,block(currBlock).rightLabel{1},block(currBlock).rightTextStartX(1),labelVPos1,block(currBlock).hiTextColor);
            DrawFormattedText(wind,orText,leftOrStartX,labelVPos2,textcolor);
            DrawFormattedText(wind,orText,rightOrStartX,labelVPos2,textcolor);
            DrawFormattedText(wind,block(currBlock).leftLabel{2},block(currBlock).leftTextStartX(2),labelVPos3,block(currBlock).loTextColor);
            DrawFormattedText(wind,block(currBlock).rightLabel{2},block(currBlock).rightTextStartX(2),labelVPos3,block(currBlock).loTextColor);
        else
            DrawFormattedText(wind,block(currBlock).leftLabel{1},block(currBlock).leftTextStartX(1),labelVPos1,block(currBlock).hiTextColor);
            DrawFormattedText(wind,block(currBlock).rightLabel{1},block(currBlock).rightTextStartX(1),labelVPos1,block(currBlock).hiTextColor);
        end
        
        screenArray=Screen('GetImage', wind, rect, 'backBuffer');
        screenText=Screen('MakeTexture', wind, screenArray);
        
        KbWait;
        Screen('Flip', wind);
        Screen('DrawTexture', wind, screenText);
        DrawFormattedText(wind,'+','center','center',fixColor);
        WaitSecs(1);
    end
    
    % Updates the screen to reflect our changes to the window.
    
    [tmp, trialStart(ind)]=Screen('Flip', wind);
    
    Screen('DrawTexture', wind, screenText); % PUT UP LABELS AS AN 'IMAGE'
    eval(stimStr{ind}); % EITHER DRAWS A PICTURE OR WRITES TEXT, DEPENDING ON WHAT KIND OF TRIAL THIS IS.
    
    while (GetSecs - trialStart(ind)) < (iti-correctionOffset)
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(esc_key_code)
                error('Experiment aborted by user!');
            end
        end
    end
    [flipTime(ind), stimOnset(ind), flipEndTime(ind)] = Screen('Flip', wind);
    theKeyResponse = '';
    while GetSecs - stimOnset(ind) < noRespTime
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if keyIsDown && keyCode(esc_key_code) %Aborts program if esc key is pressed
            error('Experiment aborted by user!');
        end
    end
    
    timecheck(ind)=GetSecs-stimOnset(ind); % Start time
%     secs=KbWait;
    
    %Continually checks for whether a key has been pressed
    while 1
        [keyIsDown, keyT, keyCode] = KbCheck(-1);
        if keyIsDown
            %After determining a key has been pressed, checks which key and acts accordingly
            if any(keyCode(resp_key_codes)) && (sum(keyCode) == 1)
                responseTime(ind) = keyT - stimOnset(ind); %Response time
                theKeyResponse = KbName(keyCode);
                while 1 %Pause until key is up
                    [keyIsDown] = KbCheck(-1);
                    if keyIsDown == 0
                        break;
                    end
                end
                
                if theKeyResponse == 'e'
                    keyResponse(ind) = 0;
                    if ismember(corrans{ind}, block(currBlock).leftLabel) %Checks to see if 'e' is the correct answer
                        trialCorrect(ind) = 1;
                        break;
                    else
                        trialCorrect(ind) = 0;
                        break;
                    end
                    
                elseif theKeyResponse == 'i'
                    keyResponse(ind) = 1;
                    if ismember(corrans{ind}, block(currBlock).rightLabel) %Checks to see if 'i' is the correct answer
                        trialCorrect(ind) = 1;
                        break;
                    else
                        trialCorrect(ind) = 0;
                        break;
                    end
                end
            elseif keyCode(esc_key_code) %Aborts program is esc key is pressed
                error('Experiment aborted by user!');
            end
        end
    end
    
    %Make sure everything is fine and dandy by printing values in testMode
    if testMode == 1
        disp(currBlock);
        disp(trialLoop);
        disp(ind);
        disp(stimName{ind});
    end
    %Save variables per trial here!
    subjData.data.blockNum(ind) = currBlock;
    subjData.data.trialNum(ind) = trialLoop;
    subjData.data.cumTrialNum(ind) = ind;
    subjData.data.stimulus{ind} = stimName{ind};
    subjData.data.response(ind) = keyResponse(ind); %0 is E and 1 is I
    subjData.data.correct(ind) = trialCorrect(ind);
    subjData.data.RT(ind) = responseTime(ind);
    subjData.data.startTime(ind) = timecheck(ind);
    subjData.data.corrans{ind} = corrans{ind};
    subjData.data.trialtype{ind} = practest{ind};
    subjData.data.cattype{ind} = block(currBlock).type;
    
    %Find valence or race of stimulus
    isPleasant = strcmp(corrans{ind}, 'Pleasant');
    isUnpleasant = strcmp(corrans{ind}, 'Unpleasant');
    isBlack = strcmp(corrans{ind}, 'Black');
    isWhite = strcmp(corrans{ind}, 'White');
    
    if isPleasant
        subjData.data.stimulusValence(ind) = 1;
    elseif isUnpleasant
        subjData.data.stimulusValence(ind) = 0;
    elseif isBlack
        subjData.data.stimulusRace(ind) = 1;
    elseif isWhite
        subjData.data.stimulusRace(ind) = 0;
    end
    
    %Code to run in the event of an incorrect answer
    if ~isnan(trialCorrect(ind)) && ~trialCorrect(ind)
        answerCorrected = 0;
        Screen('DrawTexture', wind, screenText);
        eval(stimStr{ind});
        DrawFormattedText(wind,'X','center','center',[255 0 0]);
        
        %Add some direction for what to do in the event that a mistake has been made.
        DrawFormattedText(wind, 'Please press the correct key in order to proceed through the task.', 'center', rect(4)*.9, blk);
        
        [tmp, errOnset(ind), tmp2] = Screen('Flip', wind);
        trialCorrectionStart(ind) = GetSecs;
        
        while ~answerCorrected %Runs until the correct key is pressed
            [keyIsDown, keyT, keyCode] = KbCheck(-1);
            if keyIsDown && any(keyCode(resp_key_codes)) && sum(keyCode == 1)
                while 1 %Pause until key is up
                    [keyIsDown] = KbCheck(-1);
                    if keyIsDown == 0
                        break;
                    end
                end
                correctionKey = KbName(keyCode);                
                if correctionKey == 'e' %If participant presses 'e', checks to see whether that is correct. If so, logs response time.
                    if ismember(corrans{ind}, block(currBlock).leftLabel)
                        correctionEnd = keyT; 
                        trialCorrectionTime(ind) = correctionEnd - stimOnset(ind);
                        answerCorrected = 1;
                    end
                elseif correctionKey == 'i' %If participant presses 'i', checks to see whether that is correct. If so, logs response time.
                    if ismember(corrans{ind}, block(currBlock).rightLabel)
                        correctionEnd = keyT;
                        trialCorrectionTime(ind) = correctionEnd - stimOnset(ind);
                        answerCorrected = 1;
                    end
                end
            end
            if keyIsDown && keyCode(esc_key_code)
                error('Experiment aborted by user!');
            end
        end
        
        %Collect correction data
        subjData.data.correctionTime(ind) = trialCorrectionTime(ind);
        subjData.data.correctionStart(ind) = trialCorrectionStart(ind);
          
    end
    Screen('DrawTexture', wind, screenText);
    DrawFormattedText(wind,'+','center','center',fixColor);
    
    % Save outdata for this trial
    fprintf(subjFile, '%s\t%i\t%i\t%i\t%i\t%s\t%i\t%i\t%i\t%i\t%f\t%f\t%f\t%f\n',...
        subjID, subjData.params.condition, subjData.data.blockNum(ind),subjData.data.trialNum(ind), subjData.data.cumTrialNum(ind), ...
        subjData.data.stimulus{ind}, subjData.data.stimulusValence(ind), subjData.data.stimulusRace(ind), subjData.data.response(ind),...
        subjData.data.correct(ind), subjData.data.RT(ind), subjData.data.startTime(ind), subjData.data.correctionTime(ind), subjData.data.correctionStart(ind));
end
    
%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% END OF TASK
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('FillRect', wind, gry);
    DrawFormattedText(wind, 'You have completed the task. Please ring the bell to inform the experimenter!', 'center', 'center', blk, 45, [], [], 1.4);
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
    
    fclose(subjFile);
    save([outputpath 'iatTask_subj' subjID '_day' day '_' num2str(now) '.mat'], 'subjData');
    ShowCursor;
    ListenChar(0);
    Priority(0);
    sca;
    catch ME
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Catch
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        "catch" section executes in case of an error in the "try" section above
        importantly, it closes the onscreen window if open
        ME is MATLAB Exception (aka the error code thrown during the try block)
        %}

        try
            fclose(subjFile);
        end
        
        try
           save([outputpath 'iatTask_subj' subjID '_day' day '_' num2str(now) '.mat'], 'subjData');
        end

        ListenChar(0);
        Priority(0);
        sca;
        rethrow(ME)
        
    end % end try
end % end function