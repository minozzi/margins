# margins #

**margins** is an effort to port Stata's (closed source) [`margins`](http://www.stata.com/help.cgi?margins) command to R as an S3 generic method for calculating the marginal effects (or "partial effects") of covariates included in model objects (like those of classes "lm" and "glm"). A plot method for the new "margins" class additionally ports the `marginsplot` command.

Note: While `margins` also implements fitted values from model estimation results, that functionality is already well-implemented by R's `predict` function, so that wheel is not reinvented here.

Bigger note: This is a work-in-progress. Trust nothing.

## Motivation ##

With the introduction of Stata's `margins` command, it has become incredibly simple to estimate average marginal effects (i.e., "average partial effects"), marginal effects at means (i.e., "partial effects at the average"), and marginal effects at representative cases. Indeed, in just a few lines of Stata code, regression results can be transformed into meaningful quantities of interest and related plots:

```
. import delimited mtcars.csv
. quietly reg mpg c.cyl##c.hp wt
. margins, dydx(*)
------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         cyl |   .0381376   .5998897     0.06   0.950    -1.192735     1.26901
          hp |  -.0463187    .014516    -3.19   0.004     -.076103   -.0165343
          wt |  -3.119815    .661322    -4.72   0.000    -4.476736   -1.762894
------------------------------------------------------------------------------
. marginsplot
```

![marginsplot](http://i.imgur.com/VhoaFGp.png)

R has no comparable functionality in the base tools (though `predict` implements some of the functionality for computing predicted values). Nor do any add-on packages implement appropriate marginal effect estimates. Notably, several packages provide estimates of marginal effects for different types of models. Among these are [car](http://cran.r-project.org/web/packages/car/index.html), [alr3](http://cran.r-project.org/web/packages/alr3/index.html), [mfx](http://cran.r-project.org/web/packages/mfx/index.html), [erer](http://cran.r-project.org/web/packages/erer/index.html), among others. Unfortunately, none of these packages implement marginal effects correctly (i.e., correctly account for interrelated variables such as interaction terms (e.g., `a:b`) or power terms (e.g., `I(a^2)`) and the packages all implement quite different interfaces for different types of models.

Given the importance of models that are non-linear in all statistical analyses and the difficulty of interpreting those models, there is a clear need for a simple, consistent way to estimate marginal effects for popular statistical models.

This package aims to correctly calculate marginal effects that include complex terms and provide a uniform interface for doing those calculations. Thus, the package implements a single S3 generic method (`margins`) that can be easily generalized for any type of model implemented in R. [Pull requests](https://github.com/leeper/margins/pulls) for `margins` methods for any model class that is not currently supported are more than welcome!

## Requirements and Installation ##

[![Build Status](https://travis-ci.org/leeper/margins.png?branch=master)](https://travis-ci.org/leeper/margins)

**margins** will eventually be available on [CRAN](http://cran.r-project.org/web/packages/margins/index.html), so that it can be installed using:

```
install.packages('margins')
```

The development version can be installed directly from GitHub using `devtools`:

```R
if(!require('devtools')) {
    install.packages('devtools')
    library('devtools')
}
install_github('leeper/margins')
```

## Simple code examples ##



Replicating Stata's results is incredibly simple using just `margins` method to obtain average marginal effects:


```r
x <- lm(mpg ~ cyl * hp + wt, data = mtcars)
(m <- margins(x)[[1]])
```

```
##  Factor       dy/dx   Std.Err.     z value     Pr(>|z|)       2.50%      97.50%
##     cyl  0.03813734 0.59988963  0.06357394 9.493095e-01 -1.13762472  1.21389941
##      hp -0.04631867 0.01451598 -3.19087366 1.418433e-03 -0.07476948 -0.01786787
##      wt -3.11981472 0.66132188 -4.71754349 2.387094e-06 -4.41598178 -1.82364766
```

With the exception of differences in rounding, the above results match identically what Stata's `margins` command produces. Using the `plot.margins` method also yields an aesthetically similar result to Stata's `marginsplot`:

```R
plot(m)
```

![margins plot](http://i.imgur.com/2oC5UGO.png)

The numerous package vignettes and help files contain extensive documentation and examples of all package functionality.
