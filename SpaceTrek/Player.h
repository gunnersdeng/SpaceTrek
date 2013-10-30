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
    @public b2Body          *playerBody;
    CCFiniteTimeAction *playerRunAction;
    CCAnimation *playerRunAnimation;
    CCFiniteTimeAction *crashAction;
    CCAnimation *crashAnimation;
    CCFiniteTimeAction *spacemanAction;
    CCAnimation *spacemanAnimation;
    CCFiniteTimeAction *exlosionAction;
    CCAnimation *exlosionAnimation;
    
    BOOL collison;
}

-(void) createBox2dObject:(b2World*)world;
-(void) initAnimation:(CCSpriteBatchNode*)batchNode;
-(void) crashTransformAction;
//-(void) afterUpAction:(Joker *) sprite;
//-(void) afterDownAction:(Joker *) sprite;
//-(void) jump:(float)charge;
//-(void) run;
//-(void) fall;
//-(void) accelerate;
//-(void) decelerate;
//-(void) flip;
//-(void) adjust;
//+(Joker*) getJoker;
//-(b2Body*) getBody;

@property (nonatomic, readwrite) b2Body *jokerBody;
@property (nonatomic, readwrite) BOOL collison;


@end
