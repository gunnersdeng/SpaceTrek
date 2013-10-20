//
//  HUDLayer.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-19.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "HUDLayer.h"
#import "GameScene.h"

@implementation HUDLayer

int hudLevel;

+(HUDLayer*) getHUDLayer {
    return self;
}

-(id) init
{
	if ((self = [super init]))
	{
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.tag=HUD_LAYER_TAG;
        statusBar= [CCSprite spriteWithFile:@"StatusBar.png"];
        statusBar.position = ccp(45, winSize.height/2);
        
        distanceLabel = [CCLabelTTF labelWithString:@"0" fontName:@"arial" fontSize:35];
        distanceLabel.rotation = 90;
        [distanceLabel setColor:ccORANGE];
        [distanceLabel setAnchorPoint:ccp(0.5f,1)];
        [distanceLabel setPosition:ccp(63, 100)];
        
        [self addChild:statusBar z:2];
        [statusBar addChild:distanceLabel z:30];
        
    }
    return self;
}

-(void) updateDistanceCounter:(int)amount
{
    NSString *amounts = [NSString stringWithFormat:@"%d", (int)amount];
    [distanceLabel setString:amounts];
}

@end