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

@property State *prevState;

@property NSNumber *dealerSeatNumber;
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

- (void)newGame {
    
    State *state = self.currentState;
    Player *human = [state.playerStateDict objectForKey:self.humanSeatNumber];
    Player *bot = [state.playerStateDict objectForKey:self.botSeatNumber];
    
    self.nextGameButton.hidden = true;
    self.prevState = nil;
    
    self.betRaiseButton.hidden = true;
    self.checkCallButton.hidden = true;
    self.foldButton.hidden = true;
    
    [self setLabels];
    
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
    [self getOpponentLastActions:NONE actionArray:actions];
    
    [self.pokerTable animate:[actions objectEnumerator]];
    
//    NSLog(@"getting last actions");
//    [self getOpponentLastActions:NONE];
//    NSLog(@"got last actions");
    
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

-(void) getOpponentLastActions:(PlayerAction)humanLastAction actionArray:(NSMutableArray*)actions {
    
    State *state = self.currentState;
    Bot *bot = [state.playerStateDict objectForKey:self.botSeatNumber];
    Player *dealer = [state.playerStateDict objectForKey:self.dealerSeatNumber];
    
    Boolean stateChanged = ![self.currentState.game.gameStage isEqualToString:self.prevState.game.gameStage];
    
    //3 way condition. Game has ended, bot is dealer, or human is dealer.
    if (state.game.gameHasEnded) {
        if (bot.lastActionEnum == CALL) {
            [actions addObject:[PlayerMove moveWithSeat:bot.seat action:bot.lastActionEnum amount:bot.lastActionAmount]];
        }
        //[actions addObject:state.game.gameStage]; !!!!!!!!!!! need to do something here
        NSLog(state.game.gameStage); //starting to do something
        self.nextGameButton.hidden = false;
        
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
    
//    for (id action in actions) {
//        [self setInfoText:action];
//    }
    return ;
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

- (IBAction)actionButtonPress:(id)sender {
    if (![sender isKindOfClass:[UIButton class]])
        return;    
    Player *human = [self.currentState.playerStateDict objectForKey:self.humanSeatNumber];
    NSString *move = [sender currentTitle];  
    
    self.betRaiseButton.hidden = true;
    self.checkCallButton.hidden = true;
    self.foldButton.hidden = true;
    
    NSMutableArray *actions = [NSMutableArray array]; //capactiy???
    
    PlayerAction action = [move PlayerActionEnumFromString];
    [actions addObject:[PlayerMove moveWithSeat:human.seat action:action amount:nil]];
    [self.pokerTable animate:[actions objectEnumerator]];
    
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
    
    NSMutableArray *actions = [NSMutableArray array];    
    [self getOpponentLastActions:[move PlayerActionEnumFromString] actionArray:actions];
    [self.pokerTable animate:[actions objectEnumerator]];
    
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
        case SET_DEALER:
            text = [NSString stringWithFormat:@"Dealer is %@.", player.name];
            break;
        case SMALLBLIND:
        case BIGBLIND:
            text = [NSString stringWithFormat:@"%@ pays %@ of %d.", player.name, actionString, amount];
            break;
        case PREFLOP:
        case FOLD:
        case BET:
        case RAISE:
        case CALL:
        case CHECK:
            text = [NSString stringWithFormat:@"%@ %@s.", player.name, actionString];
            break;
        case FLOP:
        case TURN:
        case RIVER:
            text = [NSString stringWithFormat:@"%@ deals %@.", player.name, actionString];
        default:
            break;
    }
    [self setInfoText:text];    
}
    
@end
