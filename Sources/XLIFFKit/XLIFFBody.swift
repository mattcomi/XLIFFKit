// Copyright © 2023 Matt Comi. All rights reserved.

import Foundation

public struct XLIFFBody {
  public private(set) var translationUnits = [XLIFFTranslationUnit]()
  private var translationUnitByUUID = [UUID: XLIFFTranslationUnit]()
  private var xmlElementByUUID = [UUID: XMLElement]()

  /// The UUIDs of all the translation units that have been changed by calling ``setTranslationUnit(forUUID:to:)``.
  private(set) var changes = Set<UUID>()

  init(_ xmlElement: XMLElement) throws {
    for translationUnitXMLElement in xmlElement.elements(forName: "trans-unit") {
      let translationUnit = try XLIFFTranslationUnit(translationUnitXMLElement, uuid: UUID())

      translationUnits.append(translationUnit)
      translationUnitByUUID[translationUnit.uuid] = translationUnit
      xmlElementByUUID[translationUnit.uuid] = translationUnitXMLElement
    }
  }

  public func translationUnit(withUUID uuid: UUID) -> XLIFFTranslationUnit? {
    translationUnitByUUID[uuid]
  }

  /// Replaces the translation unit with the given UUID.
  public mutating func setTranslationUnit(forUUID uuid: UUID, to translationUnit: XLIFFTranslationUnit) throws {
    guard translationUnitByUUID[uuid] != nil else {
      throw XLIFFError.translationUnitNotFound(uuid)
    }

    translationUnitByUUID[uuid] = translationUnit

    changes.insert(uuid)
  }

  func xmlElement(withUUID uuid: UUID) -> XMLElement? {
    xmlElementByUUID[uuid]
  }

  mutating func removeChanges() {
    changes.removeAll()
  }
}
