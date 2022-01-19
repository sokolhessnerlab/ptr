
function [subjData] = TGamev1(subjID, testMode)
%
% subjID must be a 3-character string (e.g. '003')
% testMode must be either 0 (do the fully study) or 1 (do not do the study)
%
% DATA:
%
% Stimulus Data: % Programming this is confusing me
% 'Player 1' = Democrat, 19, 80%
% 'Player 4'= Republican, 19, 80%
% 'Player 7' = NP, 19, 80%
% 'Player 2' = Democrat, 20, 50%
% 'Player 5' = Republican, 20, 50%
% 'PLayer 9' = NP, 20, 50%
% 'Player 3' = Democrat, 21, 20%
% 'Player 6' = Republican, 21, 20%
% 'Player 8' = NP, 21, 20%
% 
% POLITICAL ORIENTATION DATA: 
% 'Democrat' = 0
% 'Republican' = 1
% 'NP' = 2
%
% AGE DATA: 
% 'Age' = 
	% '19' 
	% '20'
	% '21'

    
% 
% RECIPROCITY DATA: % Do I need this or is this just in randomization? 
% 'Recp' = 
% '80%' 
% '50%'
% '20%'
%
% Partner Choice: MIGHT DO DIFFERENT KEYPRESSES 
% $1 = 'a'
% $3 = 's'
% $5 = 'd'
% $7 = 'j'
% $9 = 'k'
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
% do we need to use a Blend Function? 
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

%COPY AND PASTED FROM BST

if ismac
    homepath = [filesep 'Volumes' filesep 'research' filesep 'AHSS Psychology' filesep 'shlab' filesep 'Projects' filesep 'PTR' filesep 'task' filesep];
end
        
if IsWin
    homepath = ['S:' filesep 'Projects' filesep 'PTR' filesep 'task' filesep];
end

% imgpath = 
% outputpath = 

% Basic Keyboard Stuff
KbName('UnifyKeyNames'); 

% Response Keys
resp_keys = {'a', 's', 'd', 'j', 'k'}; %For $1, $3, $5, $7, & $9
resp_key_codes = KbName(resp_keys);
space_key_code = KbName('space');
esc_key_code = KbName('ESCAPE');
trig_key_code = KbName('Return');

% Number of Stimuli to Choose From
% numTotalStim = ____

% Number of Stimuli (per groups) 

% Setup Variable Columns for Data Table 

% Create Data Table 

% Path to the file on disk

% Capture Keypresses & don't affect the editor/console 

WaitSecs(2)
sca
