//
//  GameViewController.m
//  BlockParty
//
//  Created by Michael Ng on 9/5/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "GameViewController.h"
#import "Block.h"
#import <QuartzCore/QuartzCore.h>

@interface GameViewController () <UIAlertViewDelegate>
@property (strong) NSMutableDictionary *blocks;
@property (strong) NSTimer *timer;
@property (nonatomic) int score;
@property (strong) UILabel *scoreLabel;
@property BOOL gameOver;
@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGAffineTransform transformVerticalFlip = CGAffineTransformMakeScale(1, -1);
    self.view.transform = transformVerticalFlip;
    self.scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 455, 100, 25)];
    self.scoreLabel.layer.zPosition = 100;
    self.scoreLabel.textColor = [UIColor blackColor];
    self.scoreLabel.backgroundColor = [UIColor clearColor];
    self.scoreLabel.opaque = NO;
    self.scoreLabel.layer.transform = CATransform3DMakeAffineTransform(transformVerticalFlip);
    
    [self startGame];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setScore:(int)score
{
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
}

-(void)startGame
{
    self.blocks = [NSMutableDictionary new];
    self.gameOver = NO;

    self.view = [[UIView alloc] initWithFrame:self.view.bounds];
    CGAffineTransform transformVerticalFlip = CGAffineTransformMakeScale(1, -1);
    self.view.transform = transformVerticalFlip;
          
    self.score = 0;
    [self.view addSubview:self.scoreLabel];
    
    for (int row = 0; row < 8; row++) {
        for (int column = 0; column < 8 ; column++) {
            Block *block = [[Block alloc]init];
            [self.blocks setObject:block forKey:NSStringFromCGPoint(CGPointMake(row*40+20, column*40+20))];
            [block createLayerWithCenter:CGPointMake(row*40+20,column*40+20) andView:self.view];
        }
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(dropBlocks) userInfo:nil repeats:YES];
}

-(NSArray*)blocksInColumnAbovePoint:(CGPoint)point {
    NSMutableArray *ret = [NSMutableArray new];
    for (int row = point.y+40; row < 13*40; row+=40) {
        Block *block = [self.blocks objectForKey:NSStringFromCGPoint(CGPointMake(point.x, row))];
        if (block)
            [ret addObject:block];
    }
    return ret;
}

-(NSArray*)getNeighborsWithSameColor:(Block*)block {
    NSMutableArray *neighbors = [NSMutableArray new];
    CGPoint point = block.layer.position;
    Block *left,*right,*top,*bottom;
    if ( (left = [self.blocks objectForKey:NSStringFromCGPoint(CGPointMake(point.x-40, point.y))]) ) {
        if (left.color == block.color) {
            [neighbors addObject:left];
        }
    }
    if ( (right = [self.blocks objectForKey:NSStringFromCGPoint(CGPointMake(point.x+40, point.y))]) ) {
        if (right.color == block.color) {
            [neighbors addObject:right];
        }
    }
    if ( (top = [self.blocks objectForKey:NSStringFromCGPoint(CGPointMake(point.x, point.y+40))]) ) {
        if (top.color == block.color) {
            [neighbors addObject:top];
        }
    }
    if ( (bottom = [self.blocks objectForKey:NSStringFromCGPoint(CGPointMake(point.x, point.y-40))]) ) {
        if (bottom.color == block.color) {
            [neighbors addObject:bottom];
        }
    }
    return neighbors;
}

- (void)destroyBlockAtPoint:(CGPoint)point withArr:(NSMutableArray*)deletedBlocks {
    Block *block = [self.blocks objectForKey:NSStringFromCGPoint(point)];


    if (!block)
        return;
    
    
    NSArray *neighbors = [self getNeighborsWithSameColor:block];
    
    if ([deletedBlocks count] == 0 && [neighbors count] == 0) {
        self.score -= 5;
        return;
    }
    
    [block.layer removeFromSuperlayer];
    [self.blocks removeObjectForKey:NSStringFromCGPoint(block.layer.position)];
    [deletedBlocks addObject:block];
    
    for (Block* neighbor in neighbors) {
        [self destroyBlockAtPoint:neighbor.layer.position withArr:deletedBlocks];
    }

}

-(void)syncDictionary {
    NSMutableDictionary *newDict = [NSMutableDictionary new];
    for (NSString *key in [self.blocks allKeys]) {
        Block *block = [self.blocks objectForKey:key];
        NSString *newKey = key;
        if (![NSStringFromCGPoint(block.layer.position) isEqualToString:key]) {
            newKey = NSStringFromCGPoint(block.layer.position);
        }
        [newDict setObject:block forKey:newKey];
    }
    self.blocks = newDict;
}

//-(void)blockTouchedAtPoint:(CGPoint)point {
//    NSMutableArray *deletedBlocks = [NSMutableArray new];
////    NSMutableArray *movedBlocks = [NSMutableArray new];
//    [self destroyBlockAtPoint:point withArr:deletedBlocks];
//    for (Block *block in deletedBlocks) {
//        for (Block *blockToDrop in [self blocksInColumnAbovePoint:block.layer.position]) {
//            [blockToDrop dropBlockByNumberOfBlocks:1];
////            [movedBlocks addObject:blockToDrop];
//        }
//    }
//    [self syncDictionary];
////    for (Block* block in movedBlocks) {
////        [self blockTouchedAtPoint:block.layer.position];
////    }
//}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    touchPoint = [[touch view] convertPoint:touchPoint toView:nil];
    
    CALayer *layer = [(CALayer*)self.view.layer hitTest:touchPoint];
    
   // [self blockTouchedAtPoint:layer.position];
    
    NSMutableArray *deletedBlocks = [NSMutableArray new];
    [self destroyBlockAtPoint:layer.position withArr:deletedBlocks];
    
    if ([deletedBlocks count]>0) {
        self.score += pow(2.0, [deletedBlocks count]);
    }
    
    for (Block *block in deletedBlocks) {
        for (Block *blockToDrop in [self blocksInColumnAbovePoint:block.layer.position]) {
            [blockToDrop dropBlockByNumberOfBlocks:1];
        }
    }
    [self syncDictionary];
}

-(NSDictionary*)topPositionsForColumns {
    NSMutableDictionary *highPoints = [NSMutableDictionary new];
    for (NSString *key in self.blocks) {
        CGPoint point = CGPointFromString(key);
        if ([highPoints objectForKey:[NSNumber numberWithDouble:point.x]]) {
            if (point.y > [[highPoints objectForKey:[NSNumber numberWithDouble:point.x]] doubleValue]) {
                [highPoints setObject:[NSNumber numberWithDouble:point.y] forKey:[NSNumber numberWithDouble:point.x]];
            }
        } else {
            [highPoints setObject:[NSNumber numberWithDouble:point.y] forKey:[NSNumber numberWithDouble:point.x]];
        }
    }
    return highPoints;
}

-(void)dropBlocks
{
    NSDictionary *highPoints = [self topPositionsForColumns];
    for ( CGFloat column = 20.0; column < 12*40.0; column += 40.0 ) {
        Block *block = [[Block alloc] init];
        CGFloat topPoint;
        if ([highPoints objectForKey:[NSNumber numberWithDouble:column]]) {
            topPoint = [[highPoints objectForKey:[NSNumber numberWithDouble:column]] doubleValue] + 40.0;
        } else {
            topPoint = 20.0;
        }
    
        [self.blocks setObject:block forKey:NSStringFromCGPoint(CGPointMake(column, topPoint))];
        block.target = self;
        block.action = @selector(gameIsOver);
        [block createLayerWithCenter:CGPointMake(column, 500) andView:self.view];
        [block dropBlockByNumberOfBlocks:((500-topPoint)/40.0)];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self startGame];
}

-(void)gameIsOver {
    if (!self.gameOver) {
        [self.timer invalidate];
        self.gameOver = YES;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Game over" message:self.scoreLabel.text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

@end
