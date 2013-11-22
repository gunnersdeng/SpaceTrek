//
//  MyCocos2DClass.h
//  SpaceTrek
//
//  Created by Zhen Li on 10/19/13.
//  Copyright 2013 Zhen Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GameObject.h"

@interface Player : GameObject {
    @public b2Body *playerBody;
    CCFiniteTimeAction *playerRunAction;
    CCAnimation *playerRunAnimation;
    CCFiniteTimeAction *crashAction;
    CCAnimation *crashAnimation;
    CCFiniteTimeAction *spacemanAction;
    CCAnimation *spacemanAnimation;
    CCFiniteTimeAction *exlosionAction;
    CCAnimation *exlosionAnimation;
    CCFiniteTimeAction *magnet1Action;
    CCAnimation *magnet1Animation;
    CCFiniteTimeAction *magnet2Action;
    CCAnimation *magnet2Animation;
    CCFiniteTimeAction *invincibleAction;
    CCAnimation *invincibleAnimation;
    CCFiniteTimeAction *shield1Action;
    CCAnimation *shield1Animation;
    CCFiniteTimeAction *shield2Action;
    CCAnimation *shield2Animation;
    
    BOOL collison;
    
    int numOfAffordCollsion;
    int numOfCollsion;
    
}
-(void) adjust;
-(void) createBox2dObject:(b2World*)world;
-(void) initAnimation:(CCSpriteBatchNode*)batchNode;
-(void) crashTransformAction;
-(void) magnetAction;
-(void) invincible;
-(void) shield1;
-(void) shield2;
-(void) noshield;

+(Player*) getPlayer;
-(b2Body*) getBody;

//@property (nonatomic, readwrite) b2Body *playerBody;
@property (nonatomic, readwrite) BOOL collison;
@property (nonatomic, readwrite) int numOfAffordCollsion;
@property (nonatomic, readwrite) int numOfCollsion;


@end
