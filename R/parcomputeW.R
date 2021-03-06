#' @title Obtain quantities associated with W
#'
#' @param y an n by N matrix of ensemble members of measured variable 
#' (e.g., temperature increase)
#'
#' @param x a list of m elements under m forcing scenarios, each of which is 
#'        model-output variable (e.g., temperature increase) under 
#'        a specific forcing scenario
#'
#' @return a list of 6 elements 
#'
#' @description This function computes quantities in likelihood function based on
#'  ensembles y and model outputs x. This function is used in parallel 
#' computing of MCMC algorithm.
#'
#' @author Pulong Ma <mpulong@gmail.com>
#'
#' @export
#' 
#' @keywords models
#' 
#' @seealso computeW
#' 
#' @examples 
#' #################### simulate data ########################
#' set.seed(1234)
#' n <- 30 # number of spatial grid cells on the globe
#' N <- 10 # number of ensemble members
#' m <- 3 # number of forcing scenarios
#' Lj <- c(5, 3, 7) # number of runs for each scenario
#' L0 <- 8 # number of control runs without any external forcing scenario
#' trend <- 30
#' DAdata <- simDAdata(n, N, m, Lj, L0, trend)
#' # ensembles of the measured variable
#' y <- DAdata[[1]]
#' # model outputs for the measured variable under different forcing scenarios
#' x <- DAdata[[2]]
#' # model outputs for the measured variable without any external forcing scenario
#' x0 <- DAdata[[3]]
#' #################### end of simulation ####################
#' 
#' # center the data
#' y <- y - mean(y)
#' for(j in 1:m){
#'   x[[j]] <- x[[j]]-mean(x[[j]])
#' }
#' 
#' # precomputation for W
#' \dontrun{
#' outW <- parcomputeW(y,x)
#' }


parcomputeW <- function(y,x){

m <- length(x)

w <- apply(y, 1, var)

avg <- function(x) {return(apply(x, 1, mean))}
xbar <- sapply(x, avg)

ybar <- apply(y, 1, mean)
#Wti <- diag(w^(-1))
Wti <- Matrix::sparseMatrix(i=1:length(w), j=1:length(w), x=w^(-1))
trYpWiY <- sum(y*(Wti%*%y))
XpWiX <- as.matrix(t(xbar)%*%Wti%*%xbar)
XpWiybar <- as.matrix(t(xbar)%*%Wti%*%ybar)

out <- list(w,ybar,xbar,trYpWiY,XpWiX,XpWiybar)
names(out) <- c("w","ybar","xbar","trYpWiY","XpWiX","XpWiybar")

return(out)
}
