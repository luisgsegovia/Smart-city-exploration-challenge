# Implementation Criteria

## Context
Your team must develop a feature named "Smart City Exploration", enabling users to explore and search cities using an interactive map.

A remote JSON must be consumed to display the info. This mentioned JSON has the following structure:

```json

{
    "country":"UA",
    "name":"Hurzuf",
    "_id":707860,
    "coord":{
        "lon":34.283333,
        "lat":44.549999
    }
}

```

## Prefix search

Feature must perform quick search with lowercase names of the cities, each time user types or deletes a character in their search request.
Various solution alternatives were taken into account. 
A Trie solution is the one decided to be implemented for this specific use case.
A Trie is a data structure similar to a Tree, but it grows in an "inverse way", where the branches and the leafs go down as the Trie is filled with characters (or objects), creating "paths"/pointers.

A deep explanation on how Tries work can be found in the following link:

[Trying to understand Tries](https://medium.com/basecs/trying-to-understand-tries-3ec6bede0014)

Here's why it is the chosen solution:

* **Advantages:** 
    * **Efficient prefix matching:** Tries were created to solve this specific problem to excel at finding matches on prefixes, instead of performing typical searches algortihms in large data sets which can be potencially slower when a snappy UI is required.
    * **Fast lookups:** Search time is proportional to the length of the prefix
    * **Scalability:** Handles large datasets with shared prefixes in a good way
    * **Background thread execution:** Being an In-Memory solution, it's an immediate candidate to be executed in a background thread allowing a snappy UI response

 Analyzing pros and cons it's a more efficient solution, but it's good to take intro account the inherent disadvantages of this solution:
 * **Disadvantages:**
    * **Memory usage:** A Trie can potencially consumore more memory (specially with gigantic data sets) compared to simply storing the cities names in an Array, specially with long names. Each character in the city names contribute to the structure of the Trie
    * **Overkill for small problems:** For very short prefixes or data sets, a Trie can be an overkill solution where a string comparison in a Set or Array can be sufficient. 
    
The items are inyected into the `SearchHelper` which is respondible to create the Trie and handle search request to return the Search Result. The items in the Trie are handled with lowercase names to achieve a case-insensitive approach
    
### Alternative solutions
Some other alternatives were considered to be implemented to solve the Prefix search problem. Here they are:

#### Core Data Queries
* Advantages:
    * Direct Core Data communication: Core Data has an `NSFetchRequest` object that allows to create "Queries" to fetch information directly from store. 
* Disadvantages: 
    * Performance for Real-Time updates: Core Data fetch request for every character typed or deleted can potencially lead to performance decrease. Repeated fetching and filtering could force device resources and cause UI lag.
    * Load and indexing: Naturally, consulting disk resources is way slower than In-Memory
    * Search complexity: Due to the Core Data APIs, predicates can become complex to have an adequate strategy for searching, which can be difficult to understand for other developers with less Core Data experience.
    
As the main requirement for this problem was to perform quick real-time UI updates for the search functionality, the In-Memory Trie offers a more performant solution to this specific scenario. Making it the chosen approach

> **_NOTE:_**  An optional debouncing strategy can be added to avoid unnecessary computations if needed. For example, user types "New" word quickly, so the search lookup can be performed with that token, instead of performing a search for each character previously typed. Of course, this is an alternative solution to provide another layer of UI responsiveness.

## Favorites persistence

The favorites storing persistence approach is the following:

An additional `isFavorite` boolean property is added to the saved Core Data Entity that toggles each time user marks or unkarks a city. This sllows the favorites cities can be remembered accross app launches.

### Alternative solutions

Another approach is to use `UserDefaults` to store the id's that are marked as favorites. When user marks it as unfavorite, the id is removed from `UserDefaults`

### Device orientation

To solve the device UI adaptive orientation, the following was done:

`SwiftUI` has two environment properties that can be injected into the View struct. These properties are [`verticalSizeClass`](https://developer.apple.com/documentation/swiftui/environmentvalues/verticalsizeclass) and [`horizontalSizeClass`](https://developer.apple.com/documentation/swiftui/environmentvalues/horizontalsizeclass) and can be used as follows:

```swift
@Environment(\.horizontalSizeClass) private var horizontalSizeClass
@Environment(\.verticalSizeClass) private var verticalSizeClass

```
 Using a switch statement, you can determine what view instance must be shown in a device orientation, for example:
 
 ```swift

  if horizontalSizeClass == .compact {
      HorizontalCitiesListView()
    ...
  } else {
      CitiesListView()
    ...
  }
 ```

## Maps display

`MapKit` is used to display the city locatikon per item. It is rendered as follows:

```swift
var body: some View {
    MapView(latitude: latitude, longitude: longitude)
        .frame(height: 300)
}

struct MapView: UIViewRepresentable {
    let latitude: Double
    let longitude: Double
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        view.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        view.addAnnotation(annotation)
    }
}
```
