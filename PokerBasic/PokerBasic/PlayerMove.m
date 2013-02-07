//
//  PlayerMove.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 4/02/13.
//
//

#import "PlayerMove.h"

@implementation PlayerMove

+ (id) moveWithSeat:(NSNumber*)seat action:(PlayerAction)action amount:(NSInteger)amount {
    
    PlayerMove *move = [[PlayerMove alloc]init];
    
    move.seat = seat;
    move.action = action;
    move.betAmount = amount;
    move.cards = nil;
    
    return move;
}

+ (id) moveWithCards:(NSArray *)cards seat:(NSNumber*)seat action:(PlayerAction)action amount:(NSInteger)amount {
    
    PlayerMove *move = [[PlayerMove alloc]init];
    
    move.seat = seat;
    move.action = action;
    move.betAmount = amount;
    move.cards = cards;
    
    return move;
}

@end

@implementation NSString (EnumParser)

- (PlayerAction)PlayerActionEnumFromString {
    NSDictionary *Moves = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInteger:CHECK], @"Check",
                           [NSNumber numberWithInteger:CALL], @"Call",
                           [NSNumber numberWithInteger:BET], @"Bet",
                           [NSNumber numberWithInteger:RAISE], @"Raise",
                           [NSNumber numberWithInteger:FOLD], @"Fold",
                           nil
                           ];
    return (PlayerAction)[[Moves objectForKey:self] intValue];
}

+ (NSString *) PlayerActionStringFromEnum: (NSUInteger) key{
    
    NSDictionary *Moves = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"MOVE NONE", [NSNumber numberWithInteger:NONE],
                           @"Check",[NSNumber numberWithInteger:CHECK],
                           @"Call",[NSNumber numberWithInteger:CALL],
                           @"Bet",[NSNumber numberWithInteger:BET],
                           @"Raise",[NSNumber numberWithInteger:RAISE],
                           @"Fold",[NSNumber numberWithInteger:FOLD],
                           @"Small Blind",[NSNumber numberWithInteger:SMALLBLIND],
                           @"Big Blind",[NSNumber numberWithInteger:BIGBLIND],
                           @"Deal",[NSNumber numberWithInteger:DEAL],
                           @"Flop",[NSNumber numberWithInteger:FLOP],
                           @"Turn",[NSNumber numberWithInteger:TURN],
                           @"River",[NSNumber numberWithInteger:RIVER],
                           @"Set Dealer",[NSNumber numberWithInteger:SET_DEALER],
                           nil
                           ];
    NSNumber* newKey = [NSNumber numberWithInteger:key];
    
    return (NSString*)[Moves objectForKey:newKey];
}
@end
