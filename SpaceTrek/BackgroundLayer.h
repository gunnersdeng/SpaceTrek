//
//  BackgroundLayer.h
//  SpaceTrek
//
//  Created by huang yongke on 13-10-6.
//  Copyright 2013年 huang yongke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BackgroundLayer : CCLayer {
    
}

- (id) initWithLevel:(int)level;
-(void) reverseMap;
-(void)changeBack;
-(void)speedupBackground;
-(void)backSpeedBackground;
@end
