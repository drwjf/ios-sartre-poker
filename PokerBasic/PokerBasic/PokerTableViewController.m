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
@end
@implementation playerInfo
@end

@interface PokerTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *table;

@property NSMutableArray *tableCards;
@property playerInfo *human;
@property playerInfo *bot;
@property NSInteger gameStage;

@end

@implementation PokerTableViewController

static UIImage *cardBackImage;

static CGPoint deckLocation;
static CGFloat screenWidth = 400;
static CGFloat screenHeight= 200;

static int cardWidth = 50;

static int distanceBetweenCards = 50;
static int edgeOffset = 25;



- (id)initWithImage:(UIImageView *) tableImage
{
    self = [self init];
    if (self) {
        _table = tableImage;
    }
    return self;    
}

- (void) setUp {
    //if lanscape swicth width and height...
    //CGRect bounds = [self.table bounds];
    //screenWidth = self.table.frame.size.width;
    //screenHeight = self.table.frame.size.height;
    deckLocation  = CGPointMake(25, screenHeight/2);
    
    
    NSLog(@"Width (x) :  %f \n Height (y):  %f", screenWidth, screenHeight);
    self.human = [[playerInfo alloc] init];
    self.human.centre = CGPointMake(screenWidth/2, screenHeight - edgeOffset); //height = 300 not 320 (when status bar is showing)
    self.bot = [[playerInfo alloc] init];
    self.bot.centre = CGPointMake(screenWidth/2, 0 + edgeOffset);
    
    
    //card on bottom of deck, that is purely visual
    [self.table addSubview:[self makeCard]];
    
    _tableCards = [NSMutableArray arrayWithCapacity:9];
    for (int i=0; i < 9; i++) {
        UIImageView *card = [self makeCard];
        [self.table addSubview:card];
        [_tableCards addObject:card];
    }
}


- (UIImageView*)makeCard{
    if (!cardBackImage) {
        cardBackImage = [UIImage imageNamed:@"card_back.png"];
    }
    UIImageView *card = [[UIImageView alloc]initWithImage:cardBackImage];
    card.contentMode = UIViewContentModeScaleAspectFill;
    [card setFrame:CGRectMake(0, 0, cardWidth, 50)];
    [card setCenter:deckLocation];
    return card;
}

- (IBAction)deal:(id)sender {
    switch (self.gameStage) {
        case 0:
            [self holeCards];
            break;
        case 1:
            [self flop];
            break;
        case 2:
            [self turn];
            break;
        case 3:
            [self river];
            break;
        default:
            return;
    }
    self.gameStage++;
}

- (IBAction)newGame:(id)sender {
    self.gameStage = 0;
    for (id cardObj in self.tableCards) {
        
        if (![cardObj isKindOfClass:[UIImageView class]])
            return;
        UIImageView *card = cardObj;
        [self.table bringSubviewToFront:card];
        [UIView animateWithDuration:0.5 delay:(0.0) options:
         UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn animations:^{
             card.center = deckLocation;
             NSLog(@"Dealing river card ");
         }completion:^(BOOL done){
             //some completition
         }];
    }
}

- (IBAction)river {
    CGPoint dealPoint = CGPointMake(screenWidth/2, screenHeight/2);
    dealPoint.x += 2*cardWidth;
    
    UIImageView *card = [_tableCards objectAtIndex:0];
    [self.table bringSubviewToFront:card];
    [UIView animateWithDuration:0.8 delay:(0.0) options:
     UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn animations:^{
         card.center = dealPoint;
         NSLog(@"Dealing river card ");
     }completion:^(BOOL done){
         //some completition
     }];
    
}

- (IBAction)turn {
    CGPoint dealPoint = CGPointMake(screenWidth/2, screenHeight/2);
    dealPoint.x += cardWidth;
    
    UIImageView *card = [_tableCards objectAtIndex:1];
    [UIView animateWithDuration:0.8 delay:(0.0) options:
     UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn animations:^{
         [self.table bringSubviewToFront:card];
         card.center = dealPoint;
         NSLog(@"Dealing turn card ");
     }completion:^(BOOL done){
         //some completition
     }];
    
}

- (IBAction)flop {
    CGPoint dealPoint = CGPointMake(screenWidth/2, screenHeight/2);
    for (int i = 0; i < 3; i++) {
        UIImageView *card = [_tableCards objectAtIndex:4-i];
        [UIView animateWithDuration:0.8 delay:(0.2*i) options:
         UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn animations:^{
             card.center = dealPoint;
             NSLog(@"Dealing flop card %d: ", i+1);
         }completion:^(BOOL done){
             //some completition
         }];
        
        dealPoint.x -= cardWidth;
    }
}

- (void)holeCards {
    Boolean botIsDealer = true;
    playerInfo *playerInfo[2];
    if (botIsDealer) {
        playerInfo[0] = self.human;
        playerInfo[1] = self.bot;
    } else {
        playerInfo[0] = self.human;
        playerInfo[1] = self.bot;
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
             UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn animations:^{
                 card.center = dealPoint;
                 NSLog(@"Dealing to player %d: %f,%f", i, dealPoint.x, dealPoint.y);
             }completion:^(BOOL done){
                 //some completition
                 NSLog(@"Finished Dealing");
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