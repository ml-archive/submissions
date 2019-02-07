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
            try req.addFields(forType: User.self)
        }

        XCTAssertEqual(
            tagContextData,
            TagContextData(key: "name", label: "Name")
        )
    }

    func testRenderFieldsInFormFromInstance() throws {
        let (_, tagContextData) = try renderInputTag(key: "name") { req in
            try req.addFields(for: User(name: "Kirstine"))
        }

        XCTAssertEqual(
            tagContextData,
            TagContextData(key: "name", value: "Kirstine", label: "Name")
        )
    }

    func testValidationError() throws {
        let (_, tagContextData) = try renderInputTag(key: "name") { req in
            try req.addFields(for: User(name: "M")).validate(inContext: .create, on: req)
        }

        XCTAssertEqual(
            tagContextData,
            TagContextData(
                key: "name",
                value: "M",
                label: "Name",
                errors: ["data is less than required minimum of 2 characters"],
                hasErrors: true
            )
        )
    }

    func testMissingValue() throws {
        let (_, tagContextData) = try renderInputTag(key: "requiredButOptional") { req in
            try req.addFields(forType: User.self).validate(inContext: .create, on: req)
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
            try req.addFields(for: User()).validate(inContext: .create, on: req)
        }

        XCTAssertEqual(
            tagContextData,
            TagContextData(
                key: "emptyStringMeansAbsent",
                value: nil,
                isRequired: true,
                errors: ["data is absent"],
                hasErrors: true
            )
        )
    }

    func testUniqueValueBySimulatingCallToDatabase() throws {
        let (_, tagContextData) = try renderInputTag(key: "unique") { req in
            try req.addFields(for: User()).validate(inContext: .create, on: req)
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

    func testFailedValidationAPIResponse() throws {
        let req = try Request.test()
        let user = User(name: "Valid")

        let response = try req
            .addFields(for: user)
            .validate(inContext: .create, on: req)
            .assertValid(on: req)
            .transform(to: user)
            .promoteErrors(ofType: SubmissionValidationError.self)
            .encode(for: req)
            .wait()

        XCTAssertEqual(response.http.status, .unprocessableEntity)
        guard let data = response.http.body.data else {
            XCTFail("No data in response body")
            return
        }
        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
        XCTAssertEqual(
            errorResponse,
            ErrorResponse(
                error: true,
                reason: "One or more fields failed to pass validation.",
                validationErrors: [
                    "requiredButOptional": ["data is absent"],
                    "emptyStringMeansAbsent": ["data is absent"],
                    "unique": ["data must be unique"]
                ]
            )
        )
    }

    func testSuccessfulValidationAPIResponse() throws {
        let req = try Request.test()
        let user = User(
            name: "Valid",
            requiredButOptional: 0,
            emptyStringMeansAbsent: "nonempty",
            unique: "different"
        )
        let response = try req
            .addFields(for: user)
            .validate(inContext: .create, on: req)
            .assertValid(on: req)
            .transform(to: user)
            .encode(for: req)
            .wait()

        XCTAssertEqual(response.http.status, .ok)
        guard let data = response.http.body.data else {
            XCTFail("No data in response body")
            return
        }
        let userResponse = try JSONDecoder().decode(User.self, from: data)
        XCTAssertEqual(userResponse, user)
    }
}
