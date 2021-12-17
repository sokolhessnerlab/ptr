function [subjData] = TRTG_wrapperv2(subjID, day, testMode, wind, blk, wht, gry, rect)
    %
    % subjID must be a 3-character string (e.g. '003')
    % day is a 1 character string - '1' or '2'
    % testMode must be either 0 (do the full study) or 1 (do an abbreviated study)
    % 
    % DATA:
    %
    % set up defaults
    %Screen('Preference', 'SkipSyncTests', 1);   % skips sync tests for monitor relay timing (*ideally don't use this, mostly for use during testing w/ dual monitor setup)
    if nargin < 2
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
            2018.08.01 - ESA created file
            2019.05.09 - Included a line to shuffle the rng
        %}

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% PREPARATION & GLOBAL VARS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    rng('shuffle'); %shuffle up the random number generator
    
        % assign condition
        if rand < 0.5
            % Trust Rating first
            TRv4(subjID, day, testMode, 1, wind, blk, wht, gry, rect);
            TGamev3(subjID, day, testMode, 2, wind, blk, wht, gry, rect);
        else
            % Trust Game first
            TGamev3(subjID, day, testMode, 1, wind, blk, wht, gry, rect);
            TRv4(subjID, day, testMode, 2, wind, blk, wht, gry, rect);
        end
        
end % end function