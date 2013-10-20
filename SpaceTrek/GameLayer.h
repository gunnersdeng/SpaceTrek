//
//  GameLayer.h
//  SpaceTrek
//
//  Created by huang yongke on 13-10-2.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GameObject.h"
#import "ContactListener.h"
#import "Player.h"

@class HUDLayer;
@interface GameLayer : CCLayer {
    
    int score;
    int distance;
    
    b2World* world;
    b2Body* _groundBody;
    b2Fixture *_playerFixture;
    b2Fixture *_treasureFixture;
    b2Fixture *_bottomFixture;
    
    CCMenuItemSprite *pauseButton;
    CCMenu *pauseMenu;
    NSMutableArray * _treasures;
    
    HUDLayer *hudLayer;
    
    CCSpriteBatchNode* allBatchNode;
    
    ContactListener *contactListener;
    
    
    Player *player;
    
    b2Body* playerBody;
    float shipSpeedY;
    float shipSpeedX;
@public
    bool collision;
}

-(void) treasureBack;

@property  (nonatomic, readwrite) b2World* world;
@property  (nonatomic, readwrite) int distance;
@property  (nonatomic, readwrite) int score;
@property (nonatomic, readwrite) CCSpriteBatchNode* allBatchNode;

@end
