#import "ATVTableSection.h"

@interface ATVObjectsTableSection : ATVTableSection

@property (copy) UITableViewCell* (^cellSource)(ATVTableSection* section, NSUInteger index, id object);
@property (copy) CGFloat (^cellHeight)(ATVTableSection* section, NSUInteger index, id object);
@property (copy) void (^configureCell)(ATVTableSection* section, UITableViewCell* cell, NSUInteger index, id object);
@property (copy) void (^cellSelected)(ATVTableSection* section, NSUInteger index, id object);

- (void) setConfigureCell:(void (^)(ATVTableSection* section, UITableViewCell* cell, NSUInteger index, id object))configureCell;
- (void) setCellHeight:(CGFloat (^)(ATVTableSection* section, NSUInteger index, id object))cellHeight;
- (void) setCellSource:(UITableViewCell* (^)(ATVTableSection* section, NSUInteger index, id object))cellSource;
- (void) setCellSelected:(void (^)(ATVTableSection* section, NSUInteger index, id object))cellSelected;

@end
