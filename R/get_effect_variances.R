get_effect_variances <- 
function(data, 
         model = model, 
         which = all.vars(model[["terms"]])[-1], # which mes do we need variances of
         type = c("response", "link", "terms"),
         vcov = stats::vcov(model),
         vce = c("delta", "simulation", "bootstrap", "none"),
         iterations = 50L, # if vce == "bootstrap" or "simulation"
         eps = 1e-7,
         ...) {
    
    # march.arg() for arguments
    type <- match.arg(type)
    vce <- match.arg(vce)
    if (is.function(vcov)) {
        vcov <- vcov(model)
    }
    
    if (vce == "none") {
        
        return(NULL)
        
    } else if (vce == "delta") {
        
        # default method
        variances <- delta_once(data = data, model = model, type = type, vcov = vcov, eps = eps, ...)
        
    } else if (vce == "simulation") {
        
        # copy model for quick use in estimation
        tmpmodel <- model
        tmpmodel[["model"]] <- NULL # remove data from model for memory
        
        # simulate from multivariate normal
        coefmat <- MASS::mvrnorm(iterations, coef(model), vcov)
        
        # estimate AME from from each simulated coefficient vector
        effectmat <- apply(coefmat, 1, function(coefrow) {
            tmpmodel[["coefficients"]] <- coefrow
            means <- colMeans(marginal_effects(data, model = tmpmodel, type = type, ...), na.rm = TRUE)
            if (!is.matrix(means)) {
                matrix(means, ncol = 1L)
            }
            return(means)
        })
        # calculate the variance of the simulated AMEs
        variances <- apply(effectmat, 1, var, na.rm = TRUE)
        
    } else if (vce == "bootstrap") {
    
        # function to calculate AME for one bootstrap subsample
        bootfun <- function() {
            samp <- sample(seq_len(nrow(data)), nrow(data), TRUE)
            tmpmodel <- model
            tmpmodel[["call"]][["data"]] <- data[samp,]
            tmpmodel <- eval(tmpmodel[["call"]])
            colMeans(marginal_effects(model = tmpmodel, data = data[samp,], type = type, ...), na.rm = TRUE)
        }
        # bootstrap the data and take the variance of bootstrapped AMEs
        variances <- apply(replicate(iterations, bootfun()), 1, var, na.rm = TRUE)
        
    } 
    return(variances)
}
