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
    
    
    Human *human = [[Human alloc]initWithAttributes:playerData];
    Bot *bot = [[Bot alloc]initWithAttributes:botData];
    
    _playerStateDict = [NSDictionary dictionaryWithObjectsAndKeys: bot, @0, human, @1, nil];
    self.game = [[Game alloc]initWithAttributes:gameData];
    
//    NSLog(self.game.toString);
//    NSLog(self.player.toString);
//    NSLog(self.bot.toString);
    
    
    return self;
}

@end
