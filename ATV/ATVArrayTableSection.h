#import "ATVObjectsTableSection.h"

@interface ATVArrayTableSection : ATVObjectsTableSection

// Set this flag if the objects you supply support
// NSCopying and you want them to be compared using
// isEqual:. Otherwise, they'll be compared by pointer.
@property BOOL objectsSupportEquality;
// Set this flag if the objects you're supplying are immutable. If set, objects that remain at the same index during updates will only be refreshed if they've changed.
@property BOOL objectsAreImmutable;

- (NSArray*)objects;
- (void)setObjects:(NSArray*)objects;
- (void)setObjects:(NSArray*)objects animated:(BOOL)animated;

@end
