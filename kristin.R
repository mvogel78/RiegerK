setwd("/media/mandy/Volume/transcend/doktoranden/rieger")
load("daten_komplett.RData")
require(gamlss)
require(gamlss.tr)
require(reshape2)
require(ggplot2)


## ferritin
### daten
tmpdata_boys <- na.omit(daten[daten$SEX==1,c("LAB_FERR_S_NUM_VALUE","AGE","SEX")])
tmpdata_girls <- na.omit(daten[daten$SEX==2,c("LAB_FERR_S_NUM_VALUE","AGE","SEX")])

### modelle
mmferr_boys <- lms (LAB_FERR_S_NUM_VALUE, AGE, family= LMS, data=tmpdata_boys)
mmferr_girls <- lms (LAB_FERR_S_NUM_VALUE, AGE, family= LMS, data=tmpdata_girls)

## erzeuge truncated distribution
gen.trun(par=c(0),family="NO",type="left")
gen.trun(par=c(0),family="BCCG",type="left")

mmferr_boys2 <- gamlss(LAB_FERR_S_NUM_VALUE ~ pb(AGE), family = BCCGtr, data = tmpdata_boys )

mmferr_girls2 <- gamlss(LAB_FERR_S_NUM_VALUE ~ pb(AGE), family = BCCGtr, data = tmpdata_girls)

centiles(mmferr_boys2, xvar=tmpdata_boys$AGE, cent=c(3,10,50,90,97), col.centiles=c("gray0","gray15","gray30","gray45","gray60"), 
         ylab="Ferritin in ng/ml", xlab="Exaktes Alter in Jahren",
         xlim=c(2.5,16),ylim=c(0,110), main="Geglätte Perzentilenkurven für Ferritin (ng/ml) \n Jungen, N = 664",
         legend("topleft",c("P 3","P 10","P 50","P 90","P 97"),lty=1,lwd=2.5,col=c("gray0","gray15","gray30","gray45","gray60")),
         points=TRUE, pch=20, col="gray76", plot=TRUE, lwd=1, las=1)

centiles(mmferr_girls2, xvar=tmpdata_girls$AGE, cent=c(3,10,50,90,97), col.centiles=c("gray0","gray15","gray30","gray45","gray60"), 
         ylab="Ferritin in ng/ml", xlab="Exaktes Alter in Jahren",
         xlim=c(2.5,16),ylim=c(0,100), main="Geglätte Perzentilenkurven für Ferritin (ng/ml) \n Mädchen, N = 637",
         legend("topleft",c("P 3","P 10","P 50","P 90","P 97"),lty=1,lwd=2.5,col=c("gray0","gray15","gray30","gray45","gray60")),
         points=TRUE, pch=20, col="gray76", plot=TRUE, lwd=1, las=1)

## extract values for plotting
centilesferr1 <- centiles.pred(mmferr_boys2,type="centiles",cent=c(3,50,97),xvalues=seq(3,16,by=0.1),xname="AGE")
centilesferr2 <- centiles.pred(mmferr_girls2,type="centiles",cent=c(3,50,97),xvalues=seq(3,16,by=0.1),xname="AGE")

centilesferr1$SEX <- "male"
centilesferr2$SEX <- "female"

grdat1 <- melt(centilesferr1,id.vars = c("AGE","SEX"))
grdat2 <- melt(centilesferr2,id.vars = c("AGE","SEX"))

grdat <- rbind(grdat1,grdat2)
tmpdata_boys$SEX <- "male"

ggplot(grdat,aes(x=AGE,y=value)) +
  geom_line(aes(linetype=SEX,group=paste(SEX,variable))) +
  scale_y_continuous(limits=c(0,110)) +
  theme_bw()
