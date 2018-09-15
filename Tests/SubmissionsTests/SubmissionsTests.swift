import Submissions
import Vapor
import XCTest

final class SubmissionsTests: XCTestCase {
    func testRenderInputTagWithEmptyFieldCache() throws {
        let (path, tagContextData) = try renderInputTag(templatePath: "path")

        XCTAssertEqual(path, "path")
        XCTAssertEqual(tagContextData, TagContextData())
    }

    func testRenderInputTagWithPlaceholderAndHelpText() throws {
        let (_, tagContextData) = try renderInputTag(
            placeholder: "placeholder",
            helpText: "help text"
        )

        XCTAssertEqual(tagContextData, TagContextData(
            placeholder: "placeholder",
            helpText: "help text"
        ))
    }

    func testRenderFieldsInFormFromType() throws {
        let (_, tagContextData) = try renderInputTag(key: "name") { req in
            try User.populateFieldCache(on: req)
        }

        XCTAssertEqual(
            tagContextData,
            TagContextData(key: "name", label: "Name")
        )
    }

    func testRenderFieldsInFormFromInstance() throws {
        let (_, tagContextData) = try renderInputTag(key: "name") { req in
            try User(name: "Martin").populateFieldCache(on: req)
        }

        XCTAssertEqual(
            tagContextData,
            TagContextData(key: "name", value: "Martin", label: "Name")
        )
    }

    func testValidationError() throws {
        let (_, tagContextData) = try renderInputTag(key: "name") { req in
            try User(name: "M").populateFieldCache(on: req)
        }

        XCTAssertEqual(
            tagContextData,
            TagContextData(
                key: "name",
                value: "M",
                label: "Name",
                errors: ["data is not larger than 2"],
                hasErrors: true
            )
        )
    }

    func testMissingValue() throws {
        let (_, tagContextData) = try renderInputTag(key: "requiredButOptional") { req in
            try User().populateFieldCache(on: req)
        }

        XCTAssertEqual(
            tagContextData,
            TagContextData(
                key: "requiredButOptional",
                isRequired: true,
                errors: ["data is absent"],
                hasErrors: true
            )
        )
    }

    func testMissingValueDefinedAsEmptyString() throws {
        let (_, tagContextData) = try renderInputTag(key: "emptyStringMeansAbsent") { req in
            try User().populateFieldCache(on: req)
        }

        XCTAssertEqual(
            tagContextData,
            TagContextData(
                key: "emptyStringMeansAbsent",
                value: "",
                isRequired: true,
                errors: ["data is absent"],
                hasErrors: true
            )
        )
    }

    func testUniqueValueBySimulatingCallToDatabase() throws {
        let (_, tagContextData) = try renderInputTag(key: "unique") { req in
            try User().populateFieldCache(on: req)
        }

        XCTAssertEqual(
            tagContextData,
            TagContextData(
                key: "unique",
                value: "unique",
                errors: ["data must be unique"],
                hasErrors: true
            )
        )
    }

    func testValidationFromAPI() {

    }

    func testSuccessfulValidationAPIResponse() {

    }

    func testFailedValidationAPIResponse() {

    }
}
