//
//  State.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 27/01/13.
//
//

#import <Foundation/Foundation.h>
#import "Bot.h"
#import "Human.h"
#import "Game.h"

@interface State : NSObject

@property Bot *bot;
@property Human *player;
@property Game *game;


- (id)initWithAttributes:(NSDictionary*)JSON;

@end

