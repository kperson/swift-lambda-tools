FROM kperson/swift-5-dev

# HINT: run ldd <binary_location> to find linking locations
# https://superuser.com/questions/239590/find-libraries-a-binary-was-linked-against

ADD . /code
WORKDIR /code

RUN mkdir -p .lambda-build
#RUN swift test --generate-linuxmain
#RUN swift test --build-path .lambda-build
RUN swift build --build-path .lambda-build -c release
