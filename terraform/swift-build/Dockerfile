FROM swift:5.0.1

RUN apt-get -y update
RUN apt-get install -y zlib1g-dev libssl-dev

ADD . /code

RUN mkdir -p .lambda-build
#RUN swift test --generate-linuxmain
RUN swift test --build-path .lambda-build
RUN swift build --build-path .lambda-build -c release

