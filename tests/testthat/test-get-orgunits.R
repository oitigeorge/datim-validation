context("Get a list of organisation units")

with_mock_api({
  test_that("We can get an orgunit map", {
    config <- LoadConfigFile(test_config("test-config.json"))
    options("maxCacheAge"=NULL)
    test_ous<-getOrganisationUnitMap()
    expect_type(test_ous,"list")
    ou_map_names<-c("name","id","code","shortName")
    expect_setequal(names(test_ous),ou_map_names)
  })
})


with_mock_api({
  test_that("We can inform whether a UID is an orgunit", {
    config <- LoadConfigFile(test_config("test-config.json"))
    options("maxCacheAge"=NULL)
    expect_true(checkOperatingUnit("KKFzPM8LoXs"))
    expect_false(checkOperatingUnit("ABCDEFG123"))
    expect_true(checkOperatingUnit("KKFzPM8LoXs"))

  })
})