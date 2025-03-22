# Use Cases & Data Flow

## Load Cities from Remote and Save Use Case
Data:
-   URL

### Primary course (happy path):

1. Execute "Retrieve Cities" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates citiy items decoding from valid data.
5. System creates cached items to be inserted
6. System inserts items into Persistent store
7. System delivers ordered city items to be displayed

### Invalid data – error course (sad path):

1.  System delivers invalid data error.

### No connectivity – error course (sad path):

1.  System delivers connectivity error.

### Flow Diagram

![image](LoadCitiesFromRemoteAndSaveUseCaseFlow.png "Load Cities from Remote and Save Use Case Flow Diagram")

## Load Cities from Local storage Use Case

### Primary course (happy path):

1. System verifies there is already cached data
2. Execute "Retrieve Cities" command from Local storage
3. System retrieves cached items
4. System creates citiy items mapping from cached data.
5. System delivers ordered city items to be displayed

### Retrieval error course (sad path):

1.  System delivers error.

### Empty cache course (sad path):

1.  System delivers no cached items.

### Flow Diagram

![image](LoadCitiesFromLocalStorageUseCaseFlow.png "Load Cities from Local storage Use Case Flow Diagram")

## Perform search Use Case
### Primary course (happy path):
1. System receives input data from user
2. Execute "Perform search" command on cached items
3. System returns items that matches with valid prefix token
4. System refreshes list with filtered items

### No Search results course:
1. System delivers no items (empty list)

### Flow Diagram

![image](PerformSearchUseCaseFlow.png "Perform search Use Case Flow Diagram")

## Adding to favorites Use Case
### Course:
1. System receives UI event from user
2. Execute "Save favorite" command on cached items
3. System perform persistent storage update
4. System updates UI marking the favorite item

### Flow Diagram

![image](PerformSearchUseCaseFlow.png "Adding to favorites Use Case Flow Diagram")

## Removing from favorites Use Case
### Course:
1. System receives UI event from user
2. Execute "Remove favorite" command on cached items
3. System perform persistent storage update
4. System updates UI unmarking the favorite item

### Flow Diagram

![image](Removing from favorites Use Case Flow Diagram")
