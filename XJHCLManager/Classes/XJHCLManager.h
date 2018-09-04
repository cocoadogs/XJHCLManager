//
//  XJHCLManager.h
//  XJHCLManager
//
//  Created by xujunhao on 2018/9/4.
//  地理位置定位权限配置检测

typedef NS_ENUM(NSInteger, XJHCLPriority) {
	///默认定位优先级
	XJHCLPriorityDefault = 0,
	///应用时开启定位权限优先级
	XJHCLPriorityWhenInUse = XJHCLPriorityDefault,
	///始终保持定位权限优先级
	XJHCLPriorityAlways
};

#import <Foundation/Foundation.h>
#import "XJHCLManagerParamBuilder.h"

/**
 权限授权成功回调
 */
typedef void(^XJHCLManagerAuthorizedCompletion)(void);

/**
 权限配置受限回调

 @param builder 参数配置builder
 */
typedef void(^XJHCLManagerAuthorizedRestriction)(XJHCLManagerParamBuilder *builder);

/**
 权限配置否决回调

 @param builder 参数配置builder
 */
typedef void(^XJHCLManagerAuthorizedRejection)(XJHCLManagerParamBuilder *builder);

/**
 定位服务关闭回调

 @param builder 参数配置builder
 */
typedef void(^XJHCLManagerServiceShutdown)(XJHCLManagerParamBuilder *builder);

@interface XJHCLManager : NSObject

- (void)checkCoreLocationAuthorizationWithPriority:(XJHCLPriority)priority
										completion:(XJHCLManagerAuthorizedCompletion)completion
									   restriction:(XJHCLManagerAuthorizedRestriction)restriction
										 rejection:(XJHCLManagerAuthorizedRejection)rejection
										  shutdown:(XJHCLManagerServiceShutdown)shutdown;

@end
