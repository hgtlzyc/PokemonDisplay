# PokemonDisplay

Screen recording updated 06/13/21

![](https://github.com/hgtlzyc/PokemonDisplay/blob/077e355ec85d54af01e74c69ddd843bfeb3cde61/screenRecording.gif)

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
