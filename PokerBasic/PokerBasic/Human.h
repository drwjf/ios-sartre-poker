//
//  Bot.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import "Player.h"

@interface Human : Player

@property (readonly) NSUInteger overallResult;
@property (readonly) NSArray *validMoves;



- (id)initWithAttributes:(NSDictionary *)attributes;

- (NSString*) toString;

//+ (void)globalTimelinePostsWithBlock:(void (^)(NSArray *posts, NSError *error))block;

@end

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