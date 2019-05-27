//
//  FLTMapView.h
//  Runner
//
//  Created by Wei on 2019/5/27.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTMapViewController : NSObject<FlutterPlatformView,MAMapViewDelegate,AMapSearchDelegate,FlutterStreamHandler>

-(instancetype)initWithFrame:(CGRect)frame viewIndentifier:(int64_t)viewId arguments:(id _Nullable)args binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

-(UIView*)view;
@end


@interface FLTMapViewFactory : NSObject<FlutterPlatformViewFactory>
-(instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end
NS_ASSUME_NONNULL_END
