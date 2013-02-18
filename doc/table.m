// Prepare the table section to display story threads in My Interests
ATVArrayTableSection* section = [[ATVArrayTableSection alloc] initWithIdentifier:@"my-interests"];
[section registerNib:@"ATVSmallStoryThreadCell" forIdentifier:@"ProfileStoryThread"];
section.title = @"My Interests";
[section setCellSource:^UITableViewCell* (ATVTableSection* section, NSUInteger index, id object) {
  return [section dequeueReusableCellWithIdentifier:@"ProfileStoryThread"];
}];
[section setConfigureCell:^(ATVTableSection* section, UITableViewCell* cell,
                            NSUInteger index, id object) {
  ATVProfileStoryThreadTableViewCell* storyCell = (ATVProfileStoryThreadTableViewCell* )cell;
  storyCell.roundTop = index == 0;
  storyCell.roundBottom = index == [section numberOfRows] - 1;
  [storyCell useStoryThread:object];
}];
[section setCellHeight:^CGFloat(ATVTableSection* section, NSUInteger index, id object) {
  return 67.0;
}];
[section setCellSelected:^(ATVTableSection* section, NSUInteger index, id object) {
  ATVArrayTableSection* arraySection = (ATVArrayTableSection* )section;
  NSMutableArray* stories = [arraySection mutableArrayValueForKey:@"objects"];
  [stories removeObjectAtIndex:index];
}];
self.myInterestsSection = section;
[self.tableView addSection:self.myInterestsSection];

// In network callback:
self.myInterestsSection.objects = [homeScreen valueForKey:@"interestStories"];