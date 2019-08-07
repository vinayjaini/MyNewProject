setwd("G:/Python/Guru/Wind energy prediction")
#Consider the data which you have sent through mail praveen "enrgyfprst.scv"
energy<-enrgyfprst
names(energy)
#check number of null values associated
sapply(energy, function(x) sum(is.na(x)))
#take only complete cases
energy<-energy[complete.cases(energy),]
#Check for dimensions
dim(energy)
#first three columns sr.no, tubine number and time stamp were removed
energy<-energy[,-c(1:3)]
#Check dimensions
dim(energy)
#split data in to test and train
smp_size<-floor(0.75 * nrow(energy))
set.seed(123)
train_ind <- sample(seq_len(nrow(energy)), size = smp_size)

train <- energy[train_ind, ]
test <- energy[-train_ind, ]
dim(train); dim(test)
#variable selection
null=lm(avg_tot_prod_10M_kWh~1, data=train)
full=lm(avg_tot_prod_10M_kWh~., data=train)
stepMod<-step(null, scope=list(lower=null, upper=full), direction="forward")
# get the shortlisted variable.
shortlistedVars <- names(unlist(stepMod[[1]])) 
# remove intercept
shortlistedVars <- shortlistedVars[!shortlistedVars %in% "(Intercept)"]  
#Random forest method
library(party)
cf1 <- cforest(avg_tot_prod_10M_kWh~.,data= energy, control=cforest_unbiased(mtry=2,ntree=50)) # fit the random forest
# conditional=True, adjusts for correlations between predictors
varimp(cf1, conditional=TRUE)  
# more robust towards class imbalance.
varimpAUC(cf1)
#The 'Boruta' method can be used to decide if a variable is important or not
library(Boruta)
# Decide if a variable is important or not using Boruta
# perform Boruta search
boruta_output <- Boruta(avg_tot_prod_10M_kWh ~ ., data=energy, doTrace=2)  
# Confirmed  attributes: confirmed 94 attributes: avg_active_pwr, avg_amb_temp, avg_bearing_de_temp_10m, avg_bearing_nde_temp_10m, avg_gear_bear_temp_10m and 89 more;
# Rejected 3 attributes:rejected 1 attribute: avg_wtg_nac_pos_cor_10M_deg;still have 1 attribute left.
# collect Confirmed and Tentative variables
boruta_signif <- names(boruta_output$finalDecision[boruta_output$finalDecision %in% c("Confirmed", "Tentative")])  
# significant variables
print(boruta_signif)

#variable importance by earth package
library(earth)
# build model
marsModel <- earth(avg_tot_prod_10M_kWh ~ ., data=energy) 
ev <- evimp (marsModel) # estimate variable importance
plot(ev)

# plot variable importance
plot(boruta_output, cex.axis=.7, las=2, xlab="", main="Variable Importance")
boruta_output[["finalDecision"]]
#Model based on forward selection method
fit<-lm(avg_tot_prod_10M_kWh ~ max_power_factor + max_nac_pos + 
          min_gen_slipring_temp_10m + max_gen_wind_3_temp_10m + avg_bearing_de_temp_10m + 
          dv_gen_wind_2_temp_10m + min_amb_temp + max_trafo_wind_2_temp_10m + 
          avg_trafo_wind_1_temp_10m + avg_trafo_wind_3_temp_10m + avg_power_factor + 
          avg_gear_bear_temp_10m + avg_gearoil_temp_10m + max_rotor_speed + 
          hyd_pres_10M_bar + max_stator_pwr_10M + max_gen_wind_2_temp_10m + 
          max_gen_wind_1_temp_10m + min_gen_wind_2_temp_10m + min_gen_wind_1_temp_10m + 
          dv_gen_wind_1_temp_10m + dv_grid_vol + min_nac_pos + min_pitch_angle + 
          min_wind_dir + min_reactive_pwr + dv_stator_pwr_10M + avg_grid_vol + 
          max_grid_vol + avg_reactive_pwr + dv_trafo_wind_2_temp_10m + 
          dv_trafo_wind_3_temp_10m + min_trafo_wind_3_temp_10m + min_trafo_wind_2_temp_10m + 
          dv_reactive_pwr + max_gen_speed + avg_wind_speed + dv_gear_bear_temp_10m + 
          max_trafo_wind_1_temp_10m + avg_theory_pwr_10M + avg_active_pwr + 
          avg_gen_speed + avg_trafo_wind_2_temp_10m + min_gen_wind_3_temp_10m + 
          min_grid_vol + max_bearing_de_temp_10m + min_gearoil_temp_10m + 
          min_trafo_wind_1_temp_10m + avg_gen_wind_2_temp_10m + min_bearing_nde_temp_10m + 
          status + dv_gen_slipring_temp_10m + max_gear_bear_temp_10m + 
          dv_gen_wind_3_temp_10m, data = train)
#summary of the model
summary(fit)

#few variables are not having significance SO, Letss remove those
fit1<-lm(avg_tot_prod_10M_kWh ~ max_power_factor + max_nac_pos + 
          min_gen_slipring_temp_10m + max_gen_wind_3_temp_10m + avg_bearing_de_temp_10m 
         +dv_gen_wind_2_temp_10m + min_amb_temp + avg_trafo_wind_1_temp_10m + avg_trafo_wind_3_temp_10m + avg_power_factor + 
          avg_gear_bear_temp_10m + avg_gearoil_temp_10m + max_rotor_speed + 
          hyd_pres_10M_bar + max_stator_pwr_10M + max_gen_wind_2_temp_10m + 
          max_gen_wind_1_temp_10m + min_gen_wind_2_temp_10m + min_gen_wind_1_temp_10m + 
          dv_gen_wind_1_temp_10m + min_nac_pos+ min_wind_dir + min_reactive_pwr + dv_stator_pwr_10M + avg_grid_vol +  avg_reactive_pwr + dv_trafo_wind_2_temp_10m + 
          dv_trafo_wind_3_temp_10m + min_trafo_wind_3_temp_10m + min_trafo_wind_2_temp_10m + 
          dv_reactive_pwr + max_gen_speed + avg_wind_speed + dv_gear_bear_temp_10m + 
          max_trafo_wind_1_temp_10m + avg_theory_pwr_10M + avg_active_pwr + 
          avg_gen_speed + avg_trafo_wind_2_temp_10m + min_gen_wind_3_temp_10m + 
          min_grid_vol + max_bearing_de_temp_10m + min_gearoil_temp_10m, data = train)
summary(fit1)

#Predict using predict function for training data
pred_tr<-predict(fit1, data = train)
pred_tr
train$predicted<- NA
train$predicted<- pred_tr
train$error<-fit1$residuals
SE_tr<-train$error
MSE_tr<-mean(SE_tr)
RMSE_tr<-sqrt(MSE_tr)
RMSE_tr
train$accurcy<-NA
train$accurcy<-((train$predicted-train$avg_tot_prod_10M_kWh)/train$avg_tot_prod_10M_kWh)*100
mean(train$accurcy)
#Predict using predict function for test
pred_test<-predict(fit1, newdata = test)
pred_test
test$predicted<- NA
test$predicted<- pred_test
test$error<-test$predicted-test$avg_tot_prod_10M_kWh
SE_test<-test$error^2
MSE_test<-mean(SE_test)
RMSE_test<-sqrt(MSE_test)
RMSE_test
test$accurcy<-NA
test$accurcy<-((test$predicted)/test$avg_tot_prod_10M_kWh)*100
mean(test$accurcy)
View(test)
