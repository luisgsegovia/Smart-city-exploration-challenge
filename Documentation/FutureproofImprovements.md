# Futureproof Improvements

Here are some possible improvement to the app that can be tackled that to the project scalability

## Data Sync
The current solution only retrieves the data from network. In case a future solution must implement data synchronization to be saved in the cloud, we can tackle this in the following way:
* Create a strategy to determine if the current saved data is expired or not, to retrieve the most recent data with updates. On the other hand, we can ping the server to know if the data is not updated. In that case, we can create a "query" to only update the necessary information through Backend

## Search history

To keep a history of recently searched cities for quick access, the following can be done:
* Create a new `RecentSearchesHelper` that persists the history through `UserDefaults` as it's non-sensitive and simple information. This history could be shown when the user taps in the Search field
