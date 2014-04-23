#import <UIKit/UIKit.h>

@class ATVTableSection;

@interface ATVTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

- (void) addSection:(ATVTableSection*)section;
- (void) addSection:(ATVTableSection*)section belowSection:(ATVTableSection*)below;
- (void) addSection:(ATVTableSection*)section atIndex:(NSUInteger)index;
- (void) removeSection:(ATVTableSection*)section;
- (void) removeAllSections;

@property (nonatomic) UIView* emptyView;

#pragma mark - Private

- (UITableViewCell*) cellForRowAtIndex:(NSUInteger)index inSection:(ATVTableSection*)section;
// Return the index path in the table for the index path in the given section object.
- (NSIndexPath*) tableIndexPathForSection:(ATVTableSection*)section index:(NSUInteger)index;

- (void) insertRowsAtIndices:(NSIndexSet*)indices
                   inSection:(ATVTableSection*)section
            withRowAnimation:(UITableViewRowAnimation)animation;
- (void) deleteRowsAtIndices:(NSIndexSet*)indices
                   inSection:(ATVTableSection*)section
            withRowAnimation:(UITableViewRowAnimation)animation;
- (void) reloadRowsAtIndices:(NSIndexSet*)indices
                   inSection:(ATVTableSection*)section
            withRowAnimation:(UITableViewRowAnimation)animation;
- (void) reloadSection:(ATVTableSection*)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void) deselectRowAtIndex:(NSUInteger)index inSection:(ATVTableSection*)section animated:(BOOL)animated;

@end
