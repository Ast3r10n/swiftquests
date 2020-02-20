import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(RequestTests.allTests),
    testCase(RequestConfigurationTests.allTests)
  ]
}
#endif
