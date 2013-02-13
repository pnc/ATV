#import "ATVObjectsTableSection.h"

@interface ATVArrayTableSection : ATVObjectsTableSection

- (NSArray *)objects;
- (void)setObjects:(NSArray *)objects;
- (void)setObjects:(NSArray *)objects animated:(BOOL)animated;

@end
