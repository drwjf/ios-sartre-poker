//
//  PlayerMove.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 4/02/13.
//
//

#import <Foundation/Foundation.h>
#import "Player.h"

typedef enum playerActionTypes
{
    NONE,
    CHECK,
    CALL,
    BET,
    RAISE,
    FOLD,
    SMALLBLIND,
    BIGBLIND,
    PREFLOP,     //DEAL,
    FLOP,
    TURN,
    RIVER,
    SET_DEALER
} PlayerAction;

@interface PlayerMove : NSObject
@property NSNumber *seat;
@property NSInteger betAmount;
@property PlayerAction action;
@property NSArray *cards;

+ (id) moveWithSeat:(NSNumber*)seat action:(PlayerAction)action amount:(NSInteger)amount;
+ (id) moveWithCards:(NSArray *)cards seat:(NSNumber*)seat action:(PlayerAction)action amount:(NSInteger)amount;
@end


@interface NSString (EnumParser)
- (PlayerAction)PlayerActionEnumFromString;
+ (NSString*)PlayerActionStringFromEnum:(NSUInteger)key;
@end
