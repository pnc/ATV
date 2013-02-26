#import "ATVOrderedTableView.h"
#import "ATVTableView_Private.h"
#import "ATVTableSection.h"

@implementation ATVOrderedTableView

- (void)setSectionOrder:(NSArray*)sectionOrder {
  _sectionOrder = sectionOrder;

  // TODO: Eventually this could be a "smart" reordering of the existing sections
  //       assuming that the new ordering contains the identifier of each currently
  //       visible section. But for now we'll just assume that this won't be used
  //       very often.
  if (self.sections.count) {
    [self reloadData];
  }
}

- (void) addSection:(ATVTableSection*)section {
  NSAssert(self.sectionOrder, @"ATVOrderedTableView requires sectionOrder be set before adding sections.");
  NSAssert(section.identifier, @"Section identifiers are required for all sections in an ATVOrderedTableView.");

  NSInteger expectedSectionOrderIndex = [self.sectionOrder indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop) {
    return [section.identifier isEqualToString:obj];
  }];

  NSAssert(expectedSectionOrderIndex != NSNotFound, @"Expected to find section identifier '%@' in section order array.", section.identifier);

  // Assume that we will be adding the section at the end
  // unless can determine that it should be inserted earlier.
  NSInteger insertionIndex = self.sections.count;

  for (NSInteger i = expectedSectionOrderIndex; i > 0; --i) {
    NSUInteger existingSectionIndex = [self.sections indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop) {
      return [section.identifier isEqualToString:((ATVTableSection*)obj).identifier];
    }];
    if (existingSectionIndex != NSNotFound) {
      insertionIndex = existingSectionIndex + 1;
      break;
    }
  }

  [super addSection:section atIndex:insertionIndex];
}

// If you're looking for guaranteed ordering, then it doesn't make sense to
// manually insert a section below another section.
- (void) addSection:(ATVTableSection*)section belowSection:(ATVTableSection*)below {
  [NSException raise:NSInvalidArgumentException format:@"ATVOrderedTableView does not support addSection:belowSection:"];
}

// If you're looking for guaranteed ordering, then it doesn't make sense to
// manually insert a section at a specific index.
- (void) addSection:(ATVTableSection*)section atIndex:(NSUInteger)index {
  [NSException raise:NSInvalidArgumentException format:@"ATVOrderedTableView does not support addSection:atIndex:"];
}

@end
