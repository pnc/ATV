#import "ATVObjectsTableSection.h"
#import <CoreData/CoreData.h>

@interface ATVManagedTableSection : ATVObjectsTableSection <NSFetchedResultsControllerDelegate>
- (void)setManagedObjectContext:(NSManagedObjectContext *)context andFetchRequest:(NSFetchRequest *)fetchRequest;
@end
