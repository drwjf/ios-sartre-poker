//
//  GameViewController.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 24/01/13.
//
//

#import "GameViewController.h"
#import "GameState.h"
#import "Player.h"
#import "Bot.h"


@interface GameViewController ()
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UILabel *loginNameLabel;

@property GameState *gameState;
@property Player *player;
@property Bot *bot;


@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.loginNameLabel.text = self.loginNameText;
    self.infoTextView.text = [self.client description];
    //[self.client showState];
    [self.client loadState:^(NSDictionary *JSON) {
        
        NSDictionary *gameData = [JSON valueForKeyPath:@"GameState"];
        NSDictionary *playerData = [JSON valueForKeyPath:@"Player"];
        NSDictionary *botData = [JSON valueForKeyPath:@"Bot"];
        
        
        self.player = [[Player alloc]initWithAttributes:playerData];
        self.bot = [[Bot alloc]initWithAttributes:botData];
        self.gameState = [[GameState alloc]initWithAttributes:gameData];
        
        NSLog(self.gameState.toString);
        NSLog(self.player.toString);
        NSLog(self.bot.toString);
        
    }failure:^{
        NSLog(@"Failure in loadState block from gamecontroller");
    }];
    
    NSLog(self.player.name, @"HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
