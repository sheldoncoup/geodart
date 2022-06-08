import 'package:geodart/features.dart';

/// A [MultiPolygon] is a collection of [Polygon] Geometries with shared properties.
class MultiPolygon extends Feature {
  List<List<LinearRing>> coordinates;
  static final String type = 'MultiPolygon';

  MultiPolygon(this.coordinates, {properties = const <String, dynamic>{}})
      : super(properties: properties);

  @override
  String toString() {
    return coordinates.map((poly) => poly.toString()).toList().join(',');
  }

  /// Converts the [MultiPolygon] to a WKT [String].
  ///
  /// Example:
  /// ```dart
  /// MultiPolygon([
  ///   [
  ///     LinearRing([Coordinate(1, 2), Coordinate(3, 4), Coordinate(5, 6), Coordinate(1, 2)])
  ///   ],
  ///   [
  ///     LinearRing([Coordinate(7, 8), Coordinate(9, 10), Coordinate(11, 12), Coordinate(7, 8)])
  ///   ]
  /// ]).toWKT(); // MULTIPOLYGON(((1 2, 3 4, 5 6, 1 2)), ((7 8, 9 10, 11 12, 7 8)))
  /// ```
  @override
  String toWKT() {
    return 'MULTIPOLYGON(${coordinates.map((poly) => "(${poly.map((ring) => "(${ring.coordinates.map((c) => c.toWKT()).toList()})").toList()})").join(',')})';
  }

  /// Returns a GeoJSON representation of the [MultiPolygon]
  ///
  /// Example:
  /// ```dart
  /// MultiPolygon([
  ///   [
  ///     LinearRing([Coordinate(1, 2), Coordinate(3, 4), Coordinate(5, 6), Coordinate(1, 2)])
  ///   ],
  ///   [
  ///     LinearRing([Coordinate(7, 8), Coordinate(9, 10), Coordinate(11, 12), Coordinate(7, 8)])
  ///   ]
  /// ]).toJson(); // {'type': 'Feature', 'geometry': {'type': 'MultiPolygon', 'coordinates': [[[[1, 2], [3, 4], [5, 6], [1, 2]]], [[[7, 8], [9, 10], [11, 12], [7, 8]]]]}, 'properties': {}}
  /// ```
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'MultiPolygon',
        'coordinates': coordinates
            .map((poly) =>
                poly.map((ring) => ring.coordinates.map((c) => c.toJson())))
            .toList()
      },
      'properties': properties,
    };
  }

  /// Creates a [MultiPolygon] from a GeoJSON [Map].
  ///
  /// Example:
  /// ```dart
  /// MultiPolygon.fromJson({'type': 'Feature', 'geometry': {'type': 'MultiPolygon', 'coordinates': [[[[1, 2], [3, 4], [5, 6], [1, 2]]], [[[7, 8], [9, 10], [11, 12], [7, 8]]]]}, 'properties': {}}); // MultiPolygon([[LinearRing([Coordinate(1, 2), Coordinate(3, 4), Coordinate(5, 6), Coordinate(1, 2)]), LinearRing([Coordinate(7, 8), Coordinate(9, 10), Coordinate(11, 12), Coordinate(7, 8)])]])
  /// ```
  @override
  factory MultiPolygon.fromJson(Map<String, dynamic> json) {
    if (json['geometry']['type'] != 'MultiPolygon') {
      throw ArgumentError('json is not a MultiPolygon');
    }

    return MultiPolygon(
      (json['geometry']['coordinates'] as List<List<List<List<double>>>>)
          .map((dynamic poly) => (poly as List<List<List<double>>>)
              .map((dynamic shape) => LinearRing((shape as List<List<double>>)
                  .map((dynamic coord) => Coordinate.fromJson(coord))
                  .toList()))
              .toList())
          .toList(),
      properties: Map<String, dynamic>.from(json['properties']),
    );
  }

  /// explode the [MultiPolygon] into a [List] of [Point]s.
  ///
  /// Example:
  /// ```dart
  /// MultiPolygon([
  ///   [
  ///     LinearRing([Coordinate(1, 2), Coordinate(3, 4), Coordinate(5, 6), Coordinate(1, 2)])
  ///   ],
  ///   [
  ///     LinearRing([Coordinate(7, 8), Coordinate(9, 10), Coordinate(11, 12), Coordinate(7, 8)])
  ///   ]
  /// ]).explode(); // [Point(1, 2), Point(3, 4), Point(5, 6), Point(1, 2), Point(7, 8), Point(9, 10), Point(11, 12), Point(7, 8)]
  /// ```
  @override
  List<Point> explode() {
    final explodedFeatures = <Point>[];
    for (final poly in coordinates) {
      explodedFeatures.addAll(poly
          .map((ring) => ring.coordinates.map((cord) => Point(cord)).toList())
          .toList()
          .expand((i) => i)
          .toList());
    }
    return explodedFeatures;
  }

  /// Converts the [MultiPolygon] to a WKT a [MultiLineString].
  /// Uses the outer ring of each polygon, all holes are ignored.
  ///
  /// Example:
  /// ```dart
  /// MultiPolygon([
  ///   [
  ///     LinearRing([Coordinate(1, 2), Coordinate(3, 4), Coordinate(5, 6), Coordinate(1, 2)])
  ///   ],
  ///   [
  ///     LinearRing([Coordinate(7, 8), Coordinate(9, 10), Coordinate(11, 12), Coordinate(7, 8)])
  ///   ]
  /// ]).toMultiLineString(); // MultiLineString([[Coordinate(1, 2), Coordinate(3, 4), Coordinate(5, 6), Coordinate(1, 2)], [Coordinate(7, 8), Coordinate(9, 10), Coordinate(11, 12), Coordinate(7, 8)]])
  MultiLineString toMultiLineString() {
    return MultiLineString(
        coordinates.map((poly) => poly.first.coordinates).toList());
  }

  /// Breaks the [MultiPolygon] into a [FeatureCollection] containing each [Polygon]s.
  /// Also, copies the [properties] of the [MultiPolygon] to each [Polygon].
  ///
  /// Example:
  /// ```dart
  /// MultiPolygon([
  ///   [
  ///     LinearRing([Coordinate(1, 2), Coordinate(3, 4), Coordinate(5, 6), Coordinate(1, 2)])
  ///   ],
  ///   [
  ///     LinearRing([Coordinate(7, 8), Coordinate(9, 10), Coordinate(11, 12), Coordinate(7, 8)])
  ///   ]
  /// ]).flatten(); // FeatureCollection([Polygon([LinearRing([Coordinate(1, 2), Coordinate(3, 4), Coordinate(5, 6), Coordinate(1, 2)])]),Polygon([LinearRing([Coordinate(7, 8), Coordinate(9, 10), Coordinate(11, 12), Coordinate(7, 8)])])])
  /// ```
  FeatureCollection flatten() {
    return FeatureCollection(coordinates
        .map((poly) => Polygon(poly, properties: properties))
        .toList());
  }

  /// Returns a [MultiPolygon] that is the union of this [MultiPolygon] and another [MultiPolygon].
  /// The resulting [MultiPolygon] will have the same [properties] as this [MultiPolygon].
  ///
  /// Example:
  /// ```dart
  /// MultiPolygon([[LinearRing([Coordinate(1, 2), Coordinate(3, 4), Coordinate(5, 6), Coordinate(1, 2)])]]).union(MultiPolygon([[LinearRing([Coordinate(7, 8), Coordinate(9, 10), Coordinate(11, 12), Coordinate(7, 8)])]])); // MultiPolygon([[LinearRing([Coordinate(1, 2), Coordinate(3, 4), Coordinate(5, 6), Coordinate(1, 2)])], [LinearRing([Coordinate(7, 8), Coordinate(9, 10), Coordinate(11, 12), Coordinate(7, 8)])]])
  /// ```
  MultiPolygon union(MultiPolygon other) {
    return MultiPolygon([
      ...coordinates,
      ...other.coordinates,
    ], properties: properties);
  }

  /// The area of the [MultiPolygon] in square meters.
  ///
  /// Example:
  /// ```dart
  /// MultiPolygon([[LinearRing([Coordinate(1, 2), Coordinate(3, 4), Coordinate(5, 6), Coordinate(1, 2)])]]).area; // 0.0
  /// ```
  double get area {
    return coordinates.fold(
        0.0, (double acc, poly) => acc + Polygon(poly).area);
  }
}
