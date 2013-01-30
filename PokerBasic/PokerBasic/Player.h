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

- (id)initWithAttributes:(NSDictionary *)attributes;

typedef enum playerActionTypes
{
    NONE,
    CHECK,
    CALL,
    BET,
    RAISE,
    FOLD
} PlayerAction;

@end


@interface NSString (EnumParser)
- (PlayerAction)PlayerActionEnumFromString;
+ (NSString*)PlayerActionStringFromEnum:(NSUInteger)key;
@end
