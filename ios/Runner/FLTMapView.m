//
//  FLTMapView.m
//  Runner
//
//  Created by Wei on 2019/5/27.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

#import "FLTMapView.h"
#import "UIColor+ColorHexString.h"
#import<objc/runtime.h>

@implementation FLTMapViewController{
    int64_t _viewId;
    FlutterMethodChannel* _channel;
    MAMapView* _mapView;
    FlutterEventSink _eventSink;
    NSDictionary* _annotationViewStyle;
    NSDictionary* _polylineStyle;
    NSDictionary* _circleStyle;
    AMapSearchAPI* _search;
    
}

#pragma FlutterPlatformView

- (instancetype)initWithFrame:(CGRect)frame viewIndentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        _viewId = viewId;
    
        NSString* apiKey = args[@"apiKey"];
        [AMapServices sharedServices].apiKey = apiKey;
        [AMapServices sharedServices].enableHTTPS = YES;
        _mapView = [[MAMapView alloc] initWithFrame:frame];
        _mapView.delegate = self;
        FlutterMethodChannel* methodChannel = [FlutterMethodChannel methodChannelWithName:[NSString stringWithFormat:@"plugin.bughub.dev/amap_method_%lld",viewId] binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
        FlutterEventChannel* eventChannel = [FlutterEventChannel
                                             eventChannelWithName:[NSString stringWithFormat:@"plugin.bughub.dev/amap_event_%lld",
                                                                   viewId]
                                             binaryMessenger:messenger];
        [eventChannel setStreamHandler:self];
        
    }
    return self;
}

- (UIView *)view{
    return _mapView;
}

-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    
    NSDictionary* args = call.arguments;
    
    if ([@"addAnnotation" isEqualToString:call.method]) {//添加默认标记
        NSString* title = args[@"title"];
        NSString* subtitle = args[@"subtitle"];
        NSDictionary* coordinate = args[@"coordinate"];
        double latitude = [coordinate[@"latitude"] doubleValue];
        double longitude = [coordinate[@"longitude"] doubleValue];
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc]init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        pointAnnotation.title = title;
        pointAnnotation.subtitle = subtitle;
        [_mapView addAnnotation:pointAnnotation];
        result(nil);
    }else if ([@"addOverlay" isEqualToString:call.method]){//绘制覆盖层
        NSString* overlayType  =args[@"overlayType"];
        if([@"MAPolyline" isEqualToString:overlayType]){//折线
            NSArray* coordinates = args[@"coordinates"];
            
            //构造折线数据对象
            CLLocationCoordinate2D commonPolylineCoords[coordinates.count];
            
            for (int i=0; i<coordinates.count; i++) {
                NSDictionary* dict = coordinates[i];
                commonPolylineCoords[i].latitude = [dict[@"latitude"] doubleValue];
                commonPolylineCoords[i].longitude = [dict[@"longitude"] doubleValue];
            }
            //构造折线对象
            MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:coordinates.count];
            //在地图上添加折线对象
            [_mapView addOverlay:commonPolyline];
            result(nil);
        }else if([@"MACircle" isEqualToString:overlayType]){//圆
            NSArray* coordinates = args[@"coordinates"];
            NSDictionary* dict = coordinates[0];
            CLLocationCoordinate2D commonPolylineCoord = CLLocationCoordinate2DMake([dict[@"latitude"] doubleValue],[dict[@"longitude"] doubleValue]);
            int radius = [args[@"radius"] intValue];
            //构造圆
            MACircle *circle = [MACircle circleWithCenterCoordinate:commonPolylineCoord radius:radius];
            
            //在地图上添加圆
            [_mapView addOverlay: circle];
        }
    }else if ([@"setMAPinAnnotationStyle" isEqualToString:call.method]){//设置点标记样式
        _annotationViewStyle = args;
    }else if ([@"setMAPolylineStyle" isEqualToString:call.method]){//设置折线样式
        _polylineStyle = args;
    }else if ([@"setMACircleStyle" isEqualToString:call.method]){//设置圆圈样式
        _circleStyle = args;
    }else if ([@"search" isEqualToString:call.method]){//搜索
        _search = [[AMapSearchAPI alloc]init];
        _search.delegate = self;
        
        AMapPOIKeywordsSearchRequest* searchRequest = [[AMapPOIKeywordsSearchRequest alloc]init];
        searchRequest.keywords = args[@"keywords"];
        searchRequest.city = args[@"city"];
        searchRequest.types= args[@"types"];
        searchRequest.requireExtension  = [args[@"requireExtension"] boolValue];
        
        searchRequest.cityLimit  = [args[@"cityLimit"] boolValue];
        searchRequest.requireSubPOIs  = [args[@"requireSubPOIs"] boolValue];
        
        [_search AMapPOIKeywordsSearch:searchRequest];
        
    }else{
        result(FlutterMethodNotImplemented);
    }
}

#pragma MAMapViewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString* pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView* annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView==nil) {
            annotationView = [[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        if (_annotationViewStyle) {
            annotationView.canShowCallout=[_annotationViewStyle[@"canShowCallout"] boolValue];
            annotationView.animatesDrop=[_annotationViewStyle[@"animatesDrop"] boolValue];
            annotationView.draggable = [_annotationViewStyle[@"draggable"] boolValue];
            NSString* pinColor = _annotationViewStyle[@"pinColor"];
            int color =MAPinAnnotationColorPurple;
            if ([@"MAPinAnnotationColorPurple" isEqualToString:pinColor]) {
                color = MAPinAnnotationColorPurple;
            }else if ([@"MAPinAnnotationColorGreen" isEqualToString:pinColor]) {
                color = MAPinAnnotationColorGreen;
            }else if ([@"MAPinAnnotationColorRed" isEqualToString:pinColor]) {
                color = MAPinAnnotationColorRed;
            }
            annotationView.pinColor = color;
        }else{
            annotationView.canShowCallout=YES;
            annotationView.animatesDrop=YES;
            annotationView.draggable = YES;
            annotationView.pinColor = MAPinAnnotationColorPurple;
        }
        return annotationView;
    }
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        if (_polylineStyle) {
            polylineRenderer.lineWidth    = [_polylineStyle[@"lineWidth"] doubleValue];
            polylineRenderer.strokeColor  = [UIColor colorWithHexString:_polylineStyle[@"strokeColor"]];
            NSString* lineJoinTypeStr = _polylineStyle[@"lineJoinType"];
            if ([@"kMALineJoinRound" isEqualToString:lineJoinTypeStr]) {
                polylineRenderer.lineJoinType = kMALineJoinRound;
            }else if ([@"kMALineJoinMiter" isEqualToString:lineJoinTypeStr]) {
                polylineRenderer.lineJoinType = kMALineJoinMiter;
            }else if ([@"kMALineJoinBevel" isEqualToString:lineJoinTypeStr]) {
                polylineRenderer.lineJoinType = kMALineJoinBevel;
            }
            
            NSString* lineCapTypeStr = _polylineStyle[@"lineCapType"];
            if ([@"kMALineCapRound" isEqualToString:lineCapTypeStr]) {
                polylineRenderer.lineCapType = kMALineCapRound;
            }else if ([@"kMALineCapArrow" isEqualToString:lineCapTypeStr]) {
                polylineRenderer.lineCapType = kMALineCapArrow;
            }else if ([@"kMALineCapSquare" isEqualToString:lineCapTypeStr]) {
                polylineRenderer.lineCapType = kMALineCapSquare;
            }else if ([@"kMALineCapButt" isEqualToString:lineCapTypeStr]) {
                polylineRenderer.lineCapType = kMALineCapButt;
            }
            
        }else{
            polylineRenderer.lineWidth    = 8.f;
            polylineRenderer.strokeColor  = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.6];
            polylineRenderer.lineJoinType = kMALineJoinRound;
            polylineRenderer.lineCapType  = kMALineCapRound;
        }
        return polylineRenderer;
    }else if ([overlay isKindOfClass:[MACircle class]]){
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        if (_circleStyle) {
            circleRenderer.lineWidth    = [_circleStyle[@"lineWidth"] doubleValue];
            circleRenderer.strokeColor  = [UIColor colorWithHexString:_circleStyle[@"strokeColor"]];
            circleRenderer.fillColor    = [UIColor colorWithHexString:_circleStyle[@"fillColor"]];
        }else{
            circleRenderer.lineWidth    = 5.f;
            circleRenderer.strokeColor  = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.8];
            circleRenderer.fillColor    = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.8];
        }
        return circleRenderer;
    }
    return nil;
}

#pragma AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    
    //搜索结果
    
    
    if (response.pois.count==0) {
        return;
    }
    
    self->_eventSink(@{@"event":@"search",
                       @"raw":[response formattedDescription],
                       });
    
}

//对象转化为字典
-(NSMutableDictionary *)onereturnToDictionaryWithModel:(AMapPOISearchResponse*)model{
    NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([AMapPOISearchResponse class], &count);
    for (int i = 0; i < count; i++) {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        id propertyValue = [model valueForKey:propertyName];
        if (propertyValue) {
            [userDic setObject:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    return userDic;
}

#pragma FlutterStreamHandler
- (FlutterError *)onCancelWithArguments:(id)arguments{
    _eventSink = nil;
    return nil;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events{
    _eventSink = events;
    return nil;
}

@end

@implementation FLTMapViewFactory{
    NSObject<FlutterBinaryMessenger>* _messenger;
}

-(instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    self = [super init];
    if (self) {
        _messenger = messenger;
    }
    return self;
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
    FLTMapViewController* viewController = [[FLTMapViewController alloc]initWithFrame:frame viewIndentifier:viewId arguments:args binaryMessenger:_messenger];
    return viewController;
}

@end
