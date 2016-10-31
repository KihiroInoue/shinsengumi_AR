//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import <MapKit/MapKit.h>

#include "KMLAnnotaionView.h"

@class KMLPlacemark;
@class KMLStyle;
@class KMLStyleMap;

@interface KMLParser : NSObject <NSXMLParserDelegate> {
    NSMutableDictionary *_styles;
    NSMutableArray *_placemarks;
    NSMutableDictionary *_styleMaps;
    
    KMLPlacemark *_placemark;
    KMLStyle *_style;
    KMLStyleMap *_styleMap;
}

+ (KMLParser *)parseKMLAtURL:(NSURL *)url;
+ (KMLParser *)parseKMLAtPath:(NSString *)path;

@property (nonatomic, readonly) NSArray *overlays;
@property (nonatomic, readonly) NSArray *points;
@property (nonatomic, readonly) NSArray *kmlPlacemarkPoints;
@property (nonatomic, readonly) NSArray *placemarks;
@property (nonatomic, readonly) NSMutableDictionary *styles;
@property (nonatomic, readonly) NSMutableDictionary *styleMaps;

- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point;
- (MKOverlayRenderer *)viewForOverlay:(id <MKOverlay>)overlay;

@end

@interface KMLElement : NSObject {
    NSString *identifier;
    NSMutableString *accum;
}

- (id)initWithIdentifier:(NSString *)ident;

@property (nonatomic, readonly) NSString *identifier;

// Returns YES if we're currently parsing an element that has character
// data contents that we are interested in saving.
- (BOOL)canAddString;
// Add character data parsed from the xml
- (void)addString:(NSString *)str;
// Once the character data for an element has been parsed, use clearString to
// reset the character buffer to get ready to parse another element.
- (void)clearString;

@end

// Represents a KML <Style> element.  <Style> elements may either be specified
// at the top level of the KML document with identifiers or they may be
// specified anonymously within a Geometry element.
@interface KMLStyle : KMLElement {
    UIColor *strokeColor;
    CGFloat strokeWidth;
    UIColor *fillColor;
    
    BOOL fill;
    BOOL stroke;
    
    NSString *iconUrl;
    BOOL iconSelected;
    
    struct {
        int inLineStyle:1;
        int inPolyStyle:1;
        
        int inColor:1;
        int inWidth:1;
        int inFill:1;
        int inOutline:1;
        
        int inIconUrl:1;
        int inIconSelected:1;
        
        int inIconStyle:1;
        int inIconScale:1;
    } flags;
}

- (void)beginLineStyle;
- (void)endLineStyle;

- (void)beginPolyStyle;
- (void)endPolyStyle;

- (void)beginColor;
- (void)endColor;

- (void)beginWidth;
- (void)endWidth;

- (void)beginFill;
- (void)endFill;

- (void)beginOutline;
- (void)endOutline;

- (void)beginIconSelected;
- (void)endIconSelected;

- (void)beginIconUrl;
- (void)endIconUrl;

- (void)beginIconStyle;
- (void)endIconStyle;

- (void)beginIconScale;
- (void)endIconScale;

- (void)applyToOverlayPathView:(MKOverlayPathRenderer *)view;

@property (nonatomic, retain) NSString *iconUrl;
@property (nonatomic) CGFloat iconScale;

@end

@interface KMLStyleMap : KMLElement {
    NSString *key;
    NSString *styleID;
    
    struct {
        int inKey:1;
        int inStyleID:1;
        int inStyleIDNormal:1;
    } flags;
}

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *styleID;

- (void)beginKey;
- (void)endKey;

- (void)beginStyleID;
- (void)endStyleID;

@end

@interface KMLGeometry : KMLElement {
    struct {
        int inCoords:1;
    } flags;
}

- (void)beginCoordinates;
- (void)endCoordinates;

// Create (if necessary) and return the corresponding Map Kit MKShape object
// corresponding to this KML Geometry node.
- (MKShape *)mapkitShape;

// Create (if necessary) and return the corresponding MKOverlayPathRenderer for
// the MKShape object.
- (MKOverlayPathRenderer *)createOverlayView:(MKShape *)shape;

@end

// A KMLPoint element corresponds to an MKAnnotation and MKPinAnnotationView
@interface KMLPoint : KMLGeometry {
    CLLocationCoordinate2D point;
}

@property (nonatomic, readonly) CLLocationCoordinate2D point;

@end

// A KMLPolygon element corresponds to an MKPolygon and MKPolygonRenderer
@interface KMLPolygon : KMLGeometry {
    NSString *outerRing;
    NSMutableArray *innerRings;
    
    struct {
        int inOuterBoundary:1;
        int inInnerBoundary:1;
        int inLinearRing:1;
    } polyFlags;
}

- (void)beginOuterBoundary;
- (void)endOuterBoundary;

- (void)beginInnerBoundary;
- (void)endInnerBoundary;

- (void)beginLinearRing;
- (void)endLinearRing;

@end

@interface KMLLineString : KMLGeometry {
    CLLocationCoordinate2D *points;
    NSUInteger length;
}

@property (nonatomic, readonly) CLLocationCoordinate2D *points;
@property (nonatomic, readonly) NSUInteger length;

@end

@interface KMLPlacemark : KMLElement {
    KMLStyle *style;
    KMLGeometry *geometry;
    
    NSString *name;
    NSString *placemarkDescription;
    
    NSString *styleUrl;
    NSString *image;
    UIColor *color;
    
    MKShape *mkShape;
    
    MKAnnotationView *annotationView;
    // Deprecated: MKOverlayPathView, MKOverlayView
    MKOverlayPathRenderer *overlayView;
    
    struct {
        int inName:1;
        int inDescription:1;
        int inStyle:1;
        int inGeometry:1;
        int inStyleUrl:1;
        int inImage:1;
        int inColor:1;
    } flags;
}

- (void)beginName;
- (void)endName;

- (void)beginDescription;
- (void)endDescription;

- (void)beginStyleWithIdentifier:(NSString *)ident;
- (void)endStyle;

- (void)beginGeometryOfType:(NSString *)type withIdentifier:(NSString *)ident;
- (void)endGeometry;

- (void)beginStyleUrl;
- (void)endStyleUrl;

- (void)beginImage;
- (void)endImage;

- (void)beginColor;
- (void)endColor;

// Corresponds to the title property on MKAnnotation
@property (nonatomic, readonly) NSString *name;
// Corresponds to the subtitle property on MKAnnotation
@property (nonatomic, readonly) NSString *placemarkDescription;

@property (nonatomic, readonly) KMLGeometry *geometry;
@property (nonatomic, readonly) KMLPolygon *polygon;

@property (nonatomic, retain) KMLStyle *style;
@property (nonatomic, readonly) NSString *styleUrl;

@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) UIColor *color;

@property (nonatomic, retain) NSString *ID;

- (id <MKOverlay>)overlay;
- (id <MKAnnotation>)point;

- (MKOverlayRenderer *)overlayView;
- (MKAnnotationView *)annotationView;

@end
