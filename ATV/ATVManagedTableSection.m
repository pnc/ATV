#import "ATVManagedTableSection.h"
#import "ATVManagedTableSection_Private.h"
#import "ATVTableSection_Private.h"
#import "ATVTableView.h"

// Which section of the fetch controller results to use.
// This class does not support multiple sections from a single
// fetch controller at this time.
static const NSUInteger NTManagedTableFetchControllerSection = 0;

@implementation ATVManagedTableSection

-(void) dealloc
{
  self.fetchedResultsController.delegate = nil;
  self.fetchedResultsController = nil;
}

#pragma mark - Public API
-(void) setManagedObjectContext:(NSManagedObjectContext *)context andFetchRequest:(NSFetchRequest *)fetchRequest
{
  self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                   initWithFetchRequest:fetchRequest
                                   managedObjectContext:context
                                   sectionNameKeyPath:nil
                                   cacheName:nil];
  self.fetchedResultsController.delegate = self;

  NSError *error;
  BOOL success = [self.fetchedResultsController performFetch:&error];
  NSAssert(success, @"Unable to perform fetch for interests: %@", error);
  [self._tableView reloadData];
}

#pragma mark - Cell source
-(UITableViewCell *) cellForRowAtIndex:(NSUInteger)index
{
  NSAssert(self.cellSource, @"You must supply a cell source block.");
  NSAssert(self.configureCell, @"You must supply a configure cell block.");
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:NTManagedTableFetchControllerSection];
  id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
  UITableViewCell *cell = self.cellSource(self, index, object);
  self.configureCell(self, cell, index, object);
  return cell;
}

-(void) configureCell:(UITableViewCell *)cell atIndex:(NSUInteger)index
{
  NSAssert(self.configureCell, @"You must supply a configure cell block.");
  NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:NTManagedTableFetchControllerSection];
  id object = [self.fetchedResultsController objectAtIndexPath:path];
  self.configureCell(self, cell, index, object);
}

#pragma mark - Data source
-(NSUInteger) numberOfRows {
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:NTManagedTableFetchControllerSection];
  return [sectionInfo numberOfObjects];
}

-(CGFloat)heightForRowAtIndex:(NSUInteger)index {
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:NTManagedTableFetchControllerSection];
  id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
  if (self.cellHeight) {
    return self.cellHeight(self, index, object);
  } else {
    return [super heightForRowAtIndex:index];
  }
}

#pragma mark - Table events
-(void) didSelectRowAtIndex:(NSUInteger)index {
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:NTManagedTableFetchControllerSection];
  id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
  if (self.cellSelected) {
    self.cellSelected(self, index, object);
  }
}

#pragma mark - Fetched results controller delegate
-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller
{
  [self beginUpdates];
}

-(void) controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
  // NTManagedTableSection does not currently support displaying
  // multiple sections from an NSFetchedResultsController
}

-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
  switch(type)
  {
    case NSFetchedResultsChangeInsert:
      [self insertRowsAtIndices:[NSIndexSet indexSetWithIndex:newIndexPath.row]
               withRowAnimation:UITableViewRowAnimationFade];
      break;

    case NSFetchedResultsChangeDelete:
      [self deleteRowsAtIndices:[NSIndexSet indexSetWithIndex:indexPath.row]
                       withRowAnimation:UITableViewRowAnimationFade];
      break;

    case NSFetchedResultsChangeUpdate:
    {
      UITableViewCell *cell = [self cellForRowAtIndex:indexPath.row];
      if (cell)
      {
        [self configureCell:cell atIndex:indexPath.row];
      }
      break;
    }

    case NSFetchedResultsChangeMove:
      [self deleteRowsAtIndices:[NSIndexSet indexSetWithIndex:indexPath.row]
               withRowAnimation:UITableViewRowAnimationFade];
      [self insertRowsAtIndices:[NSIndexSet indexSetWithIndex:newIndexPath.row]
               withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}


-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  [self endUpdates];
}

@end
