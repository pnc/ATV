#import "ATVTableView.h"
#import "ATVTableSection.h"
#import "ATVTableSection_Private.h"

@interface ATVTableView ()
@property (strong) NSMutableArray* sections;
@property UITableViewCellSeparatorStyle desiredSeparatorStyle;
@end

@implementation ATVTableView

- (id) init {
  self = [super init];
  if (self) {
    [self setup];
  }
  return self;
}

- (id) initWithCoder:(NSCoder*)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self setup];
  }
  return self;
}

- (void) setup {
  self.sections = [NSMutableArray array];
  self.dataSource = self;
  self.delegate = self;
  // Trigger our special setter for separatorStyle even if
  // the user left it as the default. This also updates the
  // empty view.
  [self setSeparatorStyle:self.separatorStyle];
}

- (void) addSection:(ATVTableSection*)section {
  [self addSection:section atIndex:self.sections.count];
  [self updateEmptyView];
}

- (void) addSection:(ATVTableSection*)section belowSection:(ATVTableSection*)below {
  NSUInteger index = [self indexForSection:below];
  [self addSection:section atIndex:index + 1];
  [self updateEmptyView];
}

- (void) addSection:(ATVTableSection*)section atIndex:(NSUInteger)index {
  section._tableView = self;
  [self beginUpdates];
  [self.sections insertObject:section atIndex:index];
  NSIndexSet* indices = [NSIndexSet indexSetWithIndex:index];
  [self insertSections:indices withRowAnimation:UITableViewRowAnimationAutomatic];
  [self endUpdates];
  [self updateEmptyView];
}

- (void) addSection:(ATVTableSection*)section withIdentifierOrder:(NSArray*)expectedSectionOrder {
  NSInteger expectedSectionOrderIndex = [expectedSectionOrder indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop) {
    return [section.identifier isEqualToString:obj];
  }];

  NSAssert(expectedSectionOrderIndex != NSNotFound, @"Expected to find section identifier '%@' in expected section order array", section.identifier);

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

  [self addSection:section atIndex:insertionIndex];
}


- (void) removeSection:(ATVTableSection*)section {
  NSUInteger sectionIndex = [self indexForSection:section];
  [self beginUpdates];
  [self.sections removeObjectAtIndex:sectionIndex];
  NSIndexSet* indices = [NSIndexSet indexSetWithIndex:sectionIndex];
  [self deleteSections:indices withRowAnimation:UITableViewRowAnimationAutomatic];
  [self endUpdates];
  section._tableView = nil;
  [self updateEmptyView];
}

- (void) removeAllSections {
  [self beginUpdates];
  NSRange range = NSMakeRange(0, self.sections.count);
  NSIndexSet* indices = [NSIndexSet indexSetWithIndexesInRange:range];
  [self deleteSections:indices withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.sections removeAllObjects];
  [self endUpdates];
  [self updateEmptyView];
}


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
  return self.sections.count;
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
  ATVTableSection* tableSection = [self.sections objectAtIndex:section];
  return tableSection.title;
}

- (NSString*) tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section {
  ATVTableSection* tableSection = [self.sections objectAtIndex:section];
  return tableSection.footerTitle;
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  ATVTableSection* tableSection = [self.sections objectAtIndex:section];
  return [tableSection numberOfRows];
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  ATVTableSection* tableSection = [self.sections objectAtIndex:indexPath.section];
  return [tableSection cellForRowAtIndex:indexPath.row];
}

- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  ATVTableSection* tableSection = [self.sections objectAtIndex:indexPath.section];
  return [tableSection heightForRowAtIndex:indexPath.row];
}

- (CGFloat) tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
  ATVTableSection* tableSection = [self.sections objectAtIndex:section];
  if (tableSection.headerView) {
    return tableSection.headerView.bounds.size.height;
  } else if (tableSection.title) {
    return self.sectionHeaderHeight;
  } else {
    return 0.0;
  }
}

- (UIView*) tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
  ATVTableSection* tableSection = [self.sections objectAtIndex:section];
  // If no header view is provided, the table view will generate
  // the default system one, so it's safe for this to return nil.
  if (tableSection.headerView) {
    tableSection.headerView.frame =
    CGRectMake(tableSection.headerView.frame.origin.x,
               tableSection.headerView.frame.origin.y,
               self.bounds.size.width,
               tableSection.headerView.frame.size.height);
  }
  return tableSection.headerView;
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  ATVTableSection* tableSection = [self.sections objectAtIndex:indexPath.section];
  [tableSection didSelectRowAtIndex:indexPath.row];
}

- (void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
  ATVTableSection* tableSection = [self.sections objectAtIndex:indexPath.section];
  [tableSection commitEditingStyle:editingStyle forRowAtIndex:indexPath.row];
}

- (BOOL) tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
  ATVTableSection* tableSection = [self.sections objectAtIndex:indexPath.section];
  return [tableSection canEditRowAtIndex:indexPath.row];
}

#pragma mark - Private

- (UITableViewCell*) cellForRowAtIndex:(NSUInteger)index inSection:(ATVTableSection*)section {
  NSIndexPath* path = [self tableIndexPathForSection:section index:index];
  return [self cellForRowAtIndexPath:path];
}

- (void) insertRowsAtIndices:(NSIndexSet*)indices
                   inSection:(ATVTableSection*)section
            withRowAnimation:(UITableViewRowAnimation)animation {
  NSMutableArray* paths = [NSMutableArray array];
  [indices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL* stop) {
    NSIndexPath* path = [self tableIndexPathForSection:section index:idx];
    [paths addObject:path];
  }];
  [self insertRowsAtIndexPaths:paths withRowAnimation:animation];
  [self updateEmptyView];
}

- (void) deleteRowsAtIndices:(NSIndexSet*)indices
                   inSection:(ATVTableSection*)section
            withRowAnimation:(UITableViewRowAnimation)animation {
  NSMutableArray* paths = [NSMutableArray array];
  [indices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL* stop) {
    NSIndexPath* path = [self tableIndexPathForSection:section index:idx];
    [paths addObject:path];
  }];
  [self deleteRowsAtIndexPaths:paths withRowAnimation:animation];
  [self updateEmptyView];
}

- (void) reloadSection:(ATVTableSection*)section withRowAnimation:(UITableViewRowAnimation)animation {
  NSIndexSet* index = [NSIndexSet indexSetWithIndex:[self indexForSection:section]];
  [self reloadSections:index withRowAnimation:animation];
  [self updateEmptyView];
}

- (void) endUpdates {
  [super endUpdates];
  [self updateEmptyView];
}

#pragma mark - Converting from indices to table index paths

- (NSIndexPath*) tableIndexPathForSection:(ATVTableSection*)section index:(NSUInteger)index {
  NSUInteger sectionIndex = [self indexForSection:section];
  return [NSIndexPath indexPathForRow:index inSection:sectionIndex];
}

- (NSUInteger) indexForSection:(ATVTableSection*)section {
  NSAssert(section, @"Cannot convert an index path from a null section.");
  NSUInteger sectionIndex = [self.sections indexOfObject:section];
  NSAssert(NSNotFound != sectionIndex, @"Attempted to determine index of section %@, which is not a section in this table view.", section);
  return sectionIndex;
}

#pragma mark - Empty view display

- (void) setSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle {
  self.desiredSeparatorStyle = separatorStyle;
  // Since this setter could be called during decoding, only update
  // the empty view if it's obvious we have finished initializing.
  // If we haven't finished, -updateEmptyView will get called as
  // part of initialization.
  if (self.sections) {
    [self updateEmptyView];
  }
}

- (void) setEmptyView:(UIView*)emptyView {
  if (_emptyView && _emptyView.superview) {
    [_emptyView removeFromSuperview];
  }
  _emptyView = emptyView;
  [self updateEmptyView];
}

- (void) updateEmptyView {
  if (self.emptyView && [self isEmpty]) {
    [super setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    BOOL animate = NO;
    if (!self.emptyView.superview) {
      self.emptyView.alpha = 0.0;
      animate = YES;
    }
    [self addSubview:self.emptyView];
    self.emptyView.frame = self.bounds;
    if (animate) {
      [UIView beginAnimations:NULL context:NULL];
      [UIView setAnimationDuration:0.5];
      self.emptyView.alpha = 1.0;
      [UIView commitAnimations];
    }
  } else {
    [super setSeparatorStyle:self.desiredSeparatorStyle];
    [self.emptyView removeFromSuperview];
  }
}

- (BOOL) isEmpty {
  NSInteger sections = [self numberOfSectionsInTableView:self];
  NSInteger total = 0;
  for (NSInteger i = 0; i < sections; i++) {
    total += [self numberOfRowsInSection:i];
  }
  return 0 == total;
}

@end
