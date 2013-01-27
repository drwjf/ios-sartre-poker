//
//  Bot.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import "Human.h"

@implementation Human : Player

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _name = [attributes valueForKeyPath:@"Name"];
    _holeCards = [attributes valueForKeyPath:@"HoleCards"];
    _stack = [[attributes valueForKeyPath:@"Stack"] integerValue];
    _overallResult = [[attributes valueForKeyPath:@"OverallResult"] integerValue];
    _validMoves = [attributes valueForKeyPath:@"ValidMoves"];    
    _currentStageContribution = [[attributes valueForKeyPath:@"CurrentStageContribution"] integerValue];
    
    return self;
    
    /*
     "Player":{
     "Name":"tester32",
     "HoleCards":["8h","8s"],
     "Stack":998,
     "OverallResult":2,
     "ValidMoves":["Raise","Call"],
     "CurrentStageContribution":2
     },
     */
    
    /*
    @property (readonly) NSString *name;
    @property (readonly) NSArray *holeCards;
    @property (readonly) NSUInteger stack;
    @property (readonly) NSUInteger overallResult;
    @property (readonly) NSArray *validMoves;
    @property (readonly) NSUInteger currentStageContribution;
     */
    
}

- (NSString*) toString {
    NSString *state;
    
    state = [NSString stringWithFormat:@"Player State \n Name: %@: \n Stack: %d \n Holecards: %@ \n  Valid Moves: %@ \n Current Stage Contribution: %d \n Overall Contribution %d \n", 
             self.name, self.stack, self.holeCards, self.validMoves, self.currentStageContribution, self.overallResult];
    return state;
}

@end