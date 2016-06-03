#import "ATVObjectsTableSection.h"

@interface ATVArrayTableSection : ATVObjectsTableSection

// Set this flag if the objects you supply support
// NSCopying and you want them to be compared using
// isEqual:. Otherwise, they'll be compared by pointer.
@property BOOL objectsSupportEquality;
// Set this flag to YES if the objects you're supplying are mutable. If NO, objects that remain at the same index during updates will not be refreshed unless isEqual returns NO and objectsSupportEquality is YES.
@property BOOL objectsAreMutable;

- (NSArray*)objects;
- (void)setObjects:(NSArray*)objects;
- (void)setObjects:(NSArray*)objects animated:(BOOL)animated;

#pragma mark - Overrides

- (UITableViewRowAnimation)animationForInsertingObject:(id)object atIndex:(NSUInteger)index;
- (UITableViewRowAnimation)animationForDeletingObject:(id)object atIndex:(NSUInteger)index;

@end
