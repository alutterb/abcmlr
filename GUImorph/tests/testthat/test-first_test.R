test_that("multiplication works", {
    list.files(getwd())
    StartFunction(5)
    
    expect_equal(2 * 2, 4)
    #result <- StartFunction(1)
})