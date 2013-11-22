//
//  GameLayer3.h
//  SpaceTrek
//
//  Created by huang yongke on 13-11-12.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GameObject.h"
#import "ContactListener.h"
#import "Player.h"
#import "SimpleAudioEngine.h"
#import <vector>

@class HUDLayer;
@interface GameLayer3 : CCLayer {
    
    int score;
    int distance;
    int treasureNumber;
    
    b2World* world;
    b2Body* _groundBody;
    b2Fixture *_playerFixture;
    b2Fixture *_treasureFixture;
    b2Fixture *_bottomFixture;
    b2Fixture *_topFixture;
    
    CCMenuItemSprite *pauseButton;
    CCMenu *pauseMenu;
    NSMutableArray * _treasures;
    
    HUDLayer *hudLayer;
    
    CCSpriteBatchNode* allBatchNode;
    CCSpriteBatchNode* ExlosionBatchNode;
    
    ContactListener *contactListener;
    
    int treasureSpeedMultiplier;
    int numOfAffordCollsionTEMP;
    
    Player *player;
    
    GameObject* spaceStation;
    b2Body* spaceStationBody;
    
    float shipSpeedY;
    float shipSpeedX;
    
    SimpleAudioEngine * backgroundAmbience;
    
    bool gamePart1, gamePart2, during_invincible;
    
    ALuint firstBackgroundMusic;
    ALuint secondBackgroundMusic;
    
    std::vector<b2Body*> collectedTreasure;
    
    std::vector<b2Body*> blackholeVector;
    
@public
    bool collision;
    int getLevel;
}

-(void) playerBack;
-(void) ChangeGoBackSound;
-(bool) propertyListener: (int)propertyTag;
- (void) dealloc;
-(void)setPlayerVelocity;

@property  (nonatomic, readwrite) b2World* world;
@property  (nonatomic, readwrite) int distance;
@property  (nonatomic, readwrite) int score;
@property (nonatomic, readwrite) CCSpriteBatchNode* allBatchNode;
@property  (nonatomic, readwrite) ALuint firstBackgroundMusic;
@property  (nonatomic, readwrite) ALuint secondBackgroundMusic;
@property (nonatomic, readwrite) CCSpriteBatchNode *ExlosionBatchNode;


@end

