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

# Do we need one big dataframe? 

#Look at the data
head(PTRPart1_data)
head(PTRPart2_data)
head(PTRPostQ_data)
head(PTRRWA_SDO_Demo_Data)

#Creating basic variables 
# PTRPart1 Data
number_of_subjects = length(unique(PTRPart1_data$subjID))
subject_IDs = unique(PTRPart1_data$subjID)
subject_age = PTRRWA_SDO_Demo_Data$Age
subject_gender = PTRRWA_SDO_Demo_Data$Gender0M1F
subject_demographics = data.frame(subject_IDs, subject_age, subject_gender)

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
