//
//  PokerHTTPClient.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 24/01/13.
//
//

#import "PokerHTTPClient.h"

#import "AFJSONRequestOperation.h"
#import "LoginViewController.h"
//#import "Bot.h"

//static NSString * const pokerBaseUrl = @"nothing";
//static NSString * const pokerBaseURLString = @"http://localhost:8080/poker/mobile/limit/";
static NSString * const pokerBaseURLString = @"http://130.216.36.82:8080/poker/mobile/limit/";
//

@implementation PokerHTTPClient

+ (PokerHTTPClient *)sharedClient {
    static PokerHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PokerHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:pokerBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    
    
    return self;
}

-(void)newGame:(void(^)(NSDictionary *))successBlock failure:(void (^)(void))failureBlock {
    ///poker/mobile/limit/PokerLimitMobileServlet?gameend=true
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self getPath:@"PokerLimitMobileServlet?gameend=true" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        successBlock(JSON);
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"FAILING in PokerHttpClient: newGame");
    }];
}

- (void)playerMove:(NSString *)move success: (void(^)(NSDictionary *))successBlock failure:(void (^)(void))failureBlock {
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSString *path = [NSString stringWithFormat:@"PokerLimitMobileServlet?humanPlayerBettingAction=%@", move];
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        successBlock(JSON);
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"FAILING in PokerHttpClient: playerMove");
    }];
}

- (void)loadState:(void(^)(NSDictionary *))successBlock failure:(void (^)(void))failureBlock {

    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self getPath:@"PokerLimitMobileGameStateServlet" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        successBlock(JSON);
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"FAILING in PokerHttpClient: loadState");
    }];
}

- (void)login:(NSString *)username success:(void (^) (NSString *response))successBlock failure:(void (^)(void))failureBlock {
    [self setDefaultHeader:@"Accept" value:@"text/html"];
    NSLog(@"LOGGING IN");
    NSString *mypath = [NSString stringWithFormat:@"LoginLimitMobileServlet?username=%@", username];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:mypath parameters:nil];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock();
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void) logout:(void(^)(NSString *))successBlock failure:(void (^)(void))failureBlock {
    [self setDefaultHeader:@"Accept" value:@"text/html"];
    [self getPath:@"LoginLimitMobileServlet?loggedOut=true" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"App.net Global Stream: %@", operation.responseString);
        successBlock(operation.responseString);
    } failure:nil
     ];
}

- (void) showState {
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self getPath:@"PokerLimitMobileGameStateServlet " parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"App.net Global Stream: %@", JSON);
    } failure:nil
     ];
}

//    [self getPath:@"LoginLimitMobileServlet" parameters:@"username=SAM" success:^(AFHTTPRequestOperation *operation, id JSON) {
//        NSLog(@"App.net Global Stream: %@", JSON);
//        NSArray *postsFromResponse = [JSON valueForKeyPath:@"data"];
//        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
//        for (NSDictionary *attributes in postsFromResponse) {
//            Post *post = [[Post alloc] initWithAttributes:attributes];
//            [mutablePosts addObject:post];
//        }
//        
//        if (block) {
//            block([NSArray arrayWithArray:mutablePosts], nil);
//        }
//    } failure:nil
//     ^(AFHTTPRequestOperation *operation, NSError *error) {
//        if (block) {
//            block([NSArray array], error);
//        }
//    }
//     ];



/*
+ (void)globalTimelinePostsWithBlock:(void (^)(NSArray *posts, NSError *error))block {
    [[AFAppDotNetAPIClient sharedClient] getPath:@"stream/0/posts/stream/global" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"data"];
        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
        for (NSDictionary *attributes in postsFromResponse) {
            Post *post = [[Post alloc] initWithAttributes:attributes];
            [mutablePosts addObject:post];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutablePosts], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}
 */

@end
