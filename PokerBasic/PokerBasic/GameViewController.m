//
//  GameViewController.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 24/01/13.
//
//

#import "GameViewController.h"
#import "State.h"
#import "PokerTableView.h"



@interface GameViewController ()
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet UILabel *nameOnServerLabel;
@property (weak, nonatomic) IBOutlet UILabel *dealerLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameStageLabel;

@property (weak, nonatomic) IBOutlet UILabel *botNameLabel;
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
@property NSNumber *humanSeatNumber;
@property NSNumber *botSeatNumber;

@property PokerTableView *pokerTable;
@property (weak, nonatomic) IBOutlet UIImageView *tableImage;

//@property NSMutableArray *moveQueue;

//@property NSArray *seats;
//state.seats array //bot is seat 0, player is seat 1.
//gonna try use botIsDealer to determine dealer. if botIsDealer is true, == 1, seat 0 is dealer. need reverse values.


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

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"In GVC vDL: frame:%@, bounds:%@", NSStringFromCGRect(self.tableImage.frame), NSStringFromCGRect(self.tableImage.bounds));
    self.pokerTable = [[PokerTableView alloc] initWithImage:self.tableImage scene:self];
    
//    self.moveQueue = [NSMutableArray arrayWithCapacity:5];
    
    [self.client loadInitialState:^(NSDictionary *JSON) {
        self.currentState = [[State alloc]initWithAttributes:JSON];
        [self newGame];
        NSLog(@"Initial state: \n %@", JSON);
    }failure:^{
        NSLog(@"Failure in loadState block from gamecontroller");
    }];
    NSLog(@"END of View Controller View Did Load");
    
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.infoTextView.editable = false;
    
    NSString *logoutButtonText = [NSString stringWithFormat:@"Logout %@", self.loginNameText];
    [self.logoutButton setTitle:logoutButtonText forState:UIControlStateNormal];
    
    self.infoTextView.text = [self.client description];
    //[self.client showState];
    
    self.botSeatNumber = @0;
    self.humanSeatNumber = @1;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)setLabels {
    State *state = self.currentState;
    Player *human = [state.playerStateDict objectForKey:self.humanSeatNumber];
    Player *bot = [state.playerStateDict objectForKey:self.botSeatNumber];
    
    self.nameOnServerLabel.text = human.name;
    self.botNameLabel.text = bot.name;
    
    //3rd try - could fix this up better using seat number text.
    if (state.game.botIsDealer) {
        self.dealerLabel.text = bot.name;
    } else {
        self.dealerLabel.text = human.name;
    }
    
    self.gameStageLabel.text = state.game.gameStage;
    
//    NSString *commCards = [[[state.game.communityCards description] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
//    self.commCardsLabel.text = commCards;
    

    self.botBetAmountLabel.text = [NSString stringWithFormat:@"%d", bot.currentStageContribution];
    self.playerBetAmountLabel.text = [NSString stringWithFormat:@"%d", human.currentStageContribution];
    
    self.botStackLabel.text = [NSString stringWithFormat:@"%d", bot.stack];
    self.playerStackLabel.text = [NSString stringWithFormat:@"%d", human.stack];
    
    if (state.game.gameHasEnded) {
        self.potLabel.text = [NSString stringWithFormat:@"%d", state.game.pot];
    } else {
    self.potLabel.text = [NSString stringWithFormat:@"%d", state.game.pot + bot.currentStageContribution + human.currentStageContribution];
    }
    
    //deal cards
    self.botHoleCardsLabel.text = [bot.holeCards description];
    self.playerHoleCardsLabel.text = [human.holeCards description];
}

-(void)displayMoves {
    State *state = self.currentState;
    Human* human = [state.playerStateDict objectForKey:self.humanSeatNumber];
//    Player *bot = [state.seats objectAtIndex:botSeatNumber];
    
    int arrayLength = [human.validMoves count];
    if (arrayLength == 2) {
        [self.checkCallButton setTitle:[human.validMoves objectAtIndex:0] forState:UIControlStateNormal];
        [self.betRaiseButton setTitle:[human.validMoves objectAtIndex:1] forState:UIControlStateNormal];
        self.betRaiseButton.hidden = false;
        self.checkCallButton.hidden = false;
        self.foldButton.hidden = false;
    }
    else
    {
        [self setInfoText:[NSString stringWithFormat:@"Error. Valid moves not returned. Array length:%d, Array: %@", arrayLength, [human.validMoves description]]];
    }
}

- (void)newGame {
    
    
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:10]; //capactiy???
    
    State *state = self.currentState;
    Player *human = [state.playerStateDict objectForKey:self.humanSeatNumber];
    Player *bot = [state.playerStateDict objectForKey:self.botSeatNumber];
    
    self.nextGameButton.hidden = true;
    self.prevState = nil;
    
    self.betRaiseButton.hidden = true;
    self.checkCallButton.hidden = true;
    self.foldButton.hidden = true;
    
    [self setLabels];
    
    Player *dealer;
    Player *bigBlind;

    if (state.game.botIsDealer) {
        dealer = bot;
        bigBlind = human;

    } else {
        dealer = human;
        bigBlind = bot;
    }
    
    [self.pokerTable newGame:human.holeCards dealer:state.game.botIsDealer];
    
    NSString *dealerString = [NSString stringWithFormat:@"Dealer is %@", dealer.name];
    
    [self setInfoText:dealerString];
    
    //pay blinds
    NSInteger sb = 1;
    NSInteger bb = 2;
    
    [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:SMALLBLIND amount:sb]];
    [actions addObject:[PlayerMove moveWithSeat:bigBlind.seat action:BIGBLIND amount:bb]];
    
    [self.pokerTable animate:[actions objectEnumerator]];
    
    
//    NSString *anteString = [NSString stringWithFormat:@"%@ pays small blind of 1\n%@ pays big blind of 2.", dealer.name, bigBlind.name];
//    [self setInfoText:anteString];
    
    [self getOpponentLastActions:NONE];
    
    if (!state.game.gameHasEnded) {
        [self displayMoves];
    }
    
    
//    for (int i =0; i<3; i++) {
//        PlayerMove *move = [[PlayerMove alloc]init];
//        move.seatNumber = i;
//        move.betAmount = i+((i+1)*2);
//        move.action = BET;
//        [self.moveQueue addObject:move];
//    }
//    NSEnumerator *e = [self.moveQueue objectEnumerator];
//    [self.pokerTable animate:e];
}



-(void) getOpponentLastActions:(PlayerAction)humanLastAction {
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:5];
    
    State *state = self.currentState;
    Player *human = [state.playerStateDict objectForKey:self.humanSeatNumber];
    Bot *bot = [state.playerStateDict objectForKey:self.humanSeatNumber];
    
    Boolean stateChanged = ![self.currentState.game.gameStage isEqualToString:self.prevState.game.gameStage];
    
    //3 way condition. Game has ended, bot is dealer, or human is dealer.
    if (state.game.gameHasEnded) {
        if (bot.lastActionEnum == CALL) {
            //[self setInfoText:[NSString stringWithFormat:@"1 %@ %@s", state.bot.name, state.bot.lastActionString]];
            [actions addObject:[NSString stringWithFormat:@"1 %@ %@s", bot.name, bot.lastActionString]];
        }
        [actions addObject:state.game.gameStage];
        self.nextGameButton.hidden = false;
        
        //return;
    }
    else if (state.game.botIsDealer) //bot goes first preflop, human goes first postflop
    {
        if ([state.game.gameStage isEqualToString:_PREFLOP]) {
            [actions addObject:[NSString stringWithFormat:@"1 %@ %@s", bot.name, bot.lastActionString]];
        }
        else if ([self.prevState.game.gameStage isEqualToString:_PREFLOP] && [state.game.gameStage isEqualToString:_FLOP]) {
            if (humanLastAction == RAISE || humanLastAction == BET) {
                [actions addObject:[NSString stringWithFormat:@"1 %@ %@s", bot.name, bot.lastActionString]];
            }
            [actions addObject:state.game.gameStage];
        }
        else if (stateChanged) {
            if ((humanLastAction == CALL || humanLastAction == CHECK) && bot.lastActionEnum != CHECK) {
                [actions addObject:state.game.gameStage];
            } else {
                [actions addObject:[NSString stringWithFormat:@"1 %@ %@s", bot.name, bot.lastActionString]];
                [actions addObject:state.game.gameStage];
            }
        }
        else { //else normal hand postflop with no stateChange
            [actions addObject:[NSString stringWithFormat:@"1 %@ %@s", bot.name, bot.lastActionString]];
        }
        
        //return;
    }
    else //Human is dealer. human goes first preflop, bot goes first postflop
    {
        Bot *prevBotState = [self.prevState.playerStateDict objectForKey:self.botSeatNumber];
        if (!self.prevState || humanLastAction == NONE) { //ie player makes very first move    
            return; //don't need to show bots last action. ie "Last Action: Big Blind""
        }
        else if ([self.prevState.game.gameStage isEqualToString:_PREFLOP] && [state.game.gameStage isEqualToString:_FLOP]) {
            if (humanLastAction == BET || humanLastAction == RAISE) {
                [actions addObject:[NSString stringWithFormat:@"22 %@ %@s", bot.name, @"Calls"]];
            } else if (humanLastAction == CALL && prevBotState.lastActionEnum != BET && prevBotState.lastActionEnum != RAISE) { //special preflop case
                [actions addObject:[NSString stringWithFormat:@"24 %@ %@s bot prev state last action %@ %@", bot.name, @"Checks", prevBotState.lastActionString, [NSString PlayerActionStringFromEnum:prevBotState.lastActionEnum]]];
            }
            [actions addObject:state.game.gameStage];
        }
        else if (stateChanged) {
            if (humanLastAction == BET || humanLastAction == RAISE) {
                [actions addObject:[NSString stringWithFormat:@"27 %@ %@s", bot.name, @"Calls"]];
            }
            [actions addObject:state.game.gameStage];           
        }
        
        //then always show bots last move (unless player makes very first move)
        [actions addObject:[NSString stringWithFormat:@"1 %@ %@s", bot.name, bot.lastActionString]];
        
        //return;
    }
    
    for (id action in actions) {
        [self setInfoText:action];
    }
}

- (void)setInfoText:(NSString *)text {
    
    if ([text isEqualToString:_FLOP] || [text isEqualToString:_TURN] || [text isEqualToString:_RIVER]) {
        [self.pokerTable deal:self.currentState.game.communityCards];
    }
    
    NSString *one = self.infoTextView.text;
    NSString *new = [NSString stringWithFormat:@"%@\n%@", one, text];
    self.infoTextView.text = new;
    [self.infoTextView scrollRangeToVisible:NSMakeRange(new.length, 0)];
    //[TextView scrollRangeToVisible:NSMakeRange([TextView.text length], 0)];
   
}

//- (void)setActionText:(PlayerAction)action seat:(NSNumber*)seat amount:(NSInteger)amount {
- (void)setMoveText:(PlayerMove*)move  {
    
    Player *player = [self.currentState.playerStateDict objectForKey:move.seat];
    NSString *actionString = [NSString PlayerActionStringFromEnum:move.action];
    
    PlayerAction action = move.action;
    switch (move.action) {
        case SET_DEALER:
            <#statements#>
            break;
            
        default:
            break;
    }
    
    NSString *text;
    
    if (action == FLOP || action == TURN || action == RIVER) {
        //[self.pokerTable deal:self.currentState.game.communityCards];
        
        text = [NSString stringWithFormat:@"%@ dealt %@", player.name,  actionString];
    }
    
    NSString *one = self.infoTextView.text;
    NSString *new = [NSString stringWithFormat:@"%@\n%@", one, text];
    self.infoTextView.text = new;
    [self.infoTextView scrollRangeToVisible:NSMakeRange(new.length, 0)];
    //[TextView scrollRangeToVisible:NSMakeRange([TextView.text length], 0)];
    
}

- (IBAction)actionButtonPress:(id)sender {
    
    Player *human = [self.currentState.playerStateDict objectAtIndex:humanSeatNumber];
    Bot *bot = [self.currentState.playerStateDict objectAtIndex:botSeatNumber];
    
    self.betRaiseButton.hidden = true;
    self.checkCallButton.hidden = true;
    self.foldButton.hidden = true;
    
    if (![sender isKindOfClass:[UIButton class]])
        return;
    NSString *move = [sender currentTitle];
    
    [self setInfoText:[NSString stringWithFormat:@"%@ %@s", human.name, move]];
    
    self.prevState = self.currentState;
    [self.client playerMove:move success:^(NSDictionary *JSON) {
        NSLog(@"Player move: %@ \n Game State after player move: \n %@", move, JSON);
        self.currentState = [[State alloc]initWithAttributes:JSON];
        [self playerActed:move];
        
    }failure:^{
        NSLog(@"Failure in loadState block from gamecontroller");
    }];
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

-(void)testBet {
    
   }
    
@end
