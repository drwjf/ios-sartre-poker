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
@property CGPoint centre;
@property CGPoint chipPoint;
@property NSNumber *seat;
//@property int holeCardOneIndex;
//@property int holeCardTwoIndex;
@property UIImageView *card1; //added 6.2.2013 - needs to be implemented
@property UIImageView *card2;

@end
@implementation playerInfo
@end

@interface PokerTableView ()

@property (weak, nonatomic) IBOutlet UIImageView *table;



@property NSMutableArray *tableChips;
@property NSMutableArray *tableCards;
//@property playerInfo *human;
//@property playerInfo *bot;
//@property NSNumber *dealerSeat;
@property NSDictionary *playerInfoDict; //bot is seat 0, player is seat 1.  //playerinfo seat dict with seat as key.

@property NSEnumerator *animationEnumerator;
@property GameViewController *scene;

//Game state
@property NSInteger gameStage;
//@property NSInteger stageMoveCount;
@property Boolean botIsDealer;

@property UIImageView *button;

@end

@implementation PokerTableView

static int numPlayers = 2;
//static int BOT_SEAT = 0;
//static int HUMAN_SEAT = 1;


static UIImage *cardBackImage;
static UIImage *chipImage;

static CGPoint deckLocation;
static CGFloat screenWidth;
static CGFloat screenHeight;

static int cardWidth = 35;
static int cardHeight = 35;

static int distanceBetweenCards = 30;
static int edgeOffset = 25;

static int distanceOfDealerButtonFromPlayer = 100;

- (id)initWithImage:(UIImageView *) tableImage scene:(GameViewController *)scene
{
    self = [self init];
    if (self) {
        
        _table = tableImage;
        _scene = scene;
        NSLog(@"Init table controller with table");
        screenWidth = self.table.bounds.size.width;
        screenHeight = self.table.bounds.size.height;
        
        deckLocation  = CGPointMake(25, screenHeight/2);
        
        playerInfo *human;
        human = [[playerInfo alloc] init];
        human.centre = CGPointMake(screenWidth/2, screenHeight - edgeOffset); //height = 300 not 320 (when status bar is showing)
        human.chipPoint = CGPointMake(human.centre.x +50, human.centre.y-50);
        human.seat = @1;
        
        playerInfo *bot;
        bot = [[playerInfo alloc] init];
        bot.centre = CGPointMake(screenWidth/2, 0 + edgeOffset);
        bot.chipPoint = CGPointMake(bot.centre.x +50, bot.centre.y+50);
        bot.seat = @0;
        
        self.playerInfoDict = [NSDictionary dictionaryWithObjectsAndKeys: bot, bot.seat, human, human.seat, nil];
        
        _tableChips = [NSMutableArray array];
        
        //card on bottom of deck, that is purely visual
        [self.table addSubview:[self makeCard]];
        
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
        NSLog(@"Doing animation for %d", action);
        
        switch (action) {
            case SET_DEALER:
                [self setDealer:seat];
                break;
            case SMALLBLIND:
            case BIGBLIND:
                [self bet:amount seat:seat];
                break;
            case DEAL:
                [self holeCards];
                break;
            default:
                break;                
        }
        [self.scene setMoveText:move];
        
    } else {
        NSLog(@"BUTTONS!!!");
    }
}

- (void)setDealer:(NSNumber*) seat {
    
    playerInfo* dealer = [self.playerInfoDict objectForKey:seat];
    CGPoint dealerCenter = dealer.centre;    
    CGPoint buttonLocation = CGPointMake(dealerCenter.x - distanceOfDealerButtonFromPlayer, dealerCenter.y);
    [UIView animateWithDuration:1.0 delay:0  options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.button.center = buttonLocation;
    }completion:^(BOOL done) {
        [self doAnimations];
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
    
    NSString * newName = [name stringByReplacingOccurrencesOfString:@"T" withString:@"10"];
    NSLog(@"making card %@", newName);
    UIImage *card = [UIImage imageNamed:[NSString stringWithFormat:@"card_%@.png", newName]];
    return card;
}




- (void)deal:(NSArray*)communityCards {
//    self.stageMoveCount = 0;
    self.gameStage++;
    switch (self.gameStage) {
        case 2:
            [self flop:communityCards];
            break;
        case 3:
            [self turn:communityCards];
            break;
        case 4:
            [self river:communityCards];
            break;
        default:
            return;
    }
    
}


- (IBAction)river:(NSArray*)communityCards  {
    CGPoint dealPoint = CGPointMake(screenWidth/2, screenHeight/2);
    dealPoint.x += 2*cardWidth;
    
    UIImageView *card = [_tableCards objectAtIndex:0];
    [self.table bringSubviewToFront:card];
    [UIView animateWithDuration:0.8 delay:(0.0) options:
     UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn animations:^{
         card.center = dealPoint;
         NSLog(@"Dealing river card ");
     }completion:^(BOOL done){
         UIImageView *card = [_tableCards objectAtIndex:0];
         NSString* cardString = [communityCards objectAtIndex:4];
         [card setImage:[self getCardFrontImage:cardString]];
     }];
    
}

- (IBAction)turn:(NSArray*)communityCards {
    CGPoint dealPoint = CGPointMake(screenWidth/2, screenHeight/2);
    dealPoint.x += cardWidth;
    
    UIImageView *card = [_tableCards objectAtIndex:1];
    [UIView animateWithDuration:0.8 delay:(0.0) options:
     UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn animations:^{
         [self.table bringSubviewToFront:card];
         card.center = dealPoint;
         NSLog(@"Dealing turn card ");
     }completion:^(BOOL done){
         UIImageView *card = [_tableCards objectAtIndex:1];
         NSString* cardString = [communityCards objectAtIndex:3];
         [card setImage:[self getCardFrontImage:cardString]];
     }];
    
}

- (IBAction)flop:(NSArray*)communityCards {
    CGPoint dealPoint = CGPointMake(screenWidth/2, screenHeight/2);
    for (int i = 0; i < 3; i++) {
        UIImageView *card = [_tableCards objectAtIndex:4-i];
        [UIView animateWithDuration:0.8 delay:(0.2*i) options:
         UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn animations:^{
             card.center = dealPoint;
             NSLog(@"Dealing flop card %d: ", i+1);
         }completion:^(BOOL done){
             if (i==2) { //show cards once final card has been dealt
                 for (int j = 0; j < 3; j++) {                     
                     UIImageView *card = [_tableCards objectAtIndex:4-j];
                     NSString* cardString = [communityCards objectAtIndex:j];
                     [card setImage:[self getCardFrontImage:cardString]];
                 }
                 
             }
         }];        
        dealPoint.x -= cardWidth;
    }
}

- (void)holeCards{
    
    NSNumber *dealerseat;
    if (self.botIsDealer) {
        dealerseat = @0;
    } else {
        dealerseat = @1;
        
    }
    NSInteger dealeeSeatInt = [dealerseat integerValue];
    
    int xoffset = -(distanceBetweenCards / 2);
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
                     
                     Player *player = [self.scene.currentState.playerStateDict objectForKey:@1];
                     NSArray *holeCards = player.holeCards;
                     
                     playerInfo *human = [self.playerInfoDict objectForKey: @1];
                     
                     NSString* humanHoleCard1 = [holeCards objectAtIndex:0];
                     NSString* humanHoleCard2 = [holeCards objectAtIndex:1];
                     
                     UIImageView* cardView1 = human.card1;
                     UIImageView* cardView2 = human.card2;                     
                     
                     [UIView transitionWithView:cardView1 duration:0.4f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                         [cardView1 setImage:[self getCardFrontImage:humanHoleCard1]];
                         //[_tableCards setObject:cardView1 atIndexedSubscript:humancardIndex.card1];
                     } completion:nil];
                     
                     [UIView transitionWithView:cardView2 duration:0.4f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                         [cardView2 setImage:[self getCardFrontImage:humanHoleCard2]];
                         //[_tableCards setObject:cardView2 atIndexedSubscript:humancardIndex.card2];
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
    
    if (!chipImage) {
        chipImage = [UIImage imageNamed:@"blackChip.png"];
    }
    UIImageView *chipView = [[UIImageView alloc]initWithImage:chipImage];
    [self.tableChips addObject:chipView];
    
    playerInfo *bettor = [self.playerInfoDict objectForKey:seat];
    
    chipView.contentMode = UIViewContentModeScaleAspectFill;
    [chipView setFrame:CGRectMake(0, 0, 30, 30)];
    [chipView setCenter:bettor.centre];
    
    [self.tableChips addObject:chipView];
    [self.table addSubview:chipView];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [chipView setCenter:bettor.chipPoint];
    }completion:^(BOOL done){
       [self doAnimations];
    }];
    
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