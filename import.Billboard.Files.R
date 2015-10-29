# Read and Aggregate Top 100 List. 

library(xlsx)
library(stringr)
setwd('/Users/hopeemac/Documents/Education/Classes/UVA MSDS/15F/Linear Models/Billboard Data')
files <- list.files(path = ".", pattern = "*.xlsx")

import.Billboard.Files <- function(file.path) {
  files <- list.files(path = file.path, pattern = "*.xlsx")
  DF.Master = data.frame()
  for (file in files) {
    if (file == files[1]) {
      DF.Master <- read.xlsx(file, sheetIndex = 1, startRow = 5, header = T)
      print(nrow(DF.Master))
      Week <- rep(str_replace(file,".xlsx",""),nrow(DF.Master))
      DF.Master <- cbind(DF.Master,Week)
    }
    else {
      data.frame <- read.xlsx(file, sheetIndex = 1, startRow = 5, header = T)
      Week <- rep(str_replace(file,".xlsx",""), nrow(data.frame))
      data.frame <- cbind(data.frame,Week)
      DF.Master <- rbind(DF.Master, data.frame)
    }
    print(paste("Added", file, "to the dataframe"))
  }
  return(DF.Master)
}

# Read in all Txt Files from Working Directory and save as 'train' variable
chart <- import.Billboard.Files('.')

# Write Aggregated List to CSV
# Need to Fix Encoding
write.table(chart, "Billboard.csv", sep = ",", row.names = F)

# Find Number of Unique Songs

removeDups <- function(DF, var.dups) {
  # Identify Duplicates from Variables passed to Fuction
  dups <- which(duplicated(DF[,var.dups]) == T)
  # targetLength <- (nrow(train)-length(dups)) 
  # length(dups)
  DF <- DF[-dups,]
  # nrow(train) == targetLength
  return(DF)
}
# List of Variables to Analyze for Duplicates
varDups <- c("Recording","Artist")
uniqueSongs <- removeDups(chart,varDups)
# Add Sort
# Keep only Recording and Artist in uniqueSongs DF
View(uniqueSongs)
