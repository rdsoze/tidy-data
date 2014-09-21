# 9:45  9740731961

#Download dataset if not present in current folder.
if (!file.exists("UCI HAR Dataset")){
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url=url, destfile="UCI HAR Dataset", method="curl")
    donwloadedDate <- date()
    unzip("UCI HAR Dataset.zip", overwrite=TRUE)
}

dataPath = "./UCI HAR Dataset/"
featurePath = paste(dataPath, 'features.txt', sep="/")
activitiesPath = paste(dataPath, 'activity_labels.txt', sep="/")


readData <- function(path.prefix, file) {
    # read features, labels, subject into R
    feature.loc <- paste0(dataPath, path.prefix, '/', 'X_', file, '.txt')
    features <- read.table(feature.loc)
    
    label.loc <- paste0(dataPath, path.prefix, '/', 'y_', file, '.txt')
    label <- read.table(label.loc)
    
    subject.loc <- paste0(dataPath, path.prefix, '/', 'subject_', file, '.txt')
    subject <- read.table(subject.loc)
    
    # Names of features
    feature.names <- read.table(featurePath, stringsAsFactors = FALSE)
    feature.names <- feature.names[,2]
    
    # select columns measuring mean/std
    col.idx <- grep('mean\\(\\)|std\\(\\)', feature.names)
    
    data <- cbind(label, subject, features[ ,col.idx])
    names(data) <- c('Activity', 'SubjectID',feature.names[col.idx])
    data
}

# steps 1-2: merge the training and the test datasets
train <- readData('train', 'train')
test <- readData('test', 'test')
all <- rbind(train, test)

# step 3 clean up names
names(all) <- gsub('mean\\(\\)', 'Mean', names(all))
names(all) <- gsub('std\\(\\)', 'Std', names(all))
names(all) <- gsub('-', '', names(all))

#step 4 load activites
activities <- read.table(activitiesPath, col.names = c('Activity', 'ActivityName'), )
all <- merge(activities, all)
all$Activity <- NULL


aggregated <- aggregate(. ~ ActivityName + SubjectID, data = all, FUN = mean)

write.table(aggregated, file = 'tidy.txt', quote = FALSE)
