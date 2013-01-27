//
//  Bot.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import "Bot.h"

@implementation Bot

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _currentStageContribution = [[attributes valueForKeyPath:@"CurrentStageContribution"] integerValue];    
    _holeCards = [attributes valueForKeyPath:@"HoleCards"];    
    _lastAction = [attributes valueForKeyPath:@"LastAction"];    
    _stack = [[attributes valueForKeyPath:@"Stack"] integerValue];
    _name = @"Sartre";
    
    return self;
    
}

- (NSString*) toString {
    NSString *state;

    state = [NSString stringWithFormat:@"Bot State \n Last Action: %@ \n Stack: %d \n Cards: %@ \n Current State Contribution: %d", self.lastAction, self.stack, self.holeCards, self.currentStageContribution ];
    
    return state;
}

@end
