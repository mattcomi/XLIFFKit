// Copyright © 2023 Matt Comi. All rights reserved.

import Foundation

public enum XLIFFError: Error, Equatable {
  public enum KeyType {
    case attribute
    case element
  }

  case rootElementNotFound
  case keyNotFound(KeyType, name: String, parent: XMLElement)
  case fileNotFound(UUID)
  case translationUnitNotFound(UUID)
}
