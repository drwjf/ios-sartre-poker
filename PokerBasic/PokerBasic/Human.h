//
//  Bot.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import <Foundation/Foundation.h>

@interface Human : NSObject


@property (readonly) NSString *name;
@property (readonly) NSArray *holeCards;
@property (readonly) NSUInteger stack;
@property (readonly) NSUInteger overallResult;
@property (readonly) NSArray *validMoves;
@property (readonly) NSUInteger currentStageContribution;


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