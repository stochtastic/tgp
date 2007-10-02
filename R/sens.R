#******************************************************************************* 
#
# Bayesian Regression and Adaptive Sampling with Gaussian Process Trees
# Copyright (C) 2005, University of California
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
# Questions? Contact Robert B. Gramacy (rbgramacy@ams.ucsc.edu)
#
#*******************************************************************************

## check.sens:
##
## function to check the sens.p argument provided as input
## to the sens or b* functions, depending on the imput dimension
## d

"check.sens" <-
function(sens.p, d)
{
  ## sanity checks
  if(d==1) stop("You don't need sensitivity analysis for a single variable.")
  if(length(sens.p)!=(4*d+3)) stop("bad sens length.")

  ## nn.lhs is 'nm' in the .cc code.
  nn.lhs <- sens.p[1] 
  nn <-nn.lhs*(d+2)  ## Bobby asks Taddy: why so big?

  ## The XX matrix is of the correct size for within the .cc code.
  ## This may or may not be necessary.
  ## The first 3 rows contain the LHS parameters to begin with.
  XX <- matrix(rep(0,nn*d),nrow=nn, ncol=d)
  XX[1:2,] <- matrix(sens.p[2:(2*d+1)], nrow=2) ## this is rect

  ## check shape for validity, and copy to XX
  shape <- XX[3,] <- sens.p[(2*d+2):(3*d+1)]
  if(length(shape) != d || !all(shape > 0)) { 
    print(shape)
    stop(paste("shape should be a positive ", d, "-vector", sep=""))
  }

  ## check mode for validity, and copy to XX
  mode <- XX[4,] <- sens.p[(3*d+2):(4*d+1)]
  if(length(mode) != d || !all(mode > 0)) {
    print(mode)
    stop(paste("mode should be a positive ", d, "-vector", sep=""))
  }
  
  ## Create the Man Effect Grid
  ngrid=sens.p[4*d+2]
  span=sens.p[4*d+3]
  if((span > 1) || (span < 0)) stop("Bad smoothing span -- must be in (0,1).")
  MainEffectGrid <- matrix(ncol=d, nrow=ngrid)
  for(i in 1:d){ MainEffectGrid[,i] <- seq(XX[1,i], XX[2,i], length=ngrid) }
  
  ## return
  list(nn=nn, nn.lhs=nn.lhs, ngrid=ngrid, span=span, XX=XX,
       MainEffectGrid=MainEffectGrid)
  }


## sens:
##
## code for performaing a sensitivity analysis using the specified
## model and nn.lhs LHS re-sampled predictive grid for each of the T
## rounds under a beta prior specified by shape and mode

"sens" <-
function(X, Z, nn.lhs, model=btgp, ngrid=100, span=0.3, BTE=c(3000,8000,10),
         rect=NULL, shape=NULL, mode=NULL, ...)
{
  ## the format for rect is the same as rect in LHS (ncol=2, nrow=d).
  Xnames <- names(X)
  XZ <- check.matrix(X, Z) 
  X <- data.frame(XZ$X);  names(X) <- Xnames;
  Z <- XZ$Z;

  ## process the rect, shape and mode arguments
  d <- ncol(as.matrix(X))
  if(is.null(rect)) rect <- t(apply(as.matrix(X),2,range))
  else if(nrow(rect) != d || ncol(rect) != 2)
    stop(paste("rect should be a ", d, "x2-vector", sep=""))

  ## check the shape and mode vectors
  if(is.null(shape)) shape <- rep(1,d)
  else if(length(shape) != d || !all(shape > 0)) {
    print(shape)
    stop(paste("shape should be a positive ", d, "-vector", sep=""))
  }
  if(is.null(mode)) mode <- apply(as.matrix(X),2,mean)
  else if(length(mode) != d || !all(mode > 0)) {
    print(mode)
    stop(paste("mode should be a positive ", d, "-vector", sep=""))
  }
  
  ## build the sens parameter
  sens.p <- c(nn.lhs,t(rect),shape,mode,ngrid,span)

  ## run the b* function (model) with the sens parameter, or otherwise
  ## just return the parameter vector and do nothing
  if(!is.null(model)){ return(model(X,Z,sens.p=sens.p,BTE=BTE,...)) }
  else{ return(sens.p) }  
}


## sens.plot:
##
## function for plotting the results of a sensitivity analysis --
## intended to be used instead of plot.tgp.  The type of plot retulting
## depends on whether main effects are to be plotted or not

"sens.plot" <-
function(s, maineff=TRUE, legendloc="topright", ylab="", main="Main Effects",  ...)
{

  ## colors used for each effect (col of X)
  cols = rainbow(s$d)

  ## extract some useful things from the tgp-object 's'
  nom <- names(s$X)
  sens <- s$sens
  Zmean <- sens$ZZ.mean
  Zq1 <- sens$ZZ.q1
  Zq2 <- sens$ZZ.q2

  ## if maineff is logical then the S & T stats will get plotted
  if(is.logical(maineff)){

    ## put X on a mean 0 range 1 scale
    X <- mean0.range1(sens$Xgrid)$X

    ## plot the main effects or not?
    if(maineff){
      par(mfrow=c(1,3), ...)
      X <- mean0.range1(sens$Xgrid)$X
      plot(X[,1], Zmean[,1], main=main, ylab=ylab, xlab="scaled input",
           col=cols[1], typ="l", lwd=2, ylim=range(as.vector(Zmean)), ...)
      for(i in 2:s$d) lines(X[,i], Zmean[,i], lwd=2, col=cols[i])
      legend(x=legendloc, legend = names(s$X), col=cols, fill=cols)
    }
    else{ par(mfrow=c(1,2), ...) }

    ## plot the S and T statistics
    boxplot(data.frame(sens$S), names=names(s$X),
            main="1st order Sensitivity Indices", xlab="input variables", ylab="", ...)
    boxplot(data.frame(sens$T), names=names(s$X),
            main="Total Effect Sensitivity Indices", xlab="input variables", ylab="", ...)
    
  } else {
    ## only make a main effects plots
    
    X <- sens$Xgrid
    ME <- c(maineff)
    pdim <- dim(as.matrix(maineff))
    par(mfrow=pdim, ...)
    for(i in ME){
      plot(X[,i], Zmean[,i], main=main, ylab=ylab, xlab=nom[i],
           col=cols[i], typ="l", lwd=2, ylim=c(min(Zq1[,i]), max(Zq2[,i])), ...)
      lines(X[,i], Zq1[,i], col=cols[i], lty=2)
      lines(X[,i], Zq2[,i], col=cols[i], lty=2)
    }
  }  
}