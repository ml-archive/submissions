import XCTest

extension SubmissionsTests {
    static let __allTests = [
        ("testFailedValidationAPIResponse", testFailedValidationAPIResponse),
        ("testMissingValue", testMissingValue),
        ("testMissingValueDefinedAsEmptyString", testMissingValueDefinedAsEmptyString),
        ("testRenderFieldsInFormFromInstance", testRenderFieldsInFormFromInstance),
        ("testRenderFieldsInFormFromType", testRenderFieldsInFormFromType),
        ("testRenderInputTagWithEmptyFieldCache", testRenderInputTagWithEmptyFieldCache),
        ("testRenderInputTagWithPlaceholderAndHelpText", testRenderInputTagWithPlaceholderAndHelpText),
        ("testSuccessfulValidationAPIResponse", testSuccessfulValidationAPIResponse),
        ("testUniqueValueBySimulatingCallToDatabase", testUniqueValueBySimulatingCallToDatabase),
        ("testValidationError", testValidationError),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SubmissionsTests.__allTests),
    ]
}
#endif
