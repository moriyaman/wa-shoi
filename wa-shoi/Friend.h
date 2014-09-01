//
//  Friend.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/08/30.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <Realm/Realm.h>

@interface Friend : RLMObject

@property NSString *name;
@property NSInteger *user_id;

@end

RLM_ARRAY_TYPE(Friend)

