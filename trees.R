# Team 6 ------------------------------------------------------------------

# Hope McIntyre
# Jason Adams
# Savi Kuriakose
# James Kim

# 10/19/15

# Read in the trees data
trees <- read.csv("trees.csv", header=T)


# Part 1: Masuyama's Method -----------------------------------------------

# Define the radius
r <- 37

# Define area of circle
a <- pi * r^2

# True basil area
t <- 311.906

# Define the area of the plot
A.star<- (750 + 2*r)^2 

# Function to get the TBA estimate
get.t.hat <- function(x){
  s.1 <- trees$ba[(trees$x - x[1])^2 + (trees$y - x[2])^2 < r^2]
  t.hat <- (A.star/a)*sum(s.1)
  return(t.hat)
}

# Generate 10^5 x and y coordinates
x.coord <- runif(10^5, -r, 750+r)
y.coord <- runif(10^5, -r, 750+r)
coord <- as.data.frame(cbind(x.coord, y.coord))

# Get the TBA estimate for each
print("Part 1: Masuyama's Method Output:")
start <- proc.time()
S.1 <- apply(coord, 1, get.t.hat)
proc.time() - start

# Get percentage bias
PB.1 <- 100*(mean(S.1) - t)/t
print(paste('Percentage Bias:', round(PB.1,5),"%"))

# Get percentage root mean square error
PRMSE.1 <- 100*sqrt(var(S.1))/t
print(paste('Percentage RMSE:', round(PRMSE.1,5),"%"))


# Part 2: Measure Pi Method -----------------------------------------------

# Area overlap function
overlap.area <- function(xt,yt,rl) {  
  dx <- min(xt, 750-xt)
  dy <- min(yt, 750-yt)
  if (dx >= rl & dy >= rl) {
    area <- pi*rl^2
  } else {
    if (dx < rl & dy >= rl) {
      if (dx >= 0) {
        area <- (pi - acos(dx/rl))*rl^2 + dx*sqrt(rl^2 - dx^2)
      } else {
        ndx <- -dx
        area <- acos(ndx/rl)*rl^2 - ndx*sqrt(rl^2 - ndx^2)
      }
    }
    if (dx >= rl & dy < rl) {
      if (dy >= 0) {
        area <- (pi - acos(dy/rl))*rl^2 + dy*sqrt(rl^2 - dy^2)
      } else {
        ndy <- -dy
        area <- acos(ndy/rl)*rl^2 - ndy*sqrt(rl^2 - ndy^2)
      }
    }
    if (dx < rl & dy < rl & (dx^2 + dy^2) >= rl^2) {
      if (dx >= 0 & dy >= 0) {
        area <- (pi-acos(dx/rl)-acos(dy/rl))*rl^2 + dx*sqrt(rl^2-dx^2)+dy*sqrt(rl^2-dy^2)
      }
      if (dx >= 0 & dy < 0) {
        ndy <- -dy
        area <- acos(ndy/rl)*rl^2 - ndy*sqrt(rl^2 - ndy^2)
      }
      if (dx < 0 & dy >= 0) {
        ndx <- -dx
        area <- acos(ndx/rl)*rl^2 - ndx*sqrt(rl^2 - ndx^2)
      }
      if (dx < 0 & dy < 0) {
        area <- 0
      }
    }
    if (dx < rl & dy < rl & (dx^2 + dy^2) < rl^2) {
      if (dx >= 0 & dy >= 0) {
        theta <- (3/2)*pi - acos(dx/rl) - acos(dy/rl)
        area <- (theta/2)*rl^2 + 0.5*(dx*sqrt(rl^2-dx^2)+dy*sqrt(rl^2-dy^2)) + dx*dy
      }
      if (dx >= 0 & dy < 0) {
        area1 <- acos(dx/rl)*rl^2 - dx*sqrt(rl^2 - dx^2)
        ndy <- -dy
        theta <- (3/2)*pi - acos(dx/rl) - acos(ndy/rl)
        area2 <- (theta/2)*rl^2 + 0.5*(dx*sqrt(rl^2-dx^2)+ndy*sqrt(rl^2-ndy^2)) + dx*ndy
        area <- pi*rl^2 - (area1 + area2)
      }
      if (dx < 0 & dy >= 0) {
        area1 <- acos(dy/rl)*rl^2 - dy*sqrt(rl^2 - dy^2)
        ndx <- -dx
        theta <- (3/2)*pi - acos(ndx/rl) - acos(dy/rl)
        area2 <- (theta/2)*rl^2 + 0.5*(ndx*sqrt(rl^2-ndx^2)+dy*sqrt(rl^2-dy^2)) + ndx*dy
        area <- pi*rl^2 - (area1 + area2)
      }
      if (dx < 0 & dy < 0) {
        ndx <- -dx
        ndy <- -dy
        theta <- (3/2)*pi + asin(ndx/rl) + asin(ndy/rl)
        area <- pi*rl^2 - ((theta/2)*rl^2 + 0.5*(ndx*sqrt(rl^2-ndx^2)+ndy*sqrt(rl^2-ndy^2)) - ndx*ndy)
      }
    }
  }
  return(area)
}

# New get t hat function
get.t.hat.2 <- function(x){
  s.1 <- trees$ba[(trees$x - x[1])^2 + (trees$y - x[2])^2 < r^2]
  t.hat <- (750^2/overlap.area(x[1], x[2], r))*sum(s.1)
  return(t.hat)
}

# Generate 10^5 x and y coordinates
x.coord.2 <- runif(10^5, 0, 750)
y.coord.2 <- runif(10^5, 0, 750)
coord.2 <- as.data.frame(cbind(x.coord.2, y.coord.2))

# Get the TBA estimate for each
print("Part 2: Measure Pi(i) Method Output:")
start <- proc.time() 
S.2 <- apply(coord.2, 1, get.t.hat.2)
proc.time() - start

# Get percentage bias
PB.2 <- 100*(mean(S.2) - t)/t
print(paste('Percentage Bias:', round(PB.2,5),"%"))

# Get percentage root mean square error
PRMSE.2 <- 100*sqrt(var(S.2))/t
print(paste('Percentage RMSE:', round(PRMSE.2,5),"%"))


# Part 3: Repeated Masuyama -----------------------------------------------

# New get t hat function
get.t.hat.3 <- function(x, r=37){
  ol <- overlap.area(x[1], x[2], r)
  s.1 <- trees$ba[(trees$x - x[1])^2 + (trees$y - x[2])^2 < r^2]
  if(ol == pi*r^2){
    t.hat <- (750^2/(pi*37^2))*sum(s.1)
    return(t.hat)
  } else{
    nr <- sqrt((pi*r^2-ol)/pi)
    new.coord <- runif(2, -nr, 750+nr)
    t.hat <- (750^2/(pi*37^2))*sum(s.1) + get.t.hat.3(new.coord, nr)
    return(t.hat)
  }
  
}

# Generate 10^5 x and y coordinates
x.coord.3 <- runif(10^5, -r, 750+r)
y.coord.3 <- runif(10^5, -r, 750+r)
coord.3 <- as.data.frame(cbind(x.coord.3, y.coord.3))

# Get the TBA estimate for each
print("Part 3: Repeated Masuyama")
start <- proc.time() 
S.3 <- apply(coord.3, 1, get.t.hat.3)
proc.time() - start

# Get percentage bias
PB.3 <- 100*(mean(S.3) - t)/t
print(paste('Percentage Bias:', round(PB.3,5),"%"))

# Get percentage root mean square error
PRMSE.3 <- 100*sqrt(var(S.3))/t
print(paste('Percentage RMSE:', round(PRMSE.3,5),"%"))

