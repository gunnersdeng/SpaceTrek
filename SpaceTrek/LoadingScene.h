//
//  LoadingScene.h
//  SpaceTrek
//
//  Created by huang yongke on 13-10-20.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LoadingScene : CCLayer {
    int GameStage;
    int count;
    CCLabelTTF *loadingLabel;
}

+( id ) sceneWithTargetScene:(int)gameStage;
-( id ) initWithTargetScene:(int)gameStage;
-( void ) update:(ccTime)delta;

@end
