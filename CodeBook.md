============
Study Design
============

Background and Data Sources
---------------------------

The data analysis described here was performed as part of a project for the coursera course [Getting and Cleaning Data](https://class.coursera.org/getdata-031/).

The specific data set to be analysed was downloaded from:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
This shall hereafter be referred to as the _UCI HAR Dataset_.

The requirements for the analysis project were defined as:

> You should create one R script called run_analysis.R that does the following. 
> 1. Merges the training and the test sets to create one data set.
> 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
> 3. Uses descriptive activity names to name the activities in the data set
> 4. Appropriately labels the data set with descriptive variable names. 
> 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The dataset analysed was originally obtained from [UCI](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) and is used under the following licence:

> Use of this dataset in publications must be acknowledged by referencing the following publication [1] 
>
> [1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

Experiment Details
------------------

The source data that was analysed had already been processed. The method of collecting experimental data and then deriving further variables to calculate estimates of various "feature variables" was as described in files distributed along with the data:

> The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 
> 
> The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 
> 
> For each record it is provided:
>
> - Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
> - Triaxial Angular velocity from the gyroscope. 
> - A 561-feature vector with time and frequency domain variables. 
> - Its activity label. 
> - An identifier of the subject who carried out the experiment.

Analysis Method
---------------

RStudio version 0.99.467 and R version 3.2.1 was used to further analyse the UCI HAR Dataset.

All of the analysis code was put into a single script named `run_analysis.R` containing several "helper" functions, as well as a master function named `run_analysis()` that will orchestrate analysis of dataset and return a tidy table of results. Within the script, comments explain the purpose and usage of each function, as well as the intended usage of the script as a whole. 

The data analysis actually performed using the script used the following procedure, and can be replicated using these steps (assuming you have RStudio and have installed the pre-requisite `dplyr` package):

1. Download the [UCI HAR Dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and unzip the contents into the desired working directory.
2. Download the [run_analysis.R](https://github.com/raroney/get-and-clean-data-project/blob/master/run_analysis.R) script into the desired working directory.
3. Load the analysis script: `source("run_analysis.R")`
4. Perform analysis: `summary.data <- run_analysis()`
5. To view results: `View(summary.data)`
6. To save results: `write.table(summary.data, "activity_measurements_summary.txt", row.names=FALSE)`

The algorithm for analysing the UCI HAR Dataset (as codified into `run_analysis.R` and used in step 4 above) was as follows:

* Load labels describing the Training and Test data from the `features.txt` and `activity_labels.txt` files.

* Load Training and Test data into R from the text files in the `train` and `test` subdirectories (but not the raw data in the `Inertial Signals` subdirectories) and merge like data sets together by appending Test data rows after the end of the Training data rows. This gives us 3 data sets each with the same number of rows (activity data with 1 column, subjects data with 1 column, and feature variables data with 561 columns).

* Label the columns of all data sets as each data file is loaded, to make selects and joins easier. Columns of the feature variables data set were named with the labels read from `features.txt`, with hyphens `-` and brackets `()` replaced by dots `.` for the sake of having names that could be applied to variables within R.

* Select from the feature variables data set just the ones with names containing `.mean..` or `.std..` (corresponding to labels containing `-mean()` or `-std()` within `features.txt`). This gives us 66 columns.

* Join the raw activity data with the activity labels read from `activity_labels.txt`.

* Select just the `activity_label` from the activity data set and bind this column with the raw subjects data and then with the 66 column set of feature variables data. This gives us 68 columns.

* Group our final data set by the `activity_label` and `subject` columns, and summarise each of the other columns using the `mean` function.

The end result of this was to create a "wide" data set, with one column for each variable describing either an activity, a subject, or an average value for a feature variable from the source data set. The number of rows in the resulting data set corresponded to the number of unique combinations of `activity_label` and `subject` values that actually occured within the source data (as it turned out, this was actually the maximum possible number of combinations: 180 = 30 * 6).


=========
Code Book
=========

Generated Dataset Description
-----------------------------

The output of the analysis comprises a table of data, consisting of 68 variables:

- activity_label: Categorical data describing activities performed by the subjects during the course of the experiment. Values for this variable are the strings WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING (based on the labels in the `activity_labels.txt` file).

- subject: Integer values in the range 1 to 30 used to identify particular subjects that took part in the experiment.

- 66 averaged factor variables: These comprise a subset of the full list of feature variables in the source data and are named based on the labels in the `features.txt` file, with hyphens and brackets replaced by dots. The actual values taken by each of these variables is an average of a set of values that are normalized and bounded in the range [-1,1], so are themselves bounded in the range [-1,1].

The complete list of variables is:
1. activity_label
2. subject
3. tBodyAcc.mean...X
4. tBodyAcc.mean...Y
5. tBodyAcc.mean...Z
6. tGravityAcc.mean...X
7. tGravityAcc.mean...Y
8. tGravityAcc.mean...Z
9. tBodyAccJerk.mean...X
10. tBodyAccJerk.mean...Y
11. tBodyAccJerk.mean...Z
12. tBodyGyro.mean...X
13. tBodyGyro.mean...Y
14. tBodyGyro.mean...Z
15. tBodyGyroJerk.mean...X
16. tBodyGyroJerk.mean...Y
17. tBodyGyroJerk.mean...Z
18. tBodyAccMag.mean..
19. tGravityAccMag.mean..
20. tBodyAccJerkMag.mean..
21. tBodyGyroMag.mean..
22. tBodyGyroJerkMag.mean..
23. fBodyAcc.mean...X
24. fBodyAcc.mean...Y
25. fBodyAcc.mean...Z
26. fBodyAccJerk.mean...X
27. fBodyAccJerk.mean...Y
28. fBodyAccJerk.mean...Z
29. fBodyGyro.mean...X
30. fBodyGyro.mean...Y
31. fBodyGyro.mean...Z
32. fBodyAccMag.mean..
33. fBodyBodyAccJerkMag.mean..
34. fBodyBodyGyroMag.mean..
35. fBodyBodyGyroJerkMag.mean..
36. tBodyAcc.std...X
37. tBodyAcc.std...Y
38. tBodyAcc.std...Z
39. tGravityAcc.std...X
40. tGravityAcc.std...Y
41. tGravityAcc.std...Z
42. tBodyAccJerk.std...X
43. tBodyAccJerk.std...Y
44. tBodyAccJerk.std...Z
45. tBodyGyro.std...X
46. tBodyGyro.std...Y
47. tBodyGyro.std...Z
48. tBodyGyroJerk.std...X
49. tBodyGyroJerk.std...Y
50. tBodyGyroJerk.std...Z
51. tBodyAccMag.std..
52. tGravityAccMag.std..
53. tBodyAccJerkMag.std..
54. tBodyGyroMag.std..
55. tBodyGyroJerkMag.std..
56. fBodyAcc.std...X
57. fBodyAcc.std...Y
58. fBodyAcc.std...Z
59. fBodyAccJerk.std...X
60. fBodyAccJerk.std...Y
61. fBodyAccJerk.std...Z
62. fBodyGyro.std...X
63. fBodyGyro.std...Y
64. fBodyGyro.std...Z
65. fBodyAccMag.std..
66. fBodyBodyAccJerkMag.std..
67. fBodyBodyGyroMag.std..
68. fBodyBodyGyroJerkMag.std..


Source Dataset Description
--------------------------

The dataset includes the following files:

- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

Notes: 
------
- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

