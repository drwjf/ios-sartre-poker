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
@property NSInteger stackFromPreviousStreets;;
@property CGPoint centre;
@property CGPoint chipPoint;
//@property int holeCardOneIndex;
//@property int holeCardTwoIndex;
@property UIImageView *card1; //added 6.2.2013 - needs to be implemented
@property UIImageView *card2;
@property UILabel *stackLabel;
@property UILabel *betAmountLabel;
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
        human.stackFromPreviousStreets = startingStack;
        human.stackLabel.text = [NSString stringWithFormat:@"%d",human.stackFromPreviousStreets];
        //human.playerState = [scene.currentState.playerStateDict objectForKey:human.seat];
        
        playerInfo *bot;
        bot = [[playerInfo alloc] init];
        bot.centre = CGPointMake(screenWidth/2, 0 + edgeOffset);
        bot.chipPoint = CGPointMake(bot.centre.x + 15, bot.centre.y+50);
        bot.seat = self.botSeatNumber;
        bot.betAmountLabel = scene.botBetAmountLabel;
        bot.stackLabel = scene.botStackLabel;
        bot.betAmount = 0;
        bot.stackFromPreviousStreets = startingStack;
        bot.stackLabel.text = [NSString stringWithFormat:@"%d",bot.stackFromPreviousStreets];
        //bot.playerState = [scene.currentState.playerStateDict objectForKey:bot.seat];
        
        self.playerInfoDict = [NSDictionary dictionaryWithObjectsAndKeys: bot, bot.seat, human, human.seat, nil];
        
        _tableChips = [NSMutableArray array];
        _tableCards = [NSMutableArray arrayWithCapacity:9];
        
        //card on bottom of deck, that is purely visual
        [self.table addSubview:[self makeCard]];
        [self.tableCards removeLastObject]; //remove it from array so it always stays there.
        
        //        _tableCards = [NSMutableArray arrayWithCapacity:9];
        //        for (int i=0; i < 9; i++) {
        //            UIImageView *card = [self makeCard];
        //            [self.table addSubview:card];
        //            [_tableCards addObject:card];
        //        }
        
        self.button = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dealer_button.png"]];
        [self.button setFrame:CGRectMake(screenWidth/2, screenHeight/2,20,20)];
        [self.table addSubview:self.button];
    }
    return self;    
}

//- (void)newGame:(NSArray*)holecards dealer:(Boolean)botIsDealer {
//    
//    self.gameStage = 0;
//    NSLog(@"New game stage is %d", self.gameStage);
//    
//    playerInfo *dealer;
//    self.botIsDealer = botIsDealer;
//    if (self.botIsDealer) {
//        dealer = [self.playerInfoDict objectForKey:@0];
//    } else {
//        dealer = [self.playerInfoDict objectForKey:@1];
//    }
//    
//}

- (void)animate:(NSEnumerator *)enumerator {
    self.animationEnumerator = enumerator;
    [self doAnimations];
}

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
                //needsomething here
                [self doAnimations];
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
            case SET_DEALER:
                [self setDealer:seat];
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

//resets playerInfo betAmounts to 0.
//moves all chips bet in current round to the side.
//clear betAmountLabels when done.
- (void)dealCommCards:(PlayerAction)action {
    
    //update potsize with current bet amounts
    self.potFromPreviousStreets = [self getPotSize];
    
    //THEN reset bet amounts
    playerInfo *playerInfo;
    for (NSNumber *key in self.playerInfoDict) {
        playerInfo = [self.playerInfoDict objectForKey:key];
        //update stackFromPreviousStreet using bet amount, before resetting betAmount
        playerInfo.stackFromPreviousStreets -= playerInfo.betAmount;
        playerInfo.betAmount = 0;
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

- (void)clearBetAmountLabels {
    playerInfo *player;
    for (NSString *key in self.playerInfoDict) {
        player = [self.playerInfoDict objectForKey:key];
        player.betAmountLabel.text = @"";
    }
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

//clears board for a new game and moves the dealer chip to the dealer.
- (void)setDealer:(NSNumber*) seat {
    
    self.potFromPreviousStreets = 0;
    
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
    
    NSString * newName = [[name stringByReplacingOccurrencesOfString:@"T" withString:@"10"] lowercaseString];
    NSLog(@"making card %@", newName);
    UIImage *card = [UIImage imageNamed:[NSString stringWithFormat:@"card_%@.png", newName]];
    return card;
}



- (IBAction)river {
    
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

- (IBAction)turn {
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
                     
                     [UIView transitionWithView:cardView1 duration:0.4f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                         [cardView1 setImage:[self getCardFrontImage:humanHoleCard1]];
                         
                     } completion:nil];
                     
                     [UIView transitionWithView:cardView2 duration:0.4f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
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

-(void)bet:(NSInteger)amount seat:(NSNumber*)seat {
    
    playerInfo *bettor = [self.playerInfoDict objectForKey:seat];
    bettor.betAmount = amount; //not += because amount is total current stage amount. ??? check
    
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
        bettor.stackLabel.text = [NSString stringWithFormat:@"%d",bettor.stackFromPreviousStreets - bettor.betAmount];
        [self doAnimations];
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