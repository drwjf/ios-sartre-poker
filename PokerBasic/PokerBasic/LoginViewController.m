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
    self.loginStatusLabel.text = @"";
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
    
    [self.userNameField resignFirstResponder];
    
    if ([self checkUserName]) {
    
        self.loginStatusLabel.text = @"Connecting…";
        
        NSString *username = self.userNameField.text;
        //NSString* resultText = [result stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
        NSString *loginName = [username stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding ];
        NSLog(@"Percent escape login name: %@", loginName);

        [self.client login:loginName success:^(NSString *response){
            NSLog(@"This is the successful login block");
            //self.loginStatusLabel.text = response;
            
            if (![[[response substringToIndex:11] lowercaseString] isEqualToString:@"loginfailed"]) {
                 [self performSegueWithIdentifier: @"SegueToGame" sender: self];
            } else if ([response rangeOfString:@"InvalidUserName"].location != NSNotFound) {
                self.loginStatusLabel.text = @"User name cannot contain special characters.";
            } else {
                self.loginStatusLabel.text = response;
            }
        } failure:^{
            NSLog(@"This is the fail login block");
            self.loginStatusLabel.text = @"Unable to connect. Check Internet connection.";
        }];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"SegueToGame"]) {
        //gives this class a reference to the viewController it is about to segue to.
        GameViewController *destination = [segue destinationViewController];
        destination.loginNameText = self.userNameField.text;
        destination.client = self.client;
    }
}

-(IBAction)returned:(UIStoryboardSegue *)segue {
    self.loginStatusLabel.text = nil;
    [self.client logout:^(NSString *response){
        NSLog(@"This is the successful logout block");
        //self.loginStatusLabel.text = response;
        //self.loginStatusLabel.text = @"Thank-you for playing.";
        
        
    } failure:^{
        NSLog(@"This is the fail login block");
        self.loginStatusLabel.text = @"Unable to log out. Check Internet connection";
    }];
    
    
    if ([[segue identifier] isEqualToString:@"SegueToGame"]) {
        
    }
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    if (theTextField == self.userNameField) {        
        [theTextField resignFirstResponder];
        [self checkUserName];
    }
    return YES;
}

- (BOOL) checkUserName {
    if([self.userNameField.text length] == 0) {
        self.loginStatusLabel.text = @"Please enter a user name.";
        return false;
    }
    else if ([self.userNameField.text length] > 15)
    {
        self.loginStatusLabel.text = @"User Name must be less than 16 characters.";
        return false;
    }
    return true;
}

@end
