\name{tgp.trees}
\alias{tgp.trees}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ Plot MAP Treed Gaussian Process Models }
\description{
  Plot the maximum a' posteriori (MAP) tree as a function of
  tree height, and show the log posterior probabilities for 
  comparison.
}
\usage{
tgp.trees(out, which = NULL, main = NULL, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{out}{ \code{"tgp"} class object which is the output of one
  	the model functions with tree support (e.g. \code{\link{btgpllm}})}
  \item{which}{ Index vector of length less than \code{length(out$trees)}
  	describing trees to plot.  Default (\code{NULL}) is to
  	plot all trees, one for each height encountered when sampling
	from the Markov chain of the tree posterior.  This is equivalent to
	\code{which = 1:length(out$trees)}.  For example, the first, third,
	and forth trees would result if \code{which = c(1,3,4)}}
  \item{main}{ Optional character string to add to the main title of the plot}
  \item{\dots}{ Extra arguments to the \code{draw.tree} function from 
  	\pkg{maptree}}
}

%\details{
  %~~ If necessary, more details than the __description__  above ~~
%}

\value{
	The only output of this function is beautiful tree diagrams.
}

\author{Robert B. Gramacy \email{rbgramacy@ams.ucsc.edu}}

\references{
\url{http://people.ucsc.edu/~boobles/tgp.php}
}

\note{ Plotting trees that the \pkg{maptree} library is installed, which
itself requires that the \pkg{combinat} library also be installed.

See Examples sections of the functions in the "See Also" section, above}

\seealso{ \code{\link{bgpllm}}, \code{\link{btlm}}, \code{\link{blm}}, 
	\code{\link{bgp}}, \code{\link{btgpllm}},
	\code{\link{plot.tgp}}, \code{vignette("tgp")}}

\keyword{ hplot }
\keyword{ tree }