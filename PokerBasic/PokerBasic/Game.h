//
//  GameState.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import <Foundation/Foundation.h>
#import "PlayerMove.h"

static NSString * const _BOT = @"BOT";
static NSString * const _PLAYER = @"PLAYER";

@interface Game : NSObject

//typedef enum {
//    Player,
//    Bot
//} Dealer;

//from Game.h

@property (readonly) Boolean botIsDealer;
@property (readonly) NSString *gameType;
@property (readonly) NSString *gameStage;
@property (readonly) PlayerAction gameStageEnum;
@property (readonly) Boolean gameHasEnded;
@property (readonly) NSArray *communityCards;
@property (readonly) NSUInteger pot;

- (id)initWithAttributes:(NSDictionary *)attributes;

- (NSString*) toString;

//+ (void)globalTimelinePostsWithBlock:(void (^)(NSArray *posts, NSError *error))block;

@end

/*
 "GameState":{
 "Dealer":"BOT", or "PLAYER"
 "GameType":"Limit",
 "GameStage":"PREFLOP",
 "GameHasEnded":false,
 "CommunityCards":[],
 "Pot":0
 },
*/