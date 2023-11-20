//
//  File.swift
//  
//
//  Created by Matt Comi on 9/11/2023.
//

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
  case xmlElementMismatch
}
