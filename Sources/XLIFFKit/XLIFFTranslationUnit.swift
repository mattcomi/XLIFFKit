// Copyright © 2023 Matt Comi. All rights reserved.

import Foundation

public struct XLIFFTranslationUnit: Hashable {
  public let uuid: UUID
  public let id: String
  public let source: String
  public let note: String?
  public var target: String?
  public var state: XLIFFState?

  init(_ xmlElement: XMLElement, uuid: UUID) throws {
    self.uuid = uuid

    id = try xmlElement.attribute(forName: "id").stringValue ?? ""
    source = try xmlElement.firstElement(forName: "source").stringValue ?? ""
    note = xmlElement.firstElementIfExists(forName: "note")?.stringValue

    let targetXMLElement = xmlElement.firstElementIfExists(forName: "target")

    target = targetXMLElement?.stringValue

    targetXMLElement?.attribute(forName: "state")?.stringValue.flatMap {
      state = .init(rawValue: $0)
    }
  }

  init(
    uuid: UUID, id: String, source: String, note: String? = nil, target: String? = nil, state: XLIFFState? = nil)
  {
    self.uuid = uuid
    self.id = id
    self.source = source
    self.note = note
    self.target = target
    self.state = state
  }

  func save(to xmlElement: XMLElement) {
    guard xmlElement.attribute(forName: "id")?.stringValue == id else {
      fatalError()
    }

    if target != nil || state != nil {
      let targetXMLElement = addTargetElementIfNeeded(to: xmlElement)
      targetXMLElement.stringValue = target

      if let state {
        targetXMLElement.addAttribute(XMLNode.attribute(withName: "state", stringValue: state.rawValue) as! XMLNode)
      }
    } else if target == nil {
      if let index = xmlElement.firstElementIfExists(forName: "target")?.index {
        xmlElement.removeChild(at: index)
      }
    } else if state == nil {
      xmlElement.firstElementIfExists(forName: "target")?.removeAttribute(forName: "state")
    }
  }

  private func addTargetElementIfNeeded(to xmlElement: XMLElement) -> XMLElement {
    if let targetElement = xmlElement.firstElementIfExists(forName: "target") {
      return targetElement
    }

    let targetElement = XMLNode.element(withName: "target") as! XMLElement

    xmlElement.addChild(targetElement)

    return targetElement
  }
}
