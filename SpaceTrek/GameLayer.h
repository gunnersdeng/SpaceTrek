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
#import "SimpleAudioEngine.h"
#import <vector>

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
    CCSpriteBatchNode* ExlosionBatchNode;
    
    ContactListener *contactListener;
    
    
    Player *player;
    
    GameObject* spaceStation;
    b2Body* spaceStationBody;
    
    b2Body* playerBody;
    float shipSpeedY;
    float shipSpeedX;
    
    SimpleAudioEngine * backgroundAmbience;
    
    ALuint firstBackgroundMusic;
    ALuint secondBackgroundMusic;
    
    std::vector<b2Body*> collectedTreasure;
    
@public
    bool collision;
}

-(void) playerBack;
-(void) ChangeGoBackSound;
- (void) dealloc;

@property  (nonatomic, readwrite) b2World* world;
@property  (nonatomic, readwrite) int distance;
@property  (nonatomic, readwrite) int score;
@property (nonatomic, readwrite) CCSpriteBatchNode* allBatchNode;
@property  (nonatomic, readwrite) ALuint firstBackgroundMusic;
@property  (nonatomic, readwrite) ALuint secondBackgroundMusic;
@property (nonatomic, readwrite) CCSpriteBatchNode *ExlosionBatchNode;


@end
