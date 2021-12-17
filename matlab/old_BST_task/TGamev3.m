function [subjData] = TGamev3(subjID, day, testMode, condition, wind, blk, wht, gry, rect)
    % 
    % subjID must be a 3-character string (e.g. '003')
    % day is a 1 character string - '1' or '2'
    % testMode must be either 0 (do the full study) or 1 (do an abbreviated study)
    %
    % DATA:
    %
    % Race Data:
    % 'White' = 0
    % 'Black' = 1
    % 'Other' = 2
    %
    % PartnerChoice:
    % Shared = 1
    % Keep = 0
    %
    % set up defaults
    %Screen('Preference', 'SkipSyncTests', 1);   % skips sync tests for monitor relay timing (*ideally don't use this, mostly for use during testing w/ dual monitor setup)
    if nargin < 4
        condition = 2; % assume default condition of second task (unless otherwise specified)
    end
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
            2018.11.20 - Maaaaaaster Cooooopy
            2019.05.08 - Added lines so that only 1 keypress is recorded.
                         If 2 keys pressed simultaneously, no response
                         registered.
        %}

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% PREPARATION & GLOBAL VARS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Create Experiment Window
%       if testMode == 1
%           rect=[1600 0 2400 600];
%           [wind, rect] = Screen('OpenWindow', max(Screen('Screens')) , 200, rect); %To add: If it is test mode, don't hide cursor 
%       else
%           [wind, rect] = Screen('OpenWindow', max(Screen('Screens')));
%       end

%        % Define Experiment Window
%        Screen('BlendFunction', wind, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);   % turn on aliasing to allow line to be smooth
%        blk = BlackIndex(wind);
%        wht = WhiteIndex(wind);
%        gry = GrayIndex(wind, 0.8);
%        Screen('TextFont',wind,'default');
        
    % If TGame goes first, create a screen that waits for the experimenter to intentionally start the next task/script (for the BST wrapper)
%     if condition == 1
%         DrawFormattedText(wind, 'Waiting for experimenter to initialize the next task...', 'center', 'center');
%         Screen(wind, 'Flip');
%         while 1
%             [keyIsDown,~,keyCode] = KbCheck(-1);
%             if keyIsDown
%                 if keyCode(KbName('ESCAPE'))
%                     error('Experiment aborted by user!');
%                 elseif any(keyCode(KbName('Return')))
%                     break
%                 end
%             end
%         end
%     end

        % show loading screen
        DrawFormattedText(wind, 'Setting up...', 'center', 'center', blk);
        Screen(wind,'Flip');

        %{
        rng ('shuffle') seeds the random number generator based on the current time. if the seed is not shuffled, MATLAB will default to the same set of random numbers continuously
        %}
        rng('shuffle');
        
        if ismac
            homepath = [filesep 'Volumes' filesep 'research' filesep 'AHSS Psychology' filesep 'shlab' filesep 'Projects' filesep 'BST' filesep 'task' filesep];
        end
        
        if IsWin
            homepath = ['S:' filesep 'Projects' filesep 'BST' filesep 'task' filesep];
        end
        
        imgpath = ['images' filesep 'TRTG' filesep 'rutgers' filesep];
        outputpath = ['output' filesep];

        % basic keyboard prep
        KbName('UnifyKeyNames');    % for OS X

        % Define Response Keys
        resp_keys = {'0', '1', '2', '3', '4', '5', '0)', '1!', '2@', '3#', '4$', '5%'};
        resp_key_codes = KbName(resp_keys);
        space_key_code = KbName('space');
        esc_key_code = KbName('ESCAPE');
        trig_key_code = KbName('Return');

        % set up the number of stimuli to choose from
        %numTotalStim = 49;
        numTotalStim = 28;


        % set up the number of stimuli (per 3 stimuli groups)
        if testMode == 1
            numTGameStim = 5;
            numTGameBlocks = 2;
        else
            % For TGame the product of stim*blocks should equal 76
            numTGameStim = 38;
            numTGameBlocks = 2;
            HideCursor;
        end
        
        nT = numTGameBlocks*numTGameStim;

        %data struct setup round twooooo
        subjData = struct;
        subjData.params.ID = subjID;
        subjData.params.condition = condition;

        %Setup variable columns for data table
        blockNum = nan(nT,1);
        trialNum = nan(nT,1);
        cumTrialNum = nan(nT,1);
        stimulus = cell(nT,1);
        shared = nan(nT,1);
        partnerChoice = nan(nT,1);
        partnerRace = nan(nT,1);
        received = nan(nT,1);
        RT = nan(nT,1);
        startTime = nan(nT,1);
        
        %Create data table
        subjData.data = table(blockNum, trialNum, cumTrialNum, stimulus, shared, partnerChoice, partnerRace, received, RT, startTime);

        subjData.tOut.bonus = nan; % what's the bonus
        subjData.tOut.pickt = nan; % which trial (t) was picked for the bonus        

        % set up the path to the file on disk
        subjFile = fopen([homepath outputpath 'tmp_tgametask_subj' subjID '_' num2str(now) '.txt'],'w');
        fprintf(subjFile,'SUBJECT ID\tCONDITION\tBLOCK\tTRIAL NUM\tCUMULATIVE TRIAL NUM\tSTIM\tPARTNER RACE\tSHARED\tRECEIVED\tRT\tSTART TIME\n');

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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Trust Rating Task
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% LOAD STIMULI PATHS INTO ARRAYS, RANDOMIZE, AND SELECT SUBSETS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            DrawFormattedText(wind, 'Loading stimuli...', 'center', 'center', blk);
            Screen(wind,'Flip');
            % black faces
            images_rating_blk = dir([imgpath 'black*.png']);
            % white faces
            images_rating_wht = dir([imgpath 'white*.png']);
            % other faces
            images_rating_oth = dir([imgpath 'other*.png']);

            % faces (49 (by default) of each, except 20 of 'other')
            stim_blk = images_rating_blk(randperm(length(images_rating_blk), numTotalStim));
            stim_wht = images_rating_wht(randperm(length(images_rating_wht), numTotalStim));
            stim_oth = images_rating_oth(randperm(length(images_rating_oth), min(numTotalStim, 20)));
            TGame_stim = [stim_blk; stim_wht; stim_oth];
            TGame_stim = TGame_stim(randperm(length(TGame_stim)));

            % separate the stimuli into blocks
            for blockCount = 1:numTGameBlocks
                startLoc = ((blockCount-1)*numTGameStim)+1;
                % break up the face stimuli and put it into a temporary block
                stim_set_block = TGame_stim(startLoc:(startLoc-1+numTGameStim));

                % go through each of the stimuli and add in an image
                % texture so that we can load it quickly later on
                for loopCnt = 1:numTGameStim
                    curStimImage = imread([stim_set_block(loopCnt).('folder') filesep stim_set_block(loopCnt).('name')]);
                    stim_set_block(loopCnt).('stim_texture') = Screen('MakeTexture', wind, curStimImage);
                end

                %add it to the block cell array
                stimBlocks{blockCount} = stim_set_block; %#ok<AGROW>
            end


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
        %%% INSTRUCTIONS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Define Task Instructions  %this is what will be displayed to participants
            instructStr{1} = ['As a reminder, in the following task, you will be interacting with a number of REAL PARTNERS whose responses we already collected. '...
                'For example, some were participants in a previous experiment conducted at Rutgers University in Newark, New Jersey.'...
                '\n\nThese people were interviewed, given the specific details of the tasks, '...
                'and gave their answers in advance regarding what they would do in these situations. '...
                'Their decisions were collected and will be used to determine the outcomes of your interactions today.'];

            instructStr{2} = ['It is well known that faces are particularly important for helping us gather social information. '...
                'For this reason, and to give you a better sense of whom you''re interacting with, we will provide you with a picture of your '...
                'partner for each of these interactions.'];

            instructStr{3} = ['In the following task, you will have the opportunity to make money by participating in economic interactions with '...
                'REAL PARTNERS. For each interaction, you will see a picture of your partner''s face and then choose how much money you want to '...
                'share with that partner.'];

            instructStr{4} = ['The money that you choose to send will QUADRUPLE in amount. Your partner has previously decided, based '...
                'on the amount sent, to either share what they received with you or keep all of it for themselves. Based on your decisions and those '...
                'of your partners, the money will be distributed accordingly.'];

            instructStr{5} = ['For each of the partners, you may choose to share $0, $1, $2, $3, $4 or $5. Partners were told that you had the option to share some '...
                'of the money with them, but that you could also choose to share none of it, and keep it entirely to yourself, leaving them with no money. '...
                'They were made aware that the more you shared with them, the more both of you could make, but they also knew that they could of course '...
                'keep all the money you sent them, returning none of it to you.'];

            instructStr{6} = ['For example, you see a photo of your partner and decide to share $3 of your money with them. '...
                'The money will be quadrupled (becoming $12). If your partner decided to share the money with you, you would receive $6 and they '...
                'would keep $6. If your partner decided to keep the money, you will receive $0 back and they will keep $12. You will lose the money you shared.'];

            instructStr{7} = ['PAYMENT: In addition to receiving $15 per hour for participating in the whole experiment, we are now giving you an additional $5 credit for '...
                'this portion of the experiment, which you can choose to share with the potential of making more money. '...
                'At the end of the study, one interaction will be randomly selected to determine any bonus '...
                'you receive. At that point, you will find out whether or not you received money back. '... 
                'You will receive the amount equal to the amount you kept plus whatever your partner chose to share with you.'...
                '\n\nRemember, these transactions have REAL CONSEQUENCES. If your partner '...
                'decided to keep what you shared, you will not get it back at the end of the experiment.'];

            for loopCnt = 1:length(instructStr)

                DrawFormattedText(wind, 'Instructions: Economic Interactions Task', 'center', rect(4)*.1, blk);
                DrawFormattedText(wind, instructStr{loopCnt}, 'center', rect(4)*.2, blk, 55, [], [], 1.4);
                if loopCnt == 3
                    curStimImage = imread([TGame_stim(length(TGame_stim)).('folder') filesep TGame_stim(length(TGame_stim)).('name')]);
                    Screen('DrawTexture', wind, Screen('MakeTexture', wind, curStimImage), [], [((rect(3)-rect(1))/2)-150 rect(4)*.45 ((rect(3)-rect(1))/2)+150 (rect(4)*.45)+300]);
                end
                Screen('Flip',wind,[],1);

                WaitSecs(3);

                DrawFormattedText(wind, 'Press the space bar to continue when ready.', 'center', rect(4)*.9, blk);
                Screen('Flip', wind);

                while 1
                    [keyIsDown,~,keyCode] = KbCheck(-1);
                    if keyIsDown && any(keyCode(space_key_code))
                        DrawFormattedText(wind, 'Instructions', 'center', rect(4)*.1, blk);
                        Screen('Flip', wind);
                        break
                    elseif keyIsDown && keyCode(esc_key_code)
                        error('Experiment aborted by user!');
                    end
                end

            end     % end for loop

            % Pause to check in after instructions
            Screen('FillRect', wind, gry);
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
        %%% START EXPERIMENT
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %Create trialText string
        trialText = 'How much money would you like to share? \n\n $0     $1     $2     $3     $4     $5';

            % Allow the participant to start the task when they are ready
            DrawFormattedText(wind, 'Press a number between 0 and 5 to start the experiment.', 'center', rect(4)*.9, blk);
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

            for curBlock = 1:length(stimBlocks)
                % change the background to white to match the stimuli
                Screen('FillRect', wind, wht);
                DrawFormattedText(wind, 'Starting...', 'center', 'center', blk);
                Screen('Flip', wind);
                WaitSecs(1);

                for loopCnt = 1:numTGameStim
                    % show the stimulus
                    Screen('DrawTexture', wind, stimBlocks{curBlock}(loopCnt).stim_texture);

                    %Draw text underneath the image
                    DrawFormattedText(wind,trialText, 'center', rect(4) * 0.65);

                    Screen('Flip', wind);

                    % timestamp
                    trialStartTime = GetSecs;

                    while 1
                        [keyIsDown,~,keyCode] = KbCheck(-1);
                        if keyIsDown && any(keyCode(resp_key_codes)) && (sum(keyCode) == 1)
                            theKeyResponse = KbName(keyCode);
                            disp(theKeyResponse)
                            disp(sum(keyCode == 1))
                            disp(theKeyResponse(1))
                            % pause here until the key is up
                            while 1
                                [keyIsDown] = KbCheck(-1);
                                if keyIsDown == 0
                                    break;
                                end
                            end
                            % timestamp
                            endTime = GetSecs;
                            % get the location for saving
                            cellSaveLoc = loopCnt+((curBlock-1)*numTGameStim);
                            % block number
                            subjData.data.blockNum(cellSaveLoc) = curBlock;
                            % trial number
                            subjData.data.trialNum(cellSaveLoc) = loopCnt;
                            subjData.data.cumTrialNum(cellSaveLoc) = loopCnt+(numTGameStim*(curBlock-1));
                            % stimulus
                            subjData.data.stimulus{cellSaveLoc} = stimBlocks{curBlock}(loopCnt).name;
                            % response
                            subjData.data.shared(cellSaveLoc) = str2num(theKeyResponse(1));
                            % confederate response

                            %Find image string
                            imageName = stimBlocks{curBlock}(loopCnt).name;

                            %partnerRace
                            isWhite = contains(imageName, 'white');
                            isBlack = contains(imageName, 'black');

                            if isWhite
                                subjData.data.partnerRace(cellSaveLoc) = 0;
                            elseif isBlack
                                    subjData.data.partnerRace(cellSaveLoc) = 1;
                            else
                                    subjData.data.partnerRace(cellSaveLoc) = 2;
                            end


                            %Get the 5-digit list of responses (based on how much money shared) from the image string.
                            tmp = extractBetween(imageName, 'sk', '.png');
                            partnerResponses = tmp{1};
                            participantShared = str2num(theKeyResponse(1));

                            disp(partnerResponses);
                            disp(participantShared);

                            %Find partner choice (Share = 1 or Keep = 0) based on amount shared by participant if amount shared is not equal to zero
                            if participantShared ~= 0
                                disp(partnerResponses);
                                trialPartnerChoice = str2num(partnerResponses(participantShared));
                                subjData.data.partnerChoice(cellSaveLoc) = trialPartnerChoice;
                                disp(trialPartnerChoice);


                                %If partner chooses to share money, calculate money received for this trial.
                                if trialPartnerChoice == 1
                                    subjData.data.received(cellSaveLoc) = participantShared * 2;
                                else
                                    subjData.data.received(cellSaveLoc) = 0;
                                end
                            else
                                %If the participant shares 0 bucks, they receive 0 bucks.
                                subjData.data.received(cellSaveLoc) = 0;
                            end
                            
                            %startTime
                            subjData.data.startTime(cellSaveLoc) = trialStartTime;

                            % RT
                            subjData.data.RT(cellSaveLoc) = endTime-trialStartTime;

                            % Save out data for this trial
                            fprintf(subjFile,'%s\t%i\t%i\t%s\t%s\t%s\t%i\t%i\t%i\t%f\t%f\n',...
                                subjID, condition, subjData.data.blockNum(cellSaveLoc), num2str(subjData.data.trialNum(cellSaveLoc), '%02i'), num2str(subjData.data.cumTrialNum(cellSaveLoc), '%02i'),...
                                imageName, subjData.data.partnerRace(cellSaveLoc), subjData.data.shared(cellSaveLoc), subjData.data.received(cellSaveLoc), subjData.data.RT(cellSaveLoc), subjData.data.startTime(cellSaveLoc));

                            % ITI
                            trialStartTime = GetSecs;
                            while (GetSecs-trialStartTime) < (0.100)
                                % do nothing
                            end
                            break;
                        elseif keyIsDown && keyCode(esc_key_code)
                        	error('Experiment aborted by user!');
                        end
                    end   % end while loop

                end   % end stim 'for' loop
                if curBlock < length(stimBlocks)
                    DrawFormattedText(wind, sprintf('You''ve completed block %i of %i.\nPlease take a moment to rest your eyes.\nThe next block will be starting in 5 seconds...', curBlock, length(stimBlocks)), 'center', 'center', blk, [], [], [], 1.4); % % % "WILL STARTING IN"
                    Screen('Flip', wind);
                    WaitSecs(5);
                end

            end % end block 'for' loop


        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% END SCREEN
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % show end text
            Screen('FillRect', wind, gry);
            DrawFormattedText(wind, 'You''ve completed the task.\nPlease ring the bell to inform the experimenter!', 'center', 'center', blk, 45, [], [], 1.4);
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

            % show bonus screen
            bonusBlock = ceil(rand*numTGameBlocks);
            bonusTrial = ceil(rand*numTGameStim);
            bonusLoc = (numTGameStim * (bonusBlock-1)) + bonusTrial; %This will need to be changed now that we are matrix-ing
            bonusShared = subjData.data.shared(bonusLoc);
            leftoverAfterSharing = 5 - bonusShared;


            % calculate total bonus based on whether or not the partner chose to share money and how much the participant initially shared.
            subjData.tOut.bonus = subjData.data.received(bonusLoc) + leftoverAfterSharing;
            subjData.tOut.pickt = bonusLoc;

            % inform participants of their total bonus
            Screen('FillRect', wind, gry);
            DrawFormattedText(wind, ['The randomly-selected trial was number ', num2str(bonusLoc), '. For this trial, you shared $',...
                num2str(subjData.data.shared(bonusLoc)), ' and received $', num2str(subjData.data.received(bonusLoc)), '. Therefore, you will receive a monetary bonus of $',...
                num2str(subjData.tOut.bonus), '.'], 'center', 'center', blk, 45, [], [], 1.4);
            WaitSecs(1);
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

            % save data
            save([outputpath, 'tgametask_subj' subjID '_day' day '_' num2str(now) '.mat'], 'subjData');
            fclose(subjFile);

            % clean-up
            ListenChar(0);
        %    sca;     % close the screen
            Priority(0);    % resets window priority level (gives control back to user)

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
            save([outputpath, 'tgametask_subj' subjID '_day' day '_' num2str(now) '.mat'], 'subjData');
        end

        ListenChar(0);
        Priority(0);
        sca;
        rethrow(ME)

    end % end try

end % end function
