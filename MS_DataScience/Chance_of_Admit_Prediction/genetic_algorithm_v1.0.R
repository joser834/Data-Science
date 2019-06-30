####--------Loading Libraries--------####
require(RMySQL)
require(dplyr)
require(lubridate)
require(DT)
require(openxlsx)
require(plotly)
require(tidyr)
require(stringr)
require(xts)
source("functions.R")

####--------Feature Engineering--------####
#' This is to get squared, log and 1/x for each column that apply.
#' For example if we have a column that have values less than 0
#' then it will not be 
columns_sq <- names(train %>% dplyr::select(-Chance_of_Admit))
#columns_log <- names(train %>% dplyr::select(-Chance_of_Admit))[sapply(train %>% dplyr::select(-Chance_of_Admit), function(x) min(x))>0]
#columns_x <- names(train %>% dplyr::select(-Chance_of_Admit))[sapply(train %>% dplyr::select(-Chance_of_Admit), function(x) min(x))>0]
new_columns_sq <- paste(columns_sq, "_2", sep = "")
#new_columns_log <- paste(columns_log, "_log", sep = "")
#new_columns_x <- paste(columns_x, "_x", sep = "")

train[new_columns_sq] <- train[columns_sq]**2
#train[new_columns_log] <- log(train[columns_log])
#train[new_columns_x] <- 1/train[columns_x]

val[new_columns_sq] <- val[columns_sq]**2
#val[new_columns_log] <- log(val[columns_log])
#val[new_columns_x] <- 1/val[columns_x]

test[new_columns_sq] <- test[columns_sq]**2
#test[new_columns_log] <- log(test[columns_log])
#test[new_columns_x] <- 1/test[columns_x]


####--------Create Population (All Models)--------####
all_models <- expand.grid(c(0,1), 
                          c(0,1), 
                          c(0,1), 
                          c(0,1), 
                          c(0,1), 
                          c(0,1), 
                          c(0,1),
                          c(0,1), 
                          c(0,1), 
                          c(0,1), 
                          c(0,1), 
                          c(0,1), 
                          c(0,1), 
                          c(0,1),
                          c(0,1))
model_list <- list()
for(i in 1:nrow(all_models)){
  model_list[[i]] <- all_models[i,] %>% as.numeric()
}

population <- model_list[lapply(model_list, sum) > 0]

####--------Population--------####
pop_size <- 500
population <- lapply(1:pop_size, get_chromosome, train = train, label = "Chance_of_Admit")

forgraph <- c()

#population <- model_list[2:length(model_list)]
ga <- function(n, predict){
  population <- population[lapply(population, sum) > 0]
  for(i in 1:n){
    print(paste("----- Generation ", i, " -----", sep = ""))
    
    ####--------Fit the population--------####
    fitness <- lapply(population, get_fitness, train = train, test = val, label = predict)
    
    ####--------Creating roullete to decide which parents will be mating--------####
    roullete <- tibble(parent = 1:length(population), fitness = fitness %>% unlist()) %>% 
      arrange(desc(fitness))
    
    roullete$rank <- 1:nrow(roullete)
    
    roullete <- roullete %>% 
      mutate(cumsum_rank = cumsum(rank))
    
    ####--------Mating parents--------####
    mating_parents <- lapply(1:length(population), select_mating_parents, roullete = roullete, population = population)
    
    ####--------Getting the children--------####
    children <- lapply(mating_parents, crossover) %>% unlist(recursive = FALSE)
    children <- children[1:length(population)]
    
    ####--------Getting the top parents--------####
    top_parent <- roullete %>% tail(1) %>% pull(parent)
    top_parent_fitness <- roullete %>% tail(1) %>% pull(fitness)
    print(population[[top_parent]])
    print(paste("Top Parent Fitness: ", top_parent_fitness, sep = ""))
    
    ####--------New children--------####
    population <- lapply(children, mutation, rate=0.1)
    
    forgraph <- c(forgraph, top_parent_fitness)
  }
  
  ####--------Best fitness formula--------####
  chromosome <- population[[top_parent]]
  chromosome <- as.logical(chromosome)
  formula <- paste0(names(train)[chromosome], collapse = '+')
  formula <- paste0(predict, "~", formula)
  print(paste("Best formula: ", formula, sep = ""))
  
  forPlot <- data.frame(
    x = 1:n,
    y = forgraph
  )
  plot_ly(data = forPlot, x = ~x, y = ~y, type = "scatter", mode = "lines+markers") %>% 
    layout(title="Top Parent Fitness over iterations")
  return(formula)
}

new_values <- predict(lm(data = train, formula = ga(5, "Chance_of_Admit")), test)
submission <- test %>% 
  dplyr::select(id) %>% 
  mutate(`Chance of Admit` = new_values)
write.csv(submission, file = "submission_v1.0.csv", row.names = FALSE)
