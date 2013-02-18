//
//  GameViewController.m
//  PokerBasic
//
//  Created by Samuel Michael Russell Grace on 24/01/13.
//
//

#import "GameViewController.h"

#import "PokerTableView.h"

@interface GameViewController ()
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet UILabel *nameOnServerLabel;
@property (weak, nonatomic) IBOutlet UILabel *dealerLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameStageLabel;

@property (weak, nonatomic) IBOutlet UILabel *botNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *botHoleCardsLabel;

@property (weak, nonatomic) IBOutlet UILabel *commCardsLabel;

@property (weak, nonatomic) IBOutlet UILabel *playerHoleCardsLabel;

@property (weak, nonatomic) IBOutlet UIButton *checkCallButton;
@property (weak, nonatomic) IBOutlet UIButton *betRaiseButton;
@property (weak, nonatomic) IBOutlet UIButton *foldButton;
@property (weak, nonatomic) IBOutlet UIButton *nextGameButton;

@property State *prevState;

@property NSNumber *dealerSeatNumber;
@property NSNumber *humanSeatNumber;
@property NSNumber *botSeatNumber;

@property PokerTableView *pokerTable;
@property (weak, nonatomic) IBOutlet UIImageView *tableImage;

- (IBAction)actionButtonPress:(id)sender;
- (IBAction)nextGameButtonPress:(id)sender;

@end



@implementation GameViewController
static NSInteger numPlayers = 2;

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
    [self.client loadInitialState:^(NSDictionary *JSON) {
        self.currentState = [[State alloc]initWithAttributes:JSON];
        NSLog(@"Initial state: \n %@", JSON);
        [self newGame];        
    }failure:^{
        NSLog(@"Failure in loadState block from gamecontroller");
    }];
    NSLog(@"END of View Controller View Did Load");}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.infoTextView.editable = false;
    self.potLabel.text = 0;
    
    //logout buton replaced with an icon 18.02.2013
//    NSString *logoutButtonText = [NSString stringWithFormat:@"Logout %@", self.loginNameText];
//    [self.logoutButton setTitle:logoutButtonText forState:UIControlStateNormal];
    
    self.botBetAmountLabel.text = @"";
    self.humanBetAmountLabel.text = nil;
    
    self.humanStackLabel.text = @"1000";
    self.botStackLabel.text = @"1000";
    
    self.nameOnServerLabel.text = @"";
    self.botNameLabel.text = nil;
    
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

- (void)newGame {
    
    State *state = self.currentState;
    Player *human = [state.playerStateDict objectForKey:self.humanSeatNumber];
    Player *bot = [state.playerStateDict objectForKey:self.botSeatNumber];
    
    self.nextGameButton.hidden = true;
    self.prevState = nil;
    
    self.betRaiseButton.hidden = true;
    self.checkCallButton.hidden = true;
    self.foldButton.hidden = true;
    
    //[self setLabels]; moved to animations 18.02.2013 SG
    
    Player *bigBlind;
    Player *dealer;
    
    if (state.game.botIsDealer) {
        self.dealerSeatNumber = bot.seat;
        bigBlind = human;
        
    } else {
        self.dealerSeatNumber = human.seat;
        bigBlind = bot;
    }
    dealer = [state.playerStateDict objectForKey:self.dealerSeatNumber];
    
    //pay blinds
    NSInteger sb = 1;
    NSInteger bb = 2;
    
    NSMutableArray *actions = [NSMutableArray array]; //capactiy???
    [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:SET_DEALER amount:nil]];
    [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:SMALLBLIND amount:sb]];
    [actions addObject:[PlayerMove moveWithSeat:bigBlind.seat action:BIGBLIND amount:bb]];
    [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:PREFLOP amount:nil]];
    [self getLastActions:NONE actionArray:actions];
    
    [self.pokerTable animate:[actions objectEnumerator]];
    
    if (!state.game.gameHasEnded) {
        [self displayMoves];
    }
}

//only call this once all human and bot moves have been animated
- (void) updateLabels {
    State *state = self.currentState;
    Human *human = [state.playerStateDict objectForKey:self.humanSeatNumber];
    Bot *bot = [state.playerStateDict objectForKey:self.botSeatNumber];
    
    self.botStackLabel.text = [NSString stringWithFormat:@"%d",bot.stack];
    self.humanStackLabel.text = [NSString stringWithFormat:@"%d",human.stack];
    self.potLabel.text = [NSString stringWithFormat:@"%d",state.game.pot];
    self.botNameLabel.text = bot.name;
    self.nameOnServerLabel.text = human.name;
}


-(void) getLastActions:(PlayerAction)humanLastAction actionArray:(NSMutableArray*)actions {
    
    State *state = self.currentState;
    Human *human = [state.playerStateDict objectForKey:self.humanSeatNumber];
    Bot *bot = [state.playerStateDict objectForKey:self.botSeatNumber];
    Player *dealer = [state.playerStateDict objectForKey:self.dealerSeatNumber];
    
    Boolean stateChanged = ![self.currentState.game.gameStage isEqualToString:self.prevState.game.gameStage];
    
    //// Human move first
    if (humanLastAction != NONE) {
        if (humanLastAction == FOLD) {
            [actions addObject:[PlayerMove moveWithSeat:human.seat action:humanLastAction amount:nil]];
        } else if (!stateChanged) {
            [actions addObject:[PlayerMove moveWithSeat:human.seat action:humanLastAction amount:human.currentStageContribution]];
        } else {//stage change
            if (humanLastAction == CALL) {
                NSInteger amount = [[self.prevState.playerStateDict objectForKey:self.botSeatNumber] currentStageContribution];
                [actions addObject:[PlayerMove moveWithSeat:human.seat action:humanLastAction amount:amount]];
            }else if (humanLastAction == CHECK) {
                [actions addObject:[PlayerMove moveWithSeat:human.seat action:humanLastAction amount:nil]];
            } else if (humanLastAction == BET) {
                NSInteger amount = [[self.prevState.playerStateDict objectForKey:self.humanSeatNumber] currentStageContribution];
                if (state.game.gameStageEnum == PREFLOP || state.game.gameStageEnum == FLOP) {
                    amount = amount + 2;
                } else {
                    amount = amount + 4;
                }
                [actions addObject:[PlayerMove moveWithSeat:human.seat action:humanLastAction amount:amount]];
            } else if (humanLastAction == RAISE) {
                NSInteger amount = [[self.prevState.playerStateDict objectForKey:self.botSeatNumber] currentStageContribution];
                if (state.game.gameStageEnum == PREFLOP || state.game.gameStageEnum == FLOP) {
                    amount = amount + 2;
                } else {
                    amount = amount + 4;
                }
                [actions addObject:[PlayerMove moveWithSeat:human.seat action:humanLastAction amount:amount]];
            }
        }
    }
    ////
    
    //3 way condition. Game has ended, bot is dealer, or human is dealer.
    if (state.game.gameHasEnded) {
        if (bot.lastActionEnum == CALL) {
            [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
        }
        //[actions addObject:state.game.gameStage]; !!!!!!!!!!! need to do something here
        NSLog(state.game.gameStage); //starting to do something
        self.nextGameButton.hidden = false; //need this to be set during animations.
        
        //return;
    }
    else if (state.game.botIsDealer) //bot goes first preflop, human goes first postflop
    {
        if (state.game.gameStageEnum == PREFLOP) {
            [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
        }
        else if (self.prevState.game.gameStageEnum == PREFLOP && state.game.gameStageEnum == FLOP) {
            if (humanLastAction == RAISE || humanLastAction == BET) {
                [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
            }
            [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:FLOP amount:nil]];
        }
        else if (stateChanged) {
            if ((humanLastAction == CALL || humanLastAction == CHECK) && bot.lastActionEnum != CHECK) {
                [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:state.game.gameStageEnum amount:nil]]; //doing it
            } else {
                [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
                [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:state.game.gameStageEnum amount:nil]]; //doing it
            }
        }
        else { //else normal hand postflop with no stateChange
            [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
        }
        
        //return;
    }
    else //Human is dealer. human goes first preflop, bot goes first postflop
    {
        Bot *prevBotState = [self.prevState.playerStateDict objectForKey:self.botSeatNumber];
        if (!self.prevState || humanLastAction == NONE) { //ie player makes very first move
            return ; //don't need to show bots last action. ie "Last Action: Big Blind""
        }
        else if (self.prevState.game.gameStageEnum == PREFLOP && state.game.gameStageEnum == FLOP) {
            if (humanLastAction == BET || humanLastAction == RAISE) {
                //[actions addObject:[NSString stringWithFormat:@"22 %@ %@s", bot.name, @"Calls"]];
                [actions addObject:[PlayerMove moveWithSeat:bot.seat action:CALL amount:2]]; // !!!!!!!!!!!!!!!!!amount
            } else if (humanLastAction == CALL && prevBotState.lastActionEnum != BET && prevBotState.lastActionEnum != RAISE) { //special preflop case
                //[actions addObject:[NSString stringWithFormat:@"24 %@ %@s bot prev state last action %@ %@", bot.name, @"Checks", prevBotState.lastActionString, [NSString PlayerActionStringFromEnum:prevBotState.lastActionEnum]]];
                [actions addObject:[PlayerMove moveWithSeat:bot.seat action:CHECK amount:nil]];
            }
            //[actions addObject:state.game.gameStage]; !!!!!!!!!!! need to do something here
            [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:FLOP amount:nil]];
        }
        else if (stateChanged) {
            if (humanLastAction == BET || humanLastAction == RAISE) {
                //[actions addObject:[NSString stringWithFormat:@"27 %@ %@s", bot.name, @"Calls"]];
                [actions addObject:[PlayerMove moveWithSeat:bot.seat action:CALL amount:4]];
            }
            //[actions addObject:state.game.gameStage]; !!!!!!!!!!! need to do something here
            [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:state.game.gameStageEnum amount:nil]]; //doing it
        }
        
        //then always show bots last move (unless player makes very first move)
        //[actions addObject:[NSString stringWithFormat:@"1 %@ %@s", bot.name, bot.lastActionString]];
        [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
        
        //return;
    }
    

    return ;
}


//TODO put buttons in an array and for loop through possible moves, setting text and making buttons visible as looping through.

-(void)displayMoves {
    [self updateLabels];
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
    } else if (arrayLength == 1) {
        [self.checkCallButton setTitle:[human.validMoves objectAtIndex:0] forState:UIControlStateNormal];
        self.betRaiseButton.hidden = true;
        self.checkCallButton.hidden = false;
        self.foldButton.hidden = false;
    }
    else
    {
        [self setInfoText:[NSString stringWithFormat:@"Error. Valid moves not returned. Array length:%d, Array: %@", arrayLength, [human.validMoves description]]];
    }
}

- (IBAction)actionButtonPress:(id)sender {
    if (![sender isKindOfClass:[UIButton class]])
        return;
    
    self.betRaiseButton.hidden = true;
    self.checkCallButton.hidden = true;
    self.foldButton.hidden = true;

    NSString *move = [sender currentTitle];
     
    PlayerAction action = [move PlayerActionEnumFromString];
    
    [self.client playerMove:move success:^(NSDictionary *JSON) {
        NSLog(@"Player move: %@ \n Game State after player move: \n %@", move, JSON);
        self.prevState = self.currentState;
        self.currentState = [[State alloc]initWithAttributes:JSON];
        
        NSMutableArray *actions = [NSMutableArray array]; //capactiy???
        [self getLastActions:[move PlayerActionEnumFromString] actionArray:actions];
        [self.pokerTable animate:[actions objectEnumerator]];
        [self playerActed:move actionArray:actions];

    }failure:^{
        NSLog(@"Failure in loadState block from gamecontroller");
    }];
}

- (IBAction)nextGameButtonPress:(id)sender {
    self.botBetAmountLabel.text = nil;
    self.humanBetAmountLabel.text = nil;
    [self startNewHand];
}

-(void) playerActed:(NSString *)move actionArray:(NSMutableArray*)actions {
    
    //setLabels being moved to animations. 18.02.2013
    //[self setLabels];
    
    //else game has not ended    
//    NSMutableArray *actions = [NSMutableArray array];
    
    
    
    PlayerMove *moveal;
    for (moveal in actions) {
        NSLog(@"%@", [NSString PlayerActionStringFromEnum:moveal.action]);
    }
    
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

- (void)setInfoText:(NSString *)text {
    //
    //    if ([text isEqualToString:_FLOP] || [text isEqualToString:_TURN] || [text isEqualToString:_RIVER]) {
    //        [self.pokerTable deal:self.currentState.game.communityCards];
    //    }
    
    NSString *one = self.infoTextView.text;
    NSString *new = [NSString stringWithFormat:@"%@\n%@", one, text];
    self.infoTextView.text = new;
    [self.infoTextView scrollRangeToVisible:NSMakeRange(new.length, 0)];
    //[TextView scrollRangeToVisible:NSMakeRange([TextView.text length], 0)];
    
}

//- (void)setActionText:(PlayerAction)action seat:(NSNumber*)seat amount:(NSInteger)amount {
- (void)setMoveText:(PlayerMove*)move  {
    
    Player *player = [self.currentState.playerStateDict objectForKey:move.seat];
    PlayerAction action = move.action;
    NSString *actionString = [NSString PlayerActionStringFromEnum:action];
//    NSString *seat = [move.seat description];
    NSInteger amount = move.betAmount;
    
    
    NSString *text;
    
    switch (action) {
        case CHECK:
        case CALL:
        case BET:
        case RAISE:
            text = [NSString stringWithFormat:@"%@ %@s.", player.name, actionString];
            break;
        case FOLD:
            text = [NSString stringWithFormat:@"%@ %@s.", player.name, actionString];
            break;
        case SMALLBLIND:
        case BIGBLIND:
            text = [NSString stringWithFormat:@"%@ pays %@ of %d.", player.name, actionString, amount];
            break;
        case PREFLOP:
        case FLOP:
        case TURN:
        case RIVER:
            text = [NSString stringWithFormat:@"%@ deals %@.", player.name, actionString];
            break;
        case SET_DEALER:
            text = [NSString stringWithFormat:@"Dealer is %@.", player.name];
            break;
        default:
            text = @"Action not found";
            break;
    }
    [self setInfoText:text];    
}
    
@end
