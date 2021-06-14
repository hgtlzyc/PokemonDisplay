# PokemonDisplay

Screen recording updated 06/13/21

![](https://github.com/hgtlzyc/PokemonDisplay/blob/cfad6d11ec3aee5c087aa67e1d6a83806d66d882/screenRecording.gif)



 used flatMap to limit the calls to API, maxTasks set to 1 and delay set to 0.1s

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



Goal:

Using Combine to restore, resume, track the downloading progress of large amount of pokemon infos(including pictures) from the pokemon open API

Create cache system able to restore the app after user kills the app

Able to open by URLs and set the app to corresponding status


Currently achieved:

06/13/21 request data from the Pokemon API https://pokeapi.co/ + use stepper to set the target range upper index

06/12/21 make the task able to "resume" after cancel the task( manually or app killed)

06/11/21 Kill the app and then reopen will be able to restore the downloaded values and progress 

06/10/21 Able to track, cancel, redo the download tasks 

06/09/21 Generic Property wrapper Cache system store any type conform to Codeable as json files 

Next:

improve UI + load images


Background:

Read many books and want to practice/demonstrate my skills, 

currently I did not find codes showing how to resume/track/restore downloadings using Combine,

so I decided to make my own project/ 

currently looking for entry level iOS developer jobs
