# PokemonDisplay

Screen recording updated 06/15/21, calling API "https://pokeapi.co/api/v2/pokemon/\(id)"

![](https://github.com/hgtlzyc/PokemonDisplay/blob/225c53fc4e3f02d16c9ea43c0d93ae59aa1241a5/screenRecording.gif)



 used flatMap to limit the calls to API, maxTasks set to 1 and delay set to 0.1s, 

```swift
            .flatMap(maxPublishers: .max(maxTasks)) { urlString -> AnyPublisher<PokemonDataModel, AppError> in
                do {
                    let publisher = try generateSinglePokemonDMPublisher(urlString)
                    return publisher
                        .delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue(label: urlString))
                        .eraseToAnyPublisher()
                    
                } catch let err {
                    return Fail<PokemonDataModel, AppError>(error: AppError.networkError(err)).eraseToAnyPublisher()
                }
            }
```

*** 

FOR simple ui testing
change the `networkEnvironment: kDevelopmentEnvironment = .realAPI` to `.simulator`, to protect the public API 


### Goal:
 
Using Combine to restore, resume, track the downloading progress of large amount of pokemon infos(including pictures) from the pokemon open API

Create cache system able to restore the app after user kills the app

Able to open by URLs and set the app to corresponding status




### Achieved:
- [x] able to adjust both the lower and upper bound

- [x]  display images from API 06/14/21

- [x] request data from the Pokemon API https://pokeapi.co/ + use stepper to set the target range upper index 06/13/21

- [x] make the task able to "resume" after cancel the task( manually or app killed) 06/12/21

- [x] Kill the app and then reopen will be able to restore the downloaded values and progress  06/11/21

- [x] Able to track, cancel, redo the download tasks 06/10/21

- [x] Generic Property wrapper Cache system store any type conform to Codeable as json files 06/09/21



### Next:

improve UI + Able to open by URLs and set the app to corresponding status

### Contact
hgtlzyc92@gmail.com
