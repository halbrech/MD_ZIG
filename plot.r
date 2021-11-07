library(tcltk)
X11()
data <- read.csv('lj.csv', header = TRUE)
plot(data$t, data$px, type="l", col="#ff0000", ylim=c(-3, 3))
lines(data$t, data$py, type="l", col="#0000ff")
lines(data$t, data$pz, type="l", col="#00ff00")
lines(data$t, data$T, type="l", col="#000000")
lines(data$t, data$Lx, type="l", col="#ffaaaa")
lines(data$t, data$Ly, type="l", col="#ffbbbb")
lines(data$t, data$Lz, type="l", col="#ffcccc")
prompt  <- "hit spacebar to close plots"
extra   <- "some extra comment"
capture <- tk_messageBox(message = prompt, detail = extra)
