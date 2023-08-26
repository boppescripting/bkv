# bkv - Abstract KVP System for FiveM
An abstract KVP system built around the pre-included functionality provided by FiveM, but simplified in a way that anyone may easily use it. **bkv** includes functions such as creating a "database", saving, updating, deleting, and searching.
## Features
- Easily create and manage multiple data collections.
- Saving and fetching utilizing json encoding for massive data sets.
- Data collections are preloaded to reduce the load on the server when data fetching is needed.
- A simple caching system that only updates the collections that saw a change since the last update.
- Simple auto-saving functionality.
## Documentation
To easily understand how to use this system, refer to `API.md`, which provides examples and short explainations of the functions.
## Installation
1. Drag-and-drop the script into one of your resource folders. Ensure this resource starts before any other resource that uses it.
2. Remove `-main` from the folder name for this resource.
3. In your `server.cfg` file, add the following line: `set bkv:UpdateInterval <time, in minutes, between auto-saves>`.
## Contributions
Any and all pull requests are appreciated. They will be reviewed in the order received and tested to ensure they do not break the script.
## Issues
If you run into any issues, please open an issue on this Github page. Ensure to include any screenshots as they may be vital to resolving the issue, along with an explaination as to how you are using the code and what is happening.
## License
This project is licensed under the [GNU GPL v3.0 license](https://choosealicense.com/licenses/gpl-3.0/). To understand what this license entails, you may click the link for an explaination.
## Disclaimer
This system has been tested in specific use-cases. Understand that, in it's current state, the resource may require additional work to reach a production-ready stage. This resource was originally created for educational purposes.