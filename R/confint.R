#' @export
confint.margins <- 
function(object, parm, level = 0.95, ...) {
    mes <- marginal_effects(object)
    pnames <- colnames(mes)
    if (missing(parm)) {
        parm <- pnames
    } else if (is.numeric(parm))  {
        parm <- pnames[parm]
    } else if (is.numeric(parm)) {
        parm[!grep("^_", parm)] <- paste0("_", parm[!grep("^_", parm)])
    }
    cf <- colMeans(mes, na.rm = TRUE)[parm]
    a <- (1 - level)/2
    a <- c(a, 1 - a)
    fac <- qnorm(a)
    ci <- array(NA, dim = c(length(parm), 2L), dimnames = list(parm, a))
    variances <- attributes(object)[["variances"]]
    ses <- if (is.null(variances)) rep(NA_real_, length(cf)) else sqrt(variances)
    ci[] <- cf + ses %o% fac
    colnames(ci) <- sprintf("%0.2f%%", 100 * a)
    ci
}
