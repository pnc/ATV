#import "ATVTableView.h"

@interface ATVTableView ()

@property (strong) NSMutableArray* sections;
@property UITableViewCellSeparatorStyle desiredSeparatorStyle;

@property BOOL willPerformUpdates;
- (void)setWillPerformUpdates;

@end
