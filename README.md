# XLIFFKit

A Swift framework for parsing and modifying [XLIFF](https://en.wikipedia.org/wiki/XLIFF) files.

An example XLIFF file:

```xml
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
```

## Usage

**Import the framework:**

```swift
import XLIFFKit
```

**Opening an XLIFF:**

```swift
let document = try XLIFFDocument(data: data)
```

**Iterating through the XLIFF's translation units:**

```swift
for file in document.files {
  for translationUnit in file.body.translationUnits {
    print(translationUnit.source, translationUnit.target)
  }
}
```

Where a `XLIFFTranslationUnit` is:

```swift
public struct XLIFFTranslationUnit: Hashable {
  public let uuid: UUID
  public let id: String
  public let source: String
  public let note: String?
  public var target: String?
  public var state: XLIFFState?
}
```

**Modifying a translation unit:**

```swift
let file = document.files[0]
var translationUnit = file.body.translationUnits[0]

translationUnit.target = "New value"
translationUnit.state = .needsReviewTranslation

document.updateTranslationUnit(forFileUUID: file.uuid, to: translationUnit)
```

> The UUID is not present in the XLIFF; one is generated for files and translation units. It is used to refer to and track elements in the document.

After making a modification, `document.hasUnsavedChanges` will become true. Call `document.commitUnsavedChanged()` to write the changes back to the underlying XML document.

**Saving changes:**

```swift
if document.hasUnsavedChanges {
  document.commitUnsavedChanges()
}

let newData = document.xmlData()
```
