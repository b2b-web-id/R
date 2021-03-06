#  File src/library/base/R/stop.R
#  Part of the R package, https://www.R-project.org
#
#  Copyright (C) 1995-2019 The R Core Team
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  https://www.R-project.org/Licenses/

stop <- function(..., call. = TRUE, domain = NULL)
{
    args <- list(...)
    if (length(args) == 1L && inherits(args[[1L]], "condition")) {
        cond <- args[[1L]]
        if(nargs() > 1L)
            warning("additional arguments ignored in stop()")
        message <- conditionMessage(cond)
        call <- conditionCall(cond)
        .Internal(.signalCondition(cond, message, call))
        .Internal(.dfltStop(message, call))
    } else
        .Internal(stop(call., .makeMessage(..., domain = domain)))
}

stopifnot <- function(..., exprs, local = TRUE)
{
    n <- ...length()
    if(!missing(exprs)) {
	if(n)
	    stop("Must use 'exprs' or unnamed expressions, but not both")
	envir <- if (isTRUE(local)) parent.frame()
		 else if(isFALSE(local)) .GlobalEnv
		 else if (is.environment(local)) local
		 else stop("'local' must be TRUE, FALSE or an environment")
	exprs <- substitute(exprs) # protect from evaluation
	E1 <- if(is.call(exprs)) exprs[[1]]
	cl <- if(is.symbol(E1) &&
		 (E1 == quote(`{`) || E1 == quote(expression))) {
		  exprs[[1]] <- quote(stopifnot) ## --> stopifnot(*, *, ..., *) :
		  exprs
	      }
	      else
		  as.call(c(quote(stopifnot),
			    if(is.null(E1) && is.symbol(exprs) &&
			       is.expression(E1 <- eval(exprs))) # the *name* of an expression
				as.list(E1)
			    else
				as.expression(exprs)
			    )) # or fail ..
        names(cl) <- NULL
	return(eval(cl, envir=envir))
    }
    ## else   use '...' (and not 'exprs') :

    Dparse <- function(call, cutoff = 60L) {
	ch <- deparse(call, width.cutoff = cutoff)
	if(length(ch) > 1L) paste(ch[1L], "....") else ch
    }
    head <- function(x, n = 6L) ## basically utils:::head.default()
	x[seq_len(if(n < 0L) max(length(x) + n, 0L) else min(n, length(x)))]
    abbrev <- function(ae, n = 3L)
	paste(c(head(ae, n), if(length(ae) > n) "...."), collapse="\n  ")
    ##
    for (i in seq_len(n)) {
	r <- ...elt(i)
	tmp <- if(FALSE) eval(quote(1)) # trick to have ...elt(i) errors *not* show call
	if (!(is.logical(r) && !anyNA(r) && all(r))) {
	    cl.i <- match.call()[[i+1L]]
	    msg <- ## special case for decently written 'all.equal(*)':
		if(is.call(cl.i) && identical(cl.i[[1]], quote(all.equal)) &&
		   (is.null(ni <- names(cl.i)) || length(cl.i) == 3L ||
		    length(cl.i <- cl.i[!nzchar(ni)]) == 3L))

		    sprintf(gettext("%s and %s are not equal:\n  %s"),
			    Dparse(cl.i[[2]]),
			    Dparse(cl.i[[3]]), abbrev(r))
		else
		    sprintf(ngettext(length(r),
				     "%s is not TRUE",
				     "%s are not all TRUE"),
			    Dparse(cl.i))
            stop(simpleError(msg, call = if(p <- sys.parent(1L)) sys.call(p)))
	}
    }
    invisible()
}

warning <- function(..., call. = TRUE, immediate. = FALSE,
                    noBreaks. = FALSE, domain = NULL)
{
    args <- list(...)
    if (length(args) == 1L && inherits(args[[1L]], "condition")) {
        cond <- args[[1L]]
        if(nargs() > 1L)
            cat(gettext("additional arguments ignored in warning()"),
                "\n", sep = "", file = stderr())
        message <- conditionMessage(cond)
        call <- conditionCall(cond)
        withRestarts({
                .Internal(.signalCondition(cond, message, call))
                .Internal(.dfltWarn(message, call))
            }, muffleWarning = function() NULL) #**** allow simpler form??
        invisible(message)
    } else
        .Internal(warning(call., immediate., noBreaks.,
                          .makeMessage(..., domain = domain)))
}

gettext <- function(..., domain = NULL) {
    args <- lapply(list(...), as.character)
    .Internal(gettext(domain, unlist(args)))
}

bindtextdomain <- function(domain, dirname = NULL)
    .Internal(bindtextdomain(domain, dirname))

ngettext <- function(n, msg1, msg2, domain = NULL)
    .Internal(ngettext(n, msg1, msg2, domain))

gettextf <- function(fmt, ..., domain = NULL)
    sprintf(gettext(fmt, domain = domain), ...)
