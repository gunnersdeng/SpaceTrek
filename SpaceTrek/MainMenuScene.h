//
//  MainMenuScene.h
//  SpaceTrek
//
//  Created by huang yongke on 13-10-2.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MainMenuScene : CCScene {
    
}

@property (nonatomic, getter = isShowingStore, setter = setShowingStore:) BOOL showingStore;


+(CCScene *) scene;

+(MainMenuScene*) sharedMainMenuScene;

- (void)showStore;

@end
