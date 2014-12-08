TDB
===

TDB is intended for storing and requesting media files. It lets you organize media based on the qualities you associate with it, and provide you the files that meets your requirements.

Features include:
* laziest programmed tab-completion that still mostly works 
* the ability to provide synonyms and ignored words for more pleasing english grammar but no extra functionality
* file safety assuming you don't close the program while updating. But who would do that.
* written by a terrible programmer, so the code is probably simple. (Feedback is welcome however)

### Sample Usage

Let's assume you use this for pictures. Example query and potential relevant tags:
```
 only frank at kanazawa eating pizza or frank with others cycling in Munich
```
This would create shortcuts to all the pictures in the database that met one of these two requirements in a random order. It then starts the appropriate media viewer on the first image allowing them to be viewed.
Here's a breakdown:

#### Hypothetical Tags:
- Frank of type *friend*
- Kanazawa of type *city*
- eat cycle of type *action*
- pizza of type *points_of_interest*

The program reads in these tags and finds all images that match the combination we see. If a picture matches all the criteria, it is included.

*only* and others are keywords that exclude or require that more than one tag of the same type be in the picture. So 'only frank' ensures that no pictures will be included that have others in type *friend*.

#### ignored words:
- at
- with
- in

would be included in the *ignored_english* table of the database. This means that they would be ignored by the program and included for fluff.

Likewise, there would be two records for cycling and eating which link back to our base tags of eat and cycle, allowing us to type whichever feels more convenient at the time.

Both the *ignored_words* and *parsed_words* records don't yet have a way to be modified from the program. You must use sqlite to add entries. Sorry. :(

Honestly, I recommend typing
```
?
```
in the program to read how to use it. Then open up the config.yml file to set where you want everything. For example, on windows, you don't want to use eye of gnome, so you may want to set the media viewer to your prefered media viewer.

### Configuration File Explanation And Setup
Explanation of the options:
- windows: true or false. Otherwise, linux is assumed. Affects the file endings and dividers.
- internal structure: true or false. If false, all directories need to have absolute paths. Otherwise this assumes they are within the base directory
- base directory: This is the central directory all the other folders are stored, assuming internal structure is true. If you remove this from your config, it will default to the current working directory when you run the program.
- media viewer: What to run the media against. Music player, video player, image viewer...
- output directory: This is where the results of a query are stored
- database directory: All files contained in the database are stored here
- database location: This is the actual database file. If none exists, it will create one the first time the program is run.
- new files: This is the directory to put new files in that you wish to add to the database.

When run, all directories will be created automatically.

#### Windows Example Configuration File:
```
---
windows: true
base directory: C:/Users/Jungy/Desktop/tdb
internal structure: true
media viewer: rundll32 "%ProgramFiles%/Windows Photo Viewer/PhotoViewer.dll", ImageView_Fullscreen
output directory: watch
database directory: db
database location: database.db
new files: sort
deleted directory: deleted
potential duplicates: dups
```

#### Ubuntu Example Configuration File:
```
---
windows: false
base directory: /home/Jungy/tdb
internal structure: true
media viewer: eog
output directory: watch
database directory: db
database location: database.db
new files: sort
deleted directory: deleted
potential duplicates: dups
```

For music/video, I have not found a player I like which accepts shortcuts by the command line, so no
examples there.

### Requirements

- Ruby 1.9 or greater
- sqlite3

Gems:
- sqlite3
- curses
- win32-shortcut (if windows)


### TODO

- Do we need the convert_update method of uploading?
- Random Selection tag improvement
- Logging?
- That other update method should either be removed or improved and documented
- Convert Directory likewise should no longer be hard-coded in alterdatabase
- Allow ignored and parsed english to be updated from the program
