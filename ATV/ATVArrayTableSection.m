#import "ATVArrayTableSection.h"

@interface ATVArrayTableSection () {
  NSMutableArray *_objects;
}
@end

// To add and remove objects and get animation, use the KVC mutable array proxy
// for the "objects" property:
//
// [section setCellSelected:^(NTTableSection *section, NSUInteger index, id object) {
//   NTArrayTableSection *arraySection = (NTArrayTableSection *)section;
//   NSMutableArray *stories = [arraySection mutableArrayValueForKey:@"objects"];
//   // This will automatically animate the row leaving
//   [stories removeObjectAtIndex:index];
// }];

@implementation ATVArrayTableSection

-(id) initWithIdentifier:(NSString *)identifier
{
  if (self = [super initWithIdentifier:identifier])
  {
    _objects = [NSMutableArray array];
  }
  return self;
}

- (id)init
{
  if (self = [super init])
  {
    _objects = [NSMutableArray array];
  }
  return self;
}

#pragma mark - Public API
- (NSArray *)objects
{
  return _objects;
}

- (void)setObjects:(NSArray *)objects
{
  [self setObjects:objects animated:NO];
}

- (void)setObjects:(NSArray *)objects animated:(BOOL)animated
{
  UITableViewRowAnimation animation = animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
  _objects = [NSMutableArray arrayWithArray:objects];
  [self reloadSectionWithRowAnimation:animation];
}

- (void)removeObjectFromObjectsAtIndex:(NSUInteger)index
{
  [self beginUpdates];
  [self deleteRowsAtIndices:[NSIndexSet indexSetWithIndex:index]
           withRowAnimation:UITableViewRowAnimationTop];
  [_objects removeObjectAtIndex:index];
  [self endUpdates];
}

- (void)insertObject:(id)object inObjectsAtIndex:(NSUInteger)index
{
  [self beginUpdates];
  [self insertRowsAtIndices:[NSIndexSet indexSetWithIndex:index]
           withRowAnimation:UITableViewRowAnimationTop];
  [_objects insertObject:object atIndex:index];
  [self endUpdates];
}

#pragma mark - Cell source
-(UITableViewCell *) cellForRowAtIndex:(NSUInteger)index
{
  NSAssert(self.cellSource, @"You must supply a cell source block.");
  NSAssert(self.configureCell, @"You must supply a configure cell block.");
  id object = [self.objects objectAtIndex:index];
  UITableViewCell *cell = self.cellSource(self, index, object);
  self.configureCell(self, cell, index, object);
  return cell;
}

-(void) configureCell:(UITableViewCell *)cell atIndex:(NSUInteger)index
{
  NSAssert(self.configureCell, @"You must supply a configure cell block.");
  id object = [self.objects objectAtIndex:index];
  self.configureCell(self, cell, index, object);
}

#pragma mark - Data source
-(NSUInteger) numberOfRows {
  return self.objects.count;
}

-(CGFloat)heightForRowAtIndex:(NSUInteger)index {
  id object = [self.objects objectAtIndex:index];
  if (self.cellHeight) {
    return self.cellHeight(self, index, object);
  } else {
    return [super heightForRowAtIndex:index];
  }
}

#pragma mark - Table events
-(void) didSelectRowAtIndex:(NSUInteger)index {
  id object = [self.objects objectAtIndex:index];
  if (self.cellSelected) {
    self.cellSelected(self, index, object);
  }
}

@end
