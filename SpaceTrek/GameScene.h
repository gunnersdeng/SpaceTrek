//
//  GameScene.h
//  SpaceTrek
//
//  Created by huang yongke on 13-10-2.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameScene : CCScene {
}

@property (nonatomic, getter = isShowingPausedMenu, setter = setShowingPausedMenu:) BOOL showingPausedMenu;

+(CCScene *) scene;//what??????


+(CCScene *) sceneWithState:(int)state;

+(GameScene*) sharedGameScene;

-(void)showPausedMenu:(int)state;
@end
