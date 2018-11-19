# How to use Elm compiler from Docker image?
Just add the following alias to your .bashrc (or .bash_profile if OSX):
```bash
alias elm='docker run --rm -v $PWD:/workdir -v $PWD/.elm:/.elm -w /workdir -e http_proxy -e https_proxy semenovp/tiny-elm:latest'
```

Now you are ready to go. For example, do like this:
```bash
elm make /path/to/file.elm --output=/path/to/file.js --optimize
```


# What is about elm-analyse and elm-test tools?
Please, review the images proposed by this repository:

Elm tools available in Docker image | Docker image tags
----------------------------------- | -----------------
*elm* | latest, 0.19.0-bugfix2
*elm, elm-test* | t-latest
*elm, elm-analyse* | a-latest
*elm, elm-test, elm-analyse* | ta-latest

Just select the option you need. Please note, you have to specify the right entrypoint in your alias, e.g.:
```bash
alias elm-analyse='docker run --rm --entrypoint='elm-analyse' -v $PWD:/workdir -v $PWD/.elm:/.elm -w /workdir -e http_proxy -e https_proxy semenovp/tiny-elm:ta-latest'
```


# How to build on your own?
Use build arg `elmpackages` to select the Elm tools you want to be in Docker image:
```bash
docker build --build-arg elmpackages="elm elm-test elm-analyse" -t semenovp/tiny-elm:ta-latest .
```