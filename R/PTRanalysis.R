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

#Part 1 Means (participant)
#Offer
meansubject_offer = array(data = NA, dim=number_of_subjects); # create our placeholder
for (s in 1:number_of_subjects) {
  meansubject_offer[s] = mean(PTRPart1_data$offer[PTRPart1_data$subjID == subject_IDs[s]], na.rm = T);
}

#RTs Part 1 (participant)
#sqrt it and build it into a new dataframe 
PTRPart1_data$sqrtrt = sqrt(PTRPart1_data$RT); 
hist(PTRPart1_data$sqrtrt); # looks better 
meansubject_RT_part1 = array(data = NA, dim = number_of_subjects);
for (s in 1:number_of_subjects){
  meansubject_RT_part1[s] = mean(PTRPart1_data$sqrtrt[PTRPart1_data$subjID == subject_IDs[s]], na.rm = T);
}

#Missed Trials Part 1 (participant)
total_subject_missed_trials_part1 = array(data = NA, dim = number_of_subjects);
for (s in 1:number_of_subjects){
  total_subject_missed_trials_part1[s] = sum(is.na(PTRPart1_data$offer[PTRPart1_data$subjID == subject_IDs[s]]))
}


#Part 2 Means (participant) 
# Share/Keep, 
meansubject_share_keep = array(data = NA, dim=number_of_subjects);
for (s in 1:number_of_subjects) {
  meansubject_offer[s] = mean(PTRPart2_data$share.keep[PTRPart2_data$subjID == subject_IDs[s]], na.rm = T);
}

#RTs Part 2 (participant) 
PTRPart2_data$sqrtrt = sqrt(PTRPart2_data$RT); 
meansubject_RT_part2 = array(data = NA, dim = number_of_subjects);
for (s in 1:number_of_subjects){
  meansubject_RT_part2[s] = mean(PTRPart1_data$sqrtrt[PTRPart1_data$subjID == subject_IDs[s]], na.rm = T);
}

#Missed Trials Part 2 (participant)
total_subject_missed_trials_part2 = array(data = NA, dim = number_of_subjects);
for (s in 1:number_of_subjects){
  total_subject_missed_trials_part2[s] = sum(is.na(PTRPart2_data$share.keep[PTRPart2_data$subjID == subject_IDs[s]]))
}

#Global Mean and RT Part 1 
mean_global_RT_part1 = mean(PTRPart1_data$sqrtrt, na.rm = T);
mean_global_offer = mean(PTRPart1_data$offer, na.rm = T);

#Global Mean and RT Part 2
mean_global_RT_part2 = mean(PTRPart2_data$sqrtrt, na.rm = T);
mean_global_share_keep = mean(PTRPart2_data$share.keep, na.rm = T);

#Save out into a data frame
RT_offer_part1 = data.frame(mean_global_RT_part1, mean_global_offer);
RT_share_keep_part2 = data.frame(mean_global_RT_part2, mean_global_share_keep);

#Basic Stats for Qualtrics Data? 


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
