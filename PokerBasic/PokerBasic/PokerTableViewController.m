//
//  PokerTableViewController.m
//  
//
//  Created by Samuel Michael Russell Grace on 1/02/13.
//
//

#import "PokerTableViewController.h"

@interface playerInfo:NSObject
@property CGPoint centre;
@property CGPoint chipPoint;
@end
@implementation playerInfo
@end

@interface PokerTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *table;

@property NSMutableArray *tableCards;
@property playerInfo *human;
@property playerInfo *bot;
@property playerInfo *dealer;

//Game state
@property NSInteger gameStage;
@property Boolean botIsDealer;

@property UIImageView *button;

@end

@implementation PokerTableViewController

static UIImage *cardBackImage;

static CGPoint deckLocation;
static CGFloat screenWidth;
static CGFloat screenHeight;

static int cardWidth = 35;
static int cardHeight = 35;

static int distanceBetweenCards = 30;
static int edgeOffset = 25;

static int distanceOfDealerButtonFromPlayer = 100;

- (id)initWithImage:(UIImageView *) tableImage
{
    self = [self init];
    if (self) {
        _table = tableImage;
        NSLog(@"Init table controller with table");
        screenWidth = self.table.bounds.size.width;
        screenHeight = self.table.bounds.size.height;
        
        deckLocation  = CGPointMake(25, screenHeight/2);
        
        self.human = [[playerInfo alloc] init];
        self.human.centre = CGPointMake(screenWidth/2, screenHeight - edgeOffset); //height = 300 not 320 (when status bar is showing)
        self.human.chipPoint = CGPointMake(self.human.centre.x - 50, self.human.centre.y);
        
        self.bot = [[playerInfo alloc] init];
        self.bot.centre = CGPointMake(screenWidth/2, 0 + edgeOffset);
        self.bot.chipPoint = CGPointMake(self.bot.centre.x + 50, self.bot.centre.y);
        
        
        //card on bottom of deck, that is purely visual
        [self.table addSubview:[self makeCard]];
        
        _tableCards = [NSMutableArray arrayWithCapacity:9];
        for (int i=0; i < 9; i++) {
            UIImageView *card = [self makeCard];
            [self.table addSubview:card];
            [_tableCards addObject:card];
        }
        
        self.button = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dealer_button.png"]];
        [self.button setFrame:CGRectMake(screenWidth/2, screenHeight/2,20,20)];
        [self.table addSubview:self.button];
        
    }
    return self;    
}


- (UIImageView*)makeCard{
    if (!cardBackImage) {
        cardBackImage = [UIImage imageNamed:@"card_back.png"];
    }
    UIImageView *card = [[UIImageView alloc]initWithImage:cardBackImage];
    card.contentMode = UIViewContentModeScaleAspectFill;
    [card setFrame:CGRectMake(0, 0, cardWidth, cardHeight)];
    [card setCenter:deckLocation];
    return card;
}

- (UIImage*)getCardFrontImage:(NSString*)name{
    
    NSString * newName = [name stringByReplacingOccurrencesOfString:@"T" withString:@"10"];
    NSLog(@"making card %@", newName);
    UIImage *card = [UIImage imageNamed:[NSString stringWithFormat:@"card_%@.png", newName]];
    return card;
}

-(void)bet {
    playerInfo *bettor;
    if (self.gameStage == 1) {//preflop dealer goes first
        bettor = self.dealer;
    }
}


- (void)deal:(NSArray*)communityCards {
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

- (void)newGame:(NSArray*)holecards dealer:(Boolean)botIsDealer {
    
    self.gameStage = 0;
    NSLog(@"New game stage is %d", self.gameStage);
    self.botIsDealer = botIsDealer;
    
    CGPoint dealerCenter;
    if (self.botIsDealer) {
        dealerCenter = self.bot.centre;
    } else {
        dealerCenter = self.human.centre;
    }
    
    CGPoint buttonLocation = CGPointMake(dealerCenter.x - distanceOfDealerButtonFromPlayer, dealerCenter.y);
    
    [UIView animateWithDuration:0.5 delay:(0.0) options:UIViewAnimationOptionTransitionCrossDissolve  animations:^{

    //if (self.gameStage > 1) { //is greater than 1. ie postflop
        for (id cardObj in self.tableCards) {
            
            if (![cardObj isKindOfClass:[UIImageView class]])
                return;
            UIImageView *card = cardObj;
            [self.table bringSubviewToFront:card];
                             NSLog(@"Card current location: %@", NSStringFromCGPoint([card center]));
                 [card setImage:cardBackImage];
                 card.center = deckLocation;
                 NSLog(@"New Game cards retunred to %@", NSStringFromCGPoint(deckLocation));
             }
    }completion:^(BOOL done){
        [UIView animateWithDuration:1.0 delay:0
                            options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.button.center = buttonLocation;
            
        }completion:^(BOOL done) {
            [self holeCards:holecards];
        }];
        
    }];
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

- (void)holeCards:(NSArray*)holeCards {
    self.gameStage++;
    
    playerInfo *playerInfo[2];
    typedef struct  {
        int card1;
        int card2;
    } cardIndexs;
    cardIndexs humancardIndex;
    
    if (self.botIsDealer) {
        playerInfo[0] = self.human;
        playerInfo[1] = self.bot;
        humancardIndex.card2 = 8;
        humancardIndex.card1 = 6;
        
        self.dealer = self.bot;
    } else {
        playerInfo[0] = self.human;
        playerInfo[1] = self.bot;
        humancardIndex.card2 = 7;
        humancardIndex.card1 = 5;
        
        self.dealer = self.human;
    }    
    
    int xoffset = -(distanceBetweenCards / 2);
    int count = 0;
    for (int j=0; j < 2; j++) { //change the x offset every 2 cards dealt
        xoffset *= -1;
        for (int i = 0; i < 2; i++) {
            CGPoint dealPoint = playerInfo[i].centre;
            dealPoint.x += xoffset;
            UIImageView *card = [_tableCards objectAtIndex:8-(count)];
            [UIView animateWithDuration:0.8 delay:(0.2*count++) options:
             UIViewAnimationCurveEaseIn animations:^{
                 card.center = dealPoint;
                 NSLog(@"Dealing to player %d: %f,%f", i, dealPoint.x, dealPoint.y);
                 
             }completion:^(BOOL done){
                 NSLog(@"count: %d",count);
                 if (count==4) {
                     NSString* humanHoleCard1 = [holeCards objectAtIndex:0];
                     NSString* humanHoleCard2 = [holeCards objectAtIndex:1];
                     
                     UIImageView* cardView1 = [_tableCards objectAtIndex:humancardIndex.card1];
                     UIImageView* cardView2 = [_tableCards objectAtIndex:humancardIndex.card2];
                     
                     
                     [UIView transitionWithView:cardView1 duration:0.4f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                         [cardView1 setImage:[self getCardFrontImage:humanHoleCard1]];
                         [_tableCards setObject:cardView1 atIndexedSubscript:humancardIndex.card1];
                     } completion:nil];
                     
                     [UIView transitionWithView:cardView2 duration:0.4f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                         [cardView2 setImage:[self getCardFrontImage:humanHoleCard2]];
                         [_tableCards setObject:cardView2 atIndexedSubscript:humancardIndex.card2];
                     } completion:nil];
                 }
             }];
        }
    }    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.table];
    
    NSLog(@"%f, %f", location.x, location.y);
    
}
@end