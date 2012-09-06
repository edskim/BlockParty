//
//  BlockLayer.h
//  BlockParty
//
//  Created by Michael Ng on 9/5/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    RED,
    BLUE,
    YELLOW,
    GREEN,
    ORANGE,
    PURPLE
} BlockColor;

@interface Block : NSObject

@property (strong) CALayer *layer;
@property (readonly) BlockColor color;
-(void)createLayerWithCenter:(CGPoint)center andView:(UIView*)view;
-(void)dropBlockByNumberOfBlocks:(int)num;

@end
