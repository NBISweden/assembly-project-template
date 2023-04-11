library('ggplot2')
library('gridExtra')
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("At least one argument must be supplied (project name)", call.=FALSE)
}

data_in <- read.table(args[1],header = T)
average_molLength <- c()
average_SNR <- c()
average_labelDensity <- c()
for (i in 1:max(data_in$runID)){
  average_molLength <- c(average_molLength,mean(data_in$length[data_in$runID==i]))
  average_SNR <- c(average_SNR,mean(data_in$SNR[data_in$runID==i]))
  average_labelDensity <- c(average_labelDensity,mean(data_in$NumLabels[data_in$runID==i]/data_in$length[data_in$runID==i]))
}
average_molLength = average_molLength/1000
average_labelDensity = average_labelDensity*100000

jpeg(paste0('../../QC/bionano/',args[1],'_BionanoQC.jpeg'),width=2000,height=1600)
par(mar=c(5,6,8,1)+.1)
p1<-qplot(c(1:max(data_in$runID)),average_molLength,xlab = 'Run ID',ylab='Average molecule Length (kbp)',ylim=c(0,max(average_molLength)),main='Average molecule length per cohort')+theme(text = element_text(size=40))
p2<-qplot(c(1:max(data_in$runID)),average_SNR,xlab = 'Run ID',ylab='Average Signal-to-Noise Ratio',ylim=c(0,max(average_SNR)),main='Average SNR per cohort')+theme(text = element_text(size=40))
p3<-qplot(c(1:max(data_in$runID)),average_labelDensity,xlab = 'Run ID',ylab='Average label density (/100 kbp)',ylim=c(0,max(average_labelDensity)),main='Average label density per cohort')+theme(text = element_text(size=40))
p4 <- ggplot(data.frame(runID=data_in$runID),aes(x=runID))+geom_histogram(binwidth = 1)+labs(title="Number of molecules per cohort",x="Run ID", y = "Frequency")+theme(text = element_text(size=40))
grid.arrange(p1,p2,p3,p4,nrow=2,ncol=2)
dev.off()

