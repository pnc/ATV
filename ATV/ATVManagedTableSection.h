#import "ATVObjectsTableSection.h"
#import <CoreData/CoreData.h>

@interface ATVManagedTableSection : ATVObjectsTableSection <NSFetchedResultsControllerDelegate>

// Convenience method that instantiates an FRC using the given parameters.
- (void)setManagedObjectContext:(NSManagedObjectContext *)context andFetchRequest:(NSFetchRequest *)fetchRequest;
// Fill this section with the contents of the given FRC. You should not
// retain a reference to the FRC, since this will steal its delegate.
- (void)setFetchedResultsController:(NSFetchedResultsController *)controller;
@end
