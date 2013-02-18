#import <UIKit/UIKit.h>

@class ATVTableSection;

@interface ATVTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

- (void) addSection:(ATVTableSection*)section;
- (void) addSection:(ATVTableSection*)section belowSection:(ATVTableSection*)below;
- (void) addSection:(ATVTableSection*)section atIndex:(NSUInteger)index;
/*
 Add a section while guaranteeing that it gets inserted in the desired ordering.

 @param expectedSectionOrder a list of all possible section identifiers in the expected order.

 @discussion This method is helpful to allow an instance of ATVTableView to be
             driven completely by KVO. Each KVO change event can add/remove
             without worrying about the correct insertion order of each section
             relative to every other section and each possible combination
             of currently displayed table sections.
 */
- (void) addSection:(ATVTableSection*)section withIdentifierOrder:(NSArray*)expectedSectionOrder;
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
- (void)reloadSection:(ATVTableSection*)section withRowAnimation:(UITableViewRowAnimation)animation;

@end
