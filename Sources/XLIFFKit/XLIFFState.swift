// Copyright © 2023 Matt Comi. All rights reserved.

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
}
