context("GSEA multilevel analysis")

test_that("fgseaMultilevel works", {
	data(examplePathways)
	data(exampleRanks)
	set.seed(42)
	sampleSize <- 50
	fgseaMultilevelRes <- fgseaMultilevel(examplePathways, exampleRanks, sampleSize=sampleSize,
										  maxSize=500)
	expect_equal(fgseaMultilevelRes[23, ES], 0.5788464)

	expect_true("70385" %in% fgseaMultilevelRes[grep("5991851", pathway), leadingEdge][[1]])
	expect_true(!"68549" %in% fgseaMultilevelRes[grep("5991851", pathway), leadingEdge][[1]])

	expect_true(!"11909" %in% fgseaMultilevelRes[grep("5992314", pathway), leadingEdge][[1]])
    expect_true("69386" %in% fgseaMultilevelRes[grep("5992314", pathway), leadingEdge][[1]])

    # specifying number of threads
    fgseaMultilevelRes <- fgseaMultilevel(examplePathways, exampleRanks, sampleSize=100, maxSize=100, nproc=2)
	})


test_that("fgseaMultilevel is reproducable independent of bpparam settings", {

    data(examplePathways)
    data(exampleRanks)
    sampleSize <- 50

    set.seed(42)
    fr <- fgseaMultilevel(examplePathways[1:2], exampleRanks, sampleSize=sampleSize, maxSize=500, nproc=1)


    set.seed(42)
    fr1 <- fgseaMultilevel(examplePathways[1:2], exampleRanks, sampleSize=sampleSize, maxSize=500)
    expect_equal(fr1$nMoreExtreme, fr$nMoreExtreme)

    set.seed(42)
    fr2 <- fgseaMultilevel(examplePathways[1:2], exampleRanks, sampleSize=sampleSize, maxSize=500, nproc=0)
    expect_equal(fr2$nMoreExtreme, fr$nMoreExtreme)

    set.seed(42)
    fr3 <- fgseaMultilevel(examplePathways[1:2], exampleRanks, sampleSize=sampleSize, maxSize=500, nproc=2)
    expect_equal(fr3$nMoreExtreme, fr$nMoreExtreme)
})


test_that("fgseaMultilevel works with zero pathways", {
    data(examplePathways)
    data(exampleRanks)
    set.seed(42)
    sampleSize <- 50
    fgseaMultilevelRes <- fgseaMultilevel(examplePathways, exampleRanks, sampleSize=sampleSize,
                      minSize=50, maxSize=10)
    expect_equal(nrow(fgseaMultilevelRes), 0)
    fgseaMultilevelRes1 <- fgseaMultilevel(examplePathways[1], exampleRanks, sampleSize=sampleSize)
    expect_equal(colnames(fgseaMultilevelRes), colnames(fgseaMultilevelRes1))
})


test_that("fgseaMultilevel throws a warning when there are duplicate gene names", {
    data(examplePathways)
    data(exampleRanks)
    exampleRanks.dupNames <- exampleRanks
    names(exampleRanks.dupNames)[41] <- names(exampleRanks.dupNames)[42]

    expect_warning(fgseaMultilevel(examplePathways, exampleRanks.dupNames, sampleSize=100, minSize=10, maxSize=50, nproc=1))

})

test_that("fgseaMultilevel: Ties detection in ranking works", {
    data(examplePathways)
    data(exampleRanks)
    exampleRanks.ties <- exampleRanks
    exampleRanks.ties[41] <- exampleRanks.ties[42]
    exampleRanks.ties.zero <- exampleRanks.ties
    exampleRanks.ties.zero[41] <- exampleRanks.ties.zero[42] <- 0

    expect_silent(fgseaMultilevel(examplePathways, exampleRanks,
                                  minSize=10, maxSize=50, nproc=1))

    expect_warning(fgseaMultilevel(examplePathways, exampleRanks.ties,
                                   minSize=10, maxSize=50, nproc=1))

    expect_silent(fgseaMultilevel(examplePathways, exampleRanks.ties.zero,
                                  minSize=10, maxSize=50, nproc=1))
})

test_that("fgseaMultilevel gives valid P-value for 5990980_Cell_Cycle", {
    data(examplePathways)
    data(exampleRanks)
    ranks <- sort(exampleRanks, decreasing = TRUE)
    example.pathway <- examplePathways["5990980_Cell_Cycle"]

    set.seed(42)
    fgseaMRes <- fgseaMultilevel(example.pathway, ranks)
    pval <- fgseaMRes$pval
    expect_true(1e-29 <= pval && pval <= 1e-25)
})

test_that("The absEps parameter works correctly with 5990980_Cell_Cycle", {
    data(examplePathways)
    data(exampleRanks)
    ranks <- sort(exampleRanks, decreasing = TRUE)
    example.pathway <- examplePathways["5990980_Cell_Cycle"]

    set.seed(42)
    fgseaMRes <- fgseaMultilevel(example.pathway, ranks, absEps = 1e-10)

    pval <- fgseaMRes$pval
    expect_true(pval == 1e-10)
    expect_true(is.na(fgseaMRes$log2err))
})

test_that("The absEps parameter works correctly with 5991504_Extension_of_Telomeres", {
    data(examplePathways)
    data(exampleRanks)
    example.pathway <- examplePathways["5991504_Extension_of_Telomeres"]

    set.seed(42)
    pvals <- replicate(fgseaMultilevel(example.pathway,
                                       exampleRanks, absEps = 1e-5)$pval,
                       n = 20)

    expect_true(all(pvals >= 1e-5))

})


test_that("fgseaMultilevel throws a warning when sampleSize is less than 3", {
    data(exampleRanks)
    data(examplePathways)
    expect_silent(fgseaMultilevel(examplePathways, exampleRanks,
                                  sampleSize = 5))
    expect_warning(fgseaMultilevel(examplePathways, exampleRanks,
                                   sampleSize = 1))
})

test_that("fgseaMultilevelCpp works with sign=TRUE", {
    data(exampleRanks)
    ranks <- sort(exampleRanks, decreasing = TRUE)
    expect_silent(fgsea:::fgseaMultilevelCpp(enrichmentScores = 0.1,
                                             ranks = ranks,
                                             pathwaySize = 100,
                                             sampleSize = 11,
                                             seed = 333,
                                             absEps = 0.0,
                                             sign = TRUE))
})

test_that("The `absEps` parameter works correct in fgseaMultilevelCpp", {
    data(exampleRanks)
    ranks <- sort(exampleRanks, decreasing = TRUE)
    pvalue <- fgsea:::fgseaMultilevelCpp(enrichmentScores = 0.95, ranks = ranks, pathwaySize = 50,
                                         sampleSize = 501, seed = 42, absEps = 1e-5, sign = FALSE)
    pvalue <- pvalue$cppMPval
    expect_true(pvalue >= 1e-10)
})


test_that("fgseaMultilevel throws a warning when P-value of some pathway is overestimated", {
    data(exampleRanks)
    data(examplePathways)
    set.seed(42)

    ranks <- sort(exampleRanks, decreasing = TRUE)
    firstNegative <- which(ranks < 0)[1]
    ranks <- c(abs(ranks[1:(firstNegative - 1)]) ^ 0.1, ranks[firstNegative:length(ranks)])

    pathway <- examplePathways["5991792_Regulation_of_Apoptosis"]
    expect_warning(fgseaMultilevel(pathway, ranks, sampleSize = 51, minSize = 15, maxSize = 500))

})



test_that("fgseaMultilevel throws a warning when there are unbalanced gene-level statistic values", {
    data(exampleRanks)
    data(examplePathways)
    set.seed(42)

    ranks <- sort(exampleRanks, decreasing = TRUE)
    firstNegative <- which(ranks < 0)[1]
    ranks <- c(abs(ranks[1:(firstNegative - 1)]) ^ 0.1, ranks[firstNegative:length(ranks)])

    pathway <- examplePathways["5990976_Assembly_of_the_pre-replicative_complex"]
    expect_warning(fgseaMultilevel(pathway, ranks, minSize = 15, maxSize = 500))
})

