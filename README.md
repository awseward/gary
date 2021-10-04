# gary
Little home-rolled deployment thingamajig 🤷

### Configuration

Add a `.gary/` Directory in your project's root. Currently, includes:

##### `.gary/server`

Called to start web application server.

* Executable file (can be script or binary 🤷)
* Currently is not given any args, but that may change if deemed valuable

##### `.gary/on_deploy`

Called to do any necessary application setup (dependency install, datastore
migrations, etc…).

* Executable file (can be script or binary 🤷)
* Currently is not given any args, but that may change if deemed valuable
