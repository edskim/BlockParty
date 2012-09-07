//
//  BlockLayer.m
//  BlockParty
//
//  Created by Michael Ng on 9/5/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "Block.h"
#import <QuartzCore/QuartzCore.h>

@interface Block ()
@property (strong) NSMutableArray *animations;
@end

@implementation Block

-(id)init
{
    self = [super init];
    if (self) {
        _color = arc4random()%6;
        self.animations = [NSMutableArray new];
    }
    return self;
}

-(void)createLayerWithCenter:(CGPoint)center andView:(UIView*)view
{
    self.layer = [CALayer new];
    self.layer.bounds = CGRectMake(0, 0, 40, 40);
    self.layer.position = center;
    
    CGAffineTransform transformVerticalFlip = CGAffineTransformMakeScale(1, -1);
    self.layer.transform = CATransform3DMakeAffineTransform(transformVerticalFlip);
    
    //self.layer.backgroundColor = [self backgroundColor];
    [self setImage];
    [view.layer addSublayer:self.layer];
}

-(void)dropBlockByNumberOfBlocks:(CGFloat)num {
//    [CATransaction begin];
//    [CATransaction disableActions];
//    [CATransaction setAnimationDuration:.5];
//    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
//    self.layer.position = CGPointMake(self.layer.position.x, self.layer.position.y-(num*self.layer.bounds.size.height));
//    [CATransaction commit];
    
    CABasicAnimation *drop = [CABasicAnimation animationWithKeyPath:@"position"];
    drop.fromValue = [NSValue valueWithCGPoint:[(CALayer*)self.layer position]];
    drop.toValue = [NSValue valueWithCGPoint:CGPointMake(self.layer.position.x, self.layer.position.y-(num*self.layer.bounds.size.height))];
    drop.duration = num;
    drop.delegate = self;
    drop.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationDuration:0];
    self.layer.position = CGPointMake(self.layer.position.x, self.layer.position.y-(num*self.layer.bounds.size.height));
    [CATransaction commit];
    
    if ([self.animations count] == 0) {
        [self.layer addAnimation:drop forKey:@"firstDrop"];
    }
    [self.animations addObject:drop];
}

-(void)setImage {
    UIImage *bImage;
    switch (self.color) {
        case 0:
            bImage = [UIImage imageNamed:@"f.png"];
            self.layer.contents = (__bridge id)[bImage CGImage];
            break;
        case 1:
            bImage = [UIImage imageNamed:@"u.png"];
            self.layer.contents = (__bridge id)[bImage CGImage];
            break;
        case 2:
            bImage = [UIImage imageNamed:@"c.png"];
            self.layer.contents = (__bridge id)[bImage CGImage];
            break;
        case 3:
            bImage = [UIImage imageNamed:@"k.png"];
            self.layer.contents = (__bridge id)[bImage CGImage];
            break;
        case 4:
            bImage = [UIImage imageNamed:@"e.png"];
            self.layer.contents = (__bridge id)[bImage CGImage];
            break;
        case 5:
            bImage = [UIImage imageNamed:@"d.png"];
            self.layer.contents = (__bridge id)[bImage CGImage];
            break;
        default:
            break;
    }
    return;

}

-(CGColorRef)backgroundColor
{
    switch (self.color) {
        case 0:
            return [[UIColor redColor] CGColor];
        case 1:
            return [[UIColor blueColor] CGColor];
        case 2:
            return [[UIColor yellowColor] CGColor];
        case 3:
            return [[UIColor greenColor] CGColor];
        case 4:
            return [[UIColor orangeColor] CGColor];
        case 5:
            return [[UIColor purpleColor] CGColor];
        default:
            break;
    }
}

-(void)animateBlock
{
    CAKeyframeAnimation *flash = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    flash.removedOnCompletion = NO;
    flash.repeatDuration = 200;
    [flash setValues:@[@0,@1,@0]];
    flash.duration = 1.0;
    flash.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.layer addAnimation:flash forKey:@"flashBlock"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.layer.position.y >= 440) {
        [self animateBlock];
        [self.target performSelector:self.action];
    }
    
    [self.animations removeObjectAtIndex:0];
    if ([self.animations count]>0) {
        [self.layer addAnimation:[self.animations objectAtIndex:0] forKey:@"nextDrop"];
    }
}

@end
