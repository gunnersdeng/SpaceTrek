//
//  StoreLayer.h
//  SpaceTrek
//
//  Created by huang yongke on 13-10-22.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface StoreLayer : CCLayerColor {
    CCMenuItem *storeBackground;
}
- (id) initWithLevel:(int)level;
@end
