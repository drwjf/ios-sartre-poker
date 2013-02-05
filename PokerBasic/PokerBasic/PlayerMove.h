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
    DEAL,
    FLOP,
    TURN,
    RIVER,
    SET_DEALER
} PlayerAction;

@interface PlayerMove : NSObject
@property NSNumber *seat;
@property NSInteger betAmount;
@property PlayerAction action;

+ (id) moveWithSeat:(NSNumber*)seat action:(PlayerAction)action amount:(NSInteger)amount;
@end


@interface NSString (EnumParser)
- (PlayerAction)PlayerActionEnumFromString;
+ (NSString*)PlayerActionStringFromEnum:(NSUInteger)key;
@end
