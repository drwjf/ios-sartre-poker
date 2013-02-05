//
//  Player.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 27/01/13.
//
//

#import "Player.h"

@implementation Player


- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _holeCards = [attributes valueForKeyPath:@"HoleCards"];
    _stack = [[attributes valueForKeyPath:@"Stack"] integerValue];
    _currentStageContribution = [[attributes valueForKeyPath:@"CurrentStageContribution"] integerValue];    
    
    return self;
}

@end

