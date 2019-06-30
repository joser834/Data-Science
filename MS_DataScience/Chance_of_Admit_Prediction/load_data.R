####--------Loading data--------####
train <- read.csv("econometria-ug-2019/train.csv", header = TRUE, stringsAsFactors = FALSE)
test <- read.csv("econometria-ug-2019/test.csv", header = TRUE, stringsAsFactors = FALSE)

####--------Column names--------####
names(train) <- c("GRE", "TOEFL", "University_Rating", "SOP", "LOR", "CGPA", "Research", "Chance_of_Admit")
names(test) <- c("GRE", "TOEFL", "University_Rating", "SOP", "LOR", "CGPA", "Research", "id")

####--------Chance of Admit--------####
val_index <- createDataPartition(train$Chance_of_Admit, p=0.70, list = FALSE)
train <- train[val_index,]
val <- train[-val_index,]
