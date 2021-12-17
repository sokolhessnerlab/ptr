function [subjData] = BST_wrapper(subjID, day, testMode)
    %
    % subjID must be a 3-character string (e.g. '003')
    % day is a 1 character string - '1' or '2'
    % testMode must be either 0 (do the full study) or 1 (do an abbreviated study)
    % 
    % DATA:
    %
    % set up defaults
    Screen('Preference', 'SkipSyncTests', 1);   % skips sync tests for monitor relay timing (*ideally don't use this, mostly for use during testing w/ dual monitor setup)
    if nargin < 3
        testMode = 0; % assume full mode (unless otherwise specified)
    end
    if nargin < 1
        subjID = '000'; % assume default subjid 000 (unless otherwise specified)
    end     
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% DESCRIPTION
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %{
            YYYY.MM.DD - UPDATES
            2018.09.27 - CXP created this file
            2018.10.01 - CXP added all the task commands (TO DO: Pull out screen initialization and place it in this wrapper; figure out how to save everything by Day 1 or 2?)
            2018.11.26 - CXP pulled out screen initialization, added day and session info, and then did a final pass through everything.
        %}

        %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% PREPARATION & GLOBAL VARS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Create Experiment Window
       if testMode == 1
           rect=[1600 0 2400 600];
           [wind, rect] = Screen('OpenWindow', max(Screen('Screens')) , 200, rect);
       else
           [wind, rect] = Screen('OpenWindow', max(Screen('Screens')));
       end

        % Define Experiment Window
        Screen('BlendFunction', wind, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);   % turn on aliasing to allow line to be smooth
        blk = BlackIndex(wind);
        wht = WhiteIndex(wind);
        gry = GrayIndex(wind, 0.8);
        Screen('TextFont',wind,'default');
        
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% RUN ALL THE SCRIPTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Set up order of tasks
    %I think Peter said AMP -> acute stress -> Trust -> AMP -> IAT Same structure for both days.
    try
        
        AMPv4(subjID, day, '1', testMode, wind, blk, wht, gry, rect); % Session 1
        TRTG_wrapperv2(subjID, day, testMode, wind, blk, wht, gry, rect);
        AMPv4(subjID, day, '2', testMode, wind, blk, wht, gry, rect); % Session 2
        IATv6(subjID, day, testMode, wind, blk, wht, gry, rect);
        
    catch ME
        ListenChar(0);
        Priority(0);
        sca;
        disp('Error: Something bugged out.');
        rethrow(ME)
    end %End of the try
end % end function
