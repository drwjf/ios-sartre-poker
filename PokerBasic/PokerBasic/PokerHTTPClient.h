//
//  PokerHTTPClient.h
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 24/01/13.
//
//

#import "AFHTTPClient.h"
@class LoginViewController;

@interface PokerHTTPClient : AFHTTPClient

+ (PokerHTTPClient *)sharedClient;

- (void)login:(NSString *)username success:(void (^) (NSString *response))successBlock failure:(void (^)(void))failureBlock;

- (void)showState;

- (void)logout:(void(^)(NSString *))successBlock failure:(void (^)(void))failureBlock;

- (void)loadState:(void(^)(NSDictionary *))successBlock failure:(void (^)(void))failureBlock;

- (void)playerMove:(NSString *)move success: (void(^)(NSDictionary *))successBlock failure:(void (^)(void))failureBlock;

-(void)newGame:(void(^)(NSDictionary *))successBlock failure:(void (^)(void))failureBlock;

@end
