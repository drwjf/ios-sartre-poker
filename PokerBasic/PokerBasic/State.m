//
//  State.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 27/01/13.
//
//

#import "State.h"


@implementation State

- (id)initWithAttributes:(NSDictionary*)JSON {
    NSDictionary *gameData = [JSON valueForKeyPath:@"GameState"];
    NSDictionary *playerData = [JSON valueForKeyPath:@"Player"];
    NSDictionary *botData = [JSON valueForKeyPath:@"Bot"];
    
    
    self.player = [[Human alloc]initWithAttributes:playerData];
    self.bot = [[Bot alloc]initWithAttributes:botData];
    self.game = [[Game alloc]initWithAttributes:gameData];
    
//    NSLog(self.game.toString);
//    NSLog(self.player.toString);
//    NSLog(self.bot.toString);
    
    
    return self;
}

@end
