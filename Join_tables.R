# Join the tables
attributes.raw <- read.csv("../song_attributes.csv", header=T)
attributes <- attributes.raw[,-c(1,3,4)]

# Create index to match EchoNest table
uniqueSongs$index <- seq(from=0, to=nrow(uniqueSongs)-1)

# Join by index
unique.songs.tot <- join(uniqueSongs, attributes, by='index')

# Get the missing artists (could be written a little better)
missing <- unique.songs.tot[which(is.na(unique.songs.tot[,seq(from=11, to=23)])[,1]),]

# Create a new dataframe with the missing artists and song titles for more processing
artists <- uniqueSongs[which(is.na(unique.songs.tot[,seq(from=11, to=23)])[,1]),c("Recording1", "oneartist")]

# This gets ~6 more of the songs so still needs work
for(x in 1:nrow(artists)){
  artists[x,"Recording1"] <- str_replace(artists[x,1], "'", "’")
  artists[x,"Recording1"] <- str_replace(artists[x,1], "&", "and")
  artists[x,"oneartist"] <- str_replace(artists[x,2], "YG", "Y.G.")
  artists[x,"oneartist"] <- str_replace(artists[x,2], "ALT-J", "ALTJ")
  artists[x,"oneartist"] <- str_replace(artists[x,2], "\\$", "S")
  artists[x,"Recording1"] <- str_replace(artists[x,1], "\\*\\*", "uc")
  artists[x,"Recording1"] <- str_replace(artists[x,1], "\\#", "")
  artists[x,'oneartist'] <- str_split(artists[x,2], ",")[[1]][1]
  artists[x,'Recording1'] <- str_split(artists[x,1], "\\[")[[1]][1]
}

write.csv(artists[,c("Recording1", "oneartist")], "remaining.csv")