//  Created by Matt Comi on 6/11/2023.

import Foundation

public struct XLIFFDocument {
  private var xmlDocument: XMLDocument

  private var indexOfFileByUUID = [UUID: Int]()

  public let version: String
  public private(set) var files = [XLIFFFile]()

  public init(data: Data) throws {
    xmlDocument = try XMLDocument(data: data)

    guard let rootElement = xmlDocument.rootElement() else {
      throw XLIFFError.rootElementNotFound
    }

    version = try rootElement.attribute(forName: "version").stringValue ?? ""

    for (offset, element) in rootElement.elements(forName: "file").enumerated() {
      let file = try XLIFFFile(element, uuid: UUID())

      files.append(file)
      indexOfFileByUUID[file.uuid] = offset
    }
  }

  public func file(with uuid: UUID) -> XLIFFFile? {
    guard let index = indexOfFileByUUID[uuid] else { return nil }

    return files[index]
  }

  public mutating func updateTranslationUnit(
    forFileUUID fileUUID: UUID, to translationUnit: XLIFFTranslationUnit) throws
  {
    guard let index = indexOfFileByUUID[fileUUID] else { throw XLIFFError.fileNotFound(fileUUID) }

    try files[index].body.setTranslationUnit(forUUID: translationUnit.uuid, to: translationUnit)
  }

  public var hasUnsavedChanges: Bool {
    for file in files where !file.body.changes.isEmpty {
      return true
    }

    return false
  }

  public mutating func commitUnsavedChanges() {
    for file in files where !file.body.changes.isEmpty {
      for uuid in file.body.changes {
        guard let translationUnit = file.body.translationUnit(withUUID: uuid) else { fatalError() }
        guard let xmlElement = file.body.xmlElement(withUUID: uuid) else { fatalError() }

        translationUnit.save(to: xmlElement)
      }
    }

    files = files.map {
      var file = $0
      file.body.removeChanges()
      return file
    }
  }

  public func xmlData() -> Data {
    return xmlDocument.xmlData(options: .nodePrettyPrint)
  }
}
