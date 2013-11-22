//
//  GameObject.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-12.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "GameObject.h"


@implementation GameObject

@synthesize type;
@synthesize score;
@synthesize v_X;
@synthesize v_Y;

- (id)init
{
    self = [super init];
    if (self) {
        type = gameObjectGeneral;
        score = 0;
        v_X = 0;
        v_Y = 0;
    }
    
    return self;
}

@end
