//
//  PokerTableViewController.m
//  
//
//  Created by Samuel Michael Russell Grace on 1/02/13.
//
//

#import "PokerTableView.h"
#import "PlayerMove.h"

@interface playerInfo:NSObject
@property NSNumber *seat;
@property NSInteger betAmount;
@property NSInteger stackFromPreviousStreets;
@property NSInteger stackCurrent;
@property CGPoint centre;
@property CGPoint chipPoint;
//@property int holeCardOneIndex;
//@property int holeCardTwoIndex;
@property UIImageView *card1;
@property UIImageView *card2;
@property UILabel *stackLabel;
@property UILabel *betAmountLabel;
@property UILabel *winLabel;
//@property Player *playerState; //reference unnecessary????
@end
@implementation playerInfo
@end





@interface PokerTableView ()

@property (weak, nonatomic) IBOutlet UIImageView *table;
@property NSMutableArray *tableChips;
@property NSMutableArray *tableCards;
@property NSDictionary *playerInfoDict; //bot is seat 0, player is seat 1.
@property NSEnumerator *animationEnumerator;
@property GameViewController *scene;

//Game state
@property NSInteger potFromPreviousStreets;
@property NSNumber *humanSeatNumber;
@property NSNumber *botSeatNumber;
@property NSNumber *dealerSeat;

@property UIImageView *button;

@end

@implementation PokerTableView

static int numPlayers = 2;
static int startingStack = 1000;
//static int BOT_SEAT = 0;
//static int HUMAN_SEAT = 1;


static UIImage *cardBackImage;
static UIImage *chipImage;

static CGPoint deckLocation;
static CGPoint potLocation;
static CGPoint communityCardsCentre;

static CGFloat screenWidth;
static CGFloat screenHeight;

static int cardWidth = 46;
static int cardHeight = 46;

static int distanceBetweenHoleCards = 27;
static int edgeOffset = 30;

static int xDistanceOfDealerButtonFromPlayer = 100;

- (id)initWithImage:(UIImageView *) tableImage scene:(GameViewController *)scene
{
    self = [self init];
    if (self) {
        
        _table = tableImage;
        _scene = scene;
        NSLog(@"Init table controller with table");
        screenWidth = self.table.bounds.size.width;
        screenHeight = self.table.bounds.size.height;
        communityCardsCentre = CGPointMake(screenWidth/2 - 20, screenHeight/2);
        
        deckLocation  = CGPointMake(25, screenHeight/2);
        potLocation  = CGPointMake(screenWidth-100, screenHeight/2);
        
        self.botSeatNumber = @0;
        self.humanSeatNumber = @1;
        
        playerInfo *human;
        human = [[playerInfo alloc] init];
        human.centre = CGPointMake(screenWidth/2, screenHeight - edgeOffset); //height = 300 not 320 (when status bar is showing)
        human.chipPoint = CGPointMake(human.centre.x - 15, human.centre.y-50);
        human.seat = self.humanSeatNumber;
        human.betAmountLabel = scene.humanBetAmountLabel;
        human.stackLabel = scene.humanStackLabel;
        human.betAmount = 0;
        human.stackCurrent = startingStack;
        human.stackLabel.text = [NSString stringWithFormat:@"%d",human.stackCurrent];
        human.winLabel = scene.humanWinLabel;
        //human.playerState = [scene.currentState.playerStateDict objectForKey:human.seat];
        
        playerInfo *bot;
        bot = [[playerInfo alloc] init];
        bot.centre = CGPointMake(screenWidth/2, 0 + edgeOffset);
        bot.chipPoint = CGPointMake(bot.centre.x + 15, bot.centre.y+50);
        bot.seat = self.botSeatNumber;
        bot.betAmountLabel = scene.botBetAmountLabel;
        bot.stackLabel = scene.botStackLabel;
        bot.betAmount = 0;
        bot.stackCurrent = startingStack;
        bot.stackLabel.text = [NSString stringWithFormat:@"%d",bot.stackCurrent];
        bot.winLabel = scene.botWinLabel;
        //bot.playerState = [scene.currentState.playerStateDict objectForKey:bot.seat];
        
        self.playerInfoDict = [NSDictionary dictionaryWithObjectsAndKeys: bot, bot.seat, human, human.seat, nil];
        
        _tableChips = [NSMutableArray array];
        _tableCards = [NSMutableArray arrayWithCapacity:9];
        
        //card on bottom of deck, that is purely visual
        [self.table addSubview:[self makeCard]];
        [self.tableCards removeLastObject]; //remove card from array so it always stays on table. (Make card automatically adds it).
    
        
        self.button = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dealer_button.png"]];
        [self.button setFrame:CGRectMake(screenWidth/2, screenHeight/2,20,20)];
        [self.table addSubview:self.button];
    }
    return self;    
}

- (void)animate:(NSEnumerator *)enumerator {
    self.animationEnumerator = enumerator;
    [self doAnimations];
}

/*
Method that gets called by animte, and then again each time an animtion finishes.
 Each time enumerates through a single animation.
 When no more animtions calls back to th Game View Controller Scene.
*/
- (void)doAnimations {
    NSLog(@"Do animations");

    PlayerMove* move;
    if (move = [self.animationEnumerator nextObject]) {
        
        NSNumber* seat = move.seat;
        NSInteger amount = move.betAmount;
        PlayerAction action = move.action;
        NSLog(@"Doing animation for %@ %@", [seat description], [NSString PlayerActionStringFromEnum:action]);
        
        switch (action) {
            case CHECK:
                [self check:seat];
                break;
            case CALL:
                [self call:seat];
                break;
            case BET:
            case RAISE:
                [self bet:amount seat:seat];
                break;
            case FOLD:
                [self fold:seat];
                break;
            case SMALLBLIND:
            case BIGBLIND:
                [self bet:amount seat:seat];
                break;
            case PREFLOP:
                [self holeCards];
                break;
            case FLOP:
            case TURN:
            case RIVER:
                [self dealCommCards:action];
                break;
            case SHOWDOWN:
                [self showDown];
                break;
            case SET_DEALER:
                [self setDealer:seat];
                break;
            case WIN:
                [self win:seat];
                break;
            default:
                NSLog(@"action not found");
                break;                
        }
        [self.scene setMoveText:move];
        
    } else {
        [self.scene animationsDone];
    }
}

//clears board for a new game and moves the dealer chip to the dealer.
- (void)setDealer:(NSNumber*) seat {
    
    self.potFromPreviousStreets = 0;
    playerInfo *player;
    for (NSNumber *seat in self.playerInfoDict) {
        player = [self.playerInfoDict objectForKey:seat];
        player.stackFromPreviousStreets = player.stackCurrent;
    }
    
    self.dealerSeat = seat;
    playerInfo* dealer = [self.playerInfoDict objectForKey:seat];
    NSInteger yOffset = -12;
    if ([seat isEqualToNumber:self.botSeatNumber]) {
        yOffset *= -1;
    }
    
    CGPoint dealerCenter = dealer.centre;
    CGPoint buttonLocation = CGPointMake(dealerCenter.x - xDistanceOfDealerButtonFromPlayer, dealerCenter.y + yOffset);
    [UIView animateWithDuration:0.3 delay:0  options:UIViewAnimationOptionCurveEaseInOut animations:^{
        UIImageView *card;
        for (card in self.tableCards) {
            [card setAlpha:0];
        }
        [self.tableCards removeAllObjects];
        UIImageView *chip;
        for (chip in self.tableChips) {
            [chip setAlpha:0];
        }
        [self.tableChips removeAllObjects];
    }completion:^(BOOL done) {
        [UIView animateWithDuration:0.5 animations:^{
            self.button.center = buttonLocation;
        }completion:^(BOOL done) {
            [self doAnimations];
        }];
    }];
}

//animates hole cards being dealt. Once they are dealt, animates human players hole cards being revealed
- (void)holeCards{
    NSInteger dealeeSeatInt = [self.dealerSeat integerValue];
    
    int xoffset = -(distanceBetweenHoleCards / 2);
    int count = 0;
    for (int j=0; j < 2; j++) { //change the x offset every 2 cards dealt
        xoffset *= -1;
        for (int i = 0; i < 2; i++) {
            dealeeSeatInt = (dealeeSeatInt + 1 ) % numPlayers;
            NSNumber *seatNum = [NSNumber numberWithInt:dealeeSeatInt];
            playerInfo *dealee = [self.playerInfoDict objectForKey: seatNum];
            
            CGPoint dealPoint = dealee.centre;
            dealPoint.x += xoffset;
            
            UIImageView *card = [self makeCard];
            if (j) {
                dealee.card1 = card;
            } else {
                dealee.card2 = card;
            }
            
            
            [UIView animateWithDuration:0.8 delay:(0.2*count++) options:
             UIViewAnimationCurveEaseIn animations:^{
                 card.center = dealPoint;
                 NSLog(@"Dealing to player %d: %f,%f", i, dealPoint.x, dealPoint.y);
                 
             }completion:^(BOOL done){
                 NSLog(@"count: %d",count);
                 if (count==4) {
                     
                     Player *player = [self.scene.currentState.playerStateDict objectForKey:self.humanSeatNumber];
                     NSArray *holeCards = player.holeCards;
                     
                     playerInfo *human = [self.playerInfoDict objectForKey: self.humanSeatNumber];
                     
                     NSString* humanHoleCard1 = [holeCards objectAtIndex:0];
                     NSString* humanHoleCard2 = [holeCards objectAtIndex:1];
                     
                     UIImageView* cardView1 = human.card1;
                     UIImageView* cardView2 = human.card2;
                     
                     //[UIView transitionWithView:cardView1 duration:0.4f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                     [UIView transitionWithView:cardView1 duration:0.4f options:UIViewAnimationOptionTransitionNone animations:^{
                         [cardView1 setImage:[self getCardFrontImage:humanHoleCard1]];
                         
                     } completion:nil];
                     
                     [UIView transitionWithView:cardView2 duration:0.4f options:UIViewAnimationOptionTransitionNone animations:^{
                         [self.table bringSubviewToFront:cardView2];
                         [cardView2 setImage:[self getCardFrontImage:humanHoleCard2]];
                         
                     } completion:^(BOOL done) {
                         NSLog(@"Card images set");
                         [self doAnimations];
                     }];
                 }
             }];
        }
    }
}

- (void)clearBetAmountLabels {
    //clearBetAmountLabels
    playerInfo *player;
    for (NSString *key in self.playerInfoDict) {
        player = [self.playerInfoDict objectForKey:key];
        player.betAmountLabel.text = @"";
    }
}

//resets playerInfo betAmounts to 0.
//moves all chips bet in current round to the side.
//clear betAmountLabels when done.
- (void)dealCommCards:(PlayerAction)action {
    
    //update potsize with current bet amounts
    self.potFromPreviousStreets = [self getPotSize];
    
    //THEN reset bet amounts
    playerInfo *player;
    for (NSNumber *key in self.playerInfoDict) {
        player = [self.playerInfoDict objectForKey:key];
        //update stackFromPreviousStreet using bet amount, before resetting betAmount
        player.stackFromPreviousStreets -= player.betAmount;
        player.betAmount = 0;
    }
    
    [UIView animateWithDuration:0.8 delay:0 options:nil animations:^{
        UIImageView *chip;
        for (chip in self.tableChips) {
            [chip setCenter:potLocation];
        }
    }completion:^(BOOL finished) {        
        [self clearBetAmountLabels];
        switch (action) {
            case FLOP:
                [self flop];
                break;
            case TURN:
                [self turn];
                break;
            case RIVER:
                [self river];
                break;
            default:
                return;
        }
    }];
}

- (IBAction)flop{
    NSArray *flopCardValues = self.scene.currentState.game.communityCards;
    NSMutableArray *flopCards = [NSMutableArray arrayWithCapacity:3];
    
    CGPoint dealPoint = communityCardsCentre;
    for (int i = 0; i < 3; i++) {
        UIImageView *card = [self makeCard];
        [flopCards addObject:card];
        [UIView animateWithDuration:0.8 delay:(0.2*i) options:
         UIViewAnimationCurveEaseIn animations:^{
             card.center = dealPoint;
             NSLog(@"Dealing flop card %d: ", i+1);
         }completion:^(BOOL done){
             if (i==2) { //show cards once final card has been dealt
                 for (int j = 0; j < 3; j++) {
                     UIImageView *card = [flopCards objectAtIndex:j];
                     NSString* cardString = [flopCardValues objectAtIndex:j];
                     [card setImage:[self getCardFrontImage:cardString]];
                 }
             }
             [self doAnimations];
         }];
        dealPoint.x -= cardWidth;
    }
}
- (void)turn {
    NSArray *communityCardValues = self.scene.currentState.game.communityCards;
    
    CGPoint dealPoint = communityCardsCentre;
    dealPoint.x += cardWidth;
    
    UIImageView *card = [self makeCard];
    [UIView animateWithDuration:0.8 delay:(0.0) options:
     UIViewAnimationCurveEaseIn animations:^{
         //         [self.table bringSubviewToFront:card];
         card.center = dealPoint;
         NSLog(@"Dealing turn card ");
     }completion:^(BOOL done){
         NSString* cardString = [communityCardValues objectAtIndex:3];
         [card setImage:[self getCardFrontImage:cardString]];
         [self doAnimations];
     }];
}
- (void)river {    
    NSArray *communityCardValues = self.scene.currentState.game.communityCards;
    CGPoint dealPoint = communityCardsCentre;
    dealPoint.x += 2*cardWidth;
    
    //UIImageView *card = [_tableCards objectAtIndex:0];
    UIImageView *card = [self makeCard];
    //[self.table bringSubviewToFront:card];
    [UIView animateWithDuration:0.8 delay:(0.0) options:
     UIViewAnimationCurveEaseIn animations:^{
         card.center = dealPoint;
         NSLog(@"Dealing river card ");
     }completion:^(BOOL done){
         //UIImageView *card = [_tableCards objectAtIndex:0];
         NSString* cardString = [communityCardValues objectAtIndex:4];
         [card setImage:[self getCardFrontImage:cardString]];
         [self doAnimations];
     }];
}



-(void)call:(NSNumber*) seat {
    NSInteger amount = 0;
    playerInfo *player;
    for (NSString *key in self.playerInfoDict) {
        player = [self.playerInfoDict objectForKey:key];
        if (player.betAmount > amount) {
            amount = player.betAmount;
        }
    }    
    [self bet:amount seat:seat];
}

- (void)fold:(NSNumber*) seat {
    
    playerInfo* player = [self.playerInfoDict objectForKey:seat];
    CGPoint currentPoint1 = player.card1.center;
    CGPoint currentPoint2 = player.card2.center;
    
    NSInteger foldYDist = 20;
    if ([seat isEqualToNumber:self.humanSeatNumber]) {
        foldYDist *= -1;
        [player.card1 setImage:cardBackImage];
        [player.card2 setImage:cardBackImage];
    }
    
    [self.table bringSubviewToFront:player.card1];
    [self.table bringSubviewToFront:player.card2];
    [UIView animateWithDuration:0.5 delay:0  options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [player.card1 setCenter:CGPointMake(currentPoint1.x, currentPoint1.y + foldYDist)];
        player.card1.transform = CGAffineTransformMakeRotation(M_PI);
        [player.card2 setCenter:CGPointMake(currentPoint2.x, currentPoint2.y + foldYDist)];
        player.card2.transform = CGAffineTransformMakeRotation(300);
        
    }completion:^(BOOL done) {
        [self doAnimations];
    }];
    
}

-(void)check:(NSNumber*)seat {
    
    playerInfo* player = [self.playerInfoDict objectForKey:seat];
    CGPoint currentPoint1 = player.card1.center;
    CGPoint currentPoint2 = player.card2.center;
    
    NSInteger delay = 0;
    if ([seat isEqualToNumber:self.botSeatNumber]) {
        delay = 0.3;
    }
         
    [UIView animateWithDuration:0.3 delay:delay  options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [player.card1 setCenter:CGPointMake(currentPoint1.x - 5, currentPoint1.y)];
        [player.card2 setCenter:CGPointMake(currentPoint2.x - 5, currentPoint2.y)];
        
    }completion:^(BOOL done) {
        [UIView animateWithDuration:0.3 delay:0.1  options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [player.card1 setCenter:currentPoint1];
            [player.card2 setCenter:currentPoint2];
        }completion:nil];
        [self doAnimations];
    }];
}

-(void)bet:(NSInteger)amount seat:(NSNumber*)seat {
    
    playerInfo *bettor = [self.playerInfoDict objectForKey:seat];
    bettor.betAmount = amount; //not += because amount is total current stage amount. ??? check
    bettor.stackCurrent = bettor.stackFromPreviousStreets - bettor.betAmount;
    
    if (!chipImage) {
        chipImage = [UIImage imageNamed:@"blackChip.png"];
    }
    
    UIImageView *chipView = [[UIImageView alloc]initWithImage:chipImage];
    [self.tableChips addObject:chipView];
    chipView.contentMode = UIViewContentModeScaleAspectFill;
    [chipView setFrame:CGRectMake(0, 0, 30, 30)];
    [chipView setCenter:bettor.centre];    
    [self.tableChips addObject:chipView];
    [self.table addSubview:chipView];
        
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [chipView setCenter:bettor.chipPoint];
    }completion:^(BOOL done){
        bettor.betAmountLabel.text = [NSString stringWithFormat:@"%d",amount];
        self.scene.potLabel.text = [NSString stringWithFormat:@"%d",[self getPotSize]];
        bettor.stackLabel.text = [NSString stringWithFormat:@"%d",bettor.stackCurrent];
        [self doAnimations];
    }];
}

//animations for winner
- (void)win:(NSNumber*) seat {    
    [self clearBetAmountLabels];
    playerInfo *winner = [self.playerInfoDict objectForKey:seat];
    static NSInteger yOffset = 10;
    if ([seat isEqualToNumber:self.botSeatNumber]) {
        yOffset *= -1;
    }
    CGPoint chipPoint = CGPointMake(winner.centre.x + 60, winner.centre.y + yOffset);
    
    for (NSInteger i=0; i < [self.tableChips count]; i++) {
        [UIView animateWithDuration:0.5 delay:0.05*i  options:UIViewAnimationOptionCurveEaseInOut animations:^{
            UIImageView *chipView = [self.tableChips objectAtIndex:[self.tableChips count]-1-i];
            [self.table bringSubviewToFront:chipView];            
            [chipView setCenter:chipPoint];
            
        }completion:^(BOOL done) {
            if (i==[self.tableChips count] - 1) {
                winner.stackCurrent += [self getPotSize];
                winner.stackLabel.text = [NSString stringWithFormat:@"%d" ,winner.stackCurrent];
                self.scene.potLabel.text = nil;
                [self doAnimations];
            }
        }];
    }
}

/*
 animations for split pot. 
 Chips go to both players and both stack sizes increase by half pot.
 */
- (void)splitPot {
    
    [self clearBetAmountLabels];
    
    static NSInteger yOffset = 10;
    playerInfo *bot = [self.playerInfoDict objectForKey:self.botSeatNumber];
    CGPoint botChipPoint = CGPointMake(bot.centre.x + 60, bot.centre.y - yOffset);
    playerInfo *human = [self.playerInfoDict objectForKey:self.humanSeatNumber];
    CGPoint humanChipPoint = CGPointMake(human.centre.x + 60, human.centre.y + yOffset);
    
    
    
    for (NSInteger i=0; i < [self.tableChips count]; i++) {
        [UIView animateWithDuration:0.5 delay:0.05*i  options:UIViewAnimationOptionCurveEaseOut animations:^{
            UIImageView *chipView = [self.tableChips objectAtIndex:[self.tableChips count]-1-i];
            [self.table bringSubviewToFront:chipView];
            
            NSUInteger chipToHuman = [self.tableChips indexOfObject:chipView];
            
            CGPoint chipPoint;
            if (chipToHuman%2 == 0) {
                chipPoint = humanChipPoint;
            } else {
                chipPoint = botChipPoint;
            }            
            [chipView setCenter:chipPoint];
            
        }completion:^(BOOL done) {
            if (i==[self.tableChips count] - 1) {
                NSInteger pot = [self getPotSize];
                human.stackCurrent += pot/2;
                human.stackLabel.text = [NSString stringWithFormat:@"%d" ,human.stackCurrent];
                bot.stackCurrent += pot/2;
                bot.stackLabel.text = [NSString stringWithFormat:@"%d" ,bot.stackCurrent];
                self.scene.potLabel.text = nil;
                [self doAnimations];
            }
        }];
    }
}

- (void)showDown {
    NSLog(@"Showdown");
    NSString *result = self.scene.currentState.game.gameStage;
    NSNumber *winningSeat;
    
    //work out winner
    Player *winner;
    for (NSNumber* key in self.scene.currentState.playerStateDict) {
        winner = [self.scene.currentState.playerStateDict objectForKey:key];
        if ([result hasPrefix:winner.name]) {
            winningSeat = winner.seat;
            break;
        }
    }
    
    //move chips to pot.
    [UIView animateWithDuration:0.8 delay:0 options:nil animations:^{
        UIImageView *chip;
        for (chip in self.tableChips) {
            [chip setCenter:potLocation];
        }
    }completion:^(BOOL finished)
    {
        //show bots cards
        Player *bot = [self.scene.currentState.playerStateDict objectForKey:self.botSeatNumber];
        NSArray *holeCards = bot.holeCards;
        NSString* botHoleCard1 = [holeCards objectAtIndex:0];
        NSString* botHoleCard2 = [holeCards objectAtIndex:1];
        
        playerInfo *botInfo = [self.playerInfoDict objectForKey: self.botSeatNumber];
        UIImageView* cardView1 = botInfo.card1;
        UIImageView* cardView2 = botInfo.card2;
        
        //[UIView transitionWithView:cardView1 duration:0.4f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        [UIView transitionWithView:cardView1 duration:0.4f options:UIViewAnimationOptionTransitionNone animations:^{
            [cardView1 setImage:[self getCardFrontImage:botHoleCard1]];            
        } completion:nil];
        
        [UIView transitionWithView:cardView2 duration:0.4f options:UIViewAnimationOptionTransitionNone animations:^{
            [self.table bringSubviewToFront:cardView2];
            [cardView2 setImage:[self getCardFrontImage:botHoleCard2]];
        
        NSLog(@"Card images set for bot");
        } completion:^(BOOL done) {
            NSString* resultText = [result stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
            
            [self.scene setInfoText:resultText]; //displays winning gamestate message (includes split pot)
            
            //ensure there is a winner
            if (!winningSeat) { //otherwise split pot
                NSLog(@"NO WINNER!!!!!!! DRAW??????");
                [self splitPot];
            } else { //reveal winning hand.
                playerInfo *winnerInfo = [self.playerInfoDict objectForKey:winningSeat];
                
                NSString* resultText = [result stringByReplacingOccurrencesOfString:@"<br>" withString:@""];                
                winnerInfo.winLabel.text = resultText;
                UIImageView* cardView1 = winnerInfo.card1;
                UIImageView* cardView2 = winnerInfo.card2;
                static NSInteger xOffset = 13;
                NSInteger yOffset = -35;
                if ([winningSeat isEqualToNumber:self.botSeatNumber]) {
                    yOffset *= -1;
                }
                [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    cardView1.center = CGPointMake(cardView1.center.x - xOffset, cardView1.center.y+yOffset);
                    cardView2.center = CGPointMake(cardView2.center.x + xOffset, cardView2.center.y+yOffset);
                } completion:^(BOOL finished) {
                    [self win:winningSeat];
                }];
            }
            
        }];
    }];    
}

-(NSInteger) getPotSize {
    NSInteger potSize = self.potFromPreviousStreets;
    playerInfo *playerInfo;
    for (NSNumber *key in self.playerInfoDict) {
        playerInfo = [self.playerInfoDict objectForKey:key];
        potSize += playerInfo.betAmount;
    }
    return potSize;
}
- (UIImageView*)makeCard{
    if (!cardBackImage) {
        cardBackImage = [UIImage imageNamed:@"card_back.png"];
    }
    UIImageView *card = [[UIImageView alloc]initWithImage:cardBackImage];
    card.contentMode = UIViewContentModeScaleAspectFill;
    [card setFrame:CGRectMake(0, 0, cardWidth, cardHeight)];
    [card setCenter:deckLocation];
    
    [self.table addSubview:card];
    [_tableCards addObject:card];
    return card;
}
- (UIImage*)getCardFrontImage:(NSString*)name{
    
    //NSString * newName = [[name stringByReplacingOccurrencesOfString:@"T" withString:@"10"] lowercaseString]; for non HiDP cards
    NSString * newName = [name lowercaseString];
    NSLog(@"making card %@", newName);
    UIImage *card = [UIImage imageNamed:[NSString stringWithFormat:@"card_%@.png", newName]];
    return card;
}

//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self.table];
//    
//    NSLog(@"%f, %f", location.x, location.y);
//    
//}
@end