# McKay and Greg's Wedding Site

[![Build Status](https://dev.azure.com/gregscottatkin/WeddingSite/_apis/build/status/gatkin.WeddingSite?branchName=master)](https://dev.azure.com/gregscottatkin/WeddingSite/_build/latest?definitionId=6&branchName=master)

Simple site for information about our wedding and recording RSVPs.

The site is hosted and run by stitching together a variety of free and low-cost tier services:

- The backend is hosted as a Docker container running on Heroku
- The database is a Firebase Cloud Firestore database
- The custom domain name was purchased from Google domains

The app is built with

- .NET core backend
- [Elm](https://elm-lang.org/) frontend for the interactive RSVP page
- Vanilla bootstrap for styling
