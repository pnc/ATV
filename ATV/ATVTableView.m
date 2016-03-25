#import "ATVTableView.h"
#import "ATVTableView_Private.h"
#import "ATVTableSection.h"
#import "ATVTableSection_Private.h"

// In older iOSes, UITableView checks the CGFloat returned
// by -tableView:heightForFooterInSection: and -- this is gold --
// uses the table's "sectionFooterHeight" if the returned value is
// exactly 0. Thus, we have to use a very small value to prevent this
// behavior when it's inappropriate (such as when there is no footer text.)
// This behavior has been standarized in newer versions using
// UITableViewAutomaticDimension, so we no longer have to resort to hacks.
// See the heightCompatibilityMode setting.
static const CGFloat ATVEpsilonFooterHeight = 0.001;

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

- (instancetype) initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setup];
  }
  return self;
}

- (instancetype) initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
  if (self = [super initWithFrame:frame style:style]) {
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
  // Before UITableViewAutomaticDimension existed, ATVTableView
  // tried to be smart. Instead of breaking API, this behavior is opt-out.
  // It's on by default until a future version.
  self.heightCompatibilityMode = YES;
}

- (void) addSection:(ATVTableSection*)section {
  [self addSection:section withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) addSection:(ATVTableSection*)section belowSection:(ATVTableSection*)below {
  [self addSection:section belowSection:below withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) addSection:(ATVTableSection*)section atIndex:(NSUInteger)index {
  [self addSection:section atIndex:index withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) removeSection:(ATVTableSection*)section {
  [self removeSection:section withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) removeAllSections {
  [self removeAllSectionsWithRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) addSection:(ATVTableSection*)section withRowAnimation:(UITableViewRowAnimation)animation {
  [self addSection:section atIndex:self.sections.count withRowAnimation:animation];
  [self updateEmptyView];
}

- (void) addSection:(ATVTableSection*)section belowSection:(ATVTableSection*)below withRowAnimation:(UITableViewRowAnimation)animation {
  NSUInteger index = [self indexForSection:below];
  [self addSection:section atIndex:index + 1 withRowAnimation:animation];
  [self updateEmptyView];
}

- (void) addSection:(ATVTableSection*)section atIndex:(NSUInteger)index withRowAnimation:(UITableViewRowAnimation)animation {
  section._tableView = self;
  [self beginUpdates];
  [self.sections insertObject:section atIndex:index];
  NSIndexSet* indices = [NSIndexSet indexSetWithIndex:index];
  [self insertSections:indices withRowAnimation:animation];
  [self endUpdates];
  [self updateEmptyView];
}

- (void) removeSection:(ATVTableSection*)section withRowAnimation:(UITableViewRowAnimation)animation {
  NSUInteger sectionIndex = [self indexForSection:section];
  [self beginUpdates];
  [self.sections removeObjectAtIndex:sectionIndex];
  NSIndexSet* indices = [NSIndexSet indexSetWithIndex:sectionIndex];
  [self deleteSections:indices withRowAnimation:animation];
  [self endUpdates];
  section._tableView = nil;
  [self updateEmptyView];
}

- (void) removeAllSectionsWithRowAnimation:(UITableViewRowAnimation)animation {
  [self beginUpdates];
  NSRange range = NSMakeRange(0, self.sections.count);
  NSIndexSet* indices = [NSIndexSet indexSetWithIndexesInRange:range];
  [self deleteSections:indices withRowAnimation:animation];
  for (ATVTableSection* section in self.sections) {
    section._tableView = nil;
  }
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
  UITableViewCell* cell = [tableSection cellForRowAtIndex:indexPath.row];
  NSAssert(cell, @"Section %@ failed to return a cell", tableSection);
  return cell;
}

- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  ATVTableSection* tableSection = [self.sections objectAtIndex:indexPath.section];
  return [tableSection heightForRowAtIndex:indexPath.row];
}

- (CGFloat) tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
  ATVTableSection* tableSection = [self.sections objectAtIndex:section];
  if (self.heightCompatibilityMode) {
    if (tableSection.headerView) {
      return tableSection.headerView.bounds.size.height;
    } else if (tableSection.title) {
      return self.sectionHeaderHeight;
    } else {
      // Use the table view default
      return 0.0;
    }
  } else {
    return [tableSection headerHeight];
  }
}

- (CGFloat) tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
  ATVTableSection* tableSection = [self.sections objectAtIndex:section];
  if (self.heightCompatibilityMode) {
    if (tableSection.footerView) {
      return tableSection.footerView.bounds.size.height;
    } else if (tableSection.footerTitle) {
      return self.sectionFooterHeight;
    } else if (UITableViewStyleGrouped == tableView.style) {
      return ATVEpsilonFooterHeight;
    } else {
      // Use the table view default
      return 0.0;
    }
  } else {
    return [tableSection footerHeight];
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

- (UIView*) tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
  ATVTableSection* tableSection = [self.sections objectAtIndex:section];
  // If no header view is provided, the table view will generate
  // the default system one, so it's safe for this to return nil.
  if (tableSection.footerView) {
    tableSection.footerView.frame =
    CGRectMake(tableSection.footerView.frame.origin.x,
               tableSection.footerView.frame.origin.y,
               self.bounds.size.width,
               tableSection.footerView.frame.size.height);
  }
  return tableSection.footerView;
}

- (NSIndexPath*) tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  ATVTableSection* tableSection = [self.sections objectAtIndex:indexPath.section];
  NSUInteger index = [tableSection willSelectRowAtIndex:indexPath.row];
  if (NSNotFound == index) {
    return nil;
  } else {
    return [NSIndexPath indexPathForRow:index inSection:indexPath.section];
  }
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

- (void) tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
  ATVTableSection* tableSection = [self.sections objectAtIndex:indexPath.section];
  [tableSection willDisplayCell:cell forRowAtIndex:indexPath.row];
}

#pragma mark - Private

- (UITableViewCell*) cellForRowAtIndex:(NSUInteger)index inSection:(ATVTableSection*)section {
  NSIndexPath* path = [self tableIndexPathForSection:section index:index];
  UITableViewCell* cell = [self cellForRowAtIndexPath:path];
  return cell;
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

- (void) moveRowAtIndex:(NSUInteger)oldIndex
                toIndex:(NSUInteger)newIndex
              inSection:(ATVTableSection*)section {
  NSIndexPath* oldPath = [self tableIndexPathForSection:section
                                                  index:oldIndex];
  NSIndexPath* newPath = [self tableIndexPathForSection:section
                                                  index:newIndex];
  [self moveRowAtIndexPath:oldPath toIndexPath:newPath];
}

- (void) reloadRowsAtIndices:(NSIndexSet*)indices
                   inSection:(ATVTableSection*)section
            withRowAnimation:(UITableViewRowAnimation)animation {
  NSMutableArray* paths = [NSMutableArray array];
  [indices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL* stop) {
    NSIndexPath* path = [self tableIndexPathForSection:section index:idx];
    [paths addObject:path];
  }];
  [self reloadRowsAtIndexPaths:paths withRowAnimation:animation];
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

- (void) selectRowAtIndex:(NSUInteger)index
                inSection:(ATVTableSection*)section
                 animated:(BOOL)animated
           scrollPosition:(UITableViewScrollPosition)scrollPosition {
  NSIndexPath* path = [self tableIndexPathForSection:section index:index];
  [self selectRowAtIndexPath:path
                    animated:animated
              scrollPosition:scrollPosition];
}

- (void) deselectRowAtIndex:(NSUInteger)index
                  inSection:(ATVTableSection*)section animated:(BOOL)animated {
  NSIndexPath* path = [self tableIndexPathForSection:section index:index];
  [self deselectRowAtIndexPath:path animated:animated];
}

- (void) scrollToRowAtIndex:(NSUInteger)index inSection:(ATVTableSection *)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
  NSIndexPath* path = [self tableIndexPathForSection:section index:index];
  [self scrollToRowAtIndexPath:path
              atScrollPosition:scrollPosition
                      animated:animated];
}

#pragma mark - Converting from indices to table index paths

- (NSIndexPath*) tableIndexPathForSection:(ATVTableSection*)section index:(NSUInteger)index {
  return [self tableIndexPathForSection:section index:index mustExist:YES];
}

- (NSIndexPath*) tableIndexPathForSection:(ATVTableSection*)section index:(NSUInteger)index mustExist:(BOOL)mustExist {
  NSUInteger sectionIndex;
  if (mustExist) {
    sectionIndex = [self indexForSection:section];
  } else {
    sectionIndex = [self safeIndexForSection:section];
  }

  if (NSNotFound != sectionIndex) {
    return [NSIndexPath indexPathForRow:index inSection:sectionIndex];
  } else {
    return nil;
  }
}

- (NSUInteger) indexForSection:(ATVTableSection*)section {
  NSAssert(section, @"Cannot convert an index path from a null section.");
  if (!section) {
    [NSException raise:NSInternalInconsistencyException
                format:@"Cannot convert an index path from a null section."];
  }
  NSUInteger sectionIndex = [self safeIndexForSection:section];
  NSAssert(NSNotFound != sectionIndex, @"Attempted to determine index of section %@, which is not a section in this table view.", section);
  if (NSNotFound == sectionIndex) {
    [NSException raise:NSInternalInconsistencyException
                format:@"Attempted to determine index of section %@, which is not a section in this table view: %@", section, self.sections];
  }
  return sectionIndex;
}

// Use this version if you plan to handle NSNotFound yourself.
- (NSUInteger) safeIndexForSection:(ATVTableSection*)section {
  return [self.sections indexOfObject:section];
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
    CGRect frame = self.bounds;
    if (self.emptyViewHonorsContentInset) {
      frame.origin.y = 0;
    }
    self.emptyView.frame = frame;
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

- (void)layoutSubviews {
  [super layoutSubviews];
  [self updateEmptyView];
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
