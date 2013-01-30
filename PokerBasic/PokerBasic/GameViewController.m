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
@property (weak, nonatomic) IBOutlet UILabel *botHoleCardsLabel;

@property (weak, nonatomic) IBOutlet UILabel *potLabel;
@property (weak, nonatomic) IBOutlet UILabel *commCardsLabel;

@property (weak, nonatomic) IBOutlet UILabel *playerBetAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerHoleCardsLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerStackLabel;

@property (weak, nonatomic) IBOutlet UIButton *checkCallButton;
@property (weak, nonatomic) IBOutlet UIButton *betRaiseButton;
@property (weak, nonatomic) IBOutlet UIButton *foldButton;
@property (weak, nonatomic) IBOutlet UIButton *nextGameButton;

@property State *currentState;
@property State *prevState;


- (IBAction)actionButtonPress:(id)sender;
- (IBAction)nextGameButtonPress:(id)sender;


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
    NSLog(@"END of View Controller View Did Load");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setLabels {
    
    State *state = self.currentState;
    self.nameOnServerLabel.text = state.player.name;
    
    //self.dealerLabel.text = dealer.name; 1st try
    //self.dealerLabel.text = state.game.dealer; 2nd try
    //3rd try
    if (state.game.botIsDealer) {
        self.dealerLabel.text = state.bot.name;
    } else {
        self.dealerLabel.text = state.player.name;
    }
    
    self.gameStageLabel.text = state.game.gameStage;
    //self.commCardsLabel.text = @"XX XX XX | XX | XX";
    
    NSString *commCards = [[[state.game.communityCards description] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    self.commCardsLabel.text = commCards;
    
    //pay blinds
    self.botBetAmountLabel.text = [NSString stringWithFormat:@"%d", state.bot.currentStageContribution];
    self.playerBetAmountLabel.text = [NSString stringWithFormat:@"%d", state.player.currentStageContribution];
    
    //pay blinds - update stacks
    self.botStackLabel.text = [NSString stringWithFormat:@"%d", state.bot.stack];
    self.playerStackLabel.text = [NSString stringWithFormat:@"%d", state.player.stack];
    
    //pay blinds - update pot
    self.potLabel.text = [NSString stringWithFormat:@"%d", state.game.pot];
    
    //deal cards
    //self.playerHoleCardsLabel.text = [state.player.holeCards objectAtIndex:0];
    self.botHoleCardsLabel.text = [state.bot.holeCards description];
    self.playerHoleCardsLabel.text = [state.player.holeCards description];
}

-(void)displayMoves {
//    NSString *availableMoves = [NSString stringWithFormat:@"Fold, %@", [state.player.validMoves description]];
//    [self setInfoText:availableMoves];
    State *state = self.currentState;
    [self.checkCallButton setTitle:[state.player.validMoves objectAtIndex:0] forState:UIControlStateNormal];
    [self.betRaiseButton setTitle:[state.player.validMoves objectAtIndex:1] forState:UIControlStateNormal];
    
    self.betRaiseButton.enabled = true;
    self.checkCallButton.enabled = true;
    self.foldButton.enabled = true;
}

- (void)newGame {
    NSLog(@"Start of new game");
    
    self.nextGameButton.hidden = true;
    self.prevState = nil;
    
    self.betRaiseButton.enabled = false;
    self.checkCallButton.enabled = false;
    self.foldButton.enabled = false;
    
    State *state = self.currentState;
    [self setLabels];
    
    Player *dealer;
    Player *bigBlind;

    if (state.game.botIsDealer) {
        dealer = state.bot;
        bigBlind = state.player;

    } else {
        dealer = state.player;
        bigBlind = state.bot;

    }
    NSString *dealerString = [NSString stringWithFormat:@"Dealer is %@", dealer.name];
    [self setInfoText:dealerString];
    
    //pay blinds
    NSString *anteString = [NSString stringWithFormat:@"%@ pays small blind of 1\n%@ pays big blind of 2.", dealer.name, bigBlind.name];
    [self setInfoText:anteString];
    
    [self getOpponentLastActions:NONE];
    //NSString* botLastAction = [NSString PlayerActionStringFromEnum:self.currentState.bot.lastAction];
    //[self setInfoText:[NSString stringWithFormat:@"AAXX%@ %@s", self.currentState.bot.name, botLastAction]];
    
    if (!state.game.gameHasEnded) {
        [self displayMoves];
    }

}

-(void) getOpponentLastActions:(PlayerAction)humanLastAction {
    State *state = self.currentState;
    Boolean stateChanged = ![self.currentState.game.gameStage isEqualToString:self.prevState.game.gameStage];
    
    //Game has ended
    if (state.game.gameHasEnded) {
        if (state.bot.lastActionEnum == CALL) {
            [self setInfoText:[NSString stringWithFormat:@"1 %@ %@s", state.bot.name, state.bot.lastActionString]];
        }
        [self setInfoText:state.game.gameStage];
        self.nextGameButton.hidden = false;
        
        return;
    }
    else if (state.game.botIsDealer) //bot goes first preflop, human goes first postflop
    {
        if ([state.game.gameStage isEqualToString:_PREFLOP]) {
            [self setInfoText:[NSString stringWithFormat:@"1 %@ %@s", state.bot.name, state.bot.lastActionString]];
        }
        else if ([self.prevState.game.gameStage isEqualToString:_PREFLOP] && [state.game.gameStage isEqualToString:_FLOP]) {
            if (humanLastAction == RAISE || humanLastAction == BET) {
                [self setInfoText:[NSString stringWithFormat:@"1 %@ %@s", state.bot.name, state.bot.lastActionString]];
            }
            [self setInfoText:state.game.gameStage];
        }
        else if (stateChanged) {
            if ((humanLastAction == CALL || humanLastAction == CHECK) && state.bot.lastActionEnum != CHECK) {
                [self setInfoText:state.game.gameStage];
            } else {
                [self setInfoText:[NSString stringWithFormat:@"1 %@ %@s", state.bot.name, state.bot.lastActionString]];
                [self setInfoText:state.game.gameStage];
            }
        }
        else { //else normal hand postflop with no stateChange
            [self setInfoText:[NSString stringWithFormat:@"1 %@ %@s", state.bot.name, state.bot.lastActionString]];
        }
        
        return;
    }
    else //Human is dealer. human goes first preflop, bot goes first postflop
    {
        if (!self.prevState || humanLastAction == NONE) { //ie player makes very first move    
            return; //don't need to show bots last action. ie "Last Action: Big Blind""
        }
        else if ([self.prevState.game.gameStage isEqualToString:_PREFLOP] && [state.game.gameStage isEqualToString:_FLOP]) {
            if (humanLastAction == BET || humanLastAction == RAISE) {
                [self setInfoText:[NSString stringWithFormat:@"22 %@ %@s", state.bot.name, @"Calls"]];
            } else if (humanLastAction == CALL && self.prevState.bot.lastActionEnum != BET && self.prevState.bot.lastActionEnum != RAISE) { //special preflop case
                [self setInfoText:[NSString stringWithFormat:@"24 %@ %@s bot prev state last action %@ %@", state.bot.name, @"Checks", self.prevState.bot.lastActionString, [NSString PlayerActionStringFromEnum:self.prevState.bot.lastActionEnum]]];
            }
            [self setInfoText:state.game.gameStage];
        }
        else if (stateChanged) {
            if (humanLastAction == BET || humanLastAction == RAISE) {
                [self setInfoText:[NSString stringWithFormat:@"27 %@ %@s", state.bot.name, @"Calls"]];
            }
            [self setInfoText:state.game.gameStage];           
        }
        
        //then always show bots last move (unless player makes very first move)
        [self setInfoText:[NSString stringWithFormat:@"1 %@ %@s", state.bot.name, state.bot.lastActionString]];
        
        return;
    }
}

- (void)setInfoText:(NSString *)text {
    NSString *one = self.infoTextView.text;
    NSString *new = [NSString stringWithFormat:@"%@\n%@", one, text];
    self.infoTextView.text = new;
    [self.infoTextView scrollRangeToVisible:NSMakeRange(new.length, 0)];
    //[TextView scrollRangeToVisible:NSMakeRange([TextView.text length], 0)];
   
}

- (IBAction)actionButtonPress:(id)sender {
    
    self.betRaiseButton.enabled = false;
    self.checkCallButton.enabled = false;
    self.foldButton.enabled = false;
    
    if (![sender isKindOfClass:[UIButton class]])
        return;
    NSString *move = [sender currentTitle];
    
    [self setInfoText:[NSString stringWithFormat:@"%@ %@s", self.currentState.player.name, move]];
    
    self.prevState = self.currentState;
    [self.client playerMove:move success:^(NSDictionary *JSON) {
        
        self.currentState = [[State alloc]initWithAttributes:JSON];
        [self playerActed:move];
        
    }failure:^{
        NSLog(@"Failure in loadState block from gamecontroller");
    }];
    NSLog(@"End of actionButtonPress");
}

- (IBAction)nextGameButtonPress:(id)sender {
    [self startNewHand];
}

-(void) playerActed:(NSString *)move {
    
    [self setLabels];
    
    //else game has not ended
    
    [self getOpponentLastActions:[move PlayerActionEnumFromString]];
    
    //Game has ended
    if (self.currentState.game.gameHasEnded) {
        //[self setInfoText:self.currentState.game.gameStage];
        self.nextGameButton.hidden = false;
        return;
    } else {
        [self displayMoves];
    }
}

-(void) startNewHand {
    
    
    [self.client newGame:^(NSDictionary *JSON) {
        
        self.currentState = [[State alloc]initWithAttributes:JSON];
        [self newGame];
        
    }failure:^{
        NSLog(@"Failure in loadState block from gamecontroller");
    }];
}
    
@end
