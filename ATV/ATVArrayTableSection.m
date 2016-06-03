#import "ATVArrayTableSection.h"

@interface ATVArrayTableSection () {
  NSArray* _objects;
}
@end

// To add and remove objects and get animation, use the KVC mutable array proxy
// for the "objects" property:
//
// [section setCellSelected:^(ATVTableSection* section, NSUInteger index, id object) {
//   ATVArrayTableSection* arraySection = (ATVArrayTableSection*)section;
//   NSMutableArray* stories = [arraySection mutableArrayValueForKey:@"objects"];
//   // This will automatically animate the row leaving
//   [stories removeObjectAtIndex:index];
// }];

@implementation ATVArrayTableSection

- (id) initWithIdentifier:(NSString*)identifier {
  self = [super initWithIdentifier:identifier];
  if (self) {
    _objects = [NSMutableArray array];
  }
  return self;
}

- (id) init {
  self = [super init];
  if (self) {
    _objects = [NSMutableArray array];
  }
  return self;
}

#pragma mark - Public API

- (NSArray*) objects {
  return _objects;
}

- (void) setObjects:(NSArray*)objects {
  [self setObjects:objects animated:NO];
}

- (void) setObjects:(NSArray*)objects animated:(BOOL)animated {
  if (!_objects) {
    _objects = objects;
    [self reloadSectionWithRowAnimation:UITableViewRowAnimationNone];
    return;
  }

  NSArray *oldObjects = _objects;
  _objects = objects; // in case the table view asks during updates
  [self beginUpdates];

  // Record the previous index location of each object. We keep an array
  // in case the same object appears more than once.
  NSMutableDictionary <id, NSMutableArray <NSNumber *> *> *oldIndexes = nil;
  if (self.objectsSupportEquality) {
    oldIndexes = [NSMutableDictionary dictionary];
  } else {
    // We use an NSMapTable so that objects don't have to implement NSCopying.
    // Headers say the default for string is NSPointerFunctionsObjectPersonality,
    // which is what we want.
    // We cast since there's no map/dictionary superclass or protocol.
    oldIndexes = (id)[NSMapTable
                      mapTableWithKeyOptions:NSMapTableStrongMemory
                      valueOptions:NSMapTableStrongMemory];
  }

  // Build a map of (object) -> [old position].
  // If the same object appears more than once, it'll be
  //                (object) -> [old position 1, old position 2, ...]
  // We'll use this to figure out the previous location of each object,
  // if it's not a new entry.
  for (int i = 0; i < oldObjects.count; i++) {
    id item = [oldObjects objectAtIndex:i];
    id identifier = [self uniqueIdentifierForObject:item];
    NSMutableArray *positions = [oldIndexes objectForKey:identifier];
    if (!positions) {
      positions = [NSMutableArray array];
    }
    [positions addObject:@(i)];
    [oldIndexes setObject:positions forKey:identifier];
  }

  for (int i = 0; i < objects.count; i++) {
    id item = [objects objectAtIndex:i];
    id identifier = [self uniqueIdentifierForObject:item];
    NSMutableArray *positions = [oldIndexes objectForKey:identifier];
    NSNumber *oldIndex = nil;
    if (positions.count > 0) {
      // Without loss of generality, assume this duplicate was the first. This
      // keeps duplicates from swapping places needlessly.
      oldIndex = [positions objectAtIndex:0];
      [positions removeObjectAtIndex:0];
    } else {
      [oldIndexes removeObjectForKey:identifier];
    }

    NSNumber *newIndex = @(i);
    if (oldIndex) {
      if ([oldIndex isEqual:newIndex]) {
        // Compare the backing values and perform this update
        // only if the object has changed.
        BOOL needsRefresh = NO;
        id oldObject = [oldObjects objectAtIndex:[oldIndex unsignedIntegerValue]];
        id newObject = [objects objectAtIndex:[newIndex unsignedIntegerValue]];
        if (self.objectsSupportEquality) {
          needsRefresh = ![oldObject isEqual:newObject];
        } else if (!self.objectsAreMutable) {
          needsRefresh = oldObject != newObject;
        } else {
          needsRefresh = YES;
        }

        if (needsRefresh) {
          UITableViewCell *cell = [self cellAtIndex:[oldIndex unsignedIntegerValue]];
          if (cell) {
            // Cell is visible, repaint it
            [self configureCell:cell atIndex:[oldIndex unsignedIntegerValue]];
          } else {
            // Cell is not visible, reload it
            [self reloadRowsAtIndices:[NSIndexSet indexSetWithIndex:[oldIndex unsignedIntegerValue]] withRowAnimation:UITableViewRowAnimationNone];
          }
        }
      } else {
        [self moveRowAtIndex:[oldIndex unsignedIntegerValue] toIndex:[newIndex unsignedIntegerValue]];
      }
    } else {
      UITableViewRowAnimation insertAnimation = animated ?
      [self animationForInsertingObject:item atIndex:[newIndex unsignedIntegerValue]] : UITableViewRowAnimationNone;
      [self insertRowsAtIndices:[NSIndexSet indexSetWithIndex:[newIndex unsignedIntegerValue]] withRowAnimation:insertAnimation];
    }
  }
  for (id identifier in oldIndexes) {
    NSArray <NSNumber *> *indexes = [oldIndexes objectForKey:identifier];
    for (NSNumber *index in indexes) {
      id item = [oldObjects objectAtIndex:[index unsignedIntegerValue]];
      UITableViewRowAnimation deleteAnimation = animated ?
      [self animationForDeletingObject:item atIndex:[index unsignedIntegerValue]] : UITableViewRowAnimationNone;
      [self deleteRowsAtIndices:[NSIndexSet indexSetWithIndex:[index unsignedIntegerValue]]
               withRowAnimation:deleteAnimation];
    }
  }
  [self endUpdates];
}

- (UITableViewRowAnimation)animationForInsertingObject:(id)object atIndex:(NSUInteger)index {
  return UITableViewRowAnimationTop;
}

- (UITableViewRowAnimation)animationForDeletingObject:(id)object atIndex:(NSUInteger)index {
  return UITableViewRowAnimationBottom;
}

- (id)uniqueIdentifierForObject:(id)object {
  return object;
}

#pragma mark - Cell source

- (UITableViewCell*) cellForRowAtIndex:(NSUInteger)index {
  NSAssert(self.cellSource || self.defaultCellIdentifier, @"You must supply a cell source block or default cell identifier.");
  NSAssert(self.configureCell, @"You must supply a configure cell block.");
  id object = [self.objects objectAtIndex:index];
  UITableViewCell* cell;
  if (self.cellSource) {
    cell = self.cellSource(self, index, object);
  } else if (self.defaultCellIdentifier) {
    cell = [self dequeueReusableCellWithIdentifier:self.defaultCellIdentifier];
  }
  self.configureCell(self, cell, index, object);
  return cell;
}

- (void) configureCell:(UITableViewCell*)cell atIndex:(NSUInteger)index {
  NSAssert(self.configureCell, @"You must supply a configure cell block.");
  id object = [self.objects objectAtIndex:index];
  self.configureCell(self, cell, index, object);
}


#pragma mark - Data source

- (NSUInteger) numberOfRows {
  return self.objects.count;
}

- (CGFloat) heightForRowAtIndex:(NSUInteger)index {
  id object = [self.objects objectAtIndex:index];
  if (self.cellHeight) {
    return self.cellHeight(self, index, object);
  } else {
    return [super heightForRowAtIndex:index];
  }
}

#pragma mark - Table events

- (void) didSelectRowAtIndex:(NSUInteger)index {
  id object = [self.objects objectAtIndex:index];
  if (self.cellSelected) {
    self.cellSelected(self, index, object);
  }
}


@end
