// Copyright © 2023 Matt Comi. All rights reserved.

import Foundation

public struct XLIFFFile {
  public let uuid: UUID
  public let original: String
  public let sourceLanguage: String
  public let targetLanguage: String
  public var body: XLIFFBody

  init(_ xmlElement: XMLElement, uuid: UUID) throws {
    self.uuid = uuid
    original = try xmlElement.attribute(forName: "original").stringValue ?? ""
    sourceLanguage = try xmlElement.attribute(forName: "source-language").stringValue ?? ""
    targetLanguage = try xmlElement.attribute(forName: "target-language").stringValue ?? ""

    self.body = try XLIFFBody(try xmlElement.firstElement(forName: "body"))
  }
}
