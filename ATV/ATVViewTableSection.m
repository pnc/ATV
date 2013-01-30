#import "ATVViewTableSection.h"

@interface ATVViewTableSection ()
@property (nonatomic, retain) UITableViewCell *viewCell;
@end

@implementation ATVViewTableSection

- (UITableViewCell *)viewCell {
  if (!_viewCell) {
    _viewCell = [[UITableViewCell alloc] init];
  }
  return _viewCell;
}

- (UITableViewCell *)cellForRowAtIndex:(NSUInteger)index {
  return self.viewCell;
}

- (void)configureCell:(UITableViewCell *)cell atIndex:(NSUInteger)index
{
  
}

- (NSUInteger)numberOfRows {
  return !!self.view ? 1 : 0;
}

- (CGFloat)heightForRowAtIndex:(NSUInteger)index {
  if (self.view) {
    return self.view.frame.size.height;
  }
  return 0.0;
}

- (void)setView:(UIView *)view {
  [self beginUpdates];
  if (!_view && view) {
    [self insertRowsAtIndices:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
  } else if (_view && !view) {
    [self deleteRowsAtIndices:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
  }
  _view = view;
  self.viewCell.backgroundView = [[UIView alloc] init];
  [self.viewCell.contentView addSubview:view];
  [self endUpdates];
}

@end
