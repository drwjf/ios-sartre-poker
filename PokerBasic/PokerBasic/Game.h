//
//  GameState.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import <Foundation/Foundation.h>

static NSString * const _BOT = @"BOT";
static NSString * const _PLAYER = @"PLAYER";
static NSString * const _PREFLOP = @"PREFLOP";
static NSString * const _FLOP = @"FLOP";
static NSString * const _TURN = @"TURN";
static NSString * const _RIVER = @"RIVER";


@interface Game : NSObject

//typedef enum {
//    Player,
//    Bot
//} Dealer;

@property (readonly) Boolean botIsDealer;
@property (readonly) NSString *gameType;
@property (readonly) NSString *gameStage;
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