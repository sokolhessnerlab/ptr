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

finmtx_POSTQ = nan(0,8); %subjectID, partnerID, questions
cd([base_path qualtrics_data_path post_Q_path]);
post_Q_data = import_postq_file('PTR_POSTQ.csv');     
cd([base_path parameter_path]);
fnparam = dir('*.mat');

for s = 1:19 
    disp(['Starting subject ',num2str(s)])
    tmp_parameter = load(fnparam(s).name);
    disp('Parameters loaded')
    
    shuffle_order = tmp_parameter.study_parameters.shuffle_order;

    tmpmtx_postQ = nan(8,8);
    tmpmtx_postQ(:,1) = s;
    tmpmtx_postQ(:,2) = 1:8;
    for partner = 1:8
        %matching the text strings, ind for different columns, stringcomp
        fname_from_parameters = tmp_parameter.study_parameters.fnames(shuffle_order(partner)).name;
        fname_from_parameters = erase(fname_from_parameters,["-","."]); % Partner ID fname from parameters
        
        for col = 2:9
            match_test = strcmp(fname_from_parameters,post_Q_data.Properties.VariableNames{col}((end-14):end));
            if match_test
                break
            end
        end
        
        column_indices = col:8:49;
        tmpmtx_postQ(partner,3:end) =  table2array(post_Q_data(s,column_indices));
    end
    
    %same thing we did above in appending to final matrix 
    finmtx_POSTQ = [finmtx_POSTQ; tmpmtx_postQ];
    
    
    % subject by subject
    % loop that is partner by partner 
    % partner 1 corresponds to which picture? 
    % use erase function to remove hifens and dots in the file name 
    % go to csv, go column by column, pull out string correspoding to each
    % column name 
    % post_Q_data.Properties.VariableNames{}
    % all column headers are the same length 
    % post_Q_data.Properties.VariableNames{2}((end-14):end) for a given
    % person you have a file name 
    % 
    
end

% Save out the overall data file as one CSV
cd(base_path);
csvwrite(sprintf('PTRPOSTQPartner_data_%.4f.txt',now),finmtx_POSTQ);

%Paramater Check
%You need to
%set the value of s
%Use the variable s to load the parameters file for that participant s
%look inside the loaded parameter file.
%and then do 1, 2, and 3 again for a new value of s, and then another, 
% and another, etc.

for s = 11
    cd([base_path parameter_path]);
    fnparam = dir('*.mat');
    cd([base_path parameter_path]);
    temp_subjectparam = load(fnparam(s).name);
    temp_subjectparam.study_parameters.partner_matrix
end

    
    
    












    







