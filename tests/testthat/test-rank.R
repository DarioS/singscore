context('test generic rankGenes with different signatures')

test_that(("Test matrix input"), {
  #create data
  matrixData <- matrix(c(1,2,5,5))
  matrixMin <- rankGenes(matrixData, tiesMethod = 'min')
  matrixDefa <- rankGenes(matrixData)
  matrixMax <- rankGenes(matrixData, tiesMethod = 'max')
  
  expect_that(matrixMin, is_equivalent_to(as.matrix(c(1,2,3,3))))
  expect_that(matrixDefa, is_equivalent_to(as.matrix(c(1,2,3,3))))
  expect_that(matrixMax, is_equivalent_to(as.matrix(c(1,2,4,4))))
})

test_that("Test data.frame input for rankGenes",{
  #Test data.frame input
  df <- as.data.frame(c(1,2,5,5))
  dfmin <- as.matrix(c(1,2,3,3))
  dfmax <- as.matrix(c(1,2,4,4))
  colnames(df) <- colnames(dfmin) <- colnames(dfmax) <- 'test'
  
  dfrMin <- rankGenes(df, tiesMethod = 'min')
  dfrDefa <- rankGenes(df)
  dfrMax <- rankGenes(df, tiesMethod = 'max')
  
  expect_that(dfrMin, is_equivalent_to(dfmin))
  expect_that(dfrDefa, is_equivalent_to(dfmin))
  expect_that(dfrMax, is_equivalent_to(dfmax))
})

test_that("test expressSet input for rankGenes", {
  matrixData <- as.matrix(c(1,2,5,5))
  matrixMin <- rankGenes(matrixData, tiesMethod = 'min')
  matrixDefa <- rankGenes(matrixData)
  matrixMax <- rankGenes(matrixData, tiesMethod = 'max')
  #Test S4 class 
  e <- Biobase::ExpressionSet(assayData = as.matrix(c(1,2,5,5)))
  expect_that(rankGenes(e, 'min'), is_equivalent_to(matrixMin)) 
  expect_that(rankGenes(e), is_equivalent_to(matrixDefa)) 
  expect_that(rankGenes(e, 'max'), is_equivalent_to(matrixMax)) 
})

test_that("DGEList input for rankGenes", {
  y <- matrix(c(5,3,2,2),ncol=2)
  dge <-  edgeR::DGEList(counts = y)
  dgeMin <- matrix(c(2,1,1,1), ncol = 2)
  dgeMax <- matrix(c(2,1,2,2), ncol = 2)
  
  expect_that(rankGenes(dge, 'min'), is_equivalent_to(dgeMin))
  expect_that(rankGenes(dge), is_equivalent_to(dgeMin))
  expect_that(rankGenes(dge, 'max'), is_equivalent_to(dgeMax))
})
test_that("SummarizedExperiment input for rankGenes", {
  y <- matrix(c(5,3,2,2),ncol=2)
  dge <-  SummarizedExperiment::SummarizedExperiment(assays=list(counts=y))
  dgeMin <- matrix(c(2,1,1,1), ncol = 2)
  dgeMax <- matrix(c(2,1,2,2), ncol = 2)
  
  expect_that(rankGenes(dge, 'min'), is_equivalent_to(dgeMin))
  expect_that(rankGenes(dge), is_equivalent_to(dgeMin))
  expect_that(rankGenes(dge, 'max'), is_equivalent_to(dgeMax))
})

test_that("Stable genes based ranking", {
  matrixData = matrix(c(1,2,5,5))
  rownames(matrixData) = LETTERS[1:4]
  
  expect_equal(as.vector(rankGenes(matrixData, stableGenes = c('A', 'C'))), c(1, 2, 2, 2) / 3)
  expect_equal(as.vector(rankGenes(
    data.frame(matrixData), stableGenes = c('A', 'C')
  )), c(1, 2, 2, 2) / 3)
  expect_equal(as.vector(rankGenes(
    edgeR::DGEList(matrixData), stableGenes = c('A', 'C')
  )), c(1, 2, 2, 2) / 3)
  expect_equal(as.vector(rankGenes(
    Biobase::ExpressionSet(matrixData), stableGenes = c('A', 'C')
  )), c(1, 2, 2, 2) / 3)
  expect_equal(as.vector(
    rankGenes(
      SummarizedExperiment::SummarizedExperiment(assays = list(matrixData)),
      stableGenes = c('A', 'C')
    )
  ), c(1, 2, 2, 2) / 3)
})

test_that(" input checkings work for rankGenes", {
  y <- matrix(c(5,3,2,2),ncol=2)
  dge <-  edgeR::DGEList(counts = y)
  dgeMin <- matrix(c(2,1,1,1), ncol = 2)
  dgeMax <- matrix(c(2,1,2,2), ncol = 2)
  
  expect_error(rankGenes(dge, 'kkk'))
})
