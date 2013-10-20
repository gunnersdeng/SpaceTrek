//
//  PauseLayer.h
//  SpaceTrek
//
//  Created by huang yongke on 13-10-6.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PauseLayer : CCLayerColor {
    
    CCMenuItemImage *resume;
    CCLabelTTF *labelResume;
    CCMenuItemImage *restart;
    CCLabelTTF *restartResume;
    CCMenuItemImage *main;
    CCLabelTTF *mainResume;
    
}

- (id) initWithLevel:(int)level;

@end
