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

@interface GameViewController ()
@property (strong) NSMutableDictionary *blocks;
@property (strong) NSTimer *timer;
@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.blocks = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (int row = 0; row < 8; row++) {
        for (int column = 0; column < 8 ; column++) {
            Block *block = [[Block alloc]init];
            [self.blocks setObject:block forKey:NSStringFromCGPoint(CGPointMake(row*40+20, column*40+20))];
            [block createLayerWithCenter:CGPointMake(row*40+20,column*40+20) andView:self.view];
        }
    }
    CGAffineTransform transformVerticalFlip = CGAffineTransformMakeScale(1, -1);
    self.view.transform = transformVerticalFlip;
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

-(void)startGame
{
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
        return;
    }
    
    [block.layer removeFromSuperlayer];
    [self.blocks removeObjectForKey:NSStringFromCGPoint(block.layer.position)];
    [deletedBlocks addObject:block];
    
    for (Block* neighbor in neighbors) {
        [self destroyBlockAtPoint:neighbor.layer.position withArr:deletedBlocks];
    }

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    touchPoint = [[touch view] convertPoint:touchPoint toView:nil];
    
    CALayer *layer = [(CALayer*)self.view.layer hitTest:touchPoint];
    NSMutableArray *deletedBlocks = [NSMutableArray new];
    [self destroyBlockAtPoint:layer.position withArr:deletedBlocks];
    for (Block *block in deletedBlocks) {
        for (Block *blockToDrop in [self blocksInColumnAbovePoint:block.layer.position]) {
            [blockToDrop dropBlockByNumberOfBlocks:1];
        }
    }
    NSLog(@"%@",deletedBlocks);
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
        [block createLayerWithCenter:CGPointMake(column, topPoint) andView:self.view];
        CABasicAnimation *drop = [CABasicAnimation animationWithKeyPath:@"position"];
        drop.fromValue = [NSValue valueWithCGPoint:CGPointMake(column, 500)];
        drop.duration = (500-topPoint)/40;
        [block.layer addAnimation:drop forKey:NSStringFromCGPoint(block.layer.position)];
        
        if (topPoint >= 440) {
            [self animateBlock:block];
            [self.timer invalidate];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Game over" message:@"score" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            break;
        }
    }
}

-(void)animateBlock:(Block*)block
{
    CAKeyframeAnimation *flash = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    flash.removedOnCompletion = NO;
    flash.delegate = self;
    
    [flash setValues:@[@0,@1,@0,@1,@0,@1,@0,@1,@0,@1,@0,@1,@0]];
    flash.duration = 5.0;
    flash.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [block.layer addAnimation:flash forKey:@"flashBlock"];
}

@end
