# connect-go-fun

Playing with connect-go a bit, creating fully offline configuration with every protoc plugin installed locally into ./bin directory and used by `buf`.
Also, creating simple client/server which can be deployed to local kind cluster with `make ko-deploy-example`.

In order to try it just run `make generate` which will download all needed binaries, regenerate .go files spit out by various protoc plugins.

Fun stuff, I like connect-go better than more popular grpc plugin.
