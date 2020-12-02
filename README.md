[![Elm:0.19.1](https://img.shields.io/badge/Elm-0.19.1-green.svg)](https://elm-lang.org/)
[![](https://img.shields.io/docker/image-size/semenovp/tiny-elm/latest)](https://hub.docker.com/r/semenovp/tiny-elm/)
[![](https://img.shields.io/microbadger/layers/semenovp/tiny-elm/latest)](https://microbadger.com/images/semenovp/tiny-elm/)
[![Docker Pull](https://img.shields.io/docker/pulls/semenovp/tiny-elm.svg)](https://hub.docker.com/r/semenovp/tiny-elm/)


# How to use Elm compiler/tools from this Docker image?
Just use the following alias template to modify your .bashrc (or .bash_profile if OSX):
```bash
alias <cmd>='docker run --rm --entrypoint "<cmd>" -v `pwd`:/workdir -v `pwd`/.elm:/.elm -w /workdir -e http_proxy -e https_proxy semenovp/tiny-elm:ta-latest'
```

The placeholder `<cmd>` stands for `elm` or tools like `elm-analyse`, `elm-test`, etc.

Now you are ready to go. For example, do like this:
```bash
elm make /path/to/file.elm --output=/path/to/file.js --optimize

elm-test --version
> 0.19.1-revision4
```


# What Docker images are provided?
Please, review the images proposed by this repository.

| Elm tools available in Docker image | Docker image tags |
|:-----------------------------------:|:-----------------:|
| *elm* | latest, 0.19.1 |
| *elm, elm-test* | t-latest |
| *elm, elm-analyse* | a-latest |
| *elm, elm-review* | r-latest |
| *elm, elm-test, elm-analyse* | ta-latest |
| *elm, elm-test, elm-analyse, elm-review* | all-latest |


# How to build on your own?
Use build arg `elmpackages` to select the Elm tools you want to be in Docker image.
```bash
docker build --build-arg elmpackages="elm-test elm-coverage elm-esm" -t semenovp/tiny-elm:tce-latest .
```

# List of competing Docker images

Review the sizes of another elm-related images retrieved from [DockerHub](https://hub.docker.com) against current one built on Elm v0.19.1.

| REPOSITORY | YYYY-MM-DD | COMPRESSED / UNCOMPRESSED SIZE |
|:-----------|:----------:|:------------------------------:|
| **[semenovp/tiny-elm:latest](https://hub.docker.com/r/semenovp/tiny-elm/)** | 2020-12-02 | **/ 30.1MB** |
