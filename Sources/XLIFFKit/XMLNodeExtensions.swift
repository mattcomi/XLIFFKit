// Copyright © 2023 Matt Comi. All rights reserved.

import Foundation

extension Collection where Element: XMLNode {
  func first(withName name: String) -> Self.Element? {
    first { $0.name == name }
  }

  func elements() -> [XMLElement] {
    self.compactMap { $0 as? XMLElement }
  }

  func filter(byName name: String) -> [Self.Element] {
    self.filter { $0.name == name }
  }
}
