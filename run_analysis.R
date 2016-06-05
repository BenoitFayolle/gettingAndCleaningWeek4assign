if (!file.exsists("./UCI HAR Dataset")){
    stop("place the 'UCI HAR Dataset' folder in the same directory this script is in")
}
if (!file.exists("./tidy")){
    dir.create("./tidy")
}
library(dplyr)
library(plyr)
library(reshape2)

### 1. Merges the training and the test sets to create one data set.

folders<-c("test","train")
DataSet<-{} #the tidy dataset
iActivities<-{} #index of the activites
Sujects<-{} #subjects
for (i in length(folders)) {
    DataSet<-rbind(DataSet,read.table(paste("./UCI HAR Dataset/",
                                            folders[i],"/X_",folders[i],".txt",sep="")))
    iActivities<-rbind(iActivities,read.table(paste("./UCI HAR Dataset/",
                                      folders[i],"/y_",folders[i],".txt",sep="")))
    Sujects<-rbind(Sujects,read.table(paste("./UCI HAR Dataset/",
                                            folders[i],"/subject_",folders[i],".txt",sep="")))
}

### 2. Extracts only the measurements on the mean and standard deviation for each measurement.
DF<-read.table("./UCI HAR Dataset/features.txt",stringsAsFactors = F)
featureNames<-DF[,2]
# ifeatureNames<-DF[,1]   #index of each variable
### selecting mean and standard deviation variables
iMeanStd<-grep(pattern="-mean\\(\\)|-std()",featureNames)
DataSet<-DataSet[,iMeanStd]

### 4. Appropriately labels the data set with descriptive variable names
colnames(DataSet)<-gsub("\\(\\)","",featureNames[iMeanStd])

### 3. Uses descriptive activity names to name the activities in the data set
DF<-read.table("./UCI HAR Dataset/activity_labels.txt") # extract de descriptive activity names
activitiesStr<-DF[,2]
DataSet$activities<-activitiesStr[iActivities[,1]]  #adds a column with activity names to the tidy dataset

### 5. From the data set in step 4, creates a second, independent tidy data set 
### with the average of each variable for each activity and each subject.
DataSet$Subjects<-Subjects    #adds the subjects column to the tidy dataset
DF<-melt(DataSet,id=featureNames[iMeanStd],measure.vars = "activities")
DataSet2<-dcast(DF, featureNames[iMeanStd]~variable,mean)
