####--------Functions & Params--------####

####--------Genetic Algorithm--------####
get_chromosome <- function(train, label, x){
  col_names <- names(train)
  inputs <- base::setdiff(col_names, label)
  chromosome <- sample(c(0,1), size = length(inputs), replace = TRUE)
  if(sum(chromosome)==0){
    chromosome <- rep(1,length(inputs)) 
  }
  output <- chromosome
  return(output)
}

get_fitness <- function(chromosome, train, test, label){
  col_names <- names(train)
  inputs <- setdiff(col_names,label)
  chromosome <- as.logical(chromosome)
  formula <- paste0(inputs[chromosome], collapse = '+')
  formula <- paste0(label, "~", formula)
  fit <- lm(formula, data = train)
  pred <- predict(fit,test)
  error_square <- sum((pred-test$Chance_of_Admit)^2)
  return(error_square)
}

select_mating_parents <- function(x, roullete, population){
  sum_fit_p <- sample(1:sum(roullete$rank), size = 1)
  pindex <- roullete %>% 
    filter(cumsum_rank < sum_fit_p) %>%
    nrow()
  p1 <- roullete[pindex+1,] %>% pull(parent)
  sum_fit_p <- sample(1:sum(roullete$rank), size = 1)
  pindex <- roullete %>% 
    filter(cumsum_rank<sum_fit_p) %>%
    nrow()
  p2 <- roullete[pindex+1,] %>% pull(parent)
  return(population[c(p1,p2)])
}

crossover <- function(parents){
  p1 <- parents[[1]]
  p2 <- parents[[2]]
  chromosome_len <- length(p1)
  mask1 <- rep(0, ceiling(chromosome_len-chromosome_len/2))
  mask2 <- rep(1, chromosome_len/2)
  mask_last_half <- c(mask1, mask2)
  mask1 <- rep(1, ceiling(chromosome_len-chromosome_len/2))
  mask2 <- rep(0, chromosome_len/2)
  mask_first_half <- c(mask1, mask2)
  child1 <- mask_first_half*p1 + mask_last_half*p2
  child2 <- mask_first_half*p2 + mask_last_half*p1
  return(list(child1, child2))
}

mutation <- function(child, rate = 0.01){
  mask <- sample(c(1,0), length(child), replace = TRUE, prob = c(rate, 1-rate))
  mutation.child <- xor(child, mask)*1.0
  return(mutation.child)
}