# Tetra Kit Player

TKP is web application that streams files and events produced by [tetra-kit](https://gitlab.com/larryth/tetra-kit/). 

It's like a PVR for tetra-kit. You can pause the live stream re-listen to old messages search, sort, download them.

TKP also features a live CMCE indicator (top right).

<img src="sscreen3.png" width="500">

- Start `decoder` and `recorder` from tetra-kit
- Start the server with `yarn start`

## Environment variables for yarn

Environment variables | description
----------------------|------------
TETRA\_KIT\_LOG\_PATH | Filepath where the log of recoder is saved to
TETRA\_KIT\_RAW\_PATH | Filepath of directory where processed data is saved
SERVER\_PORT          | Port of the server facing the user
PARCEL\_PORT          | Port of the backend server
FRONTEND\_PATH        | Path to the frontend html if not set Parcel is used to build the frontend dynamically
