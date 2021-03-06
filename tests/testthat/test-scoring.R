library(GSEABase)

context("test-scoring")

test_that("checkGenes works", {
  gs1 = GeneSet(as.character(1:3))
  gs2 = GeneSet(as.character(9:11))
  gs3 = GeneSet(as.character(101:103))
  bg = as.character(1:10)

  expect_equal(geneIds(checkGenes(gs1, bg)), geneIds(gs1))
  expect_equal(geneIds(checkGenes(gs2, bg)), c('9', '10'))
  expect_equal(length(geneIds(checkGenes(gs3, bg))), 0)
})

test_that("calcBounds works", {
  known_bounds = calcBounds(300, 1000)
  unknown_bounds = calcBoundsUnknownDir(300, 1000)
  expect_lte(mean(701:1000), known_bounds$upBound)
  expect_gte(known_bounds$lowBound, mean(1:300))
  expect_lte(mean(abs(c(1:150, 851:1000) - median(1:1000))), unknown_bounds$upBound)
  expect_gte(unknown_bounds$lowBound, mean(abs(351:650 - median(1:1000))))
})

test_that("score calculation works well with vector ids", {
  df <- as.data.frame(c(1,2,5,5))
  colnames(df) <- 'test'
  dfrMin <- rankGenes(df, tiesMethod = 'min')
  rownames(dfrMin) <- c(1,2,3,4)
  scoredfUp <- simpleScore(dfrMin, upSet = c(3,4), centerScore = TRUE)
  scoredfBoth <- simpleScore(dfrMin, upSet = c(3,4), downSet = c(1))

  expect_that(dim(scoredfUp), equals(c(1,2)))
  expect_that(scoredfUp, is_equivalent_to(data.frame(0.25, 0)))
  expect_that(dim(scoredfBoth), equals(c(1,6)))
  expect_that(scoredfBoth,
              is_equivalent_to(data.frame(0.75, 0, 0.25, 0, 0.5,0)))
})

#check for all combinations of objects needed
test_that("score calculation works well with GeneSet S4 object", {
  df <- as.data.frame(c(1,2,5,5))
  colnames(df) <- 'test'
  dfrMin <- rankGenes(df, tiesMethod = 'min')
  rownames(dfrMin) <- c(1,2,3,4)
  scoredfUp <- simpleScore(dfrMin,
                           upSet = GSEABase::GeneSet(as.character(c(3,4))),
                           centerScore = FALSE)
  scoredfBoth <- simpleScore(dfrMin,
                             upSet = GSEABase::GeneSet(as.character(c(3,4))),
                             downSet = GSEABase::GeneSet(as.character(c(1))),
                             centerScore = TRUE)
  expect_that(dim(scoredfUp), equals(c(1,2)))
  expect_that(scoredfUp, is_equivalent_to(data.frame(0.75, 0)))
  expect_that(dim(scoredfBoth), equals(c(1,6)))
  expect_that(scoredfBoth,
              is_equivalent_to(data.frame(0.75, 0, 0.25, 0, 0.5,0)))
})

test_that("score calculation works well when direction is unknown", {
  df <- as.data.frame(c(1,2,5,5))
  colnames(df) <- 'test'
  dfrMin <- rankGenes(df, tiesMethod = 'min')
  rownames(dfrMin) <- c(1,2,3,4)
  scoredfUp <- simpleScore(dfrMin,
                           upSet = GSEABase::GeneSet(as.character(c(3,4))),
                           centerScore = TRUE, knownDirection = FALSE)

  expect_that(dim(scoredfUp), equals(c(1,2)))
  expect_that(scoredfUp, is_equivalent_to(data.frame(-1, 0)))

})

test_that("input checkings for simpleScore works", {
  df <- as.data.frame(c(1,2,5,5))
  colnames(df) <- 'test'
  dfrMin <- rankGenes(df, tiesMethod = 'min')
  rownames(dfrMin) <- c(1,2,3,4)

  expect_error(
    simpleScore(
      dfrMin,
      upSet = GSEABase::GeneSet(as.character(c(3, 4))),
      centerScore = TRUE,
      knownDirection = "FAsss"
    )
  )
  expect_error(
    simpleScore(
      dfrMin[, 1],
      upSet = GSEABase::GeneSet(as.character(c(3, 4))),
      centerScore = TRUE
    )
  )
})

test_that('scoring using stable genes', {
  df = as.data.frame(c(1,2,5,5,5))
  rownames(df) = LETTERS[1:5]
  colnames(df) = 'test'
  dfrMin = rankGenes(df, tiesMethod = 'min', stableGenes = c('A', 'C'))
  gsDn = GSEABase::GeneSet(as.character(c('A')))
  GSEABase::setName(gsDn) = 'Dn'
  gsUp = GSEABase::GeneSet(as.character(c('D', 'E')))
  GSEABase::setName(gsUp) = 'Up'
  
  expect_equal(simpleScore(dfrMin, gsUp)$TotalScore, 1/6)
  expect_equal(simpleScore(dfrMin, gsDn)$TotalScore, -1/6)
  expect_equal(simpleScore(dfrMin, gsUp, gsDn)$TotalScore, 1/3)
  expect_equal(simpleScore(dfrMin, gsUp, gsDn, knownDirection = FALSE)$TotalScore, 2/3)
})
