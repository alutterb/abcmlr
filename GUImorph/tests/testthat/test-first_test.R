library(GUImorph)
library(devtools)
library(testthat)

install.packages("tcltk")
install.packages("tcltk2")
install.packages("parallel")
install.packages("gemorph")
install.packages("GUImorph")
install.packages("codetools")
install.packages("vegan")
install.packages("Rvcg")
install.packages("testthat")
install.packages("Morpho")
install.packages("usethis")

test_that("multiplication works", {
    source("startGUI.R")
    
    expect_equal(2 * 2, 4)
    #result <- StartFunction(1)
})
