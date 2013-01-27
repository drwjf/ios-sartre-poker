//
//  GameViewController.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 24/01/13.
//
//

#import "GameViewController.h"
#import "State.h"

@interface GameViewController ()
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet UILabel *nameOnServerLabel;
@property (weak, nonatomic) IBOutlet UILabel *dealerLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameStageLabel;

@property (weak, nonatomic) IBOutlet UILabel *botStackLabel;
@property (weak, nonatomic) IBOutlet UILabel *botBetAmountLabel;

@property (weak, nonatomic) IBOutlet UILabel *potLabel;
@property (weak, nonatomic) IBOutlet UILabel *commCardsLabel;

@property (weak, nonatomic) IBOutlet UILabel *playerBetAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerHoleCardsLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerStackLabel;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *betButton;
@property (weak, nonatomic) IBOutlet UIButton *raiseButton;
@property (weak, nonatomic) IBOutlet UIButton *foldButton;

@property State *currentState;
@property State *prevState;

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
    self.infoTextView.editable = false;
    
    NSString *logoutButtonText = [NSString stringWithFormat:@"Logout %@", self.loginNameText];
    //self.logoutButton.titleLabel = logoutButtonText;
    [self.logoutButton setTitle:logoutButtonText forState:UIControlStateNormal];
    
    self.infoTextView.text = [self.client description];
    //[self.client showState];
    [self.client loadState:^(NSDictionary *JSON) {

        self.currentState = [[State alloc]initWithAttributes:JSON];
        [self newGame];
        
    }failure:^{
        NSLog(@"Failure in loadState block from gamecontroller");
    }];
    
    //NSLog(self.currentState.player.name, @"HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    NSLog(@"HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)newGame {
    
    State *state = self.currentState;
    self.nameOnServerLabel.text = state.player.name;
    
    //pay blinds - set dealer
    self.dealerLabel.text = state.game.dealer;
    self.gameStageLabel.text = state.game.gameStage;
    self.commCardsLabel.text = @"XX XX XX | XX | XX";
    
    //pay blinds    
    self.botBetAmountLabel.text = [NSString stringWithFormat:@"%d", state.bot.currentStageContribution];
    self.playerBetAmountLabel.text = [NSString stringWithFormat:@"%d", state.player.currentStageContribution];
    
    //pay blinds - update stacks
    self.botStackLabel.text = [NSString stringWithFormat:@"%d", state.bot.stack];
    self.playerStackLabel.text = [NSString stringWithFormat:@"%d", state.player.stack];
    
    //pay blinds - update pot
    self.potLabel.text = [NSString stringWithFormat:@"%d", state.game.pot];
    
    NSString *anteString;
    NSString *dealerString;
    if ([state.game.dealer isEqualToString:_bot]) {
        dealerString = [NSString stringWithFormat:@"Dealer is %@", state.bot.name];
        anteString = [NSString stringWithFormat:@"%@ pays small blind of 1\n%@ pays big blind of 2.", state.bot.name, state.player.name];
    } else {
        dealerString = [NSString stringWithFormat:@"Dealer is %@", state.player.name];
        anteString = [NSString stringWithFormat:@"%@ pays small blind of 1\n%@ pays big blind of 2", state.player.name, state.bot.name];
    }
    [self setInfoText:dealerString];
    [self setInfoText:anteString];

    //deal cards
    //self.playerHoleCardsLabel.text = [state.player.holeCards objectAtIndex:0];
    self.playerHoleCardsLabel.text = [state.player.holeCards description];
    
    
    
}

- (void) setInfoText:(NSString *)text {
    NSString *one = self.infoTextView.text;
    NSString *new = [NSString stringWithFormat:@"%@\n%@", one, text];
    self.infoTextView.text = new;
    [self.infoTextView scrollRangeToVisible:NSMakeRange(new.length, 0)];
    //[TextView scrollRangeToVisible:NSMakeRange([TextView.text length], 0)];
   
}

@end
