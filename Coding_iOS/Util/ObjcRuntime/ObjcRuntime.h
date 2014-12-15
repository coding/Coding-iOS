//
//  ObjcRuntime.h
///  CSMBP
//
//  Created by 杨辉 on 14-1-20.
//  Copyright (c) 2014年 Forever OpenSource Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//根据类名称获取类
//系统就提供 NSClassFromString(NSString *clsname)

//获取一个类的所有属性名字:类型的名字，具有@property的, 父类的获取不了！
NSDictionary *GetPropertyListOfObject(NSObject *object);
NSDictionary *GetPropertyListOfClass(Class cls);

void Swizzle(Class c, SEL origSEL, SEL newSEL);