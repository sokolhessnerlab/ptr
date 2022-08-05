# Your functions can go here. Then, when you want to call those functions, run
#### SETUP ####
rm(list=ls()) # CLEAR THE WORKSPACE
setwd('/Users/mia.cudahy1/Documents/MATLAB/')
setwd('/Volumes/shlab/Projects/PTR/data/')

#### Load the Data and Add Columns#### locally 

PTRPart1_data <- as.matrix(read.table("PTRPart1_data_738719.7960.txt", sep = ",", header = TRUE, 
                                      col.names = c("subjID", "trial", "offer", "RT", "totalrec", 
                                                    "partnerid", "partnerresp", "PA", "PRec", "PG", "PR")));
PTRPart1_data <- data.frame(PTRPart1_data);

PTRPart2_data <- as.matrix(read.table("PTRPart2_data_738719.7960.txt", sep = ",", header = TRUE, 
                                      col.names = c("subjID", "trial", "share/keep", "RT", "totalrec",
                                                    "partnerid", "partneroff", "PA", "PRec", "PG", "PR")));

PTRPart2_data <- data.frame(PTRPart2_data);

PTRPostQ_data <- as.matrix(read.table("PTRPOSTQPartner_data_738720.7612.txt", sep = ",", header = TRUE, 
                                      col.names = c("subjID", "partnerid", "avgoffer1", "timepshare1", "pgoodbad1",
                                                    "avgpoffer2", "timepshare2", "pgoodbad2")));
PTRPostQ_data <- data.frame(PTRPostQ_data);

PTRRWA_SDO_Demo_Data <- read.csv("PTR_RWA_SDO_Data.csv");

#Look at the data
head(PTRPart1_data)
head(PTRPart2_data)
head(PTRPostQ_data)
head(PTRRWA_SDO_Demo_Data)

#Creating basic variables 
# Demographics 
number_of_subjects = length(unique(PTRPart1_data$subjID));
subject_IDs = unique(PTRPart1_data$subjID);
subject_age = PTRRWA_SDO_Demo_Data$Age;
subject_gender = PTRRWA_SDO_Demo_Data$Gender0M1F;
subject_ethnicity = PTRRWA_SDO_Demo_Data$Ethnicity0N1Y;
subject_race = PTRRWA_SDO_Demo_Data$Race0W1B2A3L;
subject_political_affiliation = PTRRWA_SDO_Demo_Data$PolParty0R1D2N
subject_demographics = data.frame(subject_IDs, subject_age, subject_gender, subject_ethnicity, 
                                  subject_race);

#Basic Stats for Part 1 and Part 2 Behavioral Data

#Part 1 Means 
#Mean offer Rate 
naomit_offer = na.omit(PTRPart1_data$offer)
subjects_meanoffer = vector(length = number_of_subjects);
for(s in 1:number_of_subjects){
  subjects_meanoffer[s] = mean(naomit_offer[PTRPart1_data$subjID == subject_IDs[s]])
};
head(subjects_meanoffer)

#troubleshoot why am I getting NA for subject 19 

# Mean RT 
#build it into a new dataframe 
PTRPart1_data$sqrtrt = sqrt(PTRPart1_data$RT); 
subjects_meanRT = vector(length = number_of_subjects);
for(s in 1:number_of_subjects){
  subjects_meanRT[s] = mean(PTRPart1_data$sqrtrt[PTRPart1_data$subjID == subject_IDs[s]])
};

#NANs in this, troubleshoot 

### Regressions ###
# Variables in PTR Part 1 / 2 that might affect offers and share.keep
# partner gender / partner race / partner political affiliation / good bad
# PART 1 
fitoffer_race = lm(PTRPart1_data$offer ~ 1 + PR, data = PTRPart1_data); # not sure what do after the ~ (0 or 1)? 
summary(fitoffer_race);

fitoffer_gender = lm(PTRPart1_data$offer ~ 1 + PG, data = PTRPart1_data);
summary(fitoffer_gender);

fitoffer_PA = lm(PTRPart1_data$offer ~ 1 + PA, data = PTRPart1_data); 
summary(fitoffer_PA); 

fitoffer_PRec = lm(PTRPart1_data$offer ~ 1 + PRec, data = PTRPart1_data);
summary(fitoffer_PRec);

#PART 2 
fitsharekeep_race = lm(PTRPart2_data$share.keep ~ 1 + PR, data = PTRPart2_data);
summary(fitsharekeep_race);

fitsharekeep_gender = lm(PTRPart2_data$share.keep ~ 1 + PG, data = PTRPart2_data);
summary(fitsharekeep_gender);

fitsharekeep_PA = lm(PTRPart2_data$share.keep ~ 1 + PA, data = PTRPart2_data);
summary(fitsharekeep_PA);

fitsharekeep_PRec = lm(PTRPart2_data$share.keep ~ 1 + PRec, data = PTRPart2_data);
summary(fitoffer_PRec);


# `source('R/functions.R')` within a code block in the RMarkdown notebook.
print("Your scripts and functions should be in the R folder.")
