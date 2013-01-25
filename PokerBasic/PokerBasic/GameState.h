//
//  GameState.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject


@property (readonly) NSString *dealer;
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
 "Dealer":"BOT",
 "GameType":"Limit",
 "GameStage":"PREFLOP",
 "GameHasEnded":false,
 "CommunityCards":[],
 "Pot":0
 },
*/