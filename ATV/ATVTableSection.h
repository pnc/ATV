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
- (void) registerNib:(NSString*)nibName forIdentifier:(NSString*)identifier;


#pragma mark - Cell position and queueing

// Return the index of the given cell. If the cell is not visible,
// returns NSNotFound.
- (NSUInteger) indexForCell:(UITableViewCell*)cell;
- (UITableViewCell*) cellAtIndex:(NSUInteger)index;
- (CGFloat) heightForRowAtIndex:(NSUInteger)index;
// Returns the dequeued cell, or if no cell is available,
// a cell instantiated from the registered nib, if any.
- (id) dequeueReusableCellWithIdentifier:(NSString*)identifier;


#pragma mark - Editing
- (BOOL)canEditRowAtIndex:(NSUInteger)index;
- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
             forRowAtIndex:(NSUInteger)index;

#pragma mark - Cell selection

- (void) didSelectRowAtIndex:(NSUInteger)index;


#pragma mark - Row changes

// Methods for subclasses to indicate changes as though they're working with a table view.
- (void)beginUpdates;
- (void)endUpdates;

- (void) insertRowsAtIndices:(NSIndexSet*)indices
            withRowAnimation:(UITableViewRowAnimation)animation;
- (void) deleteRowsAtIndices:(NSIndexSet*)indices
            withRowAnimation:(UITableViewRowAnimation)animation;
- (void) reloadSectionWithRowAnimation:(UITableViewRowAnimation)animation;

@end
