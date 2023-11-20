//  Created by Matt Comi on 6/11/2023.

import Foundation

public enum XLIFFState: String, CaseIterable {
  /// Indicates the terminating state.
  case final

  /// Indicates only non-textual information needs adaptation.
  case needsAdaptation = "needs-adaptation"

  /// Indicates both text and non-textual information needs adaptation.
  case needsL10n = "needs-l10n"

  /// Indicates only non-textual information needs review.
  case needsReviewAdaptation = "needs-review-adaptation"

  /// Indicates both text and non-textual information needs review.
  case needsReviewL10n = "needs-review-l10n"

  /// Indicates that only the text of the item needs to be reviewed.
  case needsReviewTranslation = "needs-review-translation"

  /// Indicates that the item needs to be translated.
  case needsTranslation = "needs-translation"

  /// Indicates that the item is new. For example, translation units that were not in a previous version of the
  /// document.
  case new

  /// Indicates that changes are reviewed and approved.
  case signedOff = "signed-off"

  /// Indicates that the item has been translated.
  case translated

  case `nil`

  public var sortOrder: Int {
    switch self {
    case .needsAdaptation, .needsReviewL10n, .needsTranslation, .new:
      return 0
    case .needsL10n, .needsReviewAdaptation, .needsReviewTranslation:
      return 1
    case .final, .signedOff, .translated:
      return 2
    case .nil:
      return 3
    }
  }
}
