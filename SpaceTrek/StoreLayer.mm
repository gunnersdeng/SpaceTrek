//
//  StoreLayer.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-10-22.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import "StoreLayer.h"
#import "Constants.h"
#import "MainMenuScene.h"

@implementation StoreLayer


- (id) initWithLevel:(int)level{
    
	if ((self = [super initWithColor:ccc4(139, 137, 137, 200)]))
    {
    
        self.tag=STORE_LAYER_TAG;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
    
        storeBackground = [CCMenuItemImage itemWithNormalImage:@"storeBackground.png" selectedImage:@"storeBackground.png" target:self selector:@selector(storeMenuAction)];
    
        CCMenu *menu = [CCMenu menuWithItems:storeBackground,  nil];
        menu.position =  ccp( winSize.width/2 , winSize.height/2);
        [menu alignItemsHorizontally];

        [self addChild:menu z:15];
    
    }
    return self;
}

-(void) storeMenuAction
{
    [[MainMenuScene sharedMainMenuScene] setShowingStore:NO];
    [[CCDirector sharedDirector]resume];
    [[MainMenuScene sharedMainMenuScene] removeChildByTag:STORE_LAYER_TAG cleanup:YES];
}

@end
