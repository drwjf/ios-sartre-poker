//
//  State.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 27/01/13.
//
//

#import <Foundation/Foundation.h>

#import "Game.h"
#import "Bot.h"
#import "Human.h"

@interface State : NSObject

@property NSDictionary* playerStateDict;
@property Game *game;


- (id)initWithAttributes:(NSDictionary*)JSON;

@end

