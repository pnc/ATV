#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// A section provides cells and update notifications for a single section.
@interface ATVTableSection : NSObject

@property (strong) NSString* identifier;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* footerTitle;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIView* footerView;

// Designated initializer. Use this one.
- (id) initWithIdentifier:(NSString*)identifier;

#pragma mark - Counts

- (NSUInteger) numberOfRows;


#pragma mark - Cell source

- (UITableViewCell*) cellForRowAtIndex:(NSUInteger)index;
- (void) configureCell:(UITableViewCell*)cell atIndex:(NSUInteger)index;
// This takes a nib name, not a nib. Sorry for the confusing API.
- (void) registerNib:(NSString*)nibName forIdentifier:(NSString*)identifier;
// This is the one you want to use.
- (void) registerNib:(UINib*)nib forCellReuseIdentifier:(NSString*)identifier;


#pragma mark - Cell position and queueing

// Return the index of the given cell. If the cell is not visible,
// returns NSNotFound.
- (NSUInteger) indexForCell:(UITableViewCell*)cell;
- (UITableViewCell*) cellAtIndex:(NSUInteger)index;
- (CGFloat) heightForRowAtIndex:(NSUInteger)index;
// Returns the dequeued cell, or if no cell is available,
// a cell instantiated from the registered nib, if any.
- (id) dequeueReusableCellWithIdentifier:(NSString*)identifier;

#pragma mark - Header and footer

- (CGFloat) headerHeight;
- (CGFloat) footerHeight;

#pragma mark - Scrolling

- (void)scrollToRowAtIndex:(NSUInteger)index atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

#pragma mark - Editing
- (BOOL)canEditRowAtIndex:(NSUInteger)index;
- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
             forRowAtIndex:(NSUInteger)index;

#pragma mark - Cell selection

- (NSUInteger) willSelectRowAtIndex:(NSUInteger)index;
- (void) didSelectRowAtIndex:(NSUInteger)index;
- (void) selectRowAtIndex:(NSUInteger)index animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void) deselectRowAtIndex:(NSUInteger)index animated:(BOOL)animated;

#pragma mark - Appearance

- (void) willDisplayCell:(UITableViewCell*)cell forRowAtIndex:(NSUInteger)index;

#pragma mark - Row changes

// Methods for subclasses to indicate changes as though they're working with a table view.
- (void)beginUpdates;
- (void)endUpdates;

- (void) insertRowsAtIndices:(NSIndexSet*)indices
            withRowAnimation:(UITableViewRowAnimation)animation;
- (void) deleteRowsAtIndices:(NSIndexSet*)indices
            withRowAnimation:(UITableViewRowAnimation)animation;
- (void) reloadRowsAtIndices:(NSIndexSet*)indices
            withRowAnimation:(UITableViewRowAnimation)animation;
- (void) moveRowAtIndex:(NSUInteger)oldIndex
                toIndex:(NSUInteger)newIndex;
- (void) reloadSectionWithRowAnimation:(UITableViewRowAnimation)animation;

- (void)setNeedsToPerformUpdates;
- (void)performUpdatesAnimated:(BOOL)animated;

@end
