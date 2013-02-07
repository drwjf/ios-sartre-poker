//
//  Player.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 27/01/13.
//
//

#import <Foundation/Foundation.h>



@interface Player : NSObject

@property NSString *name;
@property (readonly) NSArray *holeCards;
@property (readonly) NSUInteger stack;
@property (readonly) NSUInteger currentStageContribution;
@property NSNumber *seat;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end



