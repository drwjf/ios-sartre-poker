//
//  PokerTableViewController.h
//  
//
//  Created by Samuel Michael Russell Grace on 1/02/13.
//
//

#import <UIKit/UIKit.h>

@interface PokerTableViewController : NSObject//UIViewController

- (void) setUp;
- (id)initWithImage:(UIImageView *) tableImage;
- (IBAction)deal:(id)sender;
- (IBAction)newGame:(id)sender;

@end
