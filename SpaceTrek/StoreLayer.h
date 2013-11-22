//
//  StoreLayer.h
//  SpaceTrek
//
//  Created by huang yongke on 13-10-22.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <vector>
#import "Global.h"
@interface StoreLayer : CCLayerColor {
    CCSprite *storeBackground;
    CCMenuItem *closesStoreBackground;
    CCMenuItemImage* property1, *property2, *property3, *property4, *property5, *property6;
    CCMenu *PropertyMenu;
    CCMenu *PropertyMenu2;
    
    CCLabelTTF *goldLabel;
    
   
    
    
}


@end
