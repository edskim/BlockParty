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
@end

@implementation Block

-(id)init
{
    self = [super init];
    if (self) {
        _color = arc4random()%6;
    }
    return self;
}

-(void)createLayerWithCenter:(CGPoint)center andView:(UIView*)view
{
    self.layer = [CALayer new];
    self.layer.bounds = CGRectMake(0, 0, 40, 40);
    self.layer.position = center;
    self.layer.backgroundColor = [self backgroundColor];
    [view.layer addSublayer:self.layer];
}

-(void)dropBlockByNumberOfBlocks:(int)num {
    [CATransaction begin];
    [CATransaction setAnimationDuration:.5];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    self.layer.position = CGPointMake(self.layer.position.x, self.layer.position.y-(num*self.layer.bounds.size.height));
    [CATransaction commit];
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
@end
