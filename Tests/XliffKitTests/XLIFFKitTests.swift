// Copyright © 2023 Matt Comi. All rights reserved.

import XCTest
@testable import XLIFFKit

import Foundation

let xml = """
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xliff version="1.2">
    <file original="Sample/en.lproj/Localizable.strings" source-language="en" target-language="it">
        <body>
            <trans-unit id="common.greeting.hello" xml:space="preserve">
                <source>Hello</source>
                <target>Ciao</target>
                <note>Casual greeting</note>
            </trans-unit>
            <trans-unit id="How are you?" xml:space="preserve">
                <source>How are you?</source>
                <target>Come stai?</target>
                <note></note>
            </trans-unit>
        </body>
    </file>
    <file original="AnotherSample/en.lproj/Localizable.string" source-language="en" target-language="it">
        <body>
            <trans-unit id="Thank you" xml:space="preserve">
                <source>Thank you</source>
                <target>Grazie</target>
            </trans-unit>
            <trans-unit id="You’re welcome" xml:space="preserve">
                <source>You’re welcome</source>
                <target state="needs-review-translation">Prego</target>
                <note>Casual thanks</note>
            </trans-unit>
            <trans-unit id="How old are you?" xml:space="preserve">
                <source>How old are you?</source>
            </trans-unit>
        </body>
    </file>
</xliff>
"""

final class XLIFFKitTests: XCTestCase {
  func testFile() throws {
    let data = try XCTUnwrap(xml.data(using: .utf8))

    let xliffDocument = try XLIFFDocument(data: data)

    XCTAssertEqual(xliffDocument.version, "1.2")

    XCTAssertEqual(xliffDocument.files.count, 2)

    let firstFile = xliffDocument.files[0]

    XCTAssertEqual(firstFile.original, "Sample/en.lproj/Localizable.strings")
    XCTAssertEqual(firstFile.sourceLanguage, "en")
    XCTAssertEqual(firstFile.targetLanguage, "it")
  }

  func testFileWithUUID() throws {
    let data = try XCTUnwrap(xml.data(using: .utf8))

    let xliffDocument = try XLIFFDocument(data: data)
    
    XCTAssertEqual(xliffDocument.files.count, 2)
    
    let firstFile = xliffDocument.files[0]

    XCTAssertEqual(xliffDocument.file(with: firstFile.uuid)?.original, firstFile.original)

    let anotherXLIFFDocument = try XLIFFDocument(data: data)

    // UUIDs are uniquely generated on init.
    XCTAssertNotEqual(xliffDocument.files[0].uuid, anotherXLIFFDocument.files[0].uuid)
  }

  func testGetTranslationUnits() throws {
    let data = try XCTUnwrap(xml.data(using: .utf8))

    let xliffDocument = try XLIFFDocument(data: data)

    let hello = xliffDocument.files[0].body.translationUnits[0]

    XCTAssertEqual(hello.id, "common.greeting.hello")
    XCTAssertEqual(hello.source, "Hello")
    XCTAssertEqual(hello.target, "Ciao")
    XCTAssertEqual(hello.note, "Casual greeting")
    XCTAssertEqual(hello.state, nil)

    let howAreYou = xliffDocument.files[0].body.translationUnits[1]

    XCTAssertEqual(howAreYou.id, "How are you?")
    XCTAssertEqual(howAreYou.source, "How are you?")
    XCTAssertEqual(howAreYou.target, "Come stai?")

    // The note element exists but it is empty.
    XCTAssertEqual(howAreYou.note, "")
    XCTAssertEqual(howAreYou.state, nil)

    let thankYou = xliffDocument.files[1].body.translationUnits[0]

    XCTAssertEqual(thankYou.id, "Thank you")
    XCTAssertEqual(thankYou.source, "Thank you")
    XCTAssertEqual(thankYou.target, "Grazie")

    // The note element does not exist.
    XCTAssertEqual(thankYou.note, nil)
    XCTAssertEqual(thankYou.state, nil)

    let youreWelcome = xliffDocument.files[1].body.translationUnits[1]

    XCTAssertEqual(youreWelcome.id, "You’re welcome")
    XCTAssertEqual(youreWelcome.source, "You’re welcome")
    XCTAssertEqual(youreWelcome.target, "Prego")
    XCTAssertEqual(youreWelcome.note, "Casual thanks")
    XCTAssertEqual(youreWelcome.state, .needsReviewTranslation)
  }

  func testTranslationUnitWithUUID() throws {
    let data = try XCTUnwrap(xml.data(using: .utf8))

    let xliffDocument = try XLIFFDocument(data: data)

    let hello = xliffDocument.files[0].body.translationUnits[0]

    let otherHello = xliffDocument.files[0].body.translationUnit(withUUID: hello.uuid)

    XCTAssertEqual(hello.uuid, otherHello?.uuid)
    XCTAssertEqual(hello.id, otherHello?.id)
  }

  func testSetTranslationUnitErrors() throws {
    let data = try XCTUnwrap(xml.data(using: .utf8))

    var xliffDocument = try XLIFFDocument(data: data)

    let file = xliffDocument.files[0]

    let missingFileUUID = UUID()

    let missingTranslationUnit = XLIFFTranslationUnit(uuid: UUID(), id: "", source: "")

    XCTAssertThrowsError(try xliffDocument.updateTranslationUnit(
      forFileUUID: missingFileUUID, to: missingTranslationUnit)) { error in

        XCTAssertEqual(error as? XLIFFError, .fileNotFound(missingFileUUID))
    }

    XCTAssertThrowsError(try xliffDocument.updateTranslationUnit(
      forFileUUID: file.uuid, to: missingTranslationUnit))  { error in

        XCTAssertEqual(error as? XLIFFError, .translationUnitNotFound(missingTranslationUnit.uuid))
    }
  }

  func testSetTranslationUnit() throws {
    let data = try XCTUnwrap(xml.data(using: .utf8))

    var xliffDocument = try XLIFFDocument(data: data)

    let file = xliffDocument.files[0]

    var hello = file.body.translationUnits[0]

    hello.target = "Ehi!"
    hello.state = .final

    XCTAssertEqual(xliffDocument.hasUnsavedChanges, false)

    try xliffDocument.updateTranslationUnit(forFileUUID: file.uuid, to: hello)

    XCTAssertEqual(xliffDocument.hasUnsavedChanges, true)

    var newData = xliffDocument.xmlData()

    // The changes haven't been committed.
    XCTAssertEqual(data, newData)

    xliffDocument.commitUnsavedChanges()

    newData = xliffDocument.xmlData()

    XCTAssertNotEqual(data, newData)

    xliffDocument = try XLIFFDocument(data: newData)

    XCTAssertEqual(xliffDocument.files[0].body.translationUnits[0].target, "Ehi!")
    XCTAssertEqual(xliffDocument.files[0].body.translationUnits[0].state, .final)

    var howOldAreYou = xliffDocument.files[1].body.translationUnits[2]

    XCTAssertEqual(howOldAreYou.source, "How old are you?")

    howOldAreYou.state = .needsTranslation

    try xliffDocument.updateTranslationUnit(forFileUUID: xliffDocument.files[1].uuid, to: howOldAreYou)

    // The "How old are you?" trans-unit doesn't have a 'target' element...
    XCTAssertNil(howOldAreYou.target)

    // ...so one will be added and then a 'state' attribute will be added to it.
    xliffDocument.commitUnsavedChanges()

    newData = xliffDocument.xmlData()

    XCTAssertNil(howOldAreYou.target)
    XCTAssertEqual(howOldAreYou.state, .needsTranslation)
  }

  func testRemoveTarget() throws {
    let data = try XCTUnwrap(xml.data(using: .utf8))

    var xliffDocument = try XLIFFDocument(data: data)

    let file = xliffDocument.files[0]

    var hello = file.body.translationUnits[0]

    hello.target = nil

    try xliffDocument.updateTranslationUnit(forFileUUID: file.uuid, to: hello)

    xliffDocument.commitUnsavedChanges()

    xliffDocument = try XLIFFDocument(data: xliffDocument.xmlData())

    XCTAssertEqual(xliffDocument.files[0].body.translationUnits[0].target, nil)
    XCTAssertEqual(xliffDocument.files[0].body.translationUnits[0].state, nil)
  }

  func testRemoveTargetWithExistingState() throws {
    let data = try XCTUnwrap(xml.data(using: .utf8))

    var xliffDocument = try XLIFFDocument(data: data)

    let file = xliffDocument.files[1]

    var youreWelcome = file.body.translationUnits[1]

    XCTAssertEqual(youreWelcome.state, .needsReviewTranslation)
    youreWelcome.target = nil

    try xliffDocument.updateTranslationUnit(forFileUUID: file.uuid, to: youreWelcome)

    xliffDocument.commitUnsavedChanges()

    xliffDocument = try XLIFFDocument(data: xliffDocument.xmlData())

    XCTAssertEqual(xliffDocument.files[1].body.translationUnits[1].target, "")
    XCTAssertEqual(xliffDocument.files[1].body.translationUnits[1].state, .needsReviewTranslation)

    print(String(data: xliffDocument.xmlData(), encoding: .utf8)!)
  }
}
