#import "ATVExampleArrayViewController.h"
#import "ATVTableView.h"
#import "ATVArrayTableSection.h"

@interface ATVExampleArrayViewController ()
@property (readonly) ATVTableView *dataView;
@property ATVArrayTableSection *arraySection;
@end

@implementation ATVExampleArrayViewController

- (void)loadView {
  self.view = [[ATVTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
}

- (ATVTableView *)dataView {
  return (id)self.view;
}

- (void)viewDidLoad {
  self.arraySection = [[ATVArrayTableSection alloc] initWithIdentifier:@"example"];
  self.arraySection.objects = nil ?: @[@"1 - Foo", @"2 - Bar", @"1 - Foo", @"4 - Darkwing"];
  self.arraySection.objectsSupportEquality = YES;
  [self.arraySection setCellSource:^UITableViewCell *(ATVTableSection *section, NSUInteger index, id object) {
    UITableViewCell *cell = [section dequeueReusableCellWithIdentifier:@"test"];
    if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
    }
    return cell;
  }];
  [self.arraySection setConfigureCell:^(ATVTableSection *section, UITableViewCell *cell, NSUInteger index, id object) {
    cell.textLabel.text = object;
  }];
  [self.dataView addSection:self.arraySection withRowAnimation:UITableViewRowAnimationNone];
  UIBarButtonItem *item = [[UIBarButtonItem alloc]
                           initWithTitle:@"Permute"
                           style:UIBarButtonItemStylePlain
                           target:self
                           action:@selector(shiftAround:)];
  UIBarButtonItem *reverse = [[UIBarButtonItem alloc]
                           initWithTitle:@"Reverse"
                           style:UIBarButtonItemStylePlain
                           target:self
                           action:@selector(reverse:)];
  self.navigationItem.rightBarButtonItems = @[item, reverse];
}

- (IBAction)reverse:(id)sender {
  self.arraySection.objects = [[self.arraySection.objects reverseObjectEnumerator] allObjects];
}

- (IBAction)shiftAround:(id)sender {
  NSMutableArray *items = [self.arraySection.objects mutableCopy];
  for (int i = 0; i < arc4random_uniform(100); i++) {
    int operation = arc4random_uniform(3);
    switch (operation) {
      case 0: { // insert
        int index = arc4random_uniform((unsigned int)items.count + 1);
        NSString *item = [NSString stringWithFormat:@"%i", arc4random_uniform(20)];
        [items insertObject:item atIndex:index];
        break;
      }
      case 1: { // delete
        if (items.count > 0) {
          int index = arc4random_uniform((unsigned int)items.count);
          [items removeObjectAtIndex:index];
        }
        break;
      }
      case 2: { // move
        if (items.count > 0) {
          int old = arc4random_uniform((unsigned int)items.count);
          int new = arc4random_uniform((unsigned int)items.count);
          NSString *item = [items objectAtIndex:old];
          [items removeObjectAtIndex:old];
          if (old < new) {
            new--;
          }
          [items insertObject:item atIndex:new];
        }
        break;
      }
    }
  }
  [self.arraySection setObjects:items animated:YES];
}

@end
