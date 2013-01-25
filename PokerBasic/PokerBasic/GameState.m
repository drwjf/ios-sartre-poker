//
//  GameState.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import "GameState.h"

@implementation GameState

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
 
    
    _dealer = [attributes valueForKeyPath:@"Dealer"];
    _gameType = [attributes valueForKeyPath:@"GameType"];
    _gameStage = [attributes valueForKeyPath:@"GameStage"];
    _gameHasEnded = (Boolean)[attributes valueForKeyPath:@"GameHasEnded"];
    _communityCards = [attributes valueForKeyPath:@"CommunityCards"];
    _pot = [[attributes valueForKeyPath:@"Pot"] integerValue];
    
//    _currentStageContribution = [[attributes valueForKeyPath:@"CurrentStageContribution"] integerValue];    
//    _holeCards = [attributes valueForKeyPath:@"HoleCards"];
//    _lastAction = [attributes valueForKeyPath:@"LastAction"];
//    _stack = [[attributes valueForKeyPath:@"Stack"] integerValue];
//    
    return self;
    
}

- (NSString*) toString {
    NSString *state;
    
    state = [NSString stringWithFormat:@"Game State \n Dealer is: %@ \n Game Stage is : %@ \n Community Cards are : %@ \n", self.dealer, self.gameStage, self.communityCards ];
    
    return state;
}

@end

/*
 @property (readonly) NSString *dealer;
 @property (readonly) NSString *gameType;
 @property (readonly) NSString *gameStage;
 @property (readonly) Boolean gameHasEnded;
 @property (readonly) NSArray *communityCards;
 @property (readonly) NSUInteger pot;
 
 "GameState":{
 "Dealer":"BOT",
 "GameType":"Limit",
 "GameStage":"PREFLOP",
 "GameHasEnded":false,
 "CommunityCards":[],
 "Pot":0
 },
*/