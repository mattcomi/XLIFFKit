// Copyright © 2023 Matt Comi. All rights reserved.

import Foundation

extension XMLElement {
  func attribute(forName name: String) throws -> XMLNode {
    guard let attribute = self.attribute(forName: name) else {
      throw XLIFFError.keyNotFound(.attribute, name: name, parent: self)
    }

    return attribute
  }

  func firstElement(forName name: String) throws -> XMLElement {
    guard let element = firstElementIfExists(forName: name) else {
      throw XLIFFError.keyNotFound(.element, name: name, parent: self)
    }

    return element
  }

  func firstElementIfExists(forName name: String) -> XMLElement? {
    elements(forName: name).first
  }
}
