%PTR data to R 
%% Loading Data
base_path = [filesep 'Volumes' filesep 'shlab' filesep 'Projects' filesep 'PTR' filesep 'data' filesep];
data_path = ['PTR_data' filesep];
parameter_path = ['PTR_dataparameters' filesep];

% Get the listing of data files
cd([base_path data_path]);
fndata = dir('*.mat');

% Get the listing of study design parameter files
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

part2_data = nan();
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

for s = 1:length(datafiles)
    % Load the behavioral data for this participant
    cd([base_path data_path]);
    temp_subjectdata = load(fndata(s).name);
    
    % how to access: temp_subjectdata.subjDataPhase1.data
    
    % Load the study design parameters for this participant
    cd([base_path parameter_path]);
    temp_subjectparam = load(fnparam(s).name);
    
    % how to access:
        % temp_subjectparam.study_parameters.interaction_matrix_phase1
        % temp_subjectparam.study_parameters.partner_matrix(partnerID)
    
    % Build up this person's part of the big matrix
    
    % Part 1
    tmpmtx_part1 = nan(80,11);
    tmpmtx_part1(:,1) = str2num(fndata(s).name(15:17)); % subject ID
    tmpmtx_part1(:,2) = 1:80; % trial number
    tmpmtx_part1(:,3:5) = table2array(temp_subjectdata.subjDataPhase1.data); % offer, RT, total received
    tmpmtx_part1(:,6:7) = temp_subjectparam.study_parameters.interaction_matrix_phase1; % partner ID, partner response
    for i = 1:80
    %     Partner Affiliation (R = 0, D = 1)
    %     Partner Reciprocation rate
    %     Partner Gender (1 = F, 0 = M)
    %     Partner Race (1 = Black, 0 = White)
        tmpmtx_part1(i,8:11) = temp_subjectparam.study_parameters.partner_matrix(tmpmtx_part1(i,6),:);
    end
    
    % Part 2
    tmpmtx_part2 = nan(80,11);
    % REST OF CODE HERE
    
    % append this person's part of the big matrix
    part1_data = [part1_data; tmpmtx_part1];
    part2_data = [part2_data; tmpmtx_part2];
    
end

% Save out the overall data file as two CSVs
cd([base_path data_path]);



%ref_files is a cell array of structs with each struct having
%subjDataPhase1 & subjDataPhase2 for each of the 19 people 



alldata = ref_files;

%% Part 1: PTR
d = nan(0,5); %subjID, trial number, offer, RT, total recieved per trial
%just make it the part 1 data
%set up emprty matrix, load subject 
for s = 1:length(alldata)
    part1subjectdata = alldata{s}.subjDataPhase1.data;
    nT = size(part1subjectdata);
    RT = part1subjectdata(:,2);
    offer = part1subjectdata(:,1);
    totalrecieved = part1subjectdata(:,3);
    subjID = %not sure how to do this one
    tmpmatrix = %getting confused 
    d = [d; tmptx];
end





    







