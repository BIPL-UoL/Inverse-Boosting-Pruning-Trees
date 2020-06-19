library("plotROC")
library("cvAUC")
library("pROC")
library("ROCR")
library("readxl")
library("MLmetrics")
library("mccr")

rm(list = ls())

readfilename <- "output/predicts.csv"



pdf('performance_curves.pdf',paper = 'A4')

saveCSVfile <- "performance_metrics.csv" 


basicinfo_test <-
  read.csv(file = readfilename,
           header = TRUE,
           sep = ",")

IBPT_Series_dummy_events <- subset(basicinfo_test, FLAG == 0)

IBPT_Series_true_events <- subset(basicinfo_test, FLAG == 1)

IBPT_Series_dummy_events_eqnum <-
  unique(IBPT_Series_dummy_events$EQ_NUM)

IBPT_Series_true_events_eqnum <-
  unique(IBPT_Series_true_events$EQ_NUM)

IBPT_Series_dummy_events_MatchRatio <- c()

for (i_dummy in IBPT_Series_dummy_events_eqnum) {
  Series_sesmic_events_i_dummy <-
    subset(IBPT_Series_dummy_events, EQ_NUM %in% i_dummy)
  
  MatchRatio <-
    nrow(subset(Series_sesmic_events_i_dummy, LABEL_PREDICTION == 1)) / nrow(Series_sesmic_events_i_dummy)
  
  IBPT_Series_dummy_events_MatchRatio <-
    c(IBPT_Series_dummy_events_MatchRatio, MatchRatio)
}

IBPT_Series_true_events_MatchRatio <- c()

for (i_true in IBPT_Series_true_events_eqnum) {
  Series_sesmic_events_i_true <-
    subset(IBPT_Series_true_events, EQ_NUM %in% i_true)
  
  MatchRatio <-
    nrow(subset(Series_sesmic_events_i_true, LABEL_PREDICTION == 1)) / nrow(Series_sesmic_events_i_true)
  
  IBPT_Series_true_events_MatchRatio <-
    c(IBPT_Series_true_events_MatchRatio, MatchRatio)
}


E1 <- IBPT_Series_true_events_MatchRatio

E2 <- IBPT_Series_dummy_events_MatchRatio

E <- c(E1, E2)

L.ex <-
  c(rep(1, length(IBPT_Series_true_events_eqnum)), rep(0, length(IBPT_Series_dummy_events_eqnum)))

IBPT_Series_MatchRatio <-
  data.frame(
    L = L.ex,
    D.str = c("N", "P")[L.ex + 1],
    predictdata = E,
    stringsAsFactors = FALSE
  )

pp <- IBPT_Series_MatchRatio$predictdata

ll <- IBPT_Series_MatchRatio$L

pred_k <- prediction(pp, ll)

peIBPT_k <- performance(pred_k, "tpr", "fpr")

v <- coords(
  roc(ll, pp),
  "best",
  ret = c(
    "specificity",
    "sensitivity",
    "accuracy",
    "precision",
    "tn",
    "tp",
    "fn",
    "fp"
  )
)

lsSpecificity <- as.numeric(tail(v, 1)[1])

lsSensitivity <- as.numeric(tail(v, 1)[2]) # recall

lsAccuracy <- as.numeric(tail(v, 1)[3])

lsPrecision <- as.numeric(tail(v, 1)[4])

lstn <- as.numeric(tail(v, 1)[5])

lstp <- as.numeric(tail(v, 1)[6])

lsfn <- as.numeric(tail(v, 1)[7])

lsfp <- as.numeric(tail(v, 1)[8])

lsPRAUC <- PRAUC(pp, ll)

lsROCAUC <- AUC(pp, ll)

lsMCC <-
  (lstp * lstn - lsfp * lsfn) / sqrt((lstp + lsfp) * (lstp + lsfn) *
                                       (lstn + lsfp) * (lstn + lsfn))

lsFscore <-
  as.numeric((2 * lsPrecision * lsSensitivity) / (lsPrecision + lsSensitivity))

lsRscore <-
  as.numeric((lstp * lstn - lsfp * lsfn) / ((lstp + lsfn) * (lsfp + lstn)))

Reslut <-
  data.frame(
    MCC = round((lsMCC), 4),
    Rscore = round((lsRscore), 4),
    PRAUC = round((lsPRAUC), 4),
    ROCAUC = round((lsROCAUC), 4),
    Fscore = round((lsFscore), 4),
    Specificity = round((lsSpecificity), 4),
    Sensitivity = round((lsSensitivity), 4),
    Accuracy  = round((lsAccuracy), 4),
    Precision = round((lsPrecision), 4),
    TN = round((lstn), 4),
    TP = round((lstp), 4),
    FN  = round((lsfn), 4),
    FP = round((lsfp), 4)
  )

write.csv(Reslut,
          saveCSVfile,
          row.names = T,
          col.names = T)

pred_k <- prediction(pp, ll)
peRF_k <- performance(pred_k, "tpr", "fpr")

par(mfrow = c(2, 2))

plot(
  peRF_k,
  main = paste0("ROC curve"),
  cex.axis = 1,
  cex.main = 0.8,
  colorize = T
)#,, col = 'green')

lines(
  x = c(0, 100),
  y = c(0, 100),
  lty = 2,
  col = 'darkslategray2'
)

legend("bottomright",
       legend = c(paste("ROC AUC = ",
                        round(lsROCAUC, 4),
                        sep = "")),
       cex = 0.7)

peRF_k <- performance(pred_k, "prec", "rec")

plot(
  peRF_k,
  main = paste0("Precision Recall Curve"),
  cex.axis = 1,
  cex.main = 0.8,
  colorize = T
)#,, col = 'green')

segments(0, 1, 1, 0.48, lty = 2,
         col = 'Dark Grey')

legend("topright",
       legend = c(paste("PR AUC = ",
                        round(lsPRAUC, 4),
                        sep = "")),
       cex = 0.7)

dev.off()

