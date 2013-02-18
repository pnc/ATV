// Prepare the table section to display story threads in My Interests
NTArrayTableSection* section = [[NTArrayTableSection alloc] initWithIdentifier:@"my-interests"];
[section registerNib:@"NTSmallStoryThreadCell" forIdentifier:@"ProfileStoryThread"];
section.title = @"My Interests";
[section setCellSource:^UITableViewCell* (NTTableSection* section, NSUInteger index, id object) {
  return [section dequeueReusableCellWithIdentifier:@"ProfileStoryThread"];
}];
[section setConfigureCell:^(NTTableSection* section, UITableViewCell* cell,
                            NSUInteger index, id object) {
  NTProfileStoryThreadTableViewCell* storyCell = (NTProfileStoryThreadTableViewCell* )cell;
  storyCell.roundTop = index == 0;
  storyCell.roundBottom = index == [section numberOfRows] - 1;
  [storyCell useStoryThread:object];
}];
[section setCellHeight:^CGFloat(NTTableSection* section, NSUInteger index, id object) {
  return 67.0;
}];
[section setCellSelected:^(NTTableSection* section, NSUInteger index, id object) {
  NTArrayTableSection* arraySection = (NTArrayTableSection* )section;
  NSMutableArray* stories = [arraySection mutableArrayValueForKey:@"objects"];
  [stories removeObjectAtIndex:index];
}];
self.myInterestsSection = section;
[self.tableView addSection:self.myInterestsSection];

// In network callback:
self.myInterestsSection.objects = [homeScreen valueForKey:@"interestStories"];