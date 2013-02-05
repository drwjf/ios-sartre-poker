//
//  GameViewController.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 24/01/13.
//
//

#import <UIKit/UIKit.h>
#import "PokerHTTPClient.h"
#import "PlayerMove.h"

@interface GameViewController : UIViewController
@property (strong, nonatomic) NSString *loginNameText;
@property (strong, nonatomic) PokerHTTPClient *client;

- (void)setActionText:(PlayerAction)action seat:(NSNumber*)seat amount:(NSInteger)amount;

@end
