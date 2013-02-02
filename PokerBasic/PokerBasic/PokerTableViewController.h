//
//  PokerTableViewController.h
//  
//
//  Created by Samuel Michael Russell Grace on 1/02/13.
//
//

#import <UIKit/UIKit.h>

@interface PokerTableViewController : NSObject//UIViewController

- (id)initWithImage:(UIImageView *) tableImage;
- (void)deal:(NSArray*) communityCards;
- (void)newGame:(NSArray*)holecards dealer:(Boolean)botIsDealer;
-(void)bet;


@end
