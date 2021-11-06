library(tcltk)
windows()
data <- read.csv('lj.csv', header = TRUE)
plot(data$T, data$X1, type="l", col="#ff0000", ylim=c(-3, 3))
lines(data$T, data$X2, type="l", col="#0000ff")
lines(data$T, data$E, type="l", col="#000000")
lines(data$T, data$Lx, type="l", col="#ffaaaa")
lines(data$T, data$Ly, type="l", col="#ffbbbb")
lines(data$T, data$Lz, type="l", col="#ffcccc")
prompt  <- "hit spacebar to close plots"
extra   <- "some extra comment"
capture <- tk_messageBox(message = prompt, detail = extra)
