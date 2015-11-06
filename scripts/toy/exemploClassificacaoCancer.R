cancer <- read.csv("data/breast-cancer-wisconsin.data", header=F)
names(cancer) <- c('id','ClumpThickness',
                   'UniformityCellSize',
                   'UniformityCellShape',
                   'MarginalAdhesion',
                   'SingleEpithelialCellSize',
                   'BareNuclei',
                   'BlandChromatin',
                   'NormalNucleoli',
                   'Mitoses',
                   'Class')
head(cancer)
sapply(cancer, class)
cancer$Class <- as.factor(cancer$Class)
cancer$Class <- ifelse(cancer$Class == '2', 
                       'benigno', 
                       'maligno')
cancer$BareNuclei <- ifelse(cancer$BareNuclei == '?', 
                            NA, 
                            cancer$BareNuclei)
cancer$BareNuclei <- as.numeric(cancer$BareNuclei)
table(cancer$BareNuclei)
