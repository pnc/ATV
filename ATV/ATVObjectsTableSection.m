#import "ATVObjectsTableSection.h"
#import "ATVTableSection_Private.h"

@implementation ATVObjectsTableSection
/*
 ___    ___    ___   _____   ___    ___    ___   _____
 /   \  | _ )  / __| |_   _| | _ \  /   \  / __| |_   _|
 | - |  | _ \  \__ \   | |   |   /  | - | | (__    | |
 |_|_|  |___/  |___/  _|_|_  |_|_\  |_|_|  \___|  _|_|_
 _|"""""_|"""""_|"""""_|"""""_|"""""_|"""""_|"""""_|"""""|
 "`-0-0-"`-0-0-"`-0-0-"`-0-0-"`-0-0-"`-0-0-"`-0-0-"`-0-0-'
 
 Ride the abstract train with me.
 */

/*
 Because every good abstract class deserves to be, well,
 a little bit less abstract.
 */
- (void) setDefaultCellIdentifier:(NSString*)defaultCellIdentifier {
  NSAssert([self.registeredNibs objectForKey:defaultCellIdentifier], @"You must register a NIB for the default cell identifier");
  _defaultCellIdentifier = defaultCellIdentifier;
}

@end
