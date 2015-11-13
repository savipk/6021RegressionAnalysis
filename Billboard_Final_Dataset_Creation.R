# Read and Aggregate Top 100 List. 
library(xlsx)
library(stringr)
library(plyr)
library(compare)
library(dplyr)

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

for(x in 1:nrow(chart)){
  a <- str_replace_all(chart[x,2],"[[:punct:]]","")
  b <- str_split(a, " ")[[1]][1] 
  chart[x,"Primary.Artist"] <- tolower(b)
}

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

varDups <- c("Recording","Artist")
uniqueSongs <- removeDups(chart,varDups)


# Create index to match EchoNest table
uniqueSongs$index <- seq(from=0, to=nrow(uniqueSongs)-1)

# Get Unique Songs --------------------------------------------------------

for(x in 1:nrow(uniqueSongs)){
  a <- str_replace_all(uniqueSongs[x,1],"[[:punct:]]","")
  uniqueSongs[x,"Primary.Song"] <- tolower(a)
}

# List of Variables to Analyze for Duplicates
varDups <- c("Recording","Primary.Artist")
uniqueSongs <- removeDups(uniqueSongs, varDups)


# Create Features on Billboard set ----------------------------------------------

get.last.week <- function(x){
  return(tail(arrange(chart[chart$Recording == x[1] & chart$Artist == x[2],], Week),1)$Week)
}

get.num.weeks <- function(x){
  all <- chart[chart$Recording == x[1] & chart$Primary.Artist == x[10],]
  return(sum(aggregate(Weeks.In.Chart ~ First.Charted.Date, all, max)$Weeks.In.Chart))
}

get.actual.peak <- function(x){
  return(min(chart[chart$Recording == x[1] & chart$Artist == x[2],]$Peak.Position))
}



uniqueSongs$last.week <- as.Date(apply(uniqueSongs, 1, get.last.week))
uniqueSongs$Weeks.In.Chart.tot1 <- apply(uniqueSongs, 1, get.num.weeks)
uniqueSongs$Peak.Position.act <- apply(uniqueSongs, 1, get.actual.peak)


# Get some stats ----------------------------------------------------------

songs.in.time <- uniqueSongs[uniqueSongs$last.week < "2014-10-25",]

hist(songs.in.time$Weeks.In.Chart.tot, breaks=81)
mean(songs.in.time$Weeks.In.Chart.tot)
plot(songs.in.time$Peak.Position, songs.in.time$Weeks.In.Chart.tot)

songs.in.time[songs.in.time$Peak.Position < 5 & songs.in.time$Weeks.In.Chart.tot <20,]

# Feature Engineering -----------------------------------------------------

uniqueSongs$feat <- 0
uniqueSongs$feat[(str_detect(uniqueSongs$Artist, "Feat"))|
                 (str_detect(uniqueSongs$Artist, "/"))|
                 (str_detect(uniqueSongs$Artist, "And"))|
                 (str_detect(uniqueSongs$Artist, ","))|
                 (str_detect(uniqueSongs$Artist, "Ft"))|
                 (str_detect(uniqueSongs$Artist, 'Duet'))] <- 1



uniqueSongs$love <- 0
uniqueSongs$love[(str_detect(uniqueSongs$Recording, "Love"))|
                 (str_detect(uniqueSongs$Recording, "Luv"))] <- 1

uniqueSongs$Top.20 <- 0
uniqueSongs$Top.20[uniqueSongs$Peak.Position <= 20] <- 1

table(uniqueSongs$love)
uniqueSongs$title.len <- nchar(as.character(uniqueSongs$Recording))

uniqueSongs$Success <- uniqueSongs$Weeks.In.Chart.tot/uniqueSongs$Peak.Position.act


# Join with EchoNest Attributes -------------------------------------------

# Join the tables
attributes.raw <- read.csv("../song_attributes.csv", header=T)
attributes <- attributes.raw[,-c(1,3,4)]



# Join by index
unique.songs.tot <- join(uniqueSongs, attributes, by='index')


# Factor Attributes ------------------------------------------------------- 

table(unique.songs.tot$key)
unique.songs.tot$key <- factor(unique.songs.tot$key, labels = c("c", "c-sharp", "d", "e-flat", "e", "f", 
                                                                "f-sharp", "g", "a-flat", "a", "b-flat", "b"))

unique.songs.tot$mode <- factor(unique.songs.tot$mode, labels = c("minor", "major"))

unique.songs.tot$time_signature <- factor(unique.songs.tot$time_signature)


unique.songs.tot[which(unique.songs.tot$Peak.Position < unique.songs.tot$Peak.Position.act),c("Recording","Artist","Peak.Position","Peak.Position.act")]
min(chart[chart$Recording == "Applause" & chart$Artist == "Lady Gaga",]$Peak.Position)


# Clean Table -------------------------------------------------------------
drops <- c("Position", "Previous.Position", "Peak.Position", "Weeks.In.Chart", "Week")
chart.clean <- unique.songs.tot[,!(names(unique.songs.tot) %in% drops)]
colnames(chart.clean)[13:25]
na.omit(chart.clean[which(duplicated(chart.clean[13:25])),])

chart.clean1 <- chart.clean
anti_join(chart.clean1, chart.clean)
chart.clean[which(!(chart.clean$index %in% chart.clean1$index)),]
chart.clean[chart.clean$Primary.Artist=="rae",]

plot(chart.clean$tempo[chart.clean$Success<5], chart.clean$Success[chart.clean$Success<5])
plot(chart.clean$tempo, chart.clean$Success)
table(chart.clean$love)
plot(chart.clean$danceability,chart.clean$Weeks.In.Chart.tot)
