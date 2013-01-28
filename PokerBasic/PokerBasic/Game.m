//
//  GameState.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import "Game.h"

@implementation Game

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    _botIsDealer = [[attributes valueForKeyPath:@"Dealer"] isEqualToString:_BOT] ? true : false;
    _gameType = [attributes valueForKeyPath:@"GameType"];
    _gameStage = [attributes valueForKeyPath:@"GameStage"];
//  _gameHasEnded = (Boolean)[attributes valueForKeyPath:@"GameHasEnded"];
    _gameHasEnded = [[attributes valueForKeyPath:@"GameHasEnded"] boolValue]; //test this for when satre folds right at the start
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
    
    state = [NSString stringWithFormat:@"Game has ended: %@ \n Game State \n Bot is Dealer: %@ \n Game Stage is : %@ \n Community Cards are : %@ \n",
             self.gameHasEnded ? @"YES" : @"NO", self.botIsDealer ? @"YES" : @"NO", self.gameStage, self.communityCards ];
    
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