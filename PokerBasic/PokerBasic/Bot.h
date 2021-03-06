//
//  Bot.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import "Player.h"
#import "PlayerMove.h"


static NSString * const _RAISE = @"Raise";

@interface Bot : Player

@property (readonly) NSArray* lastAction;
@property (readonly) NSString* lastActionString;
@property (readonly) PlayerAction lastActionEnum;
@property (readonly) NSUInteger lastActionAmount;



- (id)initWithAttributes:(NSDictionary *)attributes;

- (NSString*) toString;

//+ (void)globalTimelinePostsWithBlock:(void (^)(NSArray *posts, NSError *error))block;

@end
