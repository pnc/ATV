#import "ATVTableView.h"

/**
  ATVTableView subclass with guaranteed section ordering.

  @discussion This class is helpful to allow an instance of ATVTableView to be
  driven completely by KVO. Each KVO change event can add/remove
  without worrying about the correct insertion order of each section
  relative to every other section and each possible combination
  of currently displayed table sections.
 */

@interface ATVOrderedTableView : ATVTableView

/**
  Must be configured with a list of all possible section identifiers in the
  order in which they should be displayed.
 */
@property (strong, nonatomic) NSArray* sectionOrder;

/**
  Overridden from ATVTableView to insert a section in the correct order
  based on its identifier and the current [ATVOrderedTableView expectedSectionIdentifierOrder]
 */
- (void) addSection:(ATVTableSection*)section;

/**
  Overridden from ATVTableView to throw an exception on use.
  @warning This method should not be used on an instance of ATVOrderedTableView.
 */
- (void) addSection:(ATVTableSection*)section belowSection:(ATVTableSection*)below;

/**
 Overridden from ATVTableView to throw an exception on use.
 @warning This method should not be used on an instance of ATVOrderedTableView.
 */
- (void) addSection:(ATVTableSection*)section atIndex:(NSUInteger)index;

@end
