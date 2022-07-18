% PTR data to R 

% Loading Data S-drive 
base_path = [filesep 'Volumes' filesep 'shlab' filesep 'Projects' filesep 'PTR' filesep 'data' filesep];
data_path = ['PTR_data' filesep];
parameter_path = ['PTR_dataparameters' filesep];

% Get the listing of data files (S-drive)
cd([base_path data_path]);
fndata = dir('*.mat');

% Get the listing of study design parameter files (S-drive)
cd([base_path parameter_path]);
fnparam = dir('*.mat');

% Create empty matrices
part1_data = nan(0,11); 
%{
    Subject ID
    Trial Number
    Offer
    RT
    Total Received
    Partner ID
    Partner Response
    Partner Affiliation (R = 0, D = 1)
    Partner Reciprocation rate
    Partner Gender (1 = F, 0 = M)
    Partner Race (1 = Black, 0 = White)
%}

part2_data = nan(0,11);
%{
    Subject ID
    Trial Number
    ShareKeep
    RT
    Total Received
    Partner ID
    Partner Offer
    Partner Affiliation (R = 0, D = 1)
    Partner Reciprocation rate
    Partner Gender (1 = F, 0 = M)
    Partner Race (1 = Black, 0 = White)
%}

for s = 1:length(fndata) % what is datafiles? not a variable 
    % Load the behavioral data for this participant
    cd([base_path data_path]);
    temp_subjectdata = load(fndata(s).name);
    disp('Done with loading fndata')
    
    % how to access: temp_subjectdata.subjDataPhase1.data
    
    % Load the study design parameters for this participant
    cd([base_path parameter_path]);
    temp_subjectparam = load(fnparam(s).name);
    disp('Done with loading fnparam')
    
    
    % how to access:
        % temp_subjectparam.study_parameters.interaction_matrix_phase1
        % temp_subjectparam.study_parameters.partner_matrix(partnerID)
    
    % Build up this person's part of the big matrix
    
    % Part 1
    tmpmtx_part1 = nan(80,11);
    disp('Setting up tmptx_part1')
    tmpmtx_part1(:,1) = str2num(fndata(s).name(15:17)); % subject ID
    disp('SubjectID created')
    tmpmtx_part1(:,2) = 1:80; % trial number
    disp('Trial Number created')
    tmpmtx_part1(:,3:5) = table2array(temp_subjectdata.subjDataPhase1.data); % offer, RT, total received
    disp('Offer, RT, total received created')
    tmpmtx_part1(:,6:7) = temp_subjectparam.study_parameters.interaction_matrix_phase1;
    disp('Partner ID and Partner Response created')% partner ID, partner response
    for i = 1:80
    %     Partner Affiliation (R = 0, D = 1)
    %     Partner Reciprocation rate
    %     Partner Gender (1 = F, 0 = M)
    %     Partner Race (1 = Black, 0 = White)
        tmpmtx_part1(i,8:11) = temp_subjectparam.study_parameters.partner_matrix(tmpmtx_part1(i,6),:);
    end
    
    disp('Partner A, Partner RR, Partner G, and Partner R created')
    
    % Part 2
    % shuffled image order = different, several portions need to be held
    % constant 
    % duplicate parameters: 005, 006, 007, and 008 
    tmpmtx_part2 = nan(80,11);
    disp('tmptx_part2 created')
    tmpmtx_part2(:,1) = str2num(fndata(s).name(15:17));% subject ID
    disp('Subject ID 2 created')
    tmpmtx_part2(:,2) = 1:80; %trial number 
    disp('Trial Number 2 created')
    tmpmtx_part2(:,3:5) = table2array(temp_subjectdata.subjDataPhase2.data);
    disp('Share/Keep, RT, and TR 2 created')%share/keep, RT, total received 
    tmpmtx_part2(:,6:7) = temp_subjectparam.study_parameters.interaction_matrix_phase2;
    disp('Partner ID, Partner Offer 2 created')%partner ID, partner offer
    for i = 1:80
    %     Partner Affiliation (R = 0, D = 1)
    %     Partner Reciprocation rate
    %     Partner Gender (1 = F, 0 = M)
    %     Partner Race (1 = Black, 0 = White)
        tmpmtx_part2(i,8:11) = temp_subjectparam.study_parameters.partner_matrix(tmpmtx_part2(i,6),:);
    end 
    
    disp('Partner A, Partner RR, Partner G, and Partner R 2 Created')
    
    % append this person's part of the big matrix
    part1_data = [part1_data; tmpmtx_part1];
    disp('Part1_data done')
    part2_data = [part2_data; tmpmtx_part2];
    disp('Part2_data done')
    
end


% Save out the overall data file as two CSVs
cd(base_path);
csvwrite(sprintf('PTRPart1_data_%.4f.txt',now),part1_data);
csvwrite(sprintf('PTRPart2_data_%.4f.txt',now),part2_data);

% Loading Qualtrics data 
 base_path = [filesep 'Volumes' filesep 'shlab' filesep 'Projects' filesep 'PTR' filesep 'data' filesep];
 qualtrics_data_path = ['clean' filesep];
 post_Q_path = ['POST_Q' filesep];
 RWA_SDO_path = ['RWA_SDO' filesep];

%Listing of data files / Importing the CSV's manually saves the column headers
 %POST Q
 cd([base_path qualtrics_data_path post_Q_path]);
 post_Q_data = import_postq_file('PTR_POSTQ.csv'); %49 questions, 19 participants 

 %RWA_SDO
 cd([base_path qualtrics_data_path RWA_SDO_path]);
 RWA_SDO_data = import_RWASDODEMO_file('PTR_RWA_SDO_Data.csv');  

% POSTQ Scoring Matrix, RWA/SDO doesn't need partner ID 
 
% Columns unique to questions, every participant gets 8 rows 
% Rows identified by participant and partner number 
% That (N x 8) row matrix should have columns including participant ID and partner ID - 
% that way with some indexing (e.g. matrix$subID == 2 & matrix$partnerID == 5) 
% we can link post-task info to any given participant & partner.
% 19x49 matrix for post_Q_data
% 152 (8x19) is the number of rows per participant, 8 partners per
% participant 

%Qualtrics Partners: ordered by column in PostQ Data CSV
%column headers names have no dots and no dashes 
    % CFD-WF-234-086-N.jpg = Partner 1, White Female 
    % CFD-BF-049-032-N.jpg = Partner 2, Black Female
    % CFD-BM-010-003-N.jpg = Partner 3, Black Male 
    % CFD-WF-212-050-N.jpg = Partner 4, White Female
    % CFD-WM-209-038-N.jpg = Partner 5, White Male 
    % CFD-BM-019-002-N.jpg = Partner 6, Black Male 
    % CFD-BF-041-001-N.jpg = Partner 7, Black Female 
    % CFD-WM-024-015-N.jpg = Partner 8, White Male 
%Order of Names of Photos in Parameters (same every time) 
% how to access: temp_subjectparam.study_parameters.fnames.name
    % CFD-WM-024-015-N.jpg = Partner 8
    % CFD-WF-212-050-N.jpg = Partner 4
    % CFD-BF-041-001-N.jpg = Partner 7
    % CFD-WF-234-086-N.jpg = Partner 1
    % CFD-WM-209-038-N.jpg = Partner 5
    % CFD-BF-049-032-N.jpg = Partner 2
    % CFD-BM-019-002-N.jpg = Partner 6
    % CFD-BM-010-003-N.jpg = Partner 3

for s = 1:19 
    cd([base_path qualtrics_data_path post_Q_path]);
    post_Q_data = import_postq_file('PTR_POSTQ.csv'); 
    
    tmpmtx_POSTQ = nan(152,50); %152 rows per participant, 50 columns for the questions (add a column for partner ID)
    %which participant am I doing? 
    
    %connect the first 49 columns from postQ data and put it into the
    %temporary matrix
        % SubjID: 3 numbers 
        % 24 responses Phase 1: Phase1_AvgOffer_jpg, Phase1_TimesPShare_jpg,
        % Phase1_PGoodBad_jpg 
        % 24 responses Phase 2: Phase2_ AvgPOffer_jpg,
        % Phase2_TimesPShare_jpg, Phase2_PGoodBad_jpg
        
    %each jpg has a specific number attached to it and abbreviation for
    %race and gender 
    % Partner ID comes from parameters, putting file name into a column,
    % way to connect is through the BF, WM, WF, and BM? 
    for i = 1:8
    tmpmtx_POSTQ(i,50) = temp_subjectparam.study_parameters.fnames.name; %isn't right size 
    end
    %connect file name to the correct set of ratings by column header from
    %POST Q csv 
end


    












    







