//
//  Player.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 27/01/13.
//
//

#import "Player.h"

@implementation Player


- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _holeCards = [attributes valueForKeyPath:@"HoleCards"];
    _stack = [[attributes valueForKeyPath:@"Stack"] integerValue];
    _currentStageContribution = [[attributes valueForKeyPath:@"CurrentStageContribution"] integerValue];    
    
    return self;
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
                                    nil, [NSNumber numberWithInteger:NONE],
                                   @"Check",[NSNumber numberWithInteger:CHECK],
                                   @"Call",[NSNumber numberWithInteger:CALL],
                                   @"Bet",[NSNumber numberWithInteger:BET],
                                   @"Raise",[NSNumber numberWithInteger:RAISE],
                                   @"Fold",[NSNumber numberWithInteger:FOLD],
                                  nil
                                  ];
    NSNumber* newKey = [NSNumber numberWithInteger:key];
    
    return (NSString*)[Moves objectForKey:newKey];
}
@end