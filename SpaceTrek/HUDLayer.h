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
    CCSprite *pointer;
    GameLayer *gameLayer;
    CCMenuItemImage* property1, *property2, *property3, *property4, *property5, *property6, *propertyNull;
    CCMenu *PropertyMenu;
    CCMenuItemSprite *pauseButton;
    CCMenu *pauseMenu;
    
    CCSprite * shadow;
    CCSprite * shadow0;
    CCSprite * shadow1;
    CCSprite * shadow2;
    CCSprite * shadow4;
    
    
    bool isShowingPausedMenu;
}
- (id) initWithLevel:(int)level;
-(void) updateDistanceCounter:(int)amount;

-(void) setShadowPosition:(int) x yy:(int) y;
-(void) setShadow: (int) index;

+(HUDLayer*) getHUDLayer;

-(void) disablePauseMenu;

@end