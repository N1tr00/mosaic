### Check .Rbuildignore to see if this is being ignored.

utils::globalVariables("model_value")
#' Groupwise Models (Defunct)
#'
#' This has been removed from the package.  Watch for improved modeling functions in
#' the `mosaicModel` package.
#'
#' @rdname gwm
#'
#' @param formula A formula.  The left-hand side specifies the response variable
#' over which the mean or proportion will be taken.  The right-hand side gives
#' the explanatory variables, separated by `+`.  Means or proportions are
#' computed for every combination of the levels of the explanatory variables.
#'
#' @param data A data frame in which to evaluate variables in `formula`.
#' If not specified, variables
#' will be taken from the current environment.
#'
#' @param drop Logical flag indicating whether to drop unoccupied groups.
#' Default `FALSE`.  NOT YET IMPLEMENTED.
#'
#' @param \dots Additional arguments; currently ignored.
#'
#' @return `mm` returns an object of class `groupwiseModel`.  The functions
#' `fitted.values`, `residuals`, `coefficients`, and `summary`
#' are useful for extracting various features of the value returned by `mm`
#'
#' @details
#' `gwm` (groupwise model) is a sort of training function for
#' `lm`, meant to provide a basis for discussing inference and introducing
#' resampling in a simple, intuitive setting
#' of groupwise means or proportions.  `lm` provides a better, more general facility.
#' When using `lm` to recreate the results of `gwm`, include all the
#' interaction terms (i.e., use `*` instead of `+`) and remove the
#' intercept term.  See the examples.
#'
#' @seealso
#' [lm()],
#' [do()]
#' @export
# @examples
#
# gwm( wage ~ sex, data=CPS85 )
# gwm( wage ~ sex + married, data = CPS85 )
# # The same model, fit using lm() instead
# lm( wage ~ sex * married - 1, data = CPS85)
# do(5) * gwm( wage ~ sex + married, data = resample(CPS85))
# mod <- gwm( width ~ domhand, data=KidsFeet)
# summary(mod)
# resid(mod)
# fitted(mod)

#' @export
gwm <- function(formula, data = parent.frame(), drop = FALSE, ...) {
  .Defunct(msg = "gwm() has been removed from `mosaic'.  \n    It will be replaced by better tools in `mosaicModel'.")
  # if response categorical, a proportion, listing the response
  # if response quantitative, a mean but don't list the response
  orig.call <- match.call()
  response_var <- formula[[2]]
  response <- eval(response_var, envir=data)
  ResponseData <- data.frame(x = response, stringsAsFactors = FALSE) 
  names(ResponseData) <- as.character(response_var)
  group_vars <- all.vars(formula[[3]])
  if (is.numeric(response)) {
    grouping <- if (length(group_vars) <= 0 ) {
      group_vars <- c()
    }
    Res <- 
      data %>%
      group_by_(.dots = group_vars) %>%
      summarise(model_value = base::mean(response_var, na.rm=TRUE)) %>%
      ungroup()
    observed <- data[[as.character(response_var)]]
    
  } else {
    tmp <- tally(formula, data = data, format = "proportion")
    # keep the coefficients table with all categorical vars as character strings
    Res <- expand.grid(dimnames(tmp), stringsAsFactors = FALSE)
    Res$model_value <- c(tmp[])
#    Res <- data.frame(tally(formula, data=data, format="proportion"),
#                      stringsAsFactors = FALSE)
#    names(Res)[ncol(Res)] <- "model_value" 
    if (length(all.vars(formula[[3]])) == 0) {
      # the constant model
      # get rid of any pseudo variables added by tally
      keepers <- names(Res) %in% c(names(data), "model_value")
      Res <- Res[,keepers]
    }
    observed <- rep(1, nrow(data))
  }
  
  # Compute fitted, and residuals
  if (length(group_vars) > 0L) {
    fitted.values <- suppressMessages(suppressWarnings(left_join(data, Res))$model_value)
  } else {
    fitted.values <- rep(Res$model_value, nrow(data))
  }
 
  residuals <- observed - fitted.values
  
  structure(
    list(coefficients = Res, 
         residuals = residuals,
         fitted.values = fitted.values,
         response = observed,
         terms = formula, # a kluge for makeVars()
         data = data,
         call = orig.call,
         type = ifelse(is.numeric(response), "mean", "probability")
    ),
    class = "groupwiseModel"
  )
}

# # @export
# print.groupwiseModel <-
#   function (x, ..., digits = max(3, getOption("digits") - 3)) 
# {
#   cat("\nGroupwise Model Call:\n", paste(deparse(x$call), sep = "\n", 
#                                          collapse = "\n"), "\n\n", sep = "")
#   print(format(x$coefficients, digits = digits))
#   cat("\n")
#   invisible(x)
#   }
# 
# residuals.groupwiseModel <- function(object, ...) {
#   object$residuals
# }
# fitted.groupwiseModel <- function(object, ...) {
#   object$fitted
# }

# summary() doesn't do anything exciting at the moment.  This is just a placeholder
# for future functionality.

# # @export
# summary.groupwiseModel <- function( object, ...) {
#   structure(
#     list(model = object),
#     class = "summary.groupwiseModel"
#   )
# }
# 

# # @export
# print.summary.groupwiseModel <- function( x, ...) {
#   print(x$model)
# }

# #' Evaluate a groupwise model given new data
# #' 
# #' If \code{newdata} is not specified, the data originally used for fitting will be used.

# #' @param object a groupwise model
# #' @param type one of "class", "likelihood", or "prob"
# #' @param level an optional character string specifying the level for which probabilities are to be reported. Defaults
# #' to the first class of the potential outputs. Set to \code{".all"} to see probabilities for all levels.
# #' @param newdata new data from which to compute fitted valeus.
# #' @param ... additional arguments (currently ignored)
# #' 
# #' @details setting the \code{type} is needed only for classifiers. \code{"class"} will give just the 
# #' class as output. \code{"likelihood"} will give the probability of the observed outcome (in \code{newdata}) 
# #' given the model. \code{"prob"} will give the probability of the class named in \code{level}
# #' 
# #' @export
# predict.groupwiseModel <- 
#   function( object, newdata = object$data, 
#             type = c("class", "likelihood", "prob"), level = NULL, ... ) {
#   type <- match.arg(type)
#   vnames <- names(coef(object))
#   response_name <- vnames[1]
#   explan_var_names <- vnames[c(-1, -length(vnames))]
#   
#   if (ncol(object$coefficients) >= 2L) {
#     if (object$type == "probability") {
#       if ( ! is.null(level)) type = "prob"
#       if (type == "prob") {
#         Wide <- tidyr::spread_(coef(object), key = response_name, value = "model_value", fill = 0)
#         fitted_values <- suppressWarnings(left_join(newdata, Wide))[,-(1:ncol(newdata))]
#         if (type == "prob" && is.null(level)) level <- names(fitted_values)[1]

#         if ( ! level %in% c(".all", names(Wide))) 
#           stop("level '", level, "' is not one of the output categories.")
#         if (level != ".all") fitted_values <- fitted_values[[level]]
#       } else if (type == "likelihood") { 
#         likelihood <- suppressWarnings(left_join(newdata, coef(object)))$model_value
#         return(likelihood)
#       } else { # the most likely in each group
#         tmp <- group_by_(coef(object), .dots = explan_var_names) %>% 
#           filter(rank(desc(model_value), ties.method = "first") == 1) 
#         fitted_values <- suppressWarnings(
#           left_join(newdata[,names(newdata) != response_name, drop=FALSE], tmp))
#         if( type == "class")
#           fitted_values <- fitted_values[[response_name]]
#       }
#     } else {
#       fitted_values <- 
#         suppressWarnings(left_join(newdata, coef(object)))$model_value
#     }
#   } else {  # only happens for null model with quant. reponse
#     fitted_values <- rep(object$coefficients$model_value, nrow(newdata))
#   } 
#   
#   fitted_values # return
# }

#' Mean Squared Prediction Error
#' 
#' A one-step calculation of mean square prediction error
#' 
#' @param model a model produced by `lm`, `glm`, or `gwm`.
#' @param data a data frame. 
#' @param LL if `TRUE`, for categorical responses replace mean square error 
#' with minus mean log likelihood
#' @details
#' For categorical responses, the mean square prediction error is not ideal.  Better
#' to use the likelhood.  `LL = TRUE` (the default) turns the calculation into the mean log likelihood
#' per case, negated so that large values mean poor predictions


# #' @export
# #' @examples
# #' HELP <- HELPrct %>% sample_frac(.3)
# #' MSPE( gwm( age ~ sex, data = HELP), HELPrct)
# #' MSPE( gwm( age ~ 1, data = HELP), HELPrct)
# #' MSPE( gwm( age ~ sex + homeless, data = HELP), HELPrct)
# #' MSPE( gwm( sex ~ 1, data = HELP), HELPrct)
# #' MSPE( gwm( sex ~ homeless, data = HELP), HELPrct)
# #' MSPE( gwm( sex ~ homeless + substance, data = HELP), HELPrct)

# MSPE <- function(model, data, LL = TRUE){
#   #  was <- options("warn")
#   #  on.exit(options(warn = was))
#   #options(warn = -3)
#   formula <- model$call[[2]]
#   actual <- eval(formula[[2]], envir = data)
#   if (is.numeric(actual)) {
#     model_vals <- predict(model, newdata = data)
#     res <- stats::var(actual - model_vals, na.rm = TRUE)
#   } else {
#     # categorical response
#     if (inherits(model, "groupwiseModel")) {
#       model_vals <- predict(model, newdata = data, type = "likelihood")
#       res <- 
#         if (LL) { 
#           - mean(log(model_vals))
#         } else {
#           res <- stats::var(1 - model_vals, na.rm = TRUE)
#         }
#     } else {
#       stop("For classifiers, only set up for groupwiseModels ")
#     }
#   }
#   res
# }

# #' @export
# cull_for_do.groupwiseModel <- function( object, ... ) {
#   object$coefficients
# }


# #' @rdname makeFun
# #' @examples
# #' if (require(mosaicData)) {
# #'   mod <- gwm(wage ~ sector, data = CPS85)
# #'   modfun <- makeFun(mod)
# #'   modfun(sector = "prof")
# #' }
# #' @export
# makeFun.groupwiseModel <-
#   function( object, ... , transformation = NULL) {
#     if (is.null(transformation))  transformation <- infer_transformation(formula(object))
#     dnames <- names(eval(object$call$data, parent.frame(1)))
#     vars <- modelVars(object)
#     if (! is.null(dnames) ) vars <- intersect(vars, dnames)
#     result <- function(...){}
#     if ( length( vars ) <  1 ) {
#       result <- function(...) {
#         dots <- list(...)
#         if (length(dots) > 0) {
#           x <- dots[[1]]
#         } else {
#           x <- 1
#         }
#         dots <- dots[names(dots) != ""]
#         transformation( do.call(predict, c(list(model, newdata = data_frame(x = x)), dots)) )
#       }
#     } else {
#       body(result) <-
#         parse( text = paste(
#           "return(transformation(predict(model, newdata = data.frame(",
#           paste(vars, "= ", vars, collapse = ",", sep = ""),
#           ", stringsAsFactors = FALSE), ...)))"
#         )
#         )
#       args <- paste("alist(", paste(vars, "=", collapse = ",", sep = ""), ")")
#       args <- eval(parse(text = args))
#       args['pi'] <- NULL
#       args <- c(args, alist('...' = ), list(transformation = substitute(transformation)))
#       formals(result) <- args
#     }
#     
#     # myenv <- parent.frame()
#     # myenv$model <- object
#     # environment(result) <- myenv
#     environment(result) <- list2env( list(model = object, transformation = transformation) )
#     attr(result, "coefficients") <- coef(object)
#     return(result)
#   }
