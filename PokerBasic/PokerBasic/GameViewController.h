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
#import "State.h"


@interface GameViewController : UIViewController
@property (strong, nonatomic) NSString *loginNameText;
@property (strong, nonatomic) PokerHTTPClient *client;

@property State *currentState;

@property (weak, nonatomic) IBOutlet UILabel *humanBetAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *humanStackLabel;

@property (weak, nonatomic) IBOutlet UILabel *botBetAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *botStackLabel;

@property (weak, nonatomic) IBOutlet UILabel *potLabel;


- (void)setMoveText:(PlayerMove*)move;
- (void)updateLabels;

@end
