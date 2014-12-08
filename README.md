TDB
===

TDB is a tag-based media organizer. Each file is provided as many or as few 'tags' as you would like to identify it. For example, a song could be 'complextro', 'orchestral', 'folk', 'latin',
of the 'genre' type. It could also be sung by 'ella_fitzgerald' and 'louis_armstrong'. 

With all media tagged, you can then assemble a collection based on the particular theme you wish to use, and it will be provided to the media viewer of your choice.

### Sample Usage

Let's assume you use this for pictures. Example query and potential relevant tags:
```
only frank at kanazawa eating pizza or frank with others cycling in Munich
```
This would create shortcuts to all the pictures in the database that met one of these two requirements in a random order. It then starts the appropriate media viewer on the first image allowing them to be viewed.

*only* is built into tdb and ensures that 'frank' is the only tag of his type (say, 'friends'). or is also, which lets you chain queries.

Special words include:
- only
- or
- not
- others

#### Adding your own language constructs:
In the prior example,
- at
- with
- in
add nothing to the query but make it nicer to read or use. Any word you like can be added as a word to just be ignored. Ignored words can be autocompleted same as any other tag.

You can also have words to represent others, to make things easier. Depending on the context from the prior example, it makes more sense to say *eating* instead of the original tag, *eat*. If you type eating it will use the eat tag.

Getting started
===

### Requirements

- Ruby 1.9 or greater (I use require_relative)
- sqlite3 (needed for sqlite3 gem)

Gems:
- sqlite3

### Setup

- Edit *config.yml* to preference. An explanation is below.
- Run tdb.rb. This will create all the files you need.
- Type *i* and then enter in a few tags and types. 
- Once you are ready, insert any media you want into the *new files* directory (default: sort/). Then, press the *u* key. one of the files will be displayed in the media viewer of your choice.
- Type any tags you wish for that file, then press enter. The next file will be presented, and so on. At any time you can stop by just typing 'q' instead.

At this point, any files you have inserted can now be queried. From the top level menu just type the query you would like!

At this point, however, I would recommend typing
```
?
```
in the program for a more specific description on what can be done.

### Configuration File Explanation And Setup
Explanation of the options:
- windows: true or false. Otherwise, linux is assumed. Affects the file endings and dividers.
- internal structure: true or false. If false, all directories need to have absolute paths. Otherwise this assumes they are within the base directory
- base directory: This is the central directory all the other folders are stored, assuming internal structure is true. If you remove this from your config, it will default to the current working directory when you run the program. If you keep it, you can use the same database regardless of where you call the program.
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

### TODO

- Do we need the convert_update method of uploading?
- Random Selection tag improvement
- Logging?
- That other update method should either be removed or improved and documented
- Convert Directory likewise should no longer be hard-coded in alterdatabase
