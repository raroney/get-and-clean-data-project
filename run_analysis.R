# Analysis program for Coursera "Getting and Cleaning Data" Course Project.
#
# Use the run_analysis() function to perform data analysis automatically and
# return a data.frame containing the final result set called for in the
# assignment.
#
# The data to be analysed must have the same "shape" as the dataset created
# for the abovementioned course -- obtained from UCI and collected during a
# Human Activity Recognition Using Smartphones study.
#
# Data from the study was split into "Training" and "Test" data sets. Each of
# these includes files with "feature variables" calculated based on actual raw
# sensor readings obtained from Samsung Galaxy S II phones, for each of a
# number of volunteer test subjects who carried the phones while performing
# various activities. Activites data was generated manually based on video 
# observations.
#
# The run_analysis() function analyses this data in the following way:
# * Merge the Test and Training data sets together.
# * Extract just the "mean" and "standard deviation" feature variables.
# * Return a data set that contains the average of each variable for each 
#   activity and each subject.
#
# The "mean" and "standard deviation" variables are determined based on the 
# labels given to each feature variable in the features.txt file. Only the 
# variables with labels including "-mean()" or "-std()" are included. This
# excludes variables that have merely been calculated based on some other
# "mean" variable, as well as "meanFreq" variables that have been calculated
# for some features (in addition to a "mean" variable).
#
# The summarised data set is constructed in a "wide" format, with columns for
# activity_label and subject, as well as each mean and standard deviation 
# feature variable. The names of feature variable columns are based on the 
# labels read from the features.txt file (with hyphens and parentheses replaced
# by dots, for the sake of generating valid R variable names). The values in
# the activity_label column are based on the (text) activity labels defined in
# the activity_labels.txt file included with the sample dataset.
#
# Example Usage:
# > summary.data <- run_analysis()
#
# Other functions may be called to create data.frames containing "intermediate"
# results, such as data read from particular files.
#
# "Support" Functions that read files containing labels:
# * read_activity_labels
# * read_features
#
# "Support" Functions that read files containing Training and Test data:
# * read_data_file
# * read_activities_data
# * read_subjects_data
# * read_variables_data
#
# For more information about each function, see the comments immediately above
# each function definition. These describe the purpose and usage of each 
# function.
#
# Assumptions:
# * Data from the UCI HAR Dataset provided for the programming assignment has
#   been unzipped into the current working directory, maintaining the full
#   directory structure within the zip (ie a directory named "UCI HAR Dataset"
#   exists in the current directory, with subdirectories named "train" and
#   "test", etc.
# * The "dplyr" package has been installed.

require(dplyr)

# This is the main function of the script. This uses the other functions 
# defined below to read data from various files within the UCI HAR Dataset,
# then extracts just the mean() and std() variables of interest, before
# summarising the data as average values per variable, per activity and per
# subject.
# Return:
# * A data.frame containing summarised data, as described above (see the
#   file header comment).
run_analysis <- function() {
        
        # 1) Read in the list of features in the dataset. We'll use this to 
        # determine where to find the mean and standard deviation variables,
        # and also to assign reasonable variable names. 
        features <- read_features()
        #str(features)
        
        # 2) Read in the list of activity labels, so we can properly interpret
        # the activity codes in the dataset.
        activity.labels <- read_activity_labels()
        #str(activity.labels)
        
        # 3) Read in all the test and training data sets, merged with
        # appropriate column labels (base columns for variables on the
        # list of features read previously)
        subjects.data.raw <- read_subjects_data()
        activities.data.raw <- read_activities_data()
        variables.data.raw <- read_variables_data(features$feature_label)
        #str(subjects.data.raw)
        #str(activities.data.raw)
        #str(variables.data.raw)
        
        # 4) Extract the columns containing means and standard deviations
        # calculated based on the raw sensor readings.
        variables.data <- select(variables.data.raw, 
                                 contains(".mean.."), 
                                 contains(".std.."))
        rm(variables.data.raw)
        #str(variables.data)
        
        # 5) Join our activities, subjects and variables data together,
        # translating activity codes into activity labels
        joined.data <- 
                inner_join(activities.data.raw, 
                           activity.labels, 
                           by="activity_num") %>% 
                select(activity_label) %>%
                bind_cols(subjects.data.raw, variables.data)
        rm(variables.data, subjects.data.raw, activities.data.raw)
        #str(joined.data)
        
        # 6) Build a table of average values for each variable, grouped
        # by subject and activity. This is what we want to return.
        group_by(joined.data, activity_label, subject) %>% 
                summarise_each(funs(mean))
}

# Read the list of features from the "features.txt" file included with the
# UCI HAR Dataset.
# This is assumed to have 2 columns:
# * number corresponding to a column index (assumed to be ordered).
# * feature label corresponding to the column index.
# Return:
# * data.table of features, loaded as text.
read_features <- function() {
        fname <- file.path("UCI HAR Dataset","features.txt")
        if (file.exists(fname)) {
                read.table(fname,stringsAsFactors = FALSE, sep = " ",
                           col.names = c("feature_num", "feature_label"))
        }
}

# Read the list of features from the "activity_labels.txt" file included with
# the UCI HAR Dataset.
# This is assumed to have 2 columns:
# * activity code number.
# * activity label.
# Return:
# * Table of activity labels, loaded as text.
read_activity_labels <- function() {
        fname <- file.path("UCI HAR Dataset","activity_labels.txt")
        if (file.exists(fname)) {
                read.table(fname,stringsAsFactors = FALSE, sep = " ",
                           col.names = c("activity_num", "activity_label"))
        }
}

# Read "subject" data for both "test" and "train" data sets included with the
# UCI HAR Dataset.
# This is assumed to have 1 column:
# * subject number
# Return:
# * Table of subjects, loaded from the Training data set followed by the Test
#   data set.
read_subjects_data <- function() {
        bind_rows(mapply(read_data_file, c("train", "test"), SIMPLIFY = FALSE,
                         MoreArgs = list(file.prefix = "subject", 
                                         col.names = "subject")))
}

# Read "activity" data for both "test" and "train" data sets included with the
# UCI HAR Dataset.
# This is assumed to have 1 column:
# * activity code
# Return:
# * Table of activities, loaded from the Training data set followed by the Test
#   data set.
read_activities_data <- function() {
        bind_rows(mapply(read_data_file, c("train", "test"), SIMPLIFY = FALSE,
                         MoreArgs = list(file.prefix = "y", 
                                         col.names = "activity_num")))
}

# Read variable features data for both "test" and "train" data sets included 
# with the UCI HAR Dataset.
# This is assumed to have columns corresponding to the "features" argument:
# * features : vector of descriptive text for all variable features
# Return:
# * Table of variables, loaded from the Training data set followed by the Test
#   data set.
read_variables_data <- function(features) {
        bind_rows(mapply(read_data_file, c("train", "test"), SIMPLIFY = FALSE,
                         MoreArgs = list(file.prefix = "X", 
                                         col.names = features)))
}

# Read any of the "summary" level data files from the UCI HAR Dataset.
# Arguments:
# * data.type   : Identifies the type of data to load:
#                       "train" for Training data
#                       "test" for Test data
# * file.prefix : Prefix of the data file from which to loade data. One of:
#                       "X" for variables
#                       "y" for activity labels
#                       "subject" for subject identifiers
# * col.names   : Vector of column names to apply to the data.table created.
# Return:
# * A data.table containing data read from the appropriate file (if it
#   existed)
read_data_file <- function(data.type, file.prefix, col.names) {
        fname <- file.path("UCI HAR Dataset",data.type,
                           paste0(file.prefix,"_",data.type,".txt"))
        if (file.exists(fname)) {
                read.table(fname,col.names=col.names)
        }
}
