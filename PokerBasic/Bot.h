//
//  Bot.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 25/01/13.
//
//

#import <Foundation/Foundation.h>

@interface Bot : NSObject


@property (readonly) NSUInteger currentStageContribution;
@property (readonly) NSArray *holeCards;
@property (readonly) NSArray *lastAction;
@property (readonly) NSUInteger stack;

- (id)initWithAttributes:(NSDictionary *)attributes;

- (NSString*) toString;

//+ (void)globalTimelinePostsWithBlock:(void (^)(NSArray *posts, NSError *error))block;

@end
