FROM swift:5.0.1

RUN apt-get -y update && apt-get install -y zlib1g-dev libssl-dev

ADD . /code
WORKDIR /code
#RUN swift test --generate-linuxmain
RUN ls Tests/

RUN mkdir -p .lambda-build
RUN swift build  --build-path .lambda-build -c release
