//
//  Modified by FumikoIshizawa on 2014/01/30.
//  Copyright 2014 goga. All rights reserved.
//

#import "KMLParser.h"
#import "KMLPlacemarkAnnotation.h"
// KMLElement and subclasses declared here implement a class hierarchy for
// storing a KML document structure.  The actual KML file is parsed with a SAX
// parser and only the relevant document structure is retained in the object
// graph produced by the parser.  Data parsed is also transformed into
// appropriate UIKit and MapKit classes as necessary.

// Abstract KMLElement type.  Handles storing an element identifier (id="...")
// as well as a buffer for accumulating character data parsed from the xml.
// In general, subclasses should have beginElement and endElement classes for
// keeping track of parsing state.  The parser will call beginElement when
// an interesting element is encountered, then all character data found in the
// element will be stored into accum, and then when endElement is called accum
// will be parsed according to the conventions for that particular element type
// in order to save the data from the element.  Finally, clearString will be
// called to reset the character data accumulator.


// Convert a KML coordinate list string to a C array of CLLocationCoordinate2Ds.
// KML coordinate lists are longitude,latitude[,altitude] tuples specified by whitespace.
static void strToCoords(NSString *str, CLLocationCoordinate2D **coordsOut, NSUInteger *coordsLenOut)
{
    NSUInteger read = 0, space = 10;
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * space);
    
    NSArray *tuples = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString *tuple in tuples) {
        if (read == space) {
            space *= 2;
            coords = realloc(coords, sizeof(CLLocationCoordinate2D) * space);
        }
        
        double lat, lon;
        NSScanner *scanner = [[NSScanner alloc] initWithString:tuple];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@","]];
        BOOL success = [scanner scanDouble:&lon];
        if (success)
            success = [scanner scanDouble:&lat];
        if (success) {
            CLLocationCoordinate2D c = CLLocationCoordinate2DMake(lat, lon);
            if (CLLocationCoordinate2DIsValid(c))
                coords[read++] = c;
        }
    }
    
    *coordsOut = coords;
    *coordsLenOut = read;
}

@interface UIColor (KMLExtras)

// Parse a KML string based color into a UIColor.  KML colors are agbr hex encoded.
+ (UIColor *)colorWithKMLString:(NSString *)kmlColorString;

@end

@implementation KMLParser

@synthesize placemarks ;

- (id)init
{
    self = [super init];
    if (self) {
        _styles = [[NSMutableDictionary alloc] init];
        _placemarks = [[NSMutableArray alloc] init];
        _styleMaps = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// After parsing has completed, this method loops over all placemarks that have
// been parsed and looks up their corresponding KMLStyle objects according to
// the placemark's styleUrl property and the global KMLStyle object's identifier.
- (void)_assignStyles
{
    for (KMLPlacemark *placemark in _placemarks) {
        if (!placemark.style && placemark.styleUrl) {
            NSString *styleUrl = placemark.styleUrl;
            NSRange range = [styleUrl rangeOfString:@"#"];
            if (range.length == 1 && range.location == 0) {
                NSString *styleID = [styleUrl substringFromIndex:1];
                KMLStyle *style = [_styles objectForKey:styleID];
                placemark.style = style;
            }
        }
    }
}

+ (KMLParser *)parseKMLAtURL:(NSURL *)url
{
    NSXMLParser *xml = [[NSXMLParser alloc] initWithContentsOfURL:url];
    KMLParser *parser = [[KMLParser alloc] init];
    [xml setDelegate:parser];
    [xml parse];
    [parser _assignStyles];
    return parser;
}

+ (KMLParser *)parseKMLAtPath:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    return [KMLParser parseKMLAtURL:url];
}

// Return the list of KMLPlacemarks from the object graph that contain overlays
// (as opposed to simply point annotations).
- (NSArray *)overlays
{
    NSMutableArray *overlays = [[NSMutableArray alloc] init];
    for (KMLPlacemark *placemark in _placemarks) {
        id <MKOverlay> overlay = [placemark overlay];
        if (overlay)
            [overlays addObject:overlay];
    }
    return overlays;
}

// Return the list of KMLPlacemarks from the object graph that are simply
// MKPointAnnotations and are not MKOverlays.
- (NSArray *)points
{
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for (KMLPlacemark *placemark in _placemarks) {
        
        
        id <MKAnnotation> point = [placemark point];
        
        if (point)
            
            [points addObject:point];
    }
    return points;
}

- (NSArray *)kmlPlacemarkPoints
{
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for (KMLPlacemark *placemark in _placemarks) {
        
        
        id <MKAnnotation> point = [placemark point];
        
        if (point) {
            [points addObject:[[KMLPlacemarkAnnotation alloc] initWithKMLPlacemark:placemark coordinate:[point coordinate]]];
        }
    }
    return points;
}



- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point
{
    // Find the KMLPlacemark object that owns this point and get
    // the view from it.
    for (KMLPlacemark *placemark in _placemarks) {
        if ([placemark point] == point)
            return [placemark annotationView];
    }
    return nil;
}

- (MKOverlayRenderer *)viewForOverlay:(id <MKOverlay>)overlay
{
    // Find the KMLPlacemark object that owns this overlay and get
    // the view from it.
    for (KMLPlacemark *placemark in _placemarks) {
        if ([placemark overlay] == overlay)
            return [placemark overlayView];
    }
    return nil;
}

#pragma mark NSXMLParserDelegate

#define ELTYPE(typeName) (NSOrderedSame == [elementName caseInsensitiveCompare:@#typeName])

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    NSString *ident = [attributeDict objectForKey:@"id"];
    
    KMLStyle *style = [_placemark style] ? [_placemark style] : _style;
    
    // Style and sub-elements
    if (ELTYPE(Style)) {
        if (_placemark) {
            [_placemark beginStyleWithIdentifier:ident];
        } else if (ident != nil) {
            _style = [[KMLStyle alloc] initWithIdentifier:ident];
        }
    } else if (ELTYPE(StyleMap)) {
        if (ident != nil) {
            _styleMap = [[KMLStyleMap alloc] initWithIdentifier:ident];
        }
    } else if (ELTYPE(key)) {
        if (_styleMap) {
            [_styleMap beginKey];
        }
    } else if (ELTYPE(IconStyle)) {
        [style beginIconStyle];
    } else if (ELTYPE(scale)) {
        [style beginIconScale];
    } else if (ELTYPE(StyleUrl)) {
        if (_styleMap) {
            [_styleMap beginStyleID];
        } else {
            [_placemark beginStyleUrl];
        }
    } else if (ELTYPE(PolyStyle)) {
        [style beginPolyStyle];
    } else if (ELTYPE(LineStyle)) {
        [style beginLineStyle];
    } else if (ELTYPE(color)) {
        [style beginColor];
    } else if (ELTYPE(width)) {
        [style beginWidth];
    } else if (ELTYPE(fill)) {
        [style beginFill];
    } else if (ELTYPE(outline)) {
        [style beginOutline];
    } else if (ELTYPE(Icon)) {
        [style beginIconSelected];
    } else if (ELTYPE(href)) {
        [style beginIconUrl];
    }
    // Placemark and sub-elements
    else if (ELTYPE(Placemark)) {
        _placemark = [[KMLPlacemark alloc] initWithIdentifier:ident];
    } else if (ELTYPE(Name)) {
        [_placemark beginName];
    } else if (ELTYPE(Description)) {
        [_placemark beginDescription];
    }
    //    else if (ELTYPE(styleUrl)) {
    //        [_placemark beginStyleUrl];
    //    }
    else if (ELTYPE(Polygon) || ELTYPE(Point) || ELTYPE(LineString)) {
        [_placemark beginGeometryOfType:elementName withIdentifier:ident];
    } else if (ELTYPE(image)) {
        [_placemark beginImage];
    } else if (ELTYPE(infoColor)) {
        [_placemark beginColor];
    }
    // Geometry sub-elements
    else if (ELTYPE(coordinates)) {
        [_placemark.geometry beginCoordinates];
    }
    // Polygon sub-elements
    else if (ELTYPE(outerBoundaryIs)) {
        [_placemark.polygon beginOuterBoundary];
    } else if (ELTYPE(innerBoundaryIs)) {
        [_placemark.polygon beginInnerBoundary];
    } else if (ELTYPE(LinearRing)) {
        [_placemark.polygon beginLinearRing];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    KMLStyle *style = [_placemark style] ? [_placemark style] : _style;
    
    // Style and sub-elements
    if (ELTYPE(Style)) {
        if (_placemark) {
            [_placemark endStyle];
            //•• style = _style;
        } else if (_style) {
            [_styles setObject:_style forKey:_style.identifier];
            _style = nil;
        }
    } else if (ELTYPE(StyleMap)){
        if (_styleMap && _styleMap.styleID != nil) {
            [_styleMaps setObject:_styleMap.styleID forKey:_styleMap.identifier];
            _styleMap = nil;
        }
    } else if (ELTYPE(key)) {
        if (_styleMap) {
            [_styleMap endKey];
        }
    } else if (ELTYPE(IconStyle)) {
        [style endIconStyle];
    } else if (ELTYPE(scale)) {
        [style endIconScale];
    } else if (ELTYPE(StyleUrl)) {
        if (_styleMap) {
            [_styleMap endStyleID];
        } else {
            [_placemark endStyleUrl];
        }
    } else if (ELTYPE(PolyStyle)) {
        [style endPolyStyle];
    } else if (ELTYPE(LineStyle)) {
        [style endLineStyle];
    } else if (ELTYPE(color)) {
        [style endColor];
    } else if (ELTYPE(width)) {
        [style endWidth];
    } else if (ELTYPE(fill)) {
        [style endFill];
    } else if (ELTYPE(outline)) {
        [style endOutline];
    } else if (ELTYPE(Icon)) {
        [style endIconSelected];
    } else if (ELTYPE(href)) {
        [style endIconUrl];
    }
    // Placemark and sub-elements
    else if (ELTYPE(Placemark)) {
        if (_placemark) {
            [_placemarks addObject:_placemark];
            _placemark = nil;
        }
    } else if (ELTYPE(Name)) {
        [_placemark endName];
    } else if (ELTYPE(Description)) {
        [_placemark endDescription];
    }
    //    else if (ELTYPE(styleUrl)) {
    //        [_placemark endStyleUrl];
    //    }
    else if (ELTYPE(Polygon) || ELTYPE(Point) || ELTYPE(LineString)) {
        [_placemark endGeometry];
    } else if (ELTYPE(image)) {
        [_placemark endImage];
    } else if (ELTYPE(infoColor)) {
        [_placemark endColor];
        // Geometry sub-elements
    } else if (ELTYPE(coordinates)) {
        [_placemark.geometry endCoordinates];
    }
    // Polygon sub-elements
    else if (ELTYPE(outerBoundaryIs)) {
        [_placemark.polygon endOuterBoundary];
    } else if (ELTYPE(innerBoundaryIs)) {
        [_placemark.polygon endInnerBoundary];
    } else if (ELTYPE(LinearRing)) {
        [_placemark.polygon endLinearRing];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    KMLElement *element;
    if (_placemark) {
        element = (KMLElement *)_placemark;
    } else if (_style) {
        element = (KMLElement *)_style;
    } else if (_styleMap) {
        element = (KMLElement *)_styleMap;
    } else {
        return;
    }
    [element addString:string];
}

@end

// Begin the implementations of KMLElement and subclasses.  These objects
// act as state machines during parsing time and then once the document is
// fully parsed they act as an object graph for describing the placemarks and
// styles that have been parsed.

@implementation KMLElement

@synthesize identifier;

- (id)initWithIdentifier:(NSString *)ident
{
    self = [super init];
    if (self) {
        identifier = ident;
    }
    return self;
}

- (BOOL)canAddString
{
    return NO;
}

- (void)addString:(NSString *)str
{
    if ([self canAddString]) {
        if (!accum)
            accum = [[NSMutableString alloc] init];
        [accum appendString:str];
    }
}

- (void)clearString
{
    accum = nil;
}

@end

@implementation KMLStyle
@synthesize iconUrl;
@synthesize iconScale;

- (BOOL)canAddString {
    return flags.inColor || flags.inWidth || flags.inFill || flags.inOutline ||
    flags.inIconUrl || flags.inIconScale;
}

- (void)beginLineStyle {
    flags.inLineStyle = YES;
}
- (void)endLineStyle {
    flags.inLineStyle = NO;
}

- (void)beginPolyStyle {
    flags.inPolyStyle = YES;
}

- (void)endPolyStyle {
    flags.inPolyStyle = NO;
}

- (void)beginColor {
    flags.inColor = YES;
}

- (void)endColor {
    flags.inColor = NO;
    
    if (flags.inLineStyle) {
        strokeColor = [UIColor colorWithKMLString:accum];
    } else if (flags.inPolyStyle) {
        fillColor = [UIColor colorWithKMLString:accum];
    }
    
    [self clearString];
}

- (void)beginWidth {
    flags.inWidth = YES;
}
- (void)endWidth {
    flags.inWidth = NO;
    strokeWidth = [accum floatValue];
    [self clearString];
}

- (void)beginFill {
    flags.inFill = YES;
}

- (void)endFill {
    flags.inFill = NO;
    fill = [accum boolValue];
    [self clearString];
}

- (void)beginOutline {
    flags.inOutline = YES;
}
- (void)endOutline {
    stroke = [accum boolValue];
    [self clearString];
}

- (void)beginIconSelected {
    flags.inIconSelected = YES;
}

- (void)endIconSelected {
    flags.inIconSelected = NO;
}

- (void)beginIconUrl {
    if (flags.inIconSelected) {
        flags.inIconUrl = YES;
    }
}

- (void)endIconUrl {
    flags.inIconUrl = NO;
    iconUrl = [accum copy];
    [self clearString];
}

- (void)beginIconStyle {
    flags.inIconStyle = YES;
}

- (void)endIconStyle {
    flags.inIconStyle = NO;
}

- (void)beginIconScale {
    flags.inIconScale = YES;
}

- (void)endIconScale {
    flags.inIconScale = NO;
    if (flags.inIconStyle) {
        iconScale = [accum floatValue];
        [self clearString];
    }
}

- (void)applyToOverlayPathView:(MKOverlayPathRenderer *)view {
    view.strokeColor = strokeColor;
    view.fillColor = fillColor;
    view.lineWidth = strokeWidth;
}

@end

@implementation KMLStyleMap
@synthesize key;
@synthesize styleID;

- (BOOL)canAddString {
    return flags.inKey || flags.inStyleID;
}

- (void)beginKey {
    flags.inKey = YES;
}

- (void)endKey {
    // 現在"normal"のみに対応しています
    if ([accum isEqual:@"normal"]) {
        flags.inStyleIDNormal = YES;
    }
    flags.inKey = NO;
    [self clearString];
}

- (void)beginStyleID {
    flags.inStyleID = YES;
}

- (void)endStyleID {
    flags.inStyleID = NO;
    if (flags.inStyleIDNormal) {
        flags.inStyleIDNormal = NO;
        NSString *str = [accum stringByReplacingOccurrencesOfString:@"#" withString:@""];
        styleID = [str copy];
        [self clearString];
    }
}

@end

@implementation KMLGeometry

- (BOOL)canAddString
{
    return flags.inCoords;
}

- (void)beginCoordinates
{
    flags.inCoords = YES;
}

- (void)endCoordinates
{
    flags.inCoords = NO;
}

- (MKShape *)mapkitShape
{
    return nil;
}

- (MKOverlayPathRenderer *)createOverlayView:(MKShape *)shape
{
    return nil;
}

@end

@implementation KMLPoint

@synthesize point;

- (void)endCoordinates
{
    flags.inCoords = NO;
    
    CLLocationCoordinate2D *points = NULL;
    NSUInteger len = 0;
    
    strToCoords(accum, &points, &len);
    if (len == 1) {
        point = points[0];
    }
    free(points);
    
    [self clearString];
}

- (MKShape *)mapkitShape
{
    // KMLPoint corresponds to MKPointAnnotation
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = point;
    return annotation;
}

// KMLPoint does not override createOverlayView: because there is no such
// thing as an overlay view for a point.  They use MKAnnotationViews which
// are vended by the KMLPlacemark class.

@end

@implementation KMLPolygon

- (BOOL)canAddString
{
    return polyFlags.inLinearRing && flags.inCoords;
}

- (void)beginOuterBoundary
{
    polyFlags.inOuterBoundary = YES;
}
- (void)endOuterBoundary
{
    polyFlags.inOuterBoundary = NO;
    outerRing = [accum copy];
    [self clearString];
}

- (void)beginInnerBoundary
{
    polyFlags.inInnerBoundary = YES;
}
- (void)endInnerBoundary
{
    polyFlags.inInnerBoundary = NO;
    NSString *ring = [accum copy];
    if (!innerRings) {
        innerRings = [[NSMutableArray alloc] init];
    }
    [innerRings addObject:ring];
    [self clearString];
}

- (void)beginLinearRing
{
    polyFlags.inLinearRing = YES;
}
- (void)endLinearRing
{
    polyFlags.inLinearRing = NO;
}

- (MKShape *)mapkitShape
{
    // KMLPolygon corresponds to MKPolygon
    
    // The inner and outer rings of the polygon are stored as kml coordinate
    // list strings until we're asked for mapkitShape.  Only once we're here
    // do we lazily transform them into CLLocationCoordinate2D arrays.
    
    // First build up a list of MKPolygon cutouts for the interior rings.
    NSMutableArray *innerPolys = nil;
    if (innerRings) {
        innerPolys = [[NSMutableArray alloc] initWithCapacity:[innerPolys count]];
        for (NSString *coordStr in innerRings) {
            CLLocationCoordinate2D *coords = NULL;
            NSUInteger coordsLen = 0;
            strToCoords(coordStr, &coords, &coordsLen);
            [innerPolys addObject:[MKPolygon polygonWithCoordinates:coords count:coordsLen]];
            free(coords);
        }
    }
    // Now parse the outer ring.
    CLLocationCoordinate2D *coords = NULL;
    NSUInteger coordsLen = 0;
    strToCoords(outerRing, &coords, &coordsLen);
    
    // Build a polygon using both the outer coordinates and the list (if applicable)
    // of interior polygons parsed.
    MKPolygon *poly = [MKPolygon polygonWithCoordinates:coords count:coordsLen interiorPolygons:innerPolys];
    free(coords);
    return poly;
}

- (MKOverlayPathRenderer *)createOverlayView:(MKShape *)shape
{
    // KMLPolygon corresponds to MKPolygonRenderer
    
    MKPolygonRenderer *polyView = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)shape];
    return polyView;
}

@end

@implementation KMLLineString

@synthesize points, length;

- (void)endCoordinates
{
    flags.inCoords = NO;
    
    if (points)
        free(points);
    
    strToCoords(accum, &points, &length);
    
    [self clearString];
}

- (MKShape *)mapkitShape
{
    // KMLLineString corresponds to MKPolyline
    return [MKPolyline polylineWithCoordinates:points count:length];
}

- (MKOverlayPathRenderer *)createOverlayView:(MKShape *)shape
{
    // KMLLineString corresponds to MKPolylineView
    MKPolylineRenderer *lineView = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)shape];
    return lineView;
}

@end

@implementation KMLPlacemark

@synthesize style, styleUrl, geometry, name, placemarkDescription, image, color;

- (BOOL)canAddString
{
    return flags.inName || flags.inStyleUrl || flags.inDescription || flags.inImage || flags.inColor;
}

- (void)addString:(NSString *)str
{
    if (flags.inStyle)
        [style addString:str];
    else if (flags.inGeometry)
        [geometry addString:str];
    else
        [super addString:str];
}

- (void)beginName
{
    flags.inName = YES;
}
- (void)endName
{
    flags.inName = NO;
    name = [accum copy];
    [self clearString];
}

- (void)beginDescription
{
    flags.inDescription = YES;
}
- (void)endDescription
{
    flags.inDescription = NO;
    placemarkDescription = [accum copy];
    [self clearString];
}

- (void)beginStyleUrl
{
    flags.inStyleUrl = YES;
}
- (void)endStyleUrl
{
    flags.inStyleUrl = NO;
    NSString *str = [accum stringByReplacingOccurrencesOfString:@"#" withString:@""];
    styleUrl = [str copy];
    [self clearString];
}

- (void)beginImage {
    flags.inImage = YES;
}

- (void)endImage {
    flags.inImage = NO;
    image = [accum copy];
    [self clearString];
}

- (void)beginColor {
    flags.inColor = YES;
}

- (void)endColor {
    flags.inColor = NO;
    color = [UIColor colorWithKMLString:accum];
    [self clearString];
}

- (void)beginStyleWithIdentifier:(NSString *)ident
{
    flags.inStyle = YES;
    style = [[KMLStyle alloc] initWithIdentifier:ident];
}
- (void)endStyle
{
    flags.inStyle = NO;
}

- (void)beginGeometryOfType:(NSString *)elementName withIdentifier:(NSString *)ident
{
    flags.inGeometry = YES;
    if (ELTYPE(Point))
        geometry = [[KMLPoint alloc] initWithIdentifier:ident];
    else if (ELTYPE(Polygon))
        geometry = [[KMLPolygon alloc] initWithIdentifier:ident];
    else if (ELTYPE(LineString))
        geometry = [[KMLLineString alloc] initWithIdentifier:ident];
}
- (void)endGeometry
{
    flags.inGeometry = NO;
}

- (KMLGeometry *)geometry
{
    return geometry;
}

- (KMLPolygon *)polygon
{
    return [geometry isKindOfClass:[KMLPolygon class]] ? (id)geometry : nil;
}

- (void)_createShape
{
    if (!mkShape) {
        mkShape = [geometry mapkitShape];
        mkShape.title = name;
        // Skip setting the subtitle for now because they're frequently
        // too verbose for viewing on in a callout in most kml files.
        //        mkShape.subtitle = placemarkDescription;
    }
}

- (id <MKOverlay>)overlay
{
    [self _createShape];
    
    if ([mkShape conformsToProtocol:@protocol(MKOverlay)])
        return (id <MKOverlay>)mkShape;
    
    return nil;
}

- (id <MKAnnotation>)point
{
    [self _createShape];
    
    // Make sure to check if this is an MKPointAnnotation.  MKOverlays also
    // conform to MKAnnotation, so it isn't sufficient to just check to
    // conformance to MKAnnotation.
    if ([mkShape isKindOfClass:[MKPointAnnotation class]])
        return (id <MKAnnotation>)mkShape;
    
    return nil;
}

- (MKOverlayRenderer *)overlayView
{
    if (!overlayView) {
        id <MKOverlay> overlay = [self overlay];
        if (overlay) {
            overlayView = [geometry createOverlayView:overlay];
            [style applyToOverlayPathView:overlayView];
        }
    }
    return overlayView;
}


- (MKAnnotationView *)annotationView
{
    if (!annotationView) {
        id <MKAnnotation> annotation = [self point];
        if (annotation) {
            MKPinAnnotationView *pin =
            [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
            pin.canShowCallout = YES;
            pin.animatesDrop = NO;
            annotationView = pin;
        }
    }
    return annotationView;
}

@end

@implementation UIColor (KMLExtras)

+ (UIColor *)colorWithKMLString:(NSString *)kmlColorString
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:kmlColorString];
    unsigned color = 0;
    [scanner scanHexInt:&color];
    
    CGFloat red = ((color & 0xff000000) >> 24) / 255.0f;
    CGFloat green = ((color & 0x00ff0000) >> 16) / 255.0f;
    CGFloat blue = ((color & 0x0000ff00) >> 8) / 255.0f;
    CGFloat alpha = (color & 0x000000ff) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end


