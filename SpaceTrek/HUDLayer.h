//
//  HUDLayer.h
//  SpaceTrek
//
//  Created by huang yongke on 13-10-19.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "GameLayer.h"

@interface HUDLayer : CCLayer {
    CCLabelTTF *distanceLabel;
    CCSprite *statusBar;
    GameLayer *gameLayer;
    CCMenuItemImage* times2;
    CCMenu *PropertyMenu;
}
-(void) updateDistanceCounter:(int)amount;

+(HUDLayer*) getHUDLayer;
-(void) times2Selected;

@end