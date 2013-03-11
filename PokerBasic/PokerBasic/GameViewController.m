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


@property (weak, nonatomic) IBOutlet UILabel *dealerLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameStageLabel;

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

@property NSInteger handCount;

@property PokerTableView *pokerTable;
@property (weak, nonatomic) IBOutlet UIImageView *tableImage;
@property BOOL scrollTextViewToEnd;

- (IBAction)actionButtonPress:(id)sender;
- (IBAction)nextGameButtonPress:(id)sender;

@end



@implementation GameViewController

static NSUInteger smallBet = 2;
static NSUInteger bigBet = 4;

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
    self.potLabel.text = nil;
    self.handCount = 1;
    
    //logout buton replaced with an icon 18.02.2013
//    NSString *logoutButtonText = [NSString stringWithFormat:@"Logout %@", self.loginNameText];
//    [self.logoutButton setTitle:logoutButtonText forState:UIControlStateNormal];
    
    self.botBetAmountLabel.text = @"";
    self.humanBetAmountLabel.text = nil;
    
    self.humanStackLabel.text = @"";
    self.botStackLabel.text = nil;
    
    self.nameOnServerLabel.text = @"";
    self.botNameLabel.text = nil;
    
    self.humanWinLabel.text = nil;
    self.botWinLabel.text = nil;
    
    self.infoTextView.text = nil;
    //self.infoTextView.text = [self.client description];
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
    
    self.nameOnServerLabel.text = human.name;
    self.botNameLabel.text = bot.name;
    
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
    
    [self.pokerTable animate:[actions objectEnumerator]]; //this shows buttons at end
}

-(void) getLastActions:(PlayerAction)humanLastAction actionArray:(NSMutableArray*)actions {
    
    State *state = self.currentState;
    Human *human = [state.playerStateDict objectForKey:self.humanSeatNumber];
    Bot *bot = [state.playerStateDict objectForKey:self.botSeatNumber];
    Player *dealer = [state.playerStateDict objectForKey:self.dealerSeatNumber];
    
    Boolean stateChanged = ![self.currentState.game.gameStage isEqualToString:self.prevState.game.gameStage];//final bot move happens in a new state.
    
    //// ALways get the human move first
    if (humanLastAction != NONE) {
        if (humanLastAction == FOLD) {
            [actions addObject:[PlayerMove moveWithSeat:human.seat action:humanLastAction amount:nil]];
        } else if (!stateChanged) {
            [actions addObject:[PlayerMove moveWithSeat:human.seat action:humanLastAction amount:human.currentStageContribution]];
        } else {//stage change
            if (humanLastAction == BET) {
                NSInteger amount = [[self.prevState.playerStateDict objectForKey:self.humanSeatNumber] currentStageContribution];
                //if (state.game.gameStageEnum == PREFLOP || state.game.gameStageEnum == FLOP) {
                if (self.prevState.game.gameStageEnum == PREFLOP || self.prevState.game.gameStageEnum == FLOP) {
                    amount = amount + smallBet;
                } else {
                    amount = amount + bigBet;
                }
                [actions addObject:[PlayerMove moveWithSeat:human.seat action:humanLastAction amount:amount]];
            } else if (humanLastAction == RAISE) {
                NSInteger amount = [[self.prevState.playerStateDict objectForKey:self.botSeatNumber] currentStageContribution];
                //if (state.game.gameStageEnum == PREFLOP || state.game.gameStageEnum == FLOP) {
                if (self.prevState.game.gameStageEnum == PREFLOP || self.prevState.game.gameStageEnum == FLOP) {
                    amount = amount + smallBet;
                } else {
                    amount = amount + bigBet;
                }
                [actions addObject:[PlayerMove moveWithSeat:human.seat action:humanLastAction amount:amount]];
            } else { //Human last action was Check or Call or FOLD
                [actions addObject:[PlayerMove moveWithSeat:human.seat action:humanLastAction amount:nil]];
            }
        }
    }
    ////
    
    //3 way condition. Game has ended, bot is dealer, or human is dealer.
    if (state.game.gameHasEnded) {
        if (humanLastAction == FOLD) {            
            [actions addObject:[PlayerMove moveWithSeat:self.botSeatNumber action:WIN amount:nil]]; //bot wins.
        } else if (bot.lastActionEnum == FOLD) {
            [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
            [actions addObject:[PlayerMove moveWithSeat:self.humanSeatNumber action:WIN amount:nil]]; //human wins.             
        } else { //went to showdown
        //else if (bot.lastActionEnum == CALL || humanLastAction == CALL) { //bot called on river to end game
            NSLog(@"Game ended with showdown");
            if (!state.game.botIsDealer && humanLastAction==CHECK) {
                //No bot move
            }
            else if (humanLastAction != CALL) { //if human didn;t call, bot made last move
                [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
            }
            [actions addObject:[PlayerMove moveWithSeat:nil action:SHOWDOWN amount:nil]]; //need win animation. Winnder undecided
        }
        
//        if (bot.lastActionEnum == FOLD) {
//            [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
//        }
//        //[actions addObject:state.game.gameStage]; !!!!!!!!!!! need to do something here
//        NSLog(state.game.gameStage); //starting to do something

        return;
    }
    else if (state.game.botIsDealer) //bot goes first preflop, human goes first postflop
    {
        if (state.game.gameStageEnum == PREFLOP) {
            NSInteger amount = bot.lastActionAmount;
            [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:amount]];
        }
        else if (self.prevState.game.gameStageEnum == PREFLOP && state.game.gameStageEnum == FLOP) {
            if (humanLastAction == RAISE || humanLastAction == BET) {
                [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
            }
            [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:FLOP amount:nil]]; //DEAL
        }
        else if (stateChanged) {
            if ((humanLastAction == CALL || humanLastAction == CHECK) && bot.lastActionEnum != CHECK) {
                [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:state.game.gameStageEnum amount:nil]]; //DEAL
            } else {
                [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
                [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:state.game.gameStageEnum amount:nil]]; //DEAL
            }
        }
        else { //else normal hand postflop with no stateChange
            [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
        }
        return;
    }
    else //Human is dealer. human goes first preflop, bot goes first postflop
    {
        Bot *prevBotState = [self.prevState.playerStateDict objectForKey:self.botSeatNumber];
        if (!self.prevState || humanLastAction == NONE) { //ie player makes very first move
            return; //don't need to show bots last action. ie "Last Action: Big Blind""
        }
        else if (self.prevState.game.gameStageEnum == PREFLOP && state.game.gameStageEnum == FLOP) {
            if (humanLastAction == BET || humanLastAction == RAISE) {
                [actions addObject:[PlayerMove moveWithSeat:bot.seat action:CALL amount:smallBet]];
            } else if (humanLastAction == CALL && prevBotState.lastActionEnum != BET && prevBotState.lastActionEnum != RAISE) {
                //special preflop case. bot checks in big blind
                [actions addObject:[PlayerMove moveWithSeat:bot.seat action:CHECK amount:nil]];
            }
            [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:FLOP amount:nil]]; //DEAL
        }
        else if (stateChanged) {
            if (humanLastAction == BET || humanLastAction == RAISE) {
                [actions addObject:[PlayerMove moveWithSeat:bot.seat action:CALL amount:bigBet]];
            }
            [actions addObject:[PlayerMove moveWithSeat:dealer.seat action:state.game.gameStageEnum amount:nil]]; //DEAL
        }
        //then always show bots last move (unless player makes very first move, in which case we returned at the start of the outer else block)
        [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
        
        return;
    }
}


//OPTIONAL IMPROV put buttons in an array and for loop through possible moves, setting text and making buttons visible as looping through.
-(void)displayMoves {    
    //TODO do a comparison of pot size from server state with table state.
    State *state = self.currentState;
    Human* human = [state.playerStateDict objectForKey:self.humanSeatNumber];
    
    int arrayLength = [human.validMoves count];
    if (arrayLength == 2) {
        [self.checkCallButton setTitle:[human.validMoves objectAtIndex:0] forState:UIControlStateNormal]; //index is 0 is bet raise
        [self.betRaiseButton setTitle:[human.validMoves objectAtIndex:1] forState:UIControlStateNormal]; // index 1 is check call
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
    
    [self.client playerMove:move success:^(NSDictionary *JSON) {
        NSLog(@"Player move: %@ \n Game State after player move: \n %@", move, JSON);
        self.prevState = self.currentState;
        self.currentState = [[State alloc]initWithAttributes:JSON];
        
        NSMutableArray *actions = [NSMutableArray array]; //capactiy???
        [self getLastActions:[move PlayerActionEnumFromString] actionArray:actions];
        [self.pokerTable animate:[actions objectEnumerator]];
        
        //debugging
        PlayerMove *moveal;
        for (moveal in actions) {
            NSLog(@"So we get here ?  %@", [NSString PlayerActionStringFromEnum:moveal.action]);
        }

    }failure:^{
        NSLog(@"Failure in loadState block from gamecontroller");
    }];        
}

- (IBAction)nextGameButtonPress:(id)sender {
    self.handCount++;    
    self.botBetAmountLabel.text = nil;
    self.humanBetAmountLabel.text = nil;
    self.potLabel.text = nil;    
    self.humanWinLabel.text = nil;
    self.botWinLabel.text = nil;
    
    self.infoTextView.text = nil;
    
    [self setInfoText:@""];
    
    [self.client newGame:^(NSDictionary *JSON) {        
        self.currentState = [[State alloc]initWithAttributes:JSON];
        [self newGame];
    }failure:^{
        NSLog(@"Failure in loadState block from gamecontroller");
    }];
}

//-(void) playerActed:(NSString *)move actionArray:(NSMutableArray*)actions {
-(void) animationsDone {
    
    //Game has ended
    if (self.currentState.game.gameHasEnded) {
        //[self setInfoText:self.currentState.game.gameStage];
        self.nextGameButton.hidden = false;
        [self showhumanWinRate];
        return;
    } else {
        [self displayMoves];
        
    }
}

- (void)setInfoText:(NSString *)text {
    //
    //    if ([text isEqualToString:_FLOP] || [text isEqualToString:_TURN] || [text isEqualToString:_RIVER]) {
    //        [self.pokerTable deal:self.currentState.game.communityCards];
    //    }
    
    NSString *one = self.infoTextView.text;
    NSString *new;
    if (one.length > 0) {
        new = [NSString stringWithFormat:@"%@\n%@", one, text];
    } else {
        new = text;
    }
    self.infoTextView.text = new;
    
    if (self.scrollTextViewToEnd) {
        [self.infoTextView scrollRangeToVisible:NSMakeRange(new.length, 0)];
        //[TextView scrollRangeToVisible:NSMakeRange([TextView.text length], 0)];
    } else {
        [self.infoTextView scrollRangeToVisible:NSMakeRange(0, 4)];
    }
    
}

//- (void)setActionText:(PlayerAction)action seat:(NSNumber*)seat amount:(NSInteger)amount {
- (void)setMoveText:(PlayerMove*)move  {
    Player *player = [self.currentState.playerStateDict objectForKey:move.seat];
    PlayerAction action = move.action;
    NSString *actionString = [NSString PlayerActionStringFromEnum:action];
    NSInteger amount = move.betAmount;
    
    self.scrollTextViewToEnd = true; //used to stop first text scrolling to bottom
    
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
            self.scrollTextViewToEnd = false;
            text = [NSString stringWithFormat:@"%@ pays %@ of %d.", player.name, actionString, amount];
            break;
        case PREFLOP:
        case FLOP:
        case TURN:
        case RIVER:
        case SHOWDOWN:
            text = [NSString stringWithFormat:@"=== %@ ===", actionString];
            break;
        case SET_DEALER:
            self.scrollTextViewToEnd = false;
            text = [NSString stringWithFormat:@"Hand #%d. Dealer is %@.", self.handCount, player.name];
            break;
        case WIN:
            text = [NSString stringWithFormat:@"Winner is %@.", player.name];
            break;
        default:
            text = @"Player Move Action not found in setMoveText";
            break;
    }
    [self setInfoText:text];    
}

- (void)showhumanWinRate {
    //Player *human = [self.currentState.playerStateDict objectForKey:self.humanSeatNumber];
    float profit = [self.humanStackLabel.text integerValue] - 1000;
    float winrate = (profit / smallBet) /self.handCount;
    //NSString *text = [NSString stringWithFormat:@"\n%@ Win Rate: %.2f SB/Hand.", human.name, winrate];
    NSString *text = [NSString stringWithFormat:@"Win Rate: %.2f SB/Hand.", winrate];
    [self setInfoText:text];
}
    
@end
