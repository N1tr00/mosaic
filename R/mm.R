#' Defunct modeling function
#' 
#' The function has been removed from \pkg{mosaic}.
# #' Construct a model based on groupwise means
# #' 
# #' Calculate groupwise means, presenting the result as a model in the style of \code{lm}.
# #' 
#' @rdname mm
#'
#' @param formula A formula.  The left-hand side specifies the variable over
#' which the mean will be taken.  The right-hand side gives the grouping variables,
#' separated by `&`.
#'
#' @param data A data frame to which the formula variables refer.  If not specified, variables
#' will be taken from the current environment.
#'
#' @param fun The function used to calculate the means.  Default: `mean`.
#'
#' @param drop Logical flag indicating whether to drop unoccupied groups.  Default `TRUE`.
#' NOT YET IMPLEMENTED.
#'
#' @param \dots Additional arguments to be passed to the `fun` doing the calculation.
#'
# #' @return \code{mm} returns an object of class \code{groupwiseModel}.  The functions
# #' \code{fitted.values}, \code{residuals}, \code{coefficients}, and \code{summary}
# #' are useful for extracting various features of the value returned by \code{mm}
# #' 
# #' @details \code{mm} is a sort of training function for \code{lm}, meant to provide a
# #' basis for discussing inference and introducing resampling in a simple, intuitive setting
# #' of groupwise means.  \code{lm} provides a better, more general facility. When using
# #' \code{lm} to recreate the results of \code{mm}, include all the interaction terms,
# #' that is, use \code{*} instead of \code{&}.  See the examples.
# #' 
# #' 
# #' @seealso
# #' \code{\link{lm}},
# #' \code{\link{do}}
#' @export
 
mm <- function(formula, data=parent.frame(), fun=mean, drop=TRUE, ... ) {
  .Defunct(msg = "mm() is no longer supported")
  .Deprecated("gwm")
  return(gwm(formula, data = data, drop = drop, ...))
}
