//
//  ContactListener.c
//  SpaceTrek
//
//  Created by Deng Ziheng on 10/12/13.
//  Copyright (c) 2013 Deng Ziheng. All rights reserved.
//

#import "ContactListener.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameObject.h"
#import "GameLayer.h"
#import "BackgroundLayer.h"
#import "GameOverScene.h"

ContactListener::ContactListener() {
}

ContactListener::~ContactListener() {
}

void ContactListener::BeginContact(b2Contact *contact) {
    
    b2Body *bodyA = contact->GetFixtureA()->GetBody();
    b2Body *bodyB = contact->GetFixtureB()->GetBody();
    if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL)
    {
        GameObject *spriteA = (__bridge GameObject *) bodyA->GetUserData();
        GameObject *spriteB = (__bridge GameObject *) bodyB->GetUserData();
        
        
        if(spriteA.tag == BULLET_TAG || spriteB.tag == BULLET_TAG)
        {
            GameObject *bulletSprite=(spriteA.tag==BULLET_TAG)?spriteA:spriteB;
            GameObject* obstacleSprite =(spriteA.tag==TREASURE_TAG)?spriteA:spriteB;
            obstacleSprite.tag = TREASURE_DESTROY_BYBULLET_TAG;
            bulletSprite.tag = BULLET_DESTROY_TAG;
            
            CCScene* scene = [[CCDirector sharedDirector] runningScene];
            GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
            CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"collisionTreasure.plist"];
            particle.positionType = kCCPositionTypeFree;
            particle.position = obstacleSprite.position;
            [layer addChild:particle z:1];
            [[SimpleAudioEngine sharedEngine]playEffect:@"treasureCrash.wav"];
            return;
        }
        
        if(spriteA.type>spriteB.type)
        {
            std::swap(spriteA, spriteB);
        }
        
        if(spriteA.type==gameObjectPlayer)
        {
            if(spriteB.type==gameObjectTreasure1)
            {
                GameObject *treasuerSprite=(spriteA.type==gameObjectPlayer)?spriteB:spriteA;
                GameObject* playerSprite =(spriteA.type==gameObjectPlayer)?spriteA:spriteB;
                Player* player = (Player*)playerSprite;
                CCScene* scene = [[CCDirector sharedDirector] runningScene];
                GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
                
                
                if(player.numOfAffordCollsion > 0)
                {
                    treasuerSprite.tag = TREASURE_DESTROY_TAG;
                    player.numOfAffordCollsion--;
                    [[SimpleAudioEngine sharedEngine]playEffect:@"treasureCrash.wav"];
                    player->playerBody->SetLinearVelocity(b2Vec2(0.0f,0.0f));
                    
                    //add collision particle effect
                    CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"collisionTreasure.plist"];
                    particle.positionType = kCCPositionTypeFree;
                    particle.position = player.position;
                    [layer addChild:particle z:1];
                    
                    if ( player.numOfAffordCollsion == 1 )
                        [layer changeShield:0];
                    if ( player.numOfAffordCollsion == 0 )
                        [layer changeShield:1];
                }
                else
                {
                    [[SimpleAudioEngine sharedEngine]playEffect:@"CrashSong.mp3"];
                
                    [layer playerBack];
                    [layer ChangeGoBackSound];
                
                    treasuerSprite.tag = TREASURE_DESTROY_TAG;
                    [playerSprite setType:gameObjectCollector];
                }
                
            }
            else if(spriteB.type==gameObjectObstacle)
            {
                CCScene* scene = [[CCDirector sharedDirector] runningScene];
                GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
                [layer setVolecity:0];
            }
            else if(spriteB.type==gameObjectFallingStone)
            {
                CCScene* scene = [[CCDirector sharedDirector] runningScene];
                GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
                
                CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"crashShip.plist"];
                particle.positionType = kCCPositionTypeFree;
                particle.position = spriteB.position;
                [layer addChild:particle z:1];
                spriteA.visible = false;
                spriteB.visible = false;
                
                
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:5.0 scene:  [GameOverScene sceneWithLevel:GAME_STATE_ONE Score:layer.score Distance:layer.distance]]];
            }
        }
        else if(spriteA.type==gameObjectCollector)
        {
            if(spriteB.type==gameObjectTreasure1)
            {
                GameObject *treasuerSprite=(spriteA.type==gameObjectCollector)?spriteB:spriteA;
                
                CCScene* scene = [[CCDirector sharedDirector] runningScene];
                GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
                CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"treasureCollection.plist"];
                particle.positionType = kCCPositionTypeFree;
                particle.position = spriteB.position;
                [layer addChild:particle z:1];
                
                
                
                treasuerSprite.tag = TREASURE_DESTROY_TAG;
            }
            else if(spriteB.type==gameObjectFallingStone)
            {
                CCScene* scene = [[CCDirector sharedDirector] runningScene];
                GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
                CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"crashShip.plist"];
                particle.positionType = kCCPositionTypeFree;
                particle.position = spriteB.position;
                [layer addChild:particle z:1];
                spriteA.visible = false;
                spriteB.visible = false;
                
                
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:5.0 scene:  [GameOverScene sceneWithLevel:GAME_STATE_ONE Score:layer.score Distance:layer.distance]]];
            }
        }
    }
}


void ContactListener::EndContact(b2Contact *contact)
{
    /*
    b2Body *bodyA = contact->GetFixtureA()->GetBody();
    b2Body *bodyB = contact->GetFixtureB()->GetBody();
    if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL)
    {
        GameObject *spriteA = (__bridge GameObject *) bodyA->GetUserData();
        GameObject *spriteB = (__bridge GameObject *) bodyB->GetUserData();
        
        

        if(spriteA.type>spriteB.type)
        {
            std::swap(spriteA, spriteB);
        }
        
        if(spriteA.type==gameObjectPlayer)
        {
            
            if(spriteB.type==gameObjectObstacle)
            {
                CCScene* scene = [[CCDirector sharedDirector] runningScene];
                GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
                [layer setVolecity:1];
            }
            
        }
       
    }
     */
}
void ContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
}

void ContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
}