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

- (id)init
{
    self = [super init];
    if (self) {
        type = gameObjectGeneral;
    }
    
    return self;
}

@end
