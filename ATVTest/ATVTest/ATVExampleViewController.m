#import "ATVExampleViewController.h"
#import "ATVMessageSection.h"
#import "ATVTableView.h"

@interface ATVExampleViewController ()
@property (readonly) ATVTableView *sectionedTableView;
@property (strong) ATVMessageSection *messageSection;
@end

@implementation ATVExampleViewController

- (ATVTableView *)sectionedTableView {
  return (ATVTableView *)self.tableView;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  ATVMessageSection *section = [[ATVMessageSection alloc]
                                initWithIdentifier:@"message"];
  section.message = @"Here’s an example of a multi-sourced table view.";
  section.title = nil;
  [self.sectionedTableView addSection:section];
  self.messageSection = section;

  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                            target:self
                                            action:@selector(addToMessage:)];
}

- (void)addToMessage:(id)sender {
  self.messageSection.message = [self.messageSection.message
                                 stringByAppendingString:@" And here’s a bit more."];
}

@end
