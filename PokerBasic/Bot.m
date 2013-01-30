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
    
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    
    _lastAction = [attributes valueForKeyPath:@"LastAction"];
    _lastActionString = [_lastAction objectAtIndex:0];
    _lastActionEnum = [_lastActionString PlayerActionEnumFromString];    
    _lastActionAmount = [[_lastAction objectAtIndex:1] integerValue];

    self.name = @"Sartre";
    
    return self;
}

- (NSString*) toString {
    NSString *state;

    state = [NSString stringWithFormat:@"Bot State \n Last Action: %@ \n Stack: %d \n Cards: %@ \n Current State Contribution: %d", self.lastActionString, self.stack, self.holeCards, self.currentStageContribution ];
    
    return state;
}

@end
