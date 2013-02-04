//
//  PokerTableViewController.h
//  
//
//  Created by Samuel Michael Russell Grace on 1/02/13.
//
//

#import <UIKit/UIKit.h>

@interface PokerTableView : NSObject//UIView

- (id)initWithImage:(UIImageView *) tableImage;
- (void)deal:(NSArray*) communityCards;
- (void)newGame:(NSArray*)holecards dealer:(Boolean)botIsDealer;
- (void)animate:(NSEnumerator *)enumerator;

@end
