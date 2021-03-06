% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/inspect.R
\name{inspect}
\alias{inspect}
\alias{inspect.list}
\alias{inspect.character}
\alias{inspect.logical}
\alias{inspect.numeric}
\alias{inspect.factor}
\alias{inspect.POSIXt}
\alias{inspect.data.frame}
\alias{print.inspected_data_frame}
\title{Inspect objects}
\usage{
inspect(object, ...)

\method{inspect}{list}(object, max.level = 2, ...)

\method{inspect}{character}(object, ...)

\method{inspect}{logical}(object, ...)

\method{inspect}{numeric}(object, ...)

\method{inspect}{factor}(object, ...)

\method{inspect}{POSIXt}(object, ...)

\method{inspect}{data.frame}(object, select = TRUE,
  digits = getOption("digits", 3), ...)

\method{print}{inspected_data_frame}(x, digits = NULL, ...)
}
\arguments{
\item{object}{a data frame or a vector}

\item{...}{additional arguments passed along to specific methods}

\item{max.level}{an integer giving the depth to which lists should be expanded}

\item{select}{a logical, character (naming variables), or numeric vector or a
function used to select variables to which \code{FUN} is applied.  If a function,
it should take a vector as input and return a single logical. See examples here and
at \code{link{dfapply}}.}

\item{digits}{and integer giving the number of digits to display}

\item{x}{an object}
}
\description{
Print a short summary of the contents of an object.  Most useful as a way to
get a quick overview of the variables in data frame.
}
\examples{
inspect(Births78)
inspect(Births78, is.numeric)
}
