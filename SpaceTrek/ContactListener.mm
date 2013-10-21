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
                CCScene* scene = [[CCDirector sharedDirector] runningScene];
                GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
                
                BackgroundLayer* backgroundLayer = (BackgroundLayer*)[scene getChildByTag:BACKGROUND_LAYER_TAG];
                
                [backgroundLayer reverseMap];
                
//                [(Player *)playerSprite crashTransformAction];
                
                
                /*CCParticleSystem *collsion = [CCParticleExplosion node];
                
                [layer addChild:collsion z:12];
                collsion.texture = [[CCTextureCache sharedTextureCache] addImage:@"spaceship-boom-step-2.png"];

                
                collsion.position = playerSprite.position;
//                collsion.blendAdditive = YES;
                collsion.endSize = 200.0f;
                collsion.life = 2.0f;
                collsion.speed = 1.0f;
                collsion.opacityModifyRGB = false;
//                collsion.lifeVar = 2.0f;
                collsion.totalParticles = 1.0f;
                collsion.autoRemoveOnFinish = YES;
                */
               
                

                [[SimpleAudioEngine sharedEngine]playEffect:@"CrashSong.mp3"];
                
                [layer playerBack];
                [layer ChangeGoBackSound];
                
                treasuerSprite.tag = TREASURE_DESTROY_TAG;
                [playerSprite setType:gameObjectCollector];
                
            }
        }
        else if(spriteA.type==gameObjectCollector)
        {
            if(spriteB.type==gameObjectTreasure1)
            {
                GameObject *treasuerSprite=(spriteA.type==gameObjectCollector)?spriteB:spriteA;
                
                CCScene* scene = [[CCDirector sharedDirector] runningScene];
                GameLayer* layer = (GameLayer*)[scene getChildByTag:GAME_LAYER_TAG];
                
                [[SimpleAudioEngine sharedEngine]playEffect:@"CollectTreasure.wav"];
                
                layer.score += 10;
                
                treasuerSprite.tag = TREASURE_DESTROY_TAG;
            }

        }
    }
}


void ContactListener::EndContact(b2Contact *contact)
{
    
}
void ContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
}

void ContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
}