#if os(Linux)

import XCTest
@testable import JWTKeychainTests

// sourcery:inline:auto:LinuxMain

extension SubmissionsTests {
    static var allTests = [
        ("testAPI", testAPI),
    ]
}

XCTMain([
    testCase(SubmissionsTests.allTests),
])

// sourcery:end
#endif