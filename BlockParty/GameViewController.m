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
    for (int row = point.y+40; row < 8*40; row+=40) {
        Block *block = [self.blocks objectForKey:NSStringFromCGPoint(CGPointMake(point.x, row))];
        if (block)
            [ret addObject:block];
    }
    return ret;
}

- (void)destroyBlockAtPoint:(CGPoint)point withArr:(NSMutableArray*)deletedBlocks {
    Block *block = [self.blocks objectForKey:NSStringFromCGPoint(point)];
    
    if (!block)
        return;
    
    [block.layer removeFromSuperlayer];
    [self.blocks removeObjectForKey:NSStringFromCGPoint(block.layer.position)];
    [deletedBlocks addObject:block];
    
    Block *left,*right,*top,*bottom;
    if ( (left = [self.blocks objectForKey:NSStringFromCGPoint(CGPointMake(point.x-40, point.y))]) ) {
        if (left.color == block.color) {
            [self destroyBlockAtPoint:left.layer.position withArr:deletedBlocks];
        }
    }
    if ( (right = [self.blocks objectForKey:NSStringFromCGPoint(CGPointMake(point.x+40, point.y))]) ) {
        if (right.color == block.color) {
            [self destroyBlockAtPoint:right.layer.position withArr:deletedBlocks];
        }
    }
    if ( (top = [self.blocks objectForKey:NSStringFromCGPoint(CGPointMake(point.x, point.y+40))]) ) {
        if (top.color == block.color) {
            [self destroyBlockAtPoint:top.layer.position withArr:deletedBlocks];
        }
    }
    if ( (bottom = [self.blocks objectForKey:NSStringFromCGPoint(CGPointMake(point.x, point.y-40))]) ) {
        if (bottom.color == block.color) {
            [self destroyBlockAtPoint:bottom.layer.position withArr:deletedBlocks];
        }
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

-(void)dropBlocks
{
    for (int column = 0; column < 8 ; column++) {
        for (int row = 0; row < 8; row++) {
            
            if(![self.blocks objectForKey:NSStringFromCGPoint(CGPointMake(row*40+20, column*40+20))]){
                Block *block = [[Block alloc]init];
                [self.blocks setObject:block forKey:NSStringFromCGPoint(CGPointMake(row*40+20, column*40+20))];
                [block createLayerWithCenter:CGPointMake(row*40+20,column*40+20) andView:self.view];
                break;
            }
        }
    }
}

@end
