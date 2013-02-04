//
//  PlayerMove.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 4/02/13.
//
//

#import <Foundation/Foundation.h>
#import "Player.h"

@interface PlayerMove : NSObject
@property NSInteger seatNumber;
@property NSInteger betAmount;
@property PlayerAction action;
@end



