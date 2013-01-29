#import "ATVTableSection.h"

@class ATVTableView;

@interface ATVTableSection ()
@property (weak) ATVTableView *_tableView;
@property (strong) NSMutableDictionary *registeredNibs;
@end
