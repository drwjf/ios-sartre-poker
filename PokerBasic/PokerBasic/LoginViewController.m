//
//  PokerBasicViewController.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 14/01/13.
//
//

#import "LoginViewController.h"
#import "AFJSONRequestOperation.h"
#import "GameViewController.h"
#import "PokerHTTPClient.h"

@interface LoginViewController ()

@property PokerHTTPClient *client;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.loginStatusLabel.text = @"should be blank";
    self.client = [PokerHTTPClient sharedClient];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)testSegueButton:(id)sender {
//    [self performSegueWithIdentifier: @"SegueToGame" sender: self];
//}
//
//- (IBAction)testConnectionButton:(id)sender {
//    NSURL *url;
//    NSURLRequest *request;
//    AFJSONRequestOperation *operation;
//    
//    url = [NSURL URLWithString:@"http://httpbin.org/ip"];
//    request = [NSURLRequest requestWithURL:url];
//    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        NSLog(@"IP Address: %@", [JSON valueForKeyPath:@"origin"]);
//        self.loginStatusLabel.text = [JSON valueForKeyPath:@"origin"];
//    } failure:nil];
//    self.loginStatusLabel.text = @"Establishing internet connection";
//    [operation start];
//    
//    url = [NSURL URLWithString:@"https://alpha-api.app.net/stream/0/posts/stream/global"];
//    request = [NSURLRequest requestWithURL:url];
//    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        NSLog(@"App.net Global Stream: %@", JSON);
//    } failure:nil];
//    [operation start];
//}

- (IBAction)loginButton:(id)sender {
    
    self.loginStatusLabel.text = @"Logging in...";
    
    

    [self.client login:self.userNameField.text success:^(NSString *response){
        NSLog(@"This is the successful login block");
        self.loginStatusLabel.text = response;
        
        if (![[[response substringToIndex:11] lowercaseString] isEqualToString:@"loginfailed"]) {
             [self performSegueWithIdentifier: @"SegueToGame" sender: self];
        }
            
    } failure:^{
        NSLog(@"This is the fail login block");
        self.loginStatusLabel.text = @"Unable to login. Check Internet connection";
    }];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //gives this class a reference to the viewController it is about to segue to.
    GameViewController *destination = [segue destinationViewController];
    destination.loginNameText = self.userNameField.text;
    destination.client = self.client;
    
    
    
}

-(IBAction)returned:(UIStoryboardSegue *)segue {
    [self.client logout:^(NSString *response){
        NSLog(@"This is the successful logout block");
        self.loginStatusLabel.text = response;
        
    } failure:^{
        NSLog(@"This is the fail login block");
        self.loginStatusLabel.text = @"Unable to LOGOUT. Check Internet connection";
    }];
}


@end
