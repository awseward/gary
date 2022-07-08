# gary

A little home-rolled deployment thingamajig 🤷

Probably not anything to be taken all too seriously, and certainly nothing
novel or groundbreaking; just what works for me.

## Deployment

Deploying a Gary application looks something like this:

```sh
ssh <host> doas -nu <app> gary-deploy <git_revision>
```

## Configuration

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

## Why the name?

Honest, not entirely sure. Felt right, I guess…

<img src="https://user-images.githubusercontent.com/901035/177931348-5bc6807b-6019-43e1-a0bc-ca2db3190ebb.png" height="120" alt="Gary!" />
