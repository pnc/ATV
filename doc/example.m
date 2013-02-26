// The multi-source table view lets us install separate
// sections with a different data provider for each section.
// Each section only has to worry about row indices, not row
// _and_ section indices.

ATVTableView* tableView = …;

// ==================================================================
// Display an array
// ==================================================================

// Show suggested friends, calculated rather than fetched,
// as the second section.
NSArray* suggestedFriends = …;
ATVTableViewSection* suggestions = [[ATVTableViewArraySection alloc] 
                                   initWithObjects:suggestedFriends
                                   cellSource:
                                   ^(UITableViewCell* cell,
                                      NSIndexPath* path,
                                      id object) {
 // Cell is already instantiated / dequeued - if we wanted something
 // more complex, we'd subclass ATVTableViewSection
 cell.textLabel.text = [object objectForKey:@"name"];
}];
[suggestions setRowSelectedBlock:^(NSIndexPath* path, id object) {
  NSLog(@"Show me suggested friend: %@", object);
}];
[tableView addSection:suggestions];

// Since ATVTableViewArraySection makes a copy of the passed array,
// we need to use the mutable accessor proxy (just like in KVO) to
// modify it. However, we get animations for free!
// For instance, we could do:
[[suggestions mutableArrayForObjects] removeObjectAtIndex:1];

// ==================================================================
// Display a static list of cells that act like buttons
// ==================================================================

// Configure a static section with action buttons
ATVTableViewSection* actions = [[ATVTableViewStaticSection alloc] 
                                initWithCellSource:
                                     ^(UITableViewCell* cell,
                                       NSIndexPath* path,
                                       id info) {
  // Cell is already instantiated / dequeued - if we wanted something
  // more complex, we'd subclass ATVTableViewSection
  cell.textLabel.text = [info objectForKey:@"name"];
}];
NSDictionary* info = @{ @"name" : @"Facebook" };
[actions addRowWithInfo:info tapHandler:^{
  NSLog(@"Something with Facebook.");
}];
info = @{ @"name" : @"Twitter" };
[actions addRowWithInfo:info tapHandler:^{
  NSLog(@"Something with Twitter.");
}];
[multiSourceTableView addSection:actions];

// ===========================================================================
// Display the results of an NSFetchRequest using NSFetchedResultsController
// ===========================================================================

// Show all of the user's friends in the first table view section,
// as fetched from Core Data.
NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
ATVTableViewSection* friends = [[ATVTableViewManagedSection alloc] 
                               initWithManagedObjectContext:context
                               fetchRequest:request];

// Install the friends list as the first section
[tableView addSection:friends];

// ============================================
// Display a plain old view as a section
// ============================================

// Assume this a UIView subclass implemented elsewhere
id profileView = …;
ATVTableViewSection* profile = [[ATVTableViewEmbedSection alloc] 
                               initWithView:profileView];
// Provide the section reference to the displayed view so it can ask
// for height changes when the size of the profile changes. This must
// be weak, since the section holds a strong reference to the view.
profileView.tableViewSection = profile;
// Now the profile view can call something like
//   [self.tableViewSection resizeToHeight:newHeight];
// and get an animated resize.
[tableView addSection:profile];

// Since sections are managed, we also get section animations
// for free. Let's say we want to hide the social actions section:
[tableView removeSection:actions];
// The section indices of `friends` and `profile` have now changed,
// but this is invisible to those classes.