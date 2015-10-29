# This creates a csv of searchable artist song pairs
# It could still use some work

for(x in 1:nrow(uniqueSongs)){
  uniqueSongs[x,"Recording1"] <- str_replace(uniqueSongs[x,1], "’", "'")
  a <- str_split(uniqueSongs[x,2], " Feat")[[1]][1]
  b <- str_split(a, " &")[[1]][1]
  c <- str_split(b, "/")[[1]][1]         
  d <- str_split(c, " And")[[1]][1]                
  e <- str_split(d, " ,")[[1]][1] 
  f <- str_split(e, " Ft")[[1]][1] 
  g <- str_split(f, " Duet")[[1]][1] 
  uniqueSongs[x,"oneartist"] <- g
  
}
write.csv(uniqueSongs[,c("Recording1", "oneartist")], "unique_artists_songs.csv")