//
//  Bot.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import "Human.h"

@implementation Human

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    
    self.name = [attributes valueForKeyPath:@"Name"];
    _overallResult = [[attributes valueForKeyPath:@"OverallResult"] integerValue];
    _validMoves = [attributes valueForKeyPath:@"ValidMoves"];    

    
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
