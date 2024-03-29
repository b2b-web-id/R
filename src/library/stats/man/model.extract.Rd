% File src/library/stats/man/model.extract.Rd
% Part of the R package, https://www.R-project.org
% Copyright 1995-2021 R Core Team
% Distributed under GPL 2 or later

\name{model.extract}
\title{Extract Components from a Model Frame}
\usage{
model.extract(frame, component)
model.offset(x)
model.response(data, type = "any")
model.weights(x)
}
\alias{model.extract}
\alias{model.offset}
\alias{model.response}
\alias{model.weights}
\arguments{
 \item{frame, x, data}{A model frame.}
 \item{component}{literal character string or name. The name of a
   component to extract, such as \code{"weights"}, \code{"subset"}.}
 \item{type}{One of \code{"any"}, \code{"numeric"}, \code{"double"}.
   Using either of latter two coerces the result to have storage mode
   \code{"double"}.}
}
\description{Returns the response, offset, subset, weights or other
  special components of a model frame passed as optional arguments to
  \code{\link{model.frame}}.
}
\details{
  \code{model.extract} is provided for compatibility with S, which does
  not have the more specific functions.  It is also useful to extract
  e.g.\sspace{}the \code{etastart} and \code{mustart} components of a
  \code{\link{glm}} fit.

  \code{model.extract(m, "offset")} and \code{model.extract(m, "response")}
  are equivalent to \code{model.offset(m)} and \code{model.response(m)}
  respectively.  \code{model.offset} sums any terms specified by
  \code{\link{offset}} terms in the formula or by \code{offset} arguments
  in the call producing the model frame: it does check that the offset
  is numeric.

  \code{model.weights} is slightly different from
  \code{model.extract(, "weights")} in not naming the vector it returns.
}
\value{The specified component of the model frame, usually a vector.
  \code{model.response()} now \emph{drops} a possible \code{"Asis"} class
  (stemming from \code{\link{I}(.)}).
}

\seealso{\code{\link{model.frame}}, \code{\link{offset}}}

\examples{
a <- model.frame(cbind(ncases,ncontrols) ~ agegp + tobgp + alcgp, data = esoph)
model.extract(a, "response")
stopifnot(model.extract(a, "response") == model.response(a))

a <- model.frame(ncases/(ncases+ncontrols) ~ agegp + tobgp + alcgp,
                 data = esoph, weights = ncases+ncontrols)
model.response(a)
(mw <- model.extract(a, "weights"))
stopifnot(identical(unname(mw), model.weights(a)))

a <- model.frame(cbind(ncases,ncontrols) ~ agegp,
                 something = tobgp, data = esoph)
names(a)
stopifnot(model.extract(a, "something") == esoph$tobgp)
}
\keyword{manip}
\keyword{programming}
\keyword{models}
