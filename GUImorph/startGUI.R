rm(list=ls())

library(GUImorph)
library(devtools)
library(testthat)

require(tcltk)
require(tcltk2)
require(parallel)
require(geomorph)
require(vegan)
require(Rvcg)
require(testthat)
require(Morpho)
require(usethis)
source("R/rtkogl.r")
source("R/3dDigitize.curve.r")
source("R/3dDigitize.digitize.r")
source("R/3dDigitize.geomorph.r")
source("R/3dDigitize.main.r")
source("R/geomorph.support.code.r")
source("R/GUImorph.r")
source("R/3dDigitize.surface.r")
source("R/geomorph.support.code.r")

 # Must be in function form to be called by first_test
StartFunction = function(x) {
    x = 2
    x = GUImorph()
}

#digitize3D <-function() {
    e <- new.env()
    class(e) <- "main"
    ui(e)
    init(e)
#}
#library("roxygen2") 
#library("devtools")
#lines<-readLines("DESCRIPTION")
#lines[4]<-paste("Version: 1.0.2.",format(Sys.time(), "%m.%d.%Y.%H.%M"),sep="")
#lines[5]<-paste("Date: ",Sys.Date(),sep="")
#writeLines(lines, "DESCRIPTION")
#document("GUImorph")