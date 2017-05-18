#import "ATVTableSection.h"
#import "ATVTableSection_Private.h"
#import "ATVTableView.h"
#import "ATVTableView_Private.h"

@implementation ATVTableSection

- (id) init {
  [NSException raise:NSInvalidArgumentException format:@"Please use the designated initializer -initWithIdentifier."];
  return nil;
}

// Designated initializer. Use this one.
- (id )initWithIdentifier:(NSString*)identifier {
  if (self = [super init]) {
    self.identifier = identifier;
    self.registeredNibs = [NSMutableDictionary dictionary];
  }
  return self;
}

- (NSString*) description {
  return [NSString stringWithFormat:@"<ATVTableSection %@>", self.identifier ?: NSStringFromClass(self.class)];
}

- (void) setTitle:(NSString*)title {
  _title = title;
  [self reloadSectionWithRowAnimation:UITableViewRowAnimationNone];
}

- (void) setFooterTitle:(NSString*)footerTitle {
  _footerTitle = footerTitle;
  [self reloadSectionWithRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - Cell source

- (UITableViewCell*) cellForRowAtIndex:(NSUInteger)index {
  NSAssert(NO, @"Override this method.");
  return nil;
}

- (void) configureCell:(UITableViewCell*)cell atIndex:(NSUInteger)index {
  NSAssert(NO, @"Override this method.");
}

- (void) registerNib:(NSString*)nibName forIdentifier:(NSString*)identifier {
  [self.registeredNibs setObject:nibName forKey:identifier];
}

- (void) registerNib:(UINib*)nib forCellReuseIdentifier:(NSString*)identifier {
  [self.registeredNibs setObject:nib forKey:identifier];
}

- (NSUInteger) numberOfRows {
  return 0;
}


#pragma mark - Cell position and queueing

// Returns the dequeued cell, or if no cell is available,
// a cell instantiated from the registered nib, if any.
- (id) dequeueReusableCellWithIdentifier:(NSString*)identifier {
  UITableViewCell* cell = [self._tableView dequeueReusableCellWithIdentifier:identifier];
  id registeredNib = [self.registeredNibs objectForKey:identifier];
  if (!cell && registeredNib) {
    if ([registeredNib isKindOfClass:[UINib class]]) {
      cell = [[registeredNib instantiateWithOwner:nil options:nil]
              objectAtIndex:0];
    } else if ([registeredNib isKindOfClass:[NSString class]]) {
      UINib* nib = [UINib nibWithNibName:registeredNib bundle:nil];
      cell = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    } else {
      NSAssert(NO, @"Unexpected nib type for cell reuse identifier %@: %@",
               identifier, registeredNib);
    }
  }
  return cell;
}

- (UITableViewCell*) cellAtIndex:(NSUInteger)index {
  return [self._tableView cellForRowAtIndex:index inSection:self];
}

- (NSUInteger) indexForCell:(UITableViewCell*)cell {
  NSIndexPath* path = [self._tableView indexPathForCell:cell];
  if (path) {
    return path.row;
  } else {
    return NSNotFound;
  }
}

- (CGFloat) heightForRowAtIndex:(NSUInteger)index {
  return [self._tableView rowHeight];
}

#pragma mark - Header and footer

- (CGFloat) headerHeight {
  if (self.headerView) {
    return CGRectGetHeight(self.headerView.frame);
  } else {
    return UITableViewAutomaticDimension;
  }
}

- (CGFloat) footerHeight {
  if (self.footerView) {
    return CGRectGetHeight(self.footerView.frame);
  } else {
    return UITableViewAutomaticDimension;
  }
}

#pragma mark - Scrolling

- (void) scrollToRowAtIndex:(NSUInteger)index atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
  [self._tableView scrollToRowAtIndex:index
                            inSection:self
                     atScrollPosition:scrollPosition
                             animated:animated];
}

#pragma mark - Editing
- (BOOL) canEditRowAtIndex:(NSUInteger)index {
  return NO;
}

- (void) commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
              forRowAtIndex:(NSUInteger)index {
  // Do nothing.
}

#pragma mark - Cell selection

- (NSUInteger) willSelectRowAtIndex:(NSUInteger)index {
  return index;
}

- (void) didSelectRowAtIndex:(NSUInteger)index {
  // NOOP.
}

- (void) willDisplayCell:(UITableViewCell*)cell forRowAtIndex:(NSUInteger)index {
}

#pragma mark - Row changes

// Methods for subclasses to indicate changes as though they're working with their own table view.
- (void) beginUpdates {
  [self._tableView beginUpdates];
}

- (void) endUpdates {
  [self._tableView endUpdates];
}

- (void) insertRowsAtIndices:(NSIndexSet*)indices
            withRowAnimation:(UITableViewRowAnimation)animation {
  [self._tableView insertRowsAtIndices:indices
                             inSection:self
                      withRowAnimation:animation];
}

- (void) deleteRowsAtIndices:(NSIndexSet*)indices
            withRowAnimation:(UITableViewRowAnimation)animation {
  [self._tableView deleteRowsAtIndices:indices
                             inSection:self
                      withRowAnimation:animation];
}

- (void) reloadRowsAtIndices:(NSIndexSet*)indices
            withRowAnimation:(UITableViewRowAnimation)animation {
  [self._tableView reloadRowsAtIndices:indices
                             inSection:self
                      withRowAnimation:animation];
}

- (void) moveRowAtIndex:(NSUInteger)oldIndex
                toIndex:(NSUInteger)newIndex {
  [self._tableView moveRowAtIndex:oldIndex
                          toIndex:newIndex
                        inSection:self];
}

- (void) reloadSectionWithRowAnimation:(UITableViewRowAnimation)animation {
  [self._tableView reloadSection:self withRowAnimation:animation];
}

- (void) selectRowAtIndex:(NSUInteger)index
                 animated:(BOOL)animated
           scrollPosition:(UITableViewScrollPosition)scrollPosition {
  [self._tableView selectRowAtIndex:index
                          inSection:self
                           animated:animated
                     scrollPosition:scrollPosition];
}

- (void) deselectRowAtIndex:(NSUInteger)index animated:(BOOL)animated {
  [self._tableView deselectRowAtIndex:index inSection:self animated:animated];
}

#pragma mark - Deferred updates

- (void)setNeedsToPerformUpdates {
  self.needsToPerformUpdates = YES;
  [self._tableView setWillPerformUpdates];
}

- (void)performUpdatesAnimated:(BOOL)animated {
  self.needsToPerformUpdates = NO;
}

@end
