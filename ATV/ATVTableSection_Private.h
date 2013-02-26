#import "ATVTableSection.h"

@class ATVTableView;

#ifndef ATV_WEAK
#if __has_feature(objc_arc_weak)
#define ATV_WEAK weak
#elif __has_feature(objc_arc)
#define ATV_WEAK unsafe_unretained
#else
#define ATV_WEAK assign
#endif
#endif

@interface ATVTableSection ()
@property (ATV_WEAK) ATVTableView* _tableView;
@property (strong) NSMutableDictionary* registeredNibs;
@end
