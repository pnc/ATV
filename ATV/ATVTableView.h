#import <UIKit/UIKit.h>

@class ATVTableSection;

@interface ATVTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property BOOL heightCompatibilityMode;

- (void) addSection:(ATVTableSection*)section;
- (void) addSection:(ATVTableSection*)section belowSection:(ATVTableSection*)below;
- (void) addSection:(ATVTableSection*)section atIndex:(NSUInteger)index;
- (void) removeSection:(ATVTableSection*)section;
- (void) removeAllSections;

- (void) addSection:(ATVTableSection*)section
   withRowAnimation:(UITableViewRowAnimation)animation;
- (void) addSection:(ATVTableSection*)section belowSection:(ATVTableSection*)below
   withRowAnimation:(UITableViewRowAnimation)animation;
- (void) addSection:(ATVTableSection*)section atIndex:(NSUInteger)index
   withRowAnimation:(UITableViewRowAnimation)animation;
- (void) removeSection:(ATVTableSection*)section
      withRowAnimation:(UITableViewRowAnimation)animation;
- (void) removeAllSectionsWithRowAnimation:(UITableViewRowAnimation)animation;

@property (nonatomic, strong) UIView* emptyView;
@property (nonatomic) BOOL emptyViewHonorsContentInset;

#pragma mark - Deferred updates

- (void)performUpdatesAnimated:(BOOL)animated;

#pragma mark - Private

- (UITableViewCell*) cellForRowAtIndex:(NSUInteger)index inSection:(ATVTableSection*)section;
// Return the index path in the table for the index path in the given section object. Raises an exception if the
// section is nil or not in the table view if mustExist is true (the default.)
- (NSIndexPath*) tableIndexPathForSection:(ATVTableSection*)section index:(NSUInteger)index;
// Use this version if you plan to handle nil.
- (NSIndexPath*) tableIndexPathForSection:(ATVTableSection*)section index:(NSUInteger)index mustExist:(BOOL)mustExist;

- (void) insertRowsAtIndices:(NSIndexSet*)indices
                   inSection:(ATVTableSection*)section
            withRowAnimation:(UITableViewRowAnimation)animation;
- (void) deleteRowsAtIndices:(NSIndexSet*)indices
                   inSection:(ATVTableSection*)section
            withRowAnimation:(UITableViewRowAnimation)animation;
- (void) moveRowAtIndex:(NSUInteger)oldIndex
                toIndex:(NSUInteger)newIndex
              inSection:(ATVTableSection*)section;
- (void) reloadRowsAtIndices:(NSIndexSet*)indices
                   inSection:(ATVTableSection*)section
            withRowAnimation:(UITableViewRowAnimation)animation;
- (void) reloadSection:(ATVTableSection*)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void) selectRowAtIndex:(NSUInteger)index inSection:(ATVTableSection*)section animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void) deselectRowAtIndex:(NSUInteger)index inSection:(ATVTableSection*)section animated:(BOOL)animated;
- (void) scrollToRowAtIndex:(NSUInteger)index inSection:(ATVTableSection*)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

@end
