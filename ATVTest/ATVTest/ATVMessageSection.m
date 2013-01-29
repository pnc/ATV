#import "ATVMessageSection.h"

@interface ATVMessageSection ()

@property (nonatomic, strong) UITableViewCell *messageCell;

@end

@implementation ATVMessageSection {
  CGFloat height;
}

static CGFloat labelPaddingSides = 40.0;
static CGFloat labelPaddingTopAndBottom = 20.0;

- (UITableViewCell *)messageCell {
  if (!_messageCell) {
    _messageCell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"MessageCell"];
    _messageCell.textLabel.font = [UIFont systemFontOfSize:17.0];
  }
  return _messageCell;
}

- (UITableViewCell *)cellForRowAtIndex:(NSUInteger)index {
  [self configureCell:self.messageCell atIndex:index];
  return self.messageCell;
}

- (CGFloat)heightForRowAtIndex:(NSUInteger)index {
  [self configureCell:self.messageCell atIndex:index];
  [self updateHeight];
  return height;
}

- (void)configureCell:(UITableViewCell *)cell atIndex:(NSUInteger)index
{
  self.messageCell.textLabel.text = self.message;
  self.messageCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
  self.messageCell.textLabel.numberOfLines = 0;
  [self updateHeight];
}

- (void)updateHeight {
  if (self.messageCell) {
    UIFont *font = self.messageCell.textLabel.font;
    NSLineBreakMode mode = self.messageCell.textLabel.lineBreakMode;
    CGSize size = CGSizeMake(self.messageCell.frame.size.width - labelPaddingSides,
                             CGFLOAT_MAX);
    CGSize sizeForLabel = [self.message sizeWithFont:font
                                   constrainedToSize:size
                                       lineBreakMode:mode];
    height = sizeForLabel.height + labelPaddingTopAndBottom;
  }
}

- (NSUInteger)numberOfRows {
  return 1;
}

- (void)setMessage:(NSString *)message {
  _message = message;

  [self updateHeight];
  [self beginUpdates];
  [self endUpdates];
}

@end