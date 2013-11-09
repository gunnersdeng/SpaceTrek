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
    
    BOOL collison;
    
    int numOfAffordCollsion;
    int numOfCollsion;
}
-(void) adjust;
-(void) createBox2dObject:(b2World*)world;
-(void) initAnimation:(CCSpriteBatchNode*)batchNode;
-(void) crashTransformAction;
+(Player*) getPlayer;
-(b2Body*) getBody;

//@property (nonatomic, readwrite) b2Body *playerBody;
@property (nonatomic, readwrite) BOOL collison;
@property (nonatomic, readwrite) int numOfAffordCollsion;
@property (nonatomic, readwrite) int numOfCollsion;


@end
