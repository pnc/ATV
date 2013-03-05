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

  NSAssert((NSNotFound == [self.sections indexOfObjectPassingTest:^BOOL(ATVTableSection* existingSection, NSUInteger idx, BOOL *stop) {
    return [section.identifier isEqualToString:existingSection.identifier];
  }]), @"Attempted to add section with identifier '%@', but a section with that identifier already exists", section.identifier);

  NSInteger expectedSectionOrderIndex = [self.sectionOrder indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop) {
    return [section.identifier isEqualToString:obj];
  }];

  NSAssert(expectedSectionOrderIndex != NSNotFound, @"Expected to find section identifier '%@' in section order array.", section.identifier);

  // Assume that we will be adding the section at the beginning
  // unless can find a preceding section which it should follow.
  NSInteger insertionIndex = 0;

  for (NSInteger i = expectedSectionOrderIndex; i >= 0; --i) {
    NSString* precedingSectionIdentifier = self.sectionOrder[i];
    NSUInteger precedingSectionIndex = [self.sections indexOfObjectPassingTest:^BOOL(ATVTableSection* existingSection, NSUInteger idx, BOOL* stop) {
      return [precedingSectionIdentifier isEqualToString:existingSection.identifier];
    }];
    if (precedingSectionIndex != NSNotFound) {
      insertionIndex = precedingSectionIndex + 1;
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
